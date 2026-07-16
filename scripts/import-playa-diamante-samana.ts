/**
 * Importa Playa Diamante (Samaná / Las Galeras) que Places confunde con Nagua.
 *   npx ts-node import-playa-diamante-samana.ts --dry-run
 *   npx ts-node import-playa-diamante-samana.ts
 */

import axios from "axios";
import * as dotenv from "dotenv";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as admin from "firebase-admin";
import { OAuth2Client } from "google-auth-library";

const PROJECT_ID = "playas-rd-2b475";
const COLLECTION = "beaches";
const DOC_ID = "manual-playa-diamante-samana";
const ENV_PATH = path.join(__dirname, "..", ".env");
const DRY_RUN = process.argv.includes("--dry-run");
const SEARCH_QUERIES = [
  "Playa Diamante Las Galeras Samana Dominican Republic",
  "Playa Diamante Samana Peninsula Dominican Republic",
  "Diamante beach Las Galeras Dominican Republic",
];

const DESCRIPTION = {
  es: "Playa semisecreta de Las Galeras accesible solo en bote o por sendero de 45 minutos. Arena blanca y aguas turquesas con muy poca corriente. Considerada una de las joyas ocultas de Samaná por su belleza natural intacta.",
  en: "Semi-secret beach in Las Galeras accessible only by boat or 45-minute trail. White sand and turquoise waters with very little current. Considered one of Samaná's hidden gems for its unspoiled natural beauty.",
  activities: ["Natación", "Snorkel", "Fotografía", "Aventura"],
  amenities: {
    baños: false,
    duchas: false,
    parking: false,
    restaurantes: false,
    sombrillas: false,
    salvavidas: false,
  },
};

let restAccessToken: string | null = null;
let useAdminSdk = false;
let db: FirebaseFirestore.Firestore | null = null;
let apiKey = "";

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

function loadEnv(): void {
  if (fs.existsSync(ENV_PATH)) dotenv.config({ path: ENV_PATH });
  else dotenv.config();
  apiKey =
    process.env.GOOGLE_MAPS_API_KEY ??
    process.env.MAPS_API_KEY ??
    process.env.GOOGLE_API_KEY ??
    "";
  if (!apiKey) throw new Error("GOOGLE_MAPS_API_KEY requerida");
}

function initFirebase(): void {
  try {
    if (admin.apps.length === 0) {
      const sa = process.env.GOOGLE_APPLICATION_CREDENTIALS;
      if (sa && fs.existsSync(sa)) {
        admin.initializeApp({
          credential: admin.credential.cert(JSON.parse(fs.readFileSync(sa, "utf8"))),
          projectId: PROJECT_ID,
        });
      } else {
        admin.initializeApp({
          credential: admin.credential.applicationDefault(),
          projectId: PROJECT_ID,
        });
      }
    }
    db = admin.firestore();
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
    }
  }
  const configPath = findFirebaseToolsConfigPath();
  if (!configPath) throw new Error("firebase login requerido");
  const config = JSON.parse(fs.readFileSync(configPath, "utf8")) as {
    tokens?: { refresh_token?: string; access_token?: string; expires_at?: number };
  };
  const client = new OAuth2Client(FIREBASE_CLI_CLIENT_ID, FIREBASE_CLI_CLIENT_SECRET);
  client.setCredentials({ refresh_token: config.tokens?.refresh_token });
  restAccessToken = (await client.getAccessToken()).token ?? null;
  if (!restAccessToken) throw new Error("No token");
}

