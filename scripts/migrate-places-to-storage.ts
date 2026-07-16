/**
 * Migra imageUrls de Google Places → Firebase Storage (misma lógica que
 * FirebaseService.migrateAllGoogleImagesToFirebase en Dart).
 *
 *   cd scripts
 *   npx ts-node migrate-places-to-storage.ts --dry-run
 *   npx ts-node migrate-places-to-storage.ts
 *   npx ts-node migrate-places-to-storage.ts --only=manual-playa-trudille
 *
 * Credenciales:
 *   - Firestore/Storage escritura: firebase login (OAuth)
 *   - Lectura playas: apiKey pública de firebase_options.dart
 *   - Descarga fotos Places: GOOGLE_MAPS_API_KEY en .env
 */

import axios from "axios";
import * as dotenv from "dotenv";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as admin from "firebase-admin";
import { OAuth2Client } from "google-auth-library";

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? "playas-rd-2b475";
const STORAGE_BUCKET = "playas-rd-2b475.firebasestorage.app";
const COLLECTION = "beaches";
const ENV_PATH = path.join(__dirname, "..", ".env");
const DRY_RUN = process.argv.includes("--dry-run");
const ONLY = process.argv.find((a) => a.startsWith("--only="))?.split("=")[1];

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

interface BeachRecord {
  id: string;
  name: string;
  imageUrls: string[];
  placeId?: string;
}

const ANDROID_PACKAGE = "com.playasrd.playasrd";
const IOS_BUNDLE = "com.playasrd.playasrd";
const ANDROID_SHA_DEBUG = "72F17A530F1BEBE00DDD1D920F565A8D2D0508E6";
const ANDROID_SHA_RELEASE = "3B28ECD60C45155C9A6215344FBE771250F62486";
const MAX_PHOTOS = 5;

let placesApiKey = "";

let db: FirebaseFirestore.Firestore | null = null;
let bucket: ReturnType<admin.storage.Storage["bucket"]> | null = null;
let useAdminSdk = false;
let restAccessToken: string | null = null;
let webApiKey: string | null = null;

const stats = {
  beachesScanned: 0,
  beachesWithPlaces: 0,
  beachesMigrated: 0,
  photosMigrated: 0,
  skipped: 0,
  errors: 0,
};

function loadEnvironment(): void {
  if (fs.existsSync(ENV_PATH)) dotenv.config({ path: ENV_PATH });
  else dotenv.config();
  placesApiKey =
    process.env.GOOGLE_MAPS_API_KEY ??
    process.env.MAPS_API_KEY ??
    process.env.GOOGLE_API_KEY ??
    "";
}

function getWebApiKey(): string {
  if (webApiKey) return webApiKey;
  const optionsPath = path.join(__dirname, "..", "lib", "firebase_options.dart");
  const content = fs.readFileSync(optionsPath, "utf8");
  const match = content.match(/apiKey:\s*'([^']+)'/);
  if (!match) throw new Error("No apiKey en firebase_options.dart");
  webApiKey = match[1];
  return webApiKey;
}

function initFirebase(): void {
  if (admin.apps.length > 0) {
    db = admin.firestore();
    bucket = admin.storage().bucket(STORAGE_BUCKET);
    useAdminSdk = true;
    return;
  }

  const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (serviceAccountPath && fs.existsSync(serviceAccountPath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: PROJECT_ID,
      storageBucket: STORAGE_BUCKET,
    });
    db = admin.firestore();
    bucket = admin.storage().bucket(STORAGE_BUCKET);
    useAdminSdk = true;
    console.log("Usando service account para Storage + Firestore.\n");
    return;
  }

  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
      storageBucket: STORAGE_BUCKET,
    });
    db = admin.firestore();
    bucket = admin.storage().bucket(STORAGE_BUCKET);
    useAdminSdk = true;
    console.log("Usando Application Default Credentials.\n");
  } catch {
    db = null;
    bucket = null;
    useAdminSdk = false;
  }
}

