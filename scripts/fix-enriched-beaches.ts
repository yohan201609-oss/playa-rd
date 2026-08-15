/**
 * Corrige nombres/coords de playas enriquecidas mal matcheadas por Places,
 * intenta fotos para Trudillé, y deja needsReview donde aplique.
 *
 *   npx ts-node fix-enriched-beaches.ts --dry-run
 *   npx ts-node fix-enriched-beaches.ts
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

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

interface NameFix {
  id: string;
  name: string;
  province?: string;
  municipality?: string;
  latitude?: number;
  longitude?: number;
  address?: string;
  reason: string;
}

/** Nombres canónicos de la app (no nombres de hoteles de Places). */
const NAME_FIXES: NameFix[] = [
  {
    id: "ChIJ1T6Pcgnwro4RBh7J6w6RfDY",
    name: "Bahía de Portillo",
    province: "Samaná",
    municipality: "Samaná",
    reason: "Restaurar nombre (Places devolvió hotel Bahia Principe)",
  },
  {
    id: "manual-playa-miches",
    name: "Playa Miches",
    province: "Hato Mayor",
    municipality: "Miches",
    reason: "Restaurar nombre (Places devolvió Club Med)",
  },
  {
    id: "ChIJ52UXzT8Bpo4RcQXLQhhhA4M",
    name: "Playa Dominicus Americanus",
    province: "La Romana",
    municipality: "Bayahibe",
    reason: "Restaurar nombre (Places devolvió Sunscape)",
  },
  {
    id: "ChIJw0DA_A2qqI4RLtbfiI1SNo4",
    name: "Playa Blanca Bayahibe",
    province: "La Romana",
    municipality: "Bayahibe",
    reason: "Restaurar nombre (Places devolvió B&B)",
  },
  {
    id: "manual-playa-trudille",
    name: "Playa Trudillé",
    province: "Pedernales",
    municipality: "Pedernales",
    reason: "Restaurar nombre canónico",
  },
  {
    id: "manual-playa-esmeralda",
    name: "Playa Esmeralda",
    province: "El Seibo",
    municipality: "El Seibo",
    reason: "Restaurar nombre (Places: Costa Esmeralda)",
  },
  {
    id: "manual-playa-grande-del-sur",
    name: "Playa Grande del Sur",
    province: "Barahona",
    municipality: "Barahona",
    // Corregido abajo vía Places search específico Barahona
    reason: "Restaurar nombre + coords Barahona (Places matcheó Playa Grande norte)",
  },
  {
    id: "manual-playa-quita-coraza",
    name: "Playa Quita Coraza",
    province: "Barahona",
    municipality: "Barahona",
    reason: "Restaurar nombre (Places: Playa El Cayo)",
  },
  {
    id: "manual-playa-manzanillo",
    name: "Playa Manzanillo",
    province: "Monte Cristi",
    municipality: "Monte Cristi",
    reason: "Restaurar nombre (Places: Los Coquitos)",
  },
  {
    id: "ChIJK0nq-VFpro4R6oyt4qQ-IlY",
    name: "Playa Diamante",
    province: "María Trinidad Sánchez",
    municipality: "Nagua",
    reason: "Nombre canónico Nagua",
  },
  {
    id: "ChIJBQ0pLFjvro4RXF6y9NQeEss",
    name: "Playa Bavaro Miches",
    province: "El Seibo",
    municipality: "El Seibo",
    reason: "Restaurar nombre (Places: Playita Honda)",
  },
  {
    id: "manual-playa-limon",
    name: "Playa Limón",
    province: "Samaná",
    municipality: "Samaná",
    reason: "Restaurar acento/nombre canónico",
  },
  {
    id: "manual-playa-moron",
    name: "Playa Morón",
    province: "Samaná",
    municipality: "Samaná",
    reason: "Restaurar nombre canónico",
  },
  {
    id: "manual-playa-juan-de-bolanos",
    name: "Playa Juan de Bolaños",
    province: "Monte Cristi",
    municipality: "Monte Cristi",
    reason: "Restaurar acentos",
  },
  {
    id: "ChIJ65mKMK00uo4RQ_vh9BriC2s",
    name: "Playa Cabo Rojo",
    province: "Pedernales",
    municipality: "Pedernales",
    reason: "Confirmar nombre canónico",
  },
  {
    id: "manual-playa-diamante-samana",
    name: "Playa Diamante",
    province: "Samaná",
    municipality: "Samaná",
    reason: "Nombre canónico Samaná",
  },
];