async function findPlace(): Promise<{
  place_id: string;
  name: string;
  address: string;
  lat: number;
  lng: number;
  rating: number;
  reviewCount: number;
  photos: string[];
} | null> {
  const naguaPlaceId = "ChIJK0nq-VFpro4R6oyt4qQ-IlY";

  for (const query of SEARCH_QUERIES) {
    console.log(`  🔍 ${query}`);
    const search = await axios.get(
      "https://maps.googleapis.com/maps/api/place/textsearch/json",
      { params: { query, key: apiKey } },
    );
    const results = search.data.results as Array<{
      place_id: string;
      name: string;
      formatted_address?: string;
      geometry?: { location: { lat: number; lng: number } };
    }>;
    if (!results?.length) continue;

    for (const result of results.slice(0, 3)) {
      if (result.place_id === naguaPlaceId) continue;

      const details = await axios.get(
        "https://maps.googleapis.com/maps/api/place/details/json",
        {
          params: {
            place_id: result.place_id,
            fields:
              "place_id,name,formatted_address,geometry,rating,user_ratings_total,photos",
            key: apiKey,
          },
        },
      );
      const d = details.data.result as {
        place_id: string;
        name: string;
        formatted_address?: string;
        geometry?: { location: { lat: number; lng: number } };
        rating?: number;
        user_ratings_total?: number;
        photos?: Array<{ photo_reference: string }>;
      };
      if (!d?.geometry?.location) continue;

      const lat = d.geometry.location.lat;
      const lng = d.geometry.location.lng;
      // Samaná peninsula: lat ~19.2-19.35, lng ~69.2-69.5
      if (lat < 19.15 || lat > 19.4 || lng < -69.6 || lng > -69.2) {
        console.log(`  ⏭️  ${d.name} fuera de Samaná (${lat}, ${lng})`);
        continue;
      }

      const photos = (d.photos ?? []).slice(0, 5).map((p) => {
        const params = new URLSearchParams({
          maxwidth: "1200",
          photo_reference: p.photo_reference,
          key: apiKey,
        });
        return `https://maps.googleapis.com/maps/api/place/photo?${params}`;
      });

      return {
        place_id: d.place_id,
        name: "Playa Diamante",
        address: d.formatted_address ?? "",
        lat,
        lng,
        rating: d.rating ?? 0,
        reviewCount: d.user_ratings_total ?? 0,
        photos,
      };
    }
  }
  return null;
}

async function writeDoc(data: Record<string, unknown>): Promise<void> {
  if (DRY_RUN) {
    console.log("[dry-run] Crearía", DOC_ID, data);
    return;
  }
  if (useAdminSdk && db) {
    await db.collection(COLLECTION).doc(DOC_ID).set({
      ...data,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }
  const toVal = (v: unknown): Record<string, unknown> => {
    if (v instanceof Date) return { timestampValue: v.toISOString() };
    if (typeof v === "string") return { stringValue: v };
    if (typeof v === "number") return { doubleValue: v };
    if (typeof v === "boolean") return { booleanValue: v };
    if (Array.isArray(v)) {
      return { arrayValue: { values: v.map((x) => toVal(x)) } };
    }
    if (typeof v === "object" && v) {
      const fields: Record<string, unknown> = {};
      for (const [k, val] of Object.entries(v as Record<string, unknown>)) {
        fields[k] = toVal(val);
      }
      return { mapValue: { fields } };
    }
    return { stringValue: String(v) };
  };
  const body = {
    fields: Object.fromEntries(
      Object.entries({ ...data, lastUpdated: new Date() }).map(
        ([k, v]) => [k, toVal(v)],
      ),
    ),
  };
  const res = await fetch(
    `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}?documentId=${encodeURIComponent(DOC_ID)}`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${restAccessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    },
  );
  if (!res.ok) throw new Error(`${res.status} ${await res.text()}`);
}

async function main(): Promise<void> {
  console.log("\n=== Importar Playa Diamante (Samaná) ===\n");
  loadEnv();
  initFirebase();
  await ensureWrite();

  const place = await findPlace();
  if (!place) {
    console.log(
      "❌ No se encontró un lugar distinto en Samaná. Quedará pendiente revisión manual.",
    );
    process.exit(1);
  }

  const doc = {
    name: place.name,
    province: "Samaná",
    municipality: "Samaná",
    address: place.address,
    description: DESCRIPTION.es,
    descriptionEn: DESCRIPTION.en,
    latitude: place.lat,
    longitude: place.lng,
    imageUrls: place.photos,
    rating: place.rating,
    reviewCount: place.reviewCount,
    currentCondition: "Desconocido",
    amenities: DESCRIPTION.amenities,
    activities: DESCRIPTION.activities,
    needsReview: false,
    googlePlaceId: place.place_id,
    source: "google_places_import",
    enrichedFrom: "google_places",
  };

  await writeDoc(doc);
  console.log(
    `✅ ${DOC_ID} → ${place.lat}, ${place.lng} | ${place.photos.length} fotos | place_id=${place.place_id}`,
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
