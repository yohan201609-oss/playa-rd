/**
 * Limpia duplicados ChIJ creados por add-new-beaches cuando ya existía manual-*
 * y enriquece las playas nuevas importadas solo con ChIJ (sin fotos).
 *
 *   npx ts-node post-import-cleanup.ts --dry-run
 *   npx ts-node post-import-cleanup.ts
 */

import * as dotenv from "dotenv";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as admin from "firebase-admin";
import { OAuth2Client } from "google-auth-library";

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? "playas-rd-2b475";
const COLLECTION = "beaches";
const CACHE_PATH = path.join(__dirname, "places-cache.json");
const ENV_PATH = path.join(__dirname, "..", ".env");
const DRY_RUN = process.argv.includes("--dry-run");
const MAX_PHOTOS = 5;

/** ChIJ creados por add-new-beaches que duplican manual-* ya enriquecidos. */
const CHIJ_DUPLICATES_TO_DELETE = [
  "ChIJEfUB9g-3u44ROJNk9gqcZ5M",
  "ChIJZSq5SPUrr44RZl5qvqX6V-c",
  "ChIJ1wFnUicvr44RbMvNoME8Grc",
  "ChIJx-L9nGAWro4R3NDRQzBwBTo",
  "ChIJBSv476D5ro4RUV60Wkdpjgw",
  "ChIJd1Knainvro4RlMRlWxJeDZo",
  "ChIJrxIQqGTvro4RrmXkafp_sCU",
  "ChIJ_____8g5sY4R7ZMfbrgKYFw",
  "ChIJtYfakSdDsY4RwmfRXe-ZpmQ",
  "ChIJAyLIc-tsro4RgULem4PVXSk",
  "ChIJzwn70GmEuo4R5C4HK1Nb85k",
];

/** Playas nuevas (solo ChIJ, sin manual-* previo). */
const NEW_CHIJ_TO_ENRICH: Array<{ docId: string; cacheKey: string }> = [
  { docId: "ChIJ65mKMK00uo4RQ_vh9BriC2s", cacheKey: "Playa Cabo Rojo" },
  { docId: "ChIJ1T6Pcgnwro4RBh7J6w6RfDY", cacheKey: "Bahía de Portillo" },
  { docId: "ChIJBQ0pLFjvro4RXF6y9NQeEss", cacheKey: "Playa Bavaro Miches" },
  { docId: "ChIJ52UXzT8Bpo4RcQXLQhhhA4M", cacheKey: "Playa Dominicus Americanus" },
  { docId: "ChIJw0DA_A2qqI4RLtbfiI1SNo4", cacheKey: "Playa Blanca Bayahibe" },
  { docId: "ChIJK0nq-VFpro4R6oyt4qQ-IlY", cacheKey: "Playa Diamante Nagua" },
];

let db: FirebaseFirestore.Firestore | null = null;
let useAdminSdk = false;
let restAccessToken: string | null = null;
let placesApiKey = "";

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

interface CacheEntry {
  place_id: string | null;
  place_details: {
    photos?: Array<{ photo_reference: string }>;
    rating?: number;
    user_ratings_total?: number;
  } | null;
}

type PlacesCache = Record<string, CacheEntry>;

function loadEnvironment(): void {
  if (fs.existsSync(ENV_PATH)) dotenv.config({ path: ENV_PATH });
  else dotenv.config();
}

function getPlacesApiKey(): string {
  const fromEnv =
    process.env.GOOGLE_MAPS_API_KEY ??
    process.env.MAPS_API_KEY ??
    process.env.GOOGLE_API_KEY;
  if (fromEnv?.trim()) return fromEnv.trim();
  throw new Error("Define GOOGLE_MAPS_API_KEY en .env");
}

