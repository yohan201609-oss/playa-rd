/**
 * Rellena playas sin imageUrls: Places → Firebase Storage → Firestore.
 *
 *   npx ts-node fill-empty-beach-photos.ts --dry-run
 *   npx ts-node fill-empty-beach-photos.ts
 */

import axios from "axios";
import * as dotenv from "dotenv";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as admin from "firebase-admin";
import { OAuth2Client } from "google-auth-library";

const PROJECT_ID = "playas-rd-2b475";
const STORAGE_BUCKET = "playas-rd-2b475.firebasestorage.app";
const COLLECTION = "beaches";
const ENV_PATH = path.join(__dirname, "..", ".env");
const DRY_RUN = process.argv.includes("--dry-run");
const MAX_PHOTOS = 5;

const ANDROID_PACKAGE = "com.playasrd.playasrd";
const IOS_BUNDLE = "com.playasrd.playasrd";
const ANDROID_SHA_DEBUG = "72F17A530F1BEBE00DDD1D920F565A8D2D0508E6";
const ANDROID_SHA_RELEASE = "3B28ECD60C45155C9A6215344FBE771250F62486";

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

let placesApiKey = "";
let webApiKey = "";
let restAccessToken: string | null = null;
let useAdminSdk = false;
let db: FirebaseFirestore.Firestore | null = null;
let bucket: ReturnType<admin.storage.Storage["bucket"]> | null = null;

function loadEnv(): void {
  if (fs.existsSync(ENV_PATH)) dotenv.config({ path: ENV_PATH });
  else dotenv.config();
  placesApiKey =
    process.env.GOOGLE_MAPS_API_KEY ??
    process.env.MAPS_API_KEY ??
    process.env.GOOGLE_API_KEY ??
    "";
  if (!placesApiKey) throw new Error("GOOGLE_MAPS_API_KEY requerida");
  const options = fs.readFileSync(
    path.join(__dirname, "..", "lib", "firebase_options.dart"),
    "utf8",
  );
  webApiKey = options.match(/apiKey:\s*'([^']+)'/)?.[1] ?? "";
  if (!webApiKey) throw new Error("apiKey firebase_options requerida");
}

function initFirebase(): void {
  try {
    if (admin.apps.length === 0) {
      const sa = process.env.GOOGLE_APPLICATION_CREDENTIALS;
      if (sa && fs.existsSync(sa)) {
        admin.initializeApp({
          credential: admin.credential.cert(
            JSON.parse(fs.readFileSync(sa, "utf8")),
          ),
          projectId: PROJECT_ID,
          storageBucket: STORAGE_BUCKET,
        });
      } else {
        admin.initializeApp({
          credential: admin.credential.applicationDefault(),
          projectId: PROJECT_ID,
          storageBucket: STORAGE_BUCKET,
        });
      }
    }
    db = admin.firestore();
    bucket = admin.storage().bucket(STORAGE_BUCKET);
    useAdminSdk = true;
  } catch {
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

async function ensureWrite(): Promise<void> {
  if (DRY_RUN) return;
  if (useAdminSdk && db) {
    try {
      await db.collection(COLLECTION).limit(1).get();
      return;
    } catch {
      useAdminSdk = false;
      db = null;
      bucket = null;
    }
  }
  const configPath = findFirebaseToolsConfigPath();
  if (!configPath) throw new Error("firebase login requerido");
  const config = JSON.parse(fs.readFileSync(configPath, "utf8")) as {
    tokens?: { refresh_token?: string };
  };
  const client = new OAuth2Client(
    FIREBASE_CLI_CLIENT_ID,
    FIREBASE_CLI_CLIENT_SECRET,
  );
  client.setCredentials({ refresh_token: config.tokens?.refresh_token });
  restAccessToken = (await client.getAccessToken()).token ?? null;
  if (!restAccessToken) throw new Error("No OAuth token");
  console.log("Usando firebase login (REST).\n");
}

function parseValue(wrapped: Record<string, unknown>): unknown {
  if ("stringValue" in wrapped) return wrapped.stringValue;
  if ("doubleValue" in wrapped) return wrapped.doubleValue;
  if ("integerValue" in wrapped) return Number(wrapped.integerValue);
  if ("booleanValue" in wrapped) return wrapped.booleanValue;
  if ("arrayValue" in wrapped) {
    const values =
      ((wrapped.arrayValue as Record<string, unknown>).values as
        | Record<string, unknown>[]
        | undefined) ?? [];
    return values.map((v) => parseValue(v));
  }
  return null;
}

function toFirestoreValue(value: unknown): Record<string, unknown> {
  if (typeof value === "string") return { stringValue: value };
  if (typeof value === "number") return { doubleValue: value };
  if (typeof value === "boolean") return { booleanValue: value };
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map((i) => toFirestoreValue(i)) } };
  }
  return { stringValue: String(value) };
}