let restAccessToken: string | null = null;
let placesApiKey = "";
let bucket: ReturnType<admin.storage.Storage["bucket"]> | null = null;
let useAdminSdk = false;
let db: FirebaseFirestore.Firestore | null = null;

function loadEnv(): void {
  if (fs.existsSync(ENV_PATH)) dotenv.config({ path: ENV_PATH });
  else dotenv.config();
  placesApiKey =
    process.env.GOOGLE_MAPS_API_KEY ??
    process.env.MAPS_API_KEY ??
    process.env.GOOGLE_API_KEY ??
    "";
  if (!placesApiKey) throw new Error("GOOGLE_MAPS_API_KEY requerida");
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

function toFirestoreValue(value: unknown): Record<string, unknown> {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === "boolean") return { booleanValue: value };
  if (typeof value === "number") return { doubleValue: value };
  if (typeof value === "string") return { stringValue: value };
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map((i) => toFirestoreValue(i)) } };
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

async function patchDoc(
  id: string,
  fields: Record<string, unknown>,
): Promise<void> {
  console.log(`  PATCH ${id}:`, JSON.stringify(fields));
  if (DRY_RUN) return;

  if (useAdminSdk && db) {
    await db.collection(COLLECTION).doc(id).update({
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

async function searchPlace(query: string): Promise<{
  place_id: string;
  name: string;
  address: string;
  lat: number;
  lng: number;
  photos: Array<{ photo_reference: string }>;
} | null> {
  const search = await axios.get(
    "https://maps.googleapis.com/maps/api/place/textsearch/json",
    { params: { query, key: placesApiKey } },
  );
  const results = search.data.results as Array<{ place_id: string }> | undefined;
  if (!results?.length) return null;

  const details = await axios.get(
    "https://maps.googleapis.com/maps/api/place/details/json",
    {
      params: {
        place_id: results[0].place_id,
        fields: "place_id,name,formatted_address,geometry,photos",
        key: placesApiKey,
      },
    },
  );
  const d = details.data.result;
  if (!d?.geometry?.location) return null;
  return {
    place_id: d.place_id,
    name: d.name,
    address: d.formatted_address ?? "",
    lat: d.geometry.location.lat,
    lng: d.geometry.location.lng,
    photos: d.photos ?? [],
  };
}

function publicStorageUrl(storagePath: string): string {
  return `https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/${encodeURIComponent(storagePath)}?alt=media`;
}

function placesPhotoUrl(ref: string): string {
  const params = new URLSearchParams({
    maxwidth: "1200",
    photo_reference: ref,
    key: placesApiKey,
  });
  return `https://maps.googleapis.com/maps/api/place/photo?${params}`;
}

async function uploadPhoto(
  docId: string,
  index: number,
  photoRef: string,
): Promise<string | null> {
  const url = placesPhotoUrl(photoRef);
  try {
    const response = await axios.get(url, {
      responseType: "arraybuffer",
      headers: { "X-Ios-Bundle-Identifier": "com.playasrd.playasrd" },
      maxRedirects: 5,
      timeout: 60_000,
    });
    const bytes = Buffer.from(response.data);
    const storagePath = `beaches/${docId}/photo_${index}.jpg`;

    if (DRY_RUN) {
      console.log(`  [dry-run] Subiría ${storagePath}`);
      return publicStorageUrl(storagePath);
    }

    if (useAdminSdk && bucket) {
      await bucket.file(storagePath).save(bytes, {
        metadata: { contentType: "image/jpeg" },
      });
      return publicStorageUrl(storagePath);
    }

    if (!restAccessToken) return placesPhotoUrl(photoRef);

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
      console.log(`  ⚠️ Storage falló, usando Places URL: ${res.status}`);
      return placesPhotoUrl(photoRef);
    }
    return publicStorageUrl(storagePath);
  } catch (error) {
    const msg = error instanceof Error ? error.message : String(error);
    console.log(`  ❌ foto ${index}: ${msg.split("\n")[0]}`);
    return null;
  }
}

async function fixPlayaGrandeDelSur(): Promise<void> {
  console.log("\n--- Corregir coords Playa Grande del Sur ---\n");

  const queries = [
    "Playa Grande Barahona Dominican Republic",
    "Playa Grande del Sur Barahona Dominican Republic",
    "Playa Saladilla Barahona Dominican Republic",
  ];

  let best: Awaited<ReturnType<typeof searchPlace>> = null;
  for (const q of queries) {
    console.log(`  🔍 ${q}`);
    const place = await searchPlace(q);
    if (!place) continue;
    // Barahona costa sur: lat ~17.9-18.3, lng ~-71.3 a -70.9
    const inBarahona =
      place.lat >= 17.8 &&
      place.lat <= 18.35 &&
      place.lng >= -71.4 &&
      place.lng <= -70.85;
    console.log(
      `     → ${place.name} (${place.lat}, ${place.lng}) ${inBarahona ? "OK zona" : "fuera de Barahona"}`,
    );
    if (inBarahona) {
      best = place;
      break;
    }
  }

  if (!best) {
    // Coords aproximadas conocidas de Playa Grande / zona oeste Barahona
    console.log("  ⚠️ Places no halló match en Barahona — usando coords aproximadas");
    await patchDoc("manual-playa-grande-del-sur", {
      name: "Playa Grande del Sur",
      province: "Barahona",
      municipality: "Barahona",
      latitude: 18.208,
      longitude: -71.105,
      address: "Barahona, República Dominicana",
      needsReview: true,
    });
    return;
  }

  await patchDoc("manual-playa-grande-del-sur", {
    name: "Playa Grande del Sur",
    province: "Barahona",
    municipality: "Barahona",
    latitude: best.lat,
    longitude: best.lng,
    address: best.address,
    googlePlaceId: best.place_id,
    needsReview: false,
  });
}

async function tryTrudillePhotos(): Promise<void> {
  console.log("\n--- Fotos Playa Trudillé ---\n");
  const queries = [
    "Playa Trudillé Pedernales Dominican Republic",
    "Playa Trudille Pedernales",
    "Trudille beach Pedernales Dominican Republic",
    "Playa Cabo Rojo Pedernales Dominican Republic",
  ];

  for (const q of queries) {
    console.log(`  🔍 ${q}`);
    const place = await searchPlace(q);
    if (!place) continue;
    console.log(
      `     → ${place.name} (${place.lat}, ${place.lng}) fotos=${place.photos.length}`,
    );

    // Solo aceptar si está cerca de Trudillé actual (~17.75, -71.52)
    const near =
      Math.abs(place.lat - 17.7479) < 0.08 &&
      Math.abs(place.lng - -71.5215) < 0.08;

    if (!near) {
      console.log("     fuera de zona Trudillé, omitido");
      continue;
    }

    if (place.photos.length === 0) {
      console.log("     sin fotos en este place");
      continue;
    }

    const urls: string[] = [];
    for (let i = 0; i < Math.min(MAX_PHOTOS, place.photos.length); i++) {
      const uploaded = await uploadPhoto(
        "manual-playa-trudille",
        i,
        place.photos[i].photo_reference,
      );
      if (uploaded) urls.push(uploaded);
    }

    if (urls.length > 0) {
      await patchDoc("manual-playa-trudille", {
        name: "Playa Trudillé",
        imageUrls: urls,
        googlePlaceId: place.place_id,
      });
      console.log(`  ✅ ${urls.length} fotos para Trudillé`);
      return;
    }
  }

  console.log(
    "  ⚠️ No se encontraron fotos cerca de Trudillé — queda sin imágenes",
  );
  await patchDoc("manual-playa-trudille", {
    name: "Playa Trudillé",
    needsReview: true,
  });
}

async function main(): Promise<void> {
  console.log(`\n=== Fix playas enriquecidas — ${PROJECT_ID}${DRY_RUN ? " [DRY-RUN]" : ""} ===\n`);
  loadEnv();
  initFirebase();
  await ensureWrite();

  console.log("--- Restaurar nombres canónicos ---\n");
  for (const fix of NAME_FIXES) {
    if (fix.id === "manual-playa-grande-del-sur") continue; // handled separately
    const fields: Record<string, unknown> = { name: fix.name };
    if (fix.province) fields.province = fix.province;
    if (fix.municipality) fields.municipality = fix.municipality;
    console.log(`• ${fix.id} — ${fix.reason}`);
    await patchDoc(fix.id, fields);
  }

  await fixPlayaGrandeDelSur();
  await tryTrudillePhotos();

  console.log("\n✅ Fixes aplicados.\n");
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