function initFirebase(): void {
  if (admin.apps.length > 0) {
    db = admin.firestore();
    useAdminSdk = true;
    return;
  }
  const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (serviceAccountPath && fs.existsSync(serviceAccountPath)) {
    const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: PROJECT_ID,
    });
    db = admin.firestore();
    useAdminSdk = true;
    return;
  }
  try {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      projectId: PROJECT_ID,
    });
    db = admin.firestore();
    useAdminSdk = true;
  } catch {
    db = null;
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
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

async function getAccessTokenFromFirebaseLogin(): Promise<string> {
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
  if (!response.token) throw new Error("No se pudo refrescar token");
  return response.token;
}

async function ensureWriteConnection(): Promise<void> {
  if (DRY_RUN) return;
  if (useAdminSdk && db) {
    try {
      await db.collection(COLLECTION).limit(1).get();
      return;
    } catch {
      db = null;
      useAdminSdk = false;
    }
  }
  restAccessToken = await getAccessTokenFromFirebaseLogin();
  console.log("Usando firebase login (REST).\n");
}

async function restFetch(pathSuffix: string, init?: RequestInit): Promise<Response> {
  if (!restAccessToken) throw new Error("REST no inicializada");
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${pathSuffix}`;
  return fetch(url, {
    ...init,
    headers: {
      Authorization: `Bearer ${restAccessToken}`,
      "Content-Type": "application/json",
      ...(init?.headers ?? {}),
    },
  });
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

async function deleteDocument(docId: string): Promise<void> {
  if (DRY_RUN) {
    console.log(`  [dry-run] DELETE ${docId}`);
    return;
  }
  if (useAdminSdk && db) {
    await db.collection(COLLECTION).doc(docId).delete();
    return;
  }
  const response = await restFetch(`${COLLECTION}/${encodeURIComponent(docId)}`, {
    method: "DELETE",
  });
  if (!response.ok) {
    throw new Error(`DELETE ${docId}: ${response.status}`);
  }
}

async function updateDocument(
  docId: string,
  fields: Record<string, unknown>,
): Promise<void> {
  if (DRY_RUN) {
    console.log(`  [dry-run] PATCH ${docId}:`, {
      ...fields,
      imageUrls: Array.isArray(fields.imageUrls)
        ? `${(fields.imageUrls as string[]).length} fotos`
        : fields.imageUrls,
    });
    return;
  }
  if (useAdminSdk && db) {
    await db.collection(COLLECTION).doc(docId).update({
      ...fields,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }
  const fieldPaths = [...Object.keys(fields), "lastUpdated"];
  const body = {
    fields: {
      ...Object.fromEntries(
        Object.entries(fields).map(([k, v]) => [k, toFirestoreValue(v)]),
      ),
      lastUpdated: { timestampValue: new Date().toISOString() },
    },
  };
  const query = fieldPaths.map((f) => `updateMask.fieldPaths=${f}`).join("&");
  const response = await restFetch(
    `${COLLECTION}/${encodeURIComponent(docId)}?${query}`,
    { method: "PATCH", body: JSON.stringify(body) },
  );
  if (!response.ok) {
    throw new Error(`PATCH ${docId}: ${response.status} ${await response.text()}`);
  }
}

function buildPlacesPhotoUrl(photoReference: string): string {
  const params = new URLSearchParams({
    maxwidth: "1200",
    photo_reference: photoReference,
    key: placesApiKey,
  });
  return `https://maps.googleapis.com/maps/api/place/photo?${params.toString()}`;
}

function buildImageUrls(entry: CacheEntry): string[] {
  const photos = entry.place_details?.photos ?? [];
  return photos.slice(0, MAX_PHOTOS).map((p) => buildPlacesPhotoUrl(p.photo_reference));
}

async function main(): Promise<void> {
  console.log(`\n=== Post-import cleanup — ${PROJECT_ID}${DRY_RUN ? " [DRY-RUN]" : ""} ===\n`);

  loadEnvironment();
  placesApiKey = getPlacesApiKey();
  initFirebase();
  await ensureWriteConnection();

  const cache = JSON.parse(fs.readFileSync(CACHE_PATH, "utf8")) as PlacesCache;

  console.log("--- Eliminar duplicados ChIJ ---\n");
  let deleted = 0;
  for (const docId of CHIJ_DUPLICATES_TO_DELETE) {
    try {
      await deleteDocument(docId);
      console.log(`🗑️  ${docId}`);
      deleted++;
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      console.log(`⏭️  ${docId} — ${msg}`);
    }
  }

  console.log(`\n--- Enriquecer playas nuevas ChIJ ---\n`);
  let enriched = 0;
  for (const target of NEW_CHIJ_TO_ENRICH) {
    const docId = target.docId;
    const entry = cache[target.cacheKey];
    if (!entry?.place_id || !entry.place_details) {
      console.log(`❌ ${target.cacheKey} — sin datos en cache`);
      continue;
    }

    if (!docId) {
      console.log(`❌ ${target.cacheKey} — sin docId`);
      continue;
    }

    const imageUrls = buildImageUrls(entry);
    const fields: Record<string, unknown> = {
      imageUrls,
      rating: entry.place_details.rating ?? 0,
      reviewCount: entry.place_details.user_ratings_total ?? 0,
      needsReview: false,
      enrichedFrom: "google_places",
      googlePlaceId: entry.place_id,
    };

    try {
      await updateDocument(docId, fields);
      console.log(
        `✅ ${target.cacheKey} (${docId}) → ${imageUrls.length} fotos`,
      );
      enriched++;
    } catch (error) {
      const msg = error instanceof Error ? error.message : String(error);
      console.log(`❌ ${target.cacheKey} — ${msg}`);
    }
  }

  console.log("\n=== Resumen ===");
  console.log(`Duplicados eliminados: ${deleted}`);
  console.log(`Playas enriquecidas:   ${enriched}`);
  console.log("");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