function publicStorageUrl(storagePath: string): string {
  return `https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/${encodeURIComponent(storagePath)}?alt=media`;
}

async function loadEmptyBeaches(): Promise<
  Array<{
    id: string;
    name: string;
    province: string;
    municipality: string;
    placeId?: string;
  }>
> {
  const beaches: Array<{
    id: string;
    name: string;
    province: string;
    municipality: string;
    placeId?: string;
  }> = [];
  let pageToken = "";

  do {
    const q = pageToken
      ? `${COLLECTION}?pageSize=300&pageToken=${encodeURIComponent(pageToken)}&key=${webApiKey}`
      : `${COLLECTION}?pageSize=300&key=${webApiKey}`;
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${q}`;
    const res = await fetch(url);
    if (!res.ok) throw new Error(`List beaches: ${res.status}`);
    const payload = (await res.json()) as {
      documents?: Array<{ name: string; fields?: Record<string, Record<string, unknown>> }>;
      nextPageToken?: string;
    };
    for (const doc of payload.documents ?? []) {
      const id = doc.name.split("/").pop() ?? "";
      const f = doc.fields ?? {};
      const imageUrls = (parseValue(f.imageUrls ?? { arrayValue: { values: [] } }) ??
        []) as string[];
      if (imageUrls.length > 0) continue;
      const name = String(parseValue(f.name ?? { stringValue: "" }) ?? "");
      const province = String(parseValue(f.province ?? { stringValue: "" }) ?? "");
      const municipality = String(
        parseValue(f.municipality ?? { stringValue: "" }) ?? "",
      );
      const placeId = String(parseValue(f.placeId ?? { stringValue: "" }) ?? "");
      beaches.push({
        id,
        name,
        province,
        municipality,
        placeId: placeId || (id.startsWith("ChIJ") ? id : undefined),
      });
    }
    pageToken = payload.nextPageToken ?? "";
  } while (pageToken);

  return beaches;
}

async function fetchPhotoRefs(beach: {
  name: string;
  province: string;
  municipality: string;
  placeId?: string;
}): Promise<string[]> {
  let placeId = beach.placeId;
  if (!placeId) {
    const query = [beach.name, beach.municipality, beach.province, "Dominican Republic"]
      .filter(Boolean)
      .join(" ");
    const search = await axios.get(
      "https://maps.googleapis.com/maps/api/place/textsearch/json",
      { params: { query, key: placesApiKey }, timeout: 30_000 },
    );
    const results = search.data.results as Array<{ place_id: string }> | undefined;
    placeId = results?.[0]?.place_id;
    if (!placeId) return [];
  }

  const details = await axios.get(
    "https://maps.googleapis.com/maps/api/place/details/json",
    {
      params: { place_id: placeId, fields: "photos", key: placesApiKey },
      timeout: 30_000,
    },
  );
  const photos = (details.data.result?.photos ?? []) as Array<{
    photo_reference: string;
  }>;
  return photos.slice(0, MAX_PHOTOS).map((p) => p.photo_reference);
}

async function downloadPhoto(photoRef: string): Promise<Buffer> {
  const params = new URLSearchParams({
    maxwidth: "1200",
    photo_reference: photoRef,
    key: placesApiKey,
  });
  const url = `https://maps.googleapis.com/maps/api/place/photo?${params}`;
  const headerSets = [
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

  let lastError: unknown;
  for (const headers of headerSets) {
    try {
      const response = await axios.get(url, {
        responseType: "arraybuffer",
        headers,
        maxRedirects: 5,
        timeout: 60_000,
      });
      return Buffer.from(response.data);
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError instanceof Error ? lastError : new Error(String(lastError));
}

async function upload(storagePath: string, bytes: Buffer): Promise<string> {
  if (useAdminSdk && bucket) {
    await bucket.file(storagePath).save(bytes, {
      metadata: { contentType: "image/jpeg" },
    });
    return publicStorageUrl(storagePath);
  }
  if (!restAccessToken) throw new Error("Sin token Storage");
  const uploadUrl =
    `https://storage.googleapis.com/upload/storage/v1/b/${STORAGE_BUCKET}/o` +
    `?uploadType=media&name=${encodeURIComponent(storagePath)}`;
  const res = await fetch(uploadUrl, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${restAccessToken}`,
      "Content-Type": "image/jpeg",
    },
    body: new Uint8Array(bytes),
  });
  if (!res.ok) throw new Error(`Upload ${res.status}: ${await res.text()}`);
  return publicStorageUrl(storagePath);
}

async function patchImageUrls(id: string, imageUrls: string[]): Promise<void> {
  if (DRY_RUN) return;
  if (useAdminSdk && db) {
    await db.collection(COLLECTION).doc(id).update({
      imageUrls,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }
  const body = {
    fields: {
      imageUrls: toFirestoreValue(imageUrls),
      lastUpdated: { timestampValue: new Date().toISOString() },
    },
  };
  const query =
    "updateMask.fieldPaths=imageUrls&updateMask.fieldPaths=lastUpdated";
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}/${encodeURIComponent(id)}?${query}`,
    {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${restAccessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    },
  );
  if (!res.ok) throw new Error(`PATCH ${id}: ${res.status} ${await res.text()}`);
}

async function main(): Promise<void> {
  console.log(`\n=== Rellenar playas sin fotos — ${PROJECT_ID} ===\n`);
  if (DRY_RUN) console.log("Modo: DRY-RUN\n");

  loadEnv();
  initFirebase();
  await ensureWrite();

  const beaches = await loadEmptyBeaches();
  console.log(`Playas sin imageUrls: ${beaches.length}\n`);

  let filled = 0;
  let errors = 0;
  let photos = 0;

  for (const beach of beaches) {
    console.log(`--- ${beach.name} [${beach.id}] ---`);
    try {
      const refs = await fetchPhotoRefs(beach);
      if (!refs.length) {
        console.log("  ⏭️  Sin fotos en Places\n");
        continue;
      }
      console.log(`  Encontradas ${refs.length} foto(s) Places`);
      const urls: string[] = [];
      for (let i = 0; i < refs.length; i++) {
        if (DRY_RUN) {
          console.log(`  [dry-run] Subiría beaches/${beach.id}/photo_${i}.jpg`);
          urls.push(publicStorageUrl(`beaches/${beach.id}/photo_${i}.jpg`));
          continue;
        }
        console.log(`  📥 Descargando ${i + 1}/${refs.length}...`);
        const bytes = await downloadPhoto(refs[i]);
        const storagePath = `beaches/${beach.id}/photo_${i}.jpg`;
        console.log(`  📤 Subiendo ${storagePath} (${(bytes.length / 1024).toFixed(0)} KB)`);
        urls.push(await upload(storagePath, bytes));
        photos++;
      }
      await patchImageUrls(beach.id, urls);
      console.log(`  ✅ Firestore actualizado (${urls.length} fotos)\n`);
      filled++;
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      console.log(`  ❌ ${msg.split("\n")[0]}\n`);
      errors++;
    }
  }

  console.log("=== Resumen ===");
  console.log(`Rellenadas: ${filled}`);
  console.log(`Fotos:      ${photos}`);
  console.log(`Errores:    ${errors}`);
  console.log("");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