function findFirebaseToolsConfigPath(): string | null {
  const candidates = [
    path.join(
      process.env.APPDATA ?? path.join(os.homedir(), "AppData", "Roaming"),
      "configstore",
      "firebase-tools.json",
    ),
    path.join(os.homedir(), ".config", "configstore", "firebase-tools.json"),
    path.join(os.homedir(), ".firebase", "firebase-tools.json"),
  ];
  for (const c of candidates) if (fs.existsSync(c)) return c;
  return null;
}

async function getAccessTokenFromFirebaseLogin(): Promise<string> {
  if (process.env.FIRESTORE_ACCESS_TOKEN) return process.env.FIRESTORE_ACCESS_TOKEN;

  const configPath = findFirebaseToolsConfigPath();
  if (!configPath) throw new Error("Ejecuta: firebase login");

  const config = JSON.parse(fs.readFileSync(configPath, "utf8")) as {
    tokens?: { refresh_token?: string; access_token?: string; expires_at?: number };
  };
  const tokens = config.tokens;
  if (!tokens?.refresh_token) throw new Error("Ejecuta: firebase login --reauth");

  if (tokens.access_token && tokens.expires_at && tokens.expires_at > Date.now() + 60_000) {
    return tokens.access_token;
  }

  const client = new OAuth2Client(FIREBASE_CLI_CLIENT_ID, FIREBASE_CLI_CLIENT_SECRET);
  client.setCredentials({ refresh_token: tokens.refresh_token });
  const response = await client.getAccessToken();
  if (!response.token) throw new Error("No se pudo refrescar OAuth token");
  return response.token;
}

async function ensureWriteConnection(): Promise<void> {
  if (DRY_RUN) return;

  if (useAdminSdk && db && bucket) {
    try {
      await db.collection(COLLECTION).limit(1).get();
      return;
    } catch {
      db = null;
      bucket = null;
      useAdminSdk = false;
    }
  }

  restAccessToken = await getAccessTokenFromFirebaseLogin();
  console.log("Usando firebase login (REST) para Storage + Firestore.\n");
}

function parseFirestoreValue(wrapped: Record<string, unknown>): unknown {
  if ("stringValue" in wrapped) return wrapped.stringValue;
  if ("booleanValue" in wrapped) return wrapped.booleanValue;
  if ("doubleValue" in wrapped) return wrapped.doubleValue;
  if ("integerValue" in wrapped) return Number(wrapped.integerValue);
  if ("nullValue" in wrapped) return null;
  if ("arrayValue" in wrapped) {
    const values =
      ((wrapped.arrayValue as Record<string, unknown>).values as
        | Record<string, unknown>[]
        | undefined) ?? [];
    return values.map((v) => parseFirestoreValue(v));
  }
  if ("mapValue" in wrapped) {
    const mapFields =
      ((wrapped.mapValue as Record<string, unknown>).fields as
        | Record<string, Record<string, unknown>>
        | undefined) ?? {};
    const obj: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(mapFields)) obj[k] = parseFirestoreValue(v);
    return obj;
  }
  return null;
}

