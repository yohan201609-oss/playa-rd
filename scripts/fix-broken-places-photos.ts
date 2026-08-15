/**
 * Regenera fotos Places rotas y las sube a Storage para:
 *   - Playa Los Pescadores (58)
 *   - Playa de Arena Blanca (ChIJ7zpt34TrqI4Rfj2igDNeR7I)
 *
 *   npx ts-node fix-broken-places-photos.ts --dry-run
 *   npx ts-node fix-broken-places-photos.ts
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

const TARGETS = [
  {
    id: "58",
    searchQuery: "Playa Los Pescadores San Pedro de Macoris Dominican Republic",
  },
  {
    id: "ChIJ7zpt34TrqI4Rfj2igDNeR7I",
    searchQuery: "Playa de Arena Blanca Punta Cana Dominican Republic",
  },
];

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

let restAccessToken: string | null = null;
let placesApiKey = "";
let webApiKey = "";
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
    db = null;
    bucket = null;
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
  const client = new OAuth2Client(FIREBASE_CLI_CLIENT_ID, FIREBASE_CLI_CLIENT_SECRET);
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

async function getBeach(id: string): Promise<{
  name: string;
  province: string;
  municipality: string;
  latitude: number;
  longitude: number;
  imageUrls: string[];
} | null> {
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}/${encodeURIComponent(id)}?key=${webApiKey}`;
  const res = await fetch(url);
  if (res.status === 404) return null;
  if (!res.ok) throw new Error(`GET ${id}: ${res.status}`);
  const doc = (await res.json()) as { fields?: Record<string, Record<string, unknown>> };
  const f = doc.fields ?? {};
  return {
    name: String(parseValue(f.name ?? { stringValue: "" }) ?? ""),
    province: String(parseValue(f.province ?? { stringValue: "" }) ?? ""),
    municipality: String(parseValue(f.municipality ?? { stringValue: "" }) ?? ""),
    latitude: Number(parseValue(f.latitude ?? { doubleValue: 0 }) ?? 0),
    longitude: Number(parseValue(f.longitude ?? { doubleValue: 0 }) ?? 0),
    imageUrls: (parseValue(f.imageUrls ?? { arrayValue: { values: [] } }) ??
      []) as string[],
  };
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

async function patchImageUrls(id: string, imageUrls: string[]): Promise<void> {
  if (DRY_RUN) {
    console.log(`  [dry-run] PATCH imageUrls (${imageUrls.length})`);
    return;
  }
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

function publicStorageUrl(storagePath: string): string {
  return `https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/${encodeURIComponent(storagePath)}?alt=media`;
}

function isPlaces(url: string): boolean {
  return url.includes("maps.googleapis.com");
}

function isStorage(url: string): boolean {
  return url.includes("firebasestorage.googleapis.com");
}

async function fetchPhotoRefs(query: string): Promise<string[]> {
  const search = await axios.get(
    "https://maps.googleapis.com/maps/api/place/textsearch/json",
    { params: { query, key: placesApiKey } },
  );
  const results = search.data.results as Array<{ place_id: string }> | undefined;
  if (!results?.length) return [];

  const details = await axios.get(
    "https://maps.googleapis.com/maps/api/place/details/json",
    {
      params: {
        place_id: results[0].place_id,
        fields: "photos",
        key: placesApiKey,
      },
    },
  );
  const photos = (details.data.result?.photos ?? []) as Array<{
    photo_reference: string;
  }>;
  return photos.slice(0, MAX_PHOTOS).map((p) => p.photo_reference);
}

async function uploadPhoto(
  beachId: string,
  index: number,
  photoRef: string,
): Promise<string | null> {
  const params = new URLSearchParams({
    maxwidth: "1200",
    photo_reference: photoRef,
    key: placesApiKey,
  });
  const url = `https://maps.googleapis.com/maps/api/place/photo?${params}`;

  try {
    const response = await axios.get(url, {
      responseType: "arraybuffer",
      headers: { "X-Ios-Bundle-Identifier": "com.playasrd.playasrd" },
      maxRedirects: 5,
      timeout: 60_000,
    });
    const bytes = Buffer.from(response.data);
    const storagePath = `beaches/${beachId}/photo_${index}.jpg`;

    if (DRY_RUN) {
      console.log(`  [dry-run] Subiría ${storagePath} (${(bytes.length / 1024).toFixed(0)} KB)`);
      return publicStorageUrl(storagePath);
    }

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
    if (!res.ok) {
      throw new Error(`Storage ${res.status}: ${await res.text()}`);
    }
    return publicStorageUrl(storagePath);
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    console.log(`  ❌ foto ${index}: ${msg.split("\n")[0]}`);
    return null;
  }
}

async function fixBeach(target: { id: string; searchQuery: string }): Promise<void> {
  const beach = await getBeach(target.id);
  if (!beach) {
    console.log(`⏭️  ${target.id} no existe`);
    return;
  }

  console.log(`\n--- ${beach.name} [${target.id}] ---`);
  const storageUrls = beach.imageUrls.filter(isStorage);
  const placesUrls = beach.imageUrls.filter(isPlaces);
  console.log(`  Actual: ${storageUrls.length} Storage, ${placesUrls.length} Places`);

  // Si ya hay Storage y solo hay que limpiar Places rotas:
  // intentamos rellenar hasta 5 con Places nuevos.
  const needed = Math.max(0, MAX_PHOTOS - storageUrls.length);
  console.log(`  🔍 Places: ${target.searchQuery}`);
  const refs = await fetchPhotoRefs(target.searchQuery);
  console.log(`  Encontradas ${refs.length} fotos en Places`);

  if (refs.length === 0 && storageUrls.length > 0) {
    console.log("  Limpiando URLs Places rotas; se conservan Storage existentes");
    await patchImageUrls(target.id, storageUrls);
    console.log(`  ✅ ${storageUrls.length} fotos Storage`);
    return;
  }

  if (refs.length === 0) {
    console.log("  ❌ Sin fotos nuevas ni Storage existente");
    return;
  }

  // Para Arena Blanca (solo Places rota): subir todas desde 0.
  // Para Los Pescadores: conservar Storage y completar/reemplazar Places.
  const startIndex = storageUrls.length > 0 && placesUrls.length > 0
    ? storageUrls.length
    : 0;
  const refsToUpload =
    storageUrls.length > 0 && placesUrls.length > 0
      ? refs.slice(0, needed || 1)
      : refs;

  const uploaded: string[] = storageUrls.length > 0 && placesUrls.length > 0
    ? [...storageUrls]
    : [];

  for (let i = 0; i < refsToUpload.length; i++) {
    const index = startIndex + i;
    console.log(`  📥 Subiendo photo_${index}.jpg...`);
    const url = await uploadPhoto(target.id, index, refsToUpload[i]);
    if (url) uploaded.push(url);
  }

  // Si no había Storage previo, uploaded ya tiene las nuevas
  const finalUrls =
    storageUrls.length > 0 && placesUrls.length > 0
      ? uploaded
      : uploaded.length > 0
        ? uploaded
        : storageUrls;

  if (finalUrls.length === 0) {
    console.log("  ❌ No se pudo migrar ninguna foto");
    return;
  }

  await patchImageUrls(target.id, finalUrls);
  console.log(
    `  ✅ ${finalUrls.length} fotos (todas Storage, sin Places)`,
  );
}

async function main(): Promise<void> {
  console.log(
    `\n=== Fix fotos Places rotas — ${PROJECT_ID}${DRY_RUN ? " [DRY-RUN]" : ""} ===\n`,
  );
  loadEnv();
  initFirebase();
  await ensureWrite();

  for (const target of TARGETS) {
    await fixBeach(target);
  }

  console.log("\nListo.\n");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