async function loadBeachesWithPlacesUrls(): Promise<BeachRecord[]> {
  const apiKey = getWebApiKey();
  const beaches: BeachRecord[] = [];
  let pageToken = "";

  do {
    const query = pageToken
      ? `${COLLECTION}?pageSize=300&pageToken=${encodeURIComponent(pageToken)}&key=${apiKey}`
      : `${COLLECTION}?pageSize=300&key=${apiKey}`;
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${query}`;
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`List beaches failed: ${response.status}`);
    }
    const payload = (await response.json()) as {
      documents?: Array<{ name: string; fields?: Record<string, Record<string, unknown>> }>;
      nextPageToken?: string;
    };

    for (const doc of payload.documents ?? []) {
      const id = doc.name.split("/").pop() ?? "";
      const fields = doc.fields ?? {};
      const name = String(parseFirestoreValue(fields.name ?? { stringValue: "" }) ?? "");
      const placeId = String(
        parseFirestoreValue(fields.placeId ?? { stringValue: "" }) ?? "",
      );
      const imageUrls = (parseFirestoreValue(fields.imageUrls ?? { arrayValue: { values: [] } }) ??
        []) as string[];
      const hasPlaces = imageUrls.some((u) => u.includes("maps.googleapis.com"));
      if (!hasPlaces) continue;
      if (ONLY && id !== ONLY) continue;
      beaches.push({
        id,
        name,
        imageUrls,
        placeId: placeId || (id.startsWith("ChIJ") ? id : undefined),
      });
    }
    pageToken = payload.nextPageToken ?? "";
  } while (pageToken);

  return beaches;
}

function publicStorageUrl(storagePath: string): string {
  return `https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/${encodeURIComponent(storagePath)}?alt=media`;
}

function isPlacesUrl(url: string): boolean {
  return url.includes("maps.googleapis.com");
}

function placesDownloadHeaderSets(): Array<Record<string, string>> {
  return [
    { "X-Ios-Bundle-Identifier": IOS_BUNDLE },
    {
      "X-Android-Package": ANDROID_PACKAGE,
      "X-Android-Cert": ANDROID_SHA_DEBUG,
    },
    {
      "X-Android-Package": ANDROID_PACKAGE,
      "X-Android-Cert": ANDROID_SHA_RELEASE,
    },
  ];
}

async function downloadPlacesImage(url: string): Promise<Buffer> {
  let lastError: unknown;
  for (const headers of placesDownloadHeaderSets()) {
    try {
      const response = await axios.get(url, {
        responseType: "arraybuffer",
        headers,
        maxRedirects: 5,
        timeout: 60_000,
        validateStatus: (s) => s >= 200 && s < 400,
      });
      if (response.status >= 200 && response.status < 300) {
        return Buffer.from(response.data);
      }
      lastError = new Error(`HTTP ${response.status}`);
    } catch (error) {
      lastError = error;
    }
  }
  const msg = lastError instanceof Error ? lastError.message : String(lastError);
  throw new Error(`No se pudo descargar Places photo: ${msg}`);
}

async function listExistingStorageUrls(beachId: string): Promise<string[]> {
  const prefix = `beaches/${beachId}/`;

  if (useAdminSdk && bucket) {
    const [files] = await bucket.getFiles({ prefix });
    return files
      .filter((f) => !f.name.endsWith("/"))
      .map((f) => publicStorageUrl(f.name));
  }

  if (!restAccessToken) return [];

  const url =
    `https://storage.googleapis.com/storage/v1/b/${STORAGE_BUCKET}/o` +
    `?prefix=${encodeURIComponent(prefix)}&fields=items(name)`;
  const response = await fetch(url, {
    headers: { Authorization: `Bearer ${restAccessToken}` },
  });
  if (!response.ok) return [];
  const payload = (await response.json()) as { items?: Array<{ name: string }> };
  return (payload.items ?? [])
    .filter((i) => !i.name.endsWith("/"))
    .map((i) => publicStorageUrl(i.name));
}

function buildPhotoUrl(photoReference: string): string {
  const params = new URLSearchParams({
    maxwidth: "1200",
    photo_reference: photoReference,
    key: placesApiKey,
  });
  return `https://maps.googleapis.com/maps/api/place/photo?${params}`;
}

async function fetchFreshPhotoUrls(
  beach: BeachRecord,
  count: number,
): Promise<string[]> {
  if (!placesApiKey) return [];

  let placeId = beach.placeId;
  if (!placeId) {
    const search = await axios.get(
      "https://maps.googleapis.com/maps/api/place/textsearch/json",
      {
        params: {
          query: `${beach.name} Dominican Republic beach`,
          key: placesApiKey,
        },
        timeout: 30_000,
      },
    );
    const results = search.data.results as Array<{ place_id: string }> | undefined;
    placeId = results?.[0]?.place_id;
  }
  if (!placeId) return [];

  const details = await axios.get(
    "https://maps.googleapis.com/maps/api/place/details/json",
    {
      params: {
        place_id: placeId,
        fields: "photos",
        key: placesApiKey,
      },
      timeout: 30_000,
    },
  );
  const photos = (details.data.result?.photos ?? []) as Array<{
    photo_reference: string;
  }>;
  return photos
    .slice(0, Math.max(count, 1))
    .slice(0, MAX_PHOTOS)
    .map((p) => buildPhotoUrl(p.photo_reference));
}

async function uploadToStorage(
  storagePath: string,
  bytes: Buffer,
): Promise<string> {
  if (useAdminSdk && bucket) {
    await bucket.file(storagePath).save(bytes, {
      metadata: { contentType: "image/jpeg" },
    });
    return publicStorageUrl(storagePath);
  }

  if (!restAccessToken) throw new Error("Sin token para Storage");

  const uploadUrl =
    `https://storage.googleapis.com/upload/storage/v1/b/${STORAGE_BUCKET}/o` +
    `?uploadType=media&name=${encodeURIComponent(storagePath)}`;

  const response = await fetch(uploadUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${restAccessToken}`,
      "Content-Type": "image/jpeg",
    },
    body: new Uint8Array(bytes),
  });

  if (!response.ok) {
    throw new Error(`Storage upload failed: ${response.status} ${await response.text()}`);
  }

  return publicStorageUrl(storagePath);
}

function toFirestoreValue(value: unknown): Record<string, unknown> {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === "boolean") return { booleanValue: value };
  if (typeof value === "number") return { doubleValue: value };
  if (typeof value === "string") return { stringValue: value };
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map((item) => toFirestoreValue(item)) } };
  }
  if (typeof value === "object") {
    const fields: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(value) };
}

async function updateImageUrls(docId: string, imageUrls: string[]): Promise<void> {
  if (DRY_RUN) return;

  if (useAdminSdk && db) {
    await db.collection(COLLECTION).doc(docId).update({
      imageUrls,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }

  if (!restAccessToken) throw new Error("Sin token Firestore");

  const body = {
    fields: {
      imageUrls: toFirestoreValue(imageUrls),
      lastUpdated: { timestampValue: new Date().toISOString() },
    },
  };
  const query =
    "updateMask.fieldPaths=imageUrls&updateMask.fieldPaths=lastUpdated";
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}/${encodeURIComponent(docId)}?${query}`;
  const response = await fetch(url, {
    method: "PATCH",
    headers: {
      Authorization: `Bearer ${restAccessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    throw new Error(`Firestore patch failed: ${response.status} ${await response.text()}`);
  }
}

async function migrateBeach(beach: BeachRecord): Promise<void> {
  stats.beachesWithPlaces++;
  const placesCount = beach.imageUrls.filter(isPlacesUrl).length;
  console.log(`\n--- ${beach.name} [${beach.id}] (${placesCount} fotos Places) ---`);

  // Si ya hay fotos en Storage, apuntar Firestore ahí (sin re-descargar).
  const existingStorage = await listExistingStorageUrls(beach.id);
  if (existingStorage.length > 0) {
    console.log(`  📂 Ya hay ${existingStorage.length} foto(s) en Storage → actualizar Firestore`);
    if (!DRY_RUN) {
      await updateImageUrls(beach.id, existingStorage);
    } else {
      console.log(`  [dry-run] PATCH imageUrls con ${existingStorage.length} URLs Storage`);
    }
    stats.beachesMigrated++;
    stats.photosMigrated += existingStorage.length;
    return;
  }

  let sourceUrls = [...beach.imageUrls];
  const placesIndexes = sourceUrls
    .map((u, i) => (isPlacesUrl(u) ? i : -1))
    .filter((i) => i >= 0);

  const newUrls: string[] = [];
  let transferred = 0;
  let refreshed = false;

  for (let i = 0; i < sourceUrls.length; i++) {
    const url = sourceUrls[i];
    if (!isPlacesUrl(url)) {
      newUrls.push(url);
      continue;
    }

    try {
      if (DRY_RUN) {
        const storagePath = `beaches/${beach.id}/photo_${i}.jpg`;
        console.log(`  [dry-run] Subiría photo_${i}.jpg`);
        newUrls.push(publicStorageUrl(storagePath));
        transferred++;
        continue;
      }

      console.log(`  📥 Descargando foto ${i + 1}/${placesCount}...`);
      let bytes: Buffer;
      try {
        bytes = await downloadPlacesImage(url);
      } catch (downloadError) {
        if (!refreshed) {
          console.log("  🔄 URL expirada/bloqueada → regenerando desde Places API...");
          const fresh = await fetchFreshPhotoUrls(beach, placesIndexes.length);
          refreshed = true;
          if (fresh.length > 0) {
            let fi = 0;
            sourceUrls = sourceUrls.map((u) => {
              if (!isPlacesUrl(u)) return u;
              const next = fresh[fi] ?? fresh[fresh.length - 1];
              fi++;
              return next;
            });
            bytes = await downloadPlacesImage(sourceUrls[i]);
          } else {
            throw downloadError;
          }
        } else {
          throw downloadError;
        }
      }

      const storagePath = `beaches/${beach.id}/photo_${i}.jpg`;
      console.log(
        `  📤 Subiendo ${storagePath} (${(bytes.length / 1024).toFixed(0)} KB)...`,
      );
      const firebaseUrl = await uploadToStorage(storagePath, bytes);
      newUrls.push(firebaseUrl);
      transferred++;
      stats.photosMigrated++;
      console.log(`  ✅ photo_${i}.jpg`);
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      console.log(`  ❌ foto ${i}: ${msg.split("\n")[0]}`);
      newUrls.push(url);
      stats.errors++;
    }
  }

  if (transferred === 0) {
    console.log("  ⏭️  Sin fotos migradas");
    stats.skipped++;
    return;
  }

  await updateImageUrls(beach.id, newUrls);
  console.log(`  ✅ Firestore actualizado (${transferred} fotos → Storage)`);
  stats.beachesMigrated++;
}

function sleep(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

async function main(): Promise<void> {
  console.log(`\n=== Migrar Places → Firebase Storage — ${PROJECT_ID} ===\n`);
  if (DRY_RUN) console.log("Modo: DRY-RUN\n");
  if (ONLY) console.log(`Filtro: ${ONLY}\n`);

  loadEnvironment();
  initFirebase();
  await ensureWriteConnection();

  const beaches = await loadBeachesWithPlacesUrls();
  stats.beachesScanned = beaches.length;
  console.log(`Playas con URLs de Google Places: ${beaches.length}`);

  if (beaches.length === 0) {
    console.log("\nNada que migrar.\n");
    return;
  }

  for (const beach of beaches) {
    try {
      await migrateBeach(beach);
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      console.log(`❌ ${beach.name}: ${msg}`);
      stats.errors++;
    }
    await sleep(150);
  }

  console.log("\n=== Resumen ===");
  console.log(`Con Places:     ${stats.beachesWithPlaces}`);
  console.log(`Migradas:       ${stats.beachesMigrated}`);
  console.log(`Fotos Storage:  ${stats.photosMigrated}`);
  console.log(`Omitidas:       ${stats.skipped}`);
  console.log(`Errores:        ${stats.errors}`);
  console.log("");
}

main().catch((error) => {
  console.error("\nError:", error);
  process.exit(1);
});
