/**
 * Importa nuevas playas a Firestore desde Google Places (una sola vez por playa).
 *
 * Proyecto: playas-rd-2b475
 * Colección: beaches
 *
 * Ejecutar desde la raíz del repo:
 *   npx ts-node scripts/add-new-beaches.ts --dry-run
 *   npx ts-node scripts/add-new-beaches.ts
 *   npx ts-node scripts/add-new-beaches.ts --force
 *
 * Variables de entorno (.env en la raíz o process.env):
 *   GOOGLE_MAPS_API_KEY  ← misma key que usa la app Flutter (Places + Maps)
 *   GOOGLE_APPLICATION_CREDENTIALS=ruta/service-account.json
 *   FIREBASE_PROJECT_ID=playas-rd-2b475
 *
 * Si no hay .env, se usa la apiKey de lib/firebase_options.dart como respaldo.
 */

import axios, { AxiosError } from "axios";
import * as admin from "firebase-admin";
import * as dotenv from "dotenv";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import { OAuth2Client } from "google-auth-library";

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? "playas-rd-2b475";
const STORAGE_BUCKET = "playas-rd-2b475.firebasestorage.app";
const COLLECTION = "beaches";
const CACHE_PATH = path.join(__dirname, "places-cache.json");
const ENV_PATH = path.join(__dirname, "..", ".env");

const DRY_RUN = process.argv.includes("--dry-run");
const FORCE = process.argv.includes("--force");
const MAX_PHOTOS = 5;

interface Amenities {
  baños: boolean;
  duchas: boolean;
  parking: boolean;
  restaurantes: boolean;
  sombrillas: boolean;
  salvavidas: boolean;
}

interface BeachDescription {
  es: string;
  en: string;
  activities: string[];
  amenities: Partial<Amenities>;
}

interface BeachTarget {
  cacheKey: string;
  searchQuery: string;
  name: string;
  province: string;
  municipality: string;
  descriptionKey: string;
}

interface PlaceDetails {
  place_id: string;
  name: string;
  formatted_address?: string;
  geometry?: { location: { lat: number; lng: number } };
  rating?: number;
  user_ratings_total?: number;
  photos?: Array<{ photo_reference: string }>;
  types?: string[];
  opening_hours?: { open_now?: boolean };
}

interface CacheEntry {
  place_id: string | null;
  fetched_at: string;
  search_query: string;
  place_details: PlaceDetails | null;
  photo_urls: string[];
  error?: string;
}

type PlacesCache = Record<string, CacheEntry>;

const DEFAULT_AMENITIES: Amenities = {
  baños: false,
  duchas: false,
  parking: false,
  restaurantes: false,
  sombrillas: false,
  salvavidas: false,
};

const BEACH_TARGETS: BeachTarget[] = [
  {
    cacheKey: "Playa Cabo Rojo",
    searchQuery: "Playa Cabo Rojo Pedernales Dominican Republic",
    name: "Playa Cabo Rojo",
    province: "Pedernales",
    municipality: "Pedernales",
    descriptionKey: "Playa Cabo Rojo",
  },
  {
    cacheKey: "Playa Trudillé",
    searchQuery: "Playa Trudillé Pedernales Dominican Republic",
    name: "Playa Trudillé",
    province: "Pedernales",
    municipality: "Pedernales",
    descriptionKey: "Playa Trudillé",
  },
  {
    cacheKey: "Bahía de Portillo",
    searchQuery: "Bahia de Portillo Dominican Republic",
    name: "Bahía de Portillo",
    province: "Samaná",
    municipality: "Samaná",
    descriptionKey: "Bahía de Portillo",
  },
  {
    cacheKey: "Playa Miches",
    searchQuery: "Playa Miches Hato Mayor Dominican Republic",
    name: "Playa Miches",
    province: "Hato Mayor",
    municipality: "Miches",
    descriptionKey: "Playa Miches",
  },
  {
    cacheKey: "Playa Esmeralda",
    searchQuery: "Playa Esmeralda El Seibo Dominican Republic",
    name: "Playa Esmeralda",
    province: "El Seibo",
    municipality: "El Seibo",
    descriptionKey: "Playa Esmeralda",
  },
  {
    cacheKey: "Playa Bavaro Miches",
    searchQuery: "Playa Honda El Seibo Dominican Republic",
    name: "Playa Bavaro Miches",
    province: "El Seibo",
    municipality: "El Seibo",
    descriptionKey: "Playa Honda",
  },
  {
    cacheKey: "Playa Magante",
    searchQuery: "Playa Magante Rio San Juan Dominican Republic",
    name: "Playa Magante",
    province: "María Trinidad Sánchez",
    municipality: "Río San Juan",
    descriptionKey: "Playa Magante",
  },
  {
    cacheKey: "Playa Jackson",
    searchQuery: "Playa Jackson Cabrera Dominican Republic",
    name: "Playa Jackson",
    province: "María Trinidad Sánchez",
    municipality: "Cabrera",
    descriptionKey: "Playa Jackson",
  },
  {
    cacheKey: "Playa Diamante Nagua",
    searchQuery: "Playa Diamante Nagua Dominican Republic",
    name: "Playa Diamante",
    province: "María Trinidad Sánchez",
    municipality: "Nagua",
    descriptionKey: "Playa Diamante Nagua",
  },
  {
    cacheKey: "Playa Limón",
    searchQuery: "Playa Limon Samana Dominican Republic",
    name: "Playa Limón",
    province: "Samaná",
    municipality: "Samaná",
    descriptionKey: "Playa Limón",
  },
  {
    cacheKey: "Playa Diamante Samaná",
    searchQuery: "Playa Diamante Samana Dominican Republic",
    name: "Playa Diamante",
    province: "Samaná",
    municipality: "Samaná",
    descriptionKey: "Playa Diamante Samaná",
  },
  {
    cacheKey: "Playa Morón",
    searchQuery: "Playa Moron Samana Dominican Republic",
    name: "Playa Morón",
    province: "Samaná",
    municipality: "Samaná",
    descriptionKey: "Playa Morón",
  },
  {
    cacheKey: "Playa Manzanillo",
    searchQuery: "Playa Manzanillo Monte Cristi Dominican Republic",
    name: "Playa Manzanillo",
    province: "Monte Cristi",
    municipality: "Monte Cristi",
    descriptionKey: "Playa Manzanillo",
  },
  {
    cacheKey: "Playa Juan de Bolaños",
    searchQuery: "Playa Juan de Bolanos Monte Cristi Dominican Republic",
    name: "Playa Juan de Bolaños",
    province: "Monte Cristi",
    municipality: "Monte Cristi",
    descriptionKey: "Playa Juan de Bolaños",
  },
  {
    cacheKey: "Playa Dominicus Americanus",
    searchQuery: "Playa Dominicus Americanus La Romana Dominican Republic",
    name: "Playa Dominicus Americanus",
    province: "La Romana",
    municipality: "Bayahibe",
    descriptionKey: "Playa Dominicus Americanus",
  },
  {
    cacheKey: "Playa Blanca Bayahibe",
    searchQuery: "Playa Blanca Bayahibe Dominican Republic",
    name: "Playa Blanca Bayahibe",
    province: "La Romana",
    municipality: "Bayahibe",
    descriptionKey: "Playa Blanca Bayahibe",
  },
  {
    cacheKey: "Playa Grande del Sur",
    searchQuery: "Playa Grande Barahona Dominican Republic",
    name: "Playa Grande del Sur",
    province: "Barahona",
    municipality: "Barahona",
    descriptionKey: "Playa Grande del Sur",
  },
  {
    cacheKey: "Playa Quita Coraza",
    searchQuery: "Playa Quita Coraza Barahona Dominican Republic",
    name: "Playa Quita Coraza",
    province: "Barahona",
    municipality: "Barahona",
    descriptionKey: "Playa Quita Coraza",
  },
];

const beachDescriptions: Record<string, BeachDescription> = {
  "Playa Cabo Rojo": {
    es: "Playa de arena blanca y aguas turquesas ubicada cerca del puerto de Cabo Rojo en Pedernales. Zona industrial cercana pero la playa en sí es prístina, con arrecifes de coral y aguas poco profundas ideales para snorkel. Punto de partida para excursiones hacia Bahía de las Águilas.",
    en: "White sand beach with turquoise waters located near the port of Cabo Rojo in Pedernales. Despite nearby industrial activity, the beach itself is pristine, with coral reefs and shallow waters ideal for snorkeling. Starting point for excursions to Bahía de las Águilas.",
    activities: ["Snorkel", "Natación", "Ecoturismo", "Fotografía"],
    amenities: { parking: true, restaurantes: true },
  },
  "Playa Trudillé": {
    es: "Playa virgen de difícil acceso en la costa sur de Pedernales. Arena blanca y aguas cristalinas propias del Parque Nacional Jaragua. Ideal para quienes buscan total aislamiento y contacto con la naturaleza sin infraestructura turística.",
    en: "Untouched beach with difficult access on the southern coast of Pedernales. White sand and crystal-clear waters characteristic of Jaragua National Park. Ideal for those seeking complete isolation and contact with nature without tourist infrastructure.",
    activities: ["Natación", "Ecoturismo", "Fotografía", "Aventura"],
    amenities: {},
  },
  "Bahía de Portillo": {
    es: "Bahía protegida en la Península de Samaná con aguas calmadas de color esmeralda. Bordeada por cocoteros y vegetación exuberante. Destino tranquilo con ambiente de pescadores, muy lejos del turismo masivo del norte de Samaná.",
    en: "Protected bay on the Samaná Peninsula with calm emerald-colored waters. Lined by coconut trees and lush vegetation. Tranquil destination with a fishing atmosphere, far from the mass tourism of northern Samaná.",
    activities: ["Natación", "Kayak", "Pesca", "Tranquilidad"],
    amenities: { parking: true, restaurantes: true },
  },
  "Playa Miches": {
    es: "Extensa playa de arena dorada en el municipio de Miches, puerta de entrada al Cabo Engaño y las lagunas costeras de Hato Mayor. Aguas del Atlántico con oleaje moderado, ambiente local auténtico y en proceso de desarrollo turístico exclusivo.",
    en: "Expansive golden sand beach in the municipality of Miches, gateway to Cabo Engaño and the coastal lagoons of Hato Mayor. Atlantic waters with moderate waves, authentic local atmosphere and undergoing exclusive tourist development.",
    activities: ["Natación", "Surf", "Kitesurf", "Fotografía"],
    amenities: { parking: true, restaurantes: true },
  },
  "Playa Esmeralda": {
    es: "Playa de arena fina con aguas de color esmeralda en la costa atlántica de El Seibo. Poco conocida, con acceso por caminos rurales y ambiente completamente virgen. Destino de ecoturismo emergente con increíble biodiversidad costera.",
    en: "Fine sand beach with emerald-colored waters on the Atlantic coast of El Seibo. Little known, accessible via rural roads and completely unspoiled atmosphere. Emerging ecotourism destination with incredible coastal biodiversity.",
    activities: ["Natación", "Ecoturismo", "Fotografía", "Naturaleza"],
    amenities: {},
  },
  "Playa Honda": {
    es: "Playa de arena clara en la costa de El Seibo, cerca de la zona de Miches y Cabo Engaño. Aguas del Atlántico con oleaje suave a moderado y entorno de palmeras y vegetación costera. Frecuentada por pescadores locales y visitantes que buscan playas poco masificadas del este.",
    en: "Light sand beach on the coast of El Seibo, near the Miches and Cabo Engaño area. Atlantic waters with gentle to moderate waves and a setting of palm trees and coastal vegetation. Visited by local fishermen and travelers seeking less crowded eastern beaches.",
    activities: ["Natación", "Pesca", "Fotografía", "Ecoturismo"],
    amenities: { parking: true },
  },
  "Playa Magante": {
    es: "Una de las playas más bellas y menos concurridas de la costa atlántica, cerca de Río San Juan. Arena blanca, aguas transparentes de color turquesa y un entorno natural de cocoteros. Ideal para quienes buscan la tranquilidad del norte sin las multitudes de Cabarete.",
    en: "One of the most beautiful and least crowded beaches on the Atlantic coast, near Río San Juan. White sand, transparent turquoise waters and a natural setting of coconut trees. Ideal for those seeking northern tranquility without the crowds of Cabarete.",
    activities: ["Natación", "Snorkel", "Fotografía", "Tranquilidad"],
    amenities: { parking: true },
  },
  "Playa Jackson": {
    es: "Playa escondida entre acantilados en Cabrera, accesible por escaleras de piedra. Sus piscinas naturales formadas entre las rocas son su característica más especial. Aguas cristalinas con tonos verdes y azules perfectas para fotografía submarina.",
    en: "Hidden beach between cliffs in Cabrera, accessible by stone stairs. Its natural pools formed between the rocks are its most special feature. Crystal-clear waters with green and blue tones perfect for underwater photography.",
    activities: ["Snorkel", "Fotografía", "Natación", "Aventura"],
    amenities: {},
  },
  "Playa Diamante Nagua": {
    es: "Playa de arena dorada en la costa de Nagua, dentro de la provincia María Trinidad Sánchez. Aguas del Atlántico con oleaje moderado y ambiente local auténtico. Destino accesible para quienes recorren la costa norte entre Cabrera y Samaná.",
    en: "Golden sand beach on the coast of Nagua, within María Trinidad Sánchez province. Atlantic waters with moderate waves and an authentic local atmosphere. Accessible destination for those traveling the northern coast between Cabrera and Samaná.",
    activities: ["Natación", "Surf", "Fotografía", "Pesca"],
    amenities: { parking: true, restaurantes: true },
  },
  "Playa Limón": {
    es: "Playa silvestre de 5 km de longitud en la Península de Samaná, considerada una de las más bellas y prístinas de República Dominicana. Solo accesible a caballo o a pie desde Las Galeras. Sin desarrollo turístico, rodeada de palmeras y manglar.",
    en: "Wild beach stretching 5 km on the Samaná Peninsula, considered one of the most beautiful and pristine in the Dominican Republic. Only accessible by horse or on foot from Las Galeras. No tourist development, surrounded by palm trees and mangroves.",
    activities: ["Natación", "Ecoturismo", "Fotografía", "Senderismo"],
    amenities: {},
  },
  "Playa Diamante Samaná": {
    es: "Playa semisecreta de Las Galeras accesible solo en bote o por sendero de 45 minutos. Arena blanca y aguas turquesas con muy poca corriente. Considerada una de las joyas ocultas de Samaná por su belleza natural intacta.",
    en: "Semi-secret beach in Las Galeras accessible only by boat or 45-minute trail. White sand and turquoise waters with very little current. Considered one of Samaná's hidden gems for its unspoiled natural beauty.",
    activities: ["Natación", "Snorkel", "Fotografía", "Aventura"],
    amenities: {},
  },
  "Playa Morón": {
    es: "Playa amplia de arena clara en la costa sur de la Península de Samaná, cerca del pueblo de Morón. Aguas tranquilas protegidas por la bahía, ambiente pesquero y paisajes de montañas al fondo. Menos conocida que Las Terrenas pero igualmente pintoresca.",
    en: "Wide light sand beach on the southern coast of the Samaná Peninsula, near the town of Morón. Calm bay-protected waters, fishing atmosphere and mountain scenery in the background. Less known than Las Terrenas but equally picturesque.",
    activities: ["Natación", "Kayak", "Pesca", "Fotografía"],
    amenities: { parking: true },
  },
  "Playa Manzanillo": {
    es: "Playa de Monte Cristi ubicada cerca del pueblo de Manzanillo, en el extremo noroeste del país. Ambiente de pescadores, aguas tranquilas del Canal de la Mona y acceso a los famosos Cayos de los Siete Hermanos.",
    en: "Monte Cristi beach located near the town of Manzanillo, in the far northwest of the country. Fishing atmosphere, calm waters of the Mona Canal and access to the famous Seven Brothers Cays.",
    activities: ["Pesca", "Natación", "Ecoturismo", "Kayak"],
    amenities: { parking: true, restaurantes: true },
  },
  "Playa Juan de Bolaños": {
    es: "Playa costera en Monte Cristi con arena clara y aguas del Canal de la Mona. Zona de actividad pesquera tradicional con vistas hacia Haití en días despejados. Entorno natural poco desarrollado, ideal para quienes exploran el noroeste dominicano.",
    en: "Coastal beach in Monte Cristi with light sand and waters of the Mona Canal. Area of traditional fishing activity with views toward Haiti on clear days. Undeveloped natural setting, ideal for those exploring the Dominican northwest.",
    activities: ["Pesca", "Natación", "Fotografía", "Ecoturismo"],
    amenities: { parking: true },
  },
  "Playa Dominicus Americanus": {
    es: "Playa de arena blanca y aguas cristalinas en Bayahibe, diferente a Playa Dominicus por su ubicación más al este. Menos transitada, con acceso a complejos hoteleros y área pública. Snorkel excepcional con arrecifes de coral intactos.",
    en: "White sand beach with crystal-clear waters in Bayahibe, different from Playa Dominicus due to its more eastern location. Less crowded, with access to hotel complexes and a public area. Exceptional snorkeling with intact coral reefs.",
    activities: ["Snorkel", "Natación", "Buceo", "Relajación"],
    amenities: {
      baños: true,
      duchas: true,
      parking: true,
      restaurantes: true,
      sombrillas: true,
      salvavidas: true,
    },
  },
  "Playa Blanca Bayahibe": {
    es: "Pequeña playa de arena blanca fina en las afueras de Bayahibe, accesible en bote o caminando por la costa. Aguas color turquesa de poca profundidad, rodeada de vegetación nativa. Una de las playas más fotografiadas del este dominicano.",
    en: "Small fine white sand beach on the outskirts of Bayahibe, accessible by boat or walking along the coast. Shallow turquoise-colored waters, surrounded by native vegetation. One of the most photographed beaches in the eastern Dominican Republic.",
    activities: ["Natación", "Snorkel", "Fotografía", "Relajación"],
    amenities: { sombrillas: true },
  },
  "Playa Grande del Sur": {
    es: "Playa extensa en la costa sur de Barahona con arena oscura característica de la región y aguas del Mar Caribe. Olas más pronunciadas que las playas del norte, ideal para surf y deportes acuáticos. Entorno montañoso espectacular.",
    en: "Extensive beach on the southern coast of Barahona with dark sand characteristic of the region and Caribbean Sea waters. More pronounced waves than northern beaches, ideal for surfing and water sports. Spectacular mountain surroundings.",
    activities: ["Surf", "Natación", "Fotografía", "Atardecer"],
    amenities: { parking: true },
  },
  "Playa Quita Coraza": {
    es: "Playa rocosa y de arena oscura en la costa sur de Barahona, conocida por sus formaciones rocosas y piscinas naturales en marea baja. Aguas del Caribe con oleaje moderado y entorno montañoso del sur dominicano. Destino apreciado por bañistas locales y surfistas.",
    en: "Rocky and dark sand beach on the southern coast of Barahona, known for its rock formations and natural pools at low tide. Caribbean waters with moderate waves and the mountainous setting of the Dominican south. Appreciated by local swimmers and surfers.",
    activities: ["Natación", "Surf", "Fotografía", "Aventura"],
    amenities: { parking: true },
  },
};

const stats = {
  processed: 0,
  added: 0,
  skipped: 0,
  errors: 0,
};

let db: FirebaseFirestore.Firestore | null = null;
let bucket: ReturnType<admin.storage.Storage["bucket"]> | null = null;
let useAdminSdk = false;
let restAccessToken: string | null = null;

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

function loadEnvironment(): void {
  if (fs.existsSync(ENV_PATH)) {
    dotenv.config({ path: ENV_PATH });
  } else {
    dotenv.config();
  }
}

function getPlacesApiKey(): string {
  // Misma prioridad que lib/services/google_places_service.dart
  const fromEnv =
    process.env.GOOGLE_MAPS_API_KEY ??
    process.env.MAPS_API_KEY ??
    process.env.GOOGLE_API_KEY ??
    process.env.GOOGLE_PLACES_API_KEY;

  if (fromEnv?.trim()) {
    console.log("Usando Google Maps API Key desde .env\n");
    return fromEnv.trim();
  }

  const optionsPath = path.join(__dirname, "..", "lib", "firebase_options.dart");
  if (fs.existsSync(optionsPath)) {
    const content = fs.readFileSync(optionsPath, "utf8");
    const match = content.match(/apiKey:\s*'([^']+)'/);
    if (match?.[1]?.startsWith("AIzaSy")) {
      console.log("Usando apiKey desde lib/firebase_options.dart\n");
      return match[1];
    }
  }

  throw new Error(
    "No se encontró API key. Define GOOGLE_MAPS_API_KEY en .env " +
      "(la misma que usa la app) o verifica lib/firebase_options.dart",
  );
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
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

async function getAccessTokenFromFirebaseLogin(): Promise<string> {
  if (process.env.FIRESTORE_ACCESS_TOKEN) {
    return process.env.FIRESTORE_ACCESS_TOKEN;
  }

  const configPath = findFirebaseToolsConfigPath();
  if (!configPath) {
    throw new Error("No se encontró firebase-tools.json. Ejecuta: firebase login");
  }

  const config = JSON.parse(fs.readFileSync(configPath, "utf8")) as {
    tokens?: { refresh_token?: string; access_token?: string; expires_at?: number };
  };

  const tokens = config.tokens;
  if (!tokens?.refresh_token) {
    throw new Error("Sin refresh_token. Ejecuta: firebase login --reauth");
  }

  if (tokens.access_token && tokens.expires_at && tokens.expires_at > Date.now() + 60_000) {
    return tokens.access_token;
  }

  const client = new OAuth2Client(FIREBASE_CLI_CLIENT_ID, FIREBASE_CLI_CLIENT_SECRET);
  client.setCredentials({ refresh_token: tokens.refresh_token });
  const response = await client.getAccessToken();
  if (!response.token) {
    throw new Error("No se pudo refrescar el access token OAuth.");
  }
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
  console.log("Usando sesión firebase login (REST) para Firestore.\n");
}

async function restFetch(pathSuffix: string, init?: RequestInit): Promise<Response> {
  if (!restAccessToken) throw new Error("REST API no inicializada");
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
  if (typeof value === "string") {
    if (/^\d{4}-\d{2}-\d{2}T/.test(value)) {
      return { timestampValue: value };
    }
    return { stringValue: value };
  }
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

async function documentExists(docId: string): Promise<boolean> {
  if (useAdminSdk && db) {
    const snap = await db.collection(COLLECTION).doc(docId).get();
    return snap.exists;
  }

  const response = await restFetch(`${COLLECTION}/${encodeURIComponent(docId)}`);
  if (response.status === 404) return false;
  if (!response.ok) {
    throw new Error(`Firestore GET failed: ${response.status} ${await response.text()}`);
  }
  return true;
}

async function writeDocument(
  docId: string,
  data: FirebaseFirestore.DocumentData,
): Promise<void> {
  const payload = {
    ...data,
    addedAt: new Date().toISOString(),
  };

  if (useAdminSdk && db) {
    await db
      .collection(COLLECTION)
      .doc(docId)
      .set({
        ...payload,
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    return;
  }

  const body = {
    fields: Object.fromEntries(
      Object.entries(payload).map(([k, v]) => [k, toFirestoreValue(v)]),
    ),
  };

  const response = await restFetch(
    `${COLLECTION}?documentId=${encodeURIComponent(docId)}`,
    { method: "POST", body: JSON.stringify(body) },
  );

  if (!response.ok) {
    throw new Error(`Firestore POST failed: ${response.status} ${await response.text()}`);
  }
}

function loadCache(): PlacesCache {
  if (!fs.existsSync(CACHE_PATH)) return {};
  return JSON.parse(fs.readFileSync(CACHE_PATH, "utf8")) as PlacesCache;
}

function saveCache(cache: PlacesCache): void {
  fs.writeFileSync(CACHE_PATH, JSON.stringify(cache, null, 2), "utf8");
}

function publicStorageUrl(storagePath: string): string {
  const encoded = encodeURIComponent(storagePath);
  return `https://firebasestorage.googleapis.com/v0/b/${STORAGE_BUCKET}/o/${encoded}?alt=media`;
}

function mergeAmenities(
  hardcoded: Partial<Amenities>,
  inferred: Partial<Amenities>,
): Amenities {
  return {
    ...DEFAULT_AMENITIES,
    ...inferred,
    ...hardcoded,
  };
}

function inferAmenitiesFromPlace(details: PlaceDetails | null): Partial<Amenities> {
  if (!details?.types) return {};
  const types = details.types;
  const amenities: Partial<Amenities> = {};

  if (
    types.some((t) =>
      ["restaurant", "food", "cafe", "bar", "meal_takeaway"].includes(t),
    )
  ) {
    amenities.restaurantes = true;
  }
  if (types.includes("parking")) amenities.parking = true;
  if (types.includes("lodging")) {
    amenities.restaurantes = true;
    amenities.parking = true;
  }
  if (types.includes("tourist_attraction") && types.includes("natural_feature")) {
    amenities.parking = true;
  }

  return amenities;
}

function inferActivitiesFromPlace(details: PlaceDetails | null): string[] {
  if (!details?.types) return [];
  const types = details.types;
  const activities: string[] = [];

  if (types.includes("natural_feature") || types.includes("park")) {
    activities.push("Ecoturismo");
  }
  if (types.includes("tourist_attraction")) {
    activities.push("Fotografía");
  }

  return activities;
}

function mergeActivities(hardcoded: string[], inferred: string[]): string[] {
  return Array.from(new Set([...hardcoded, ...inferred]));
}

function generateManualId(name: string): string {
  const slug = name
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
  return `manual-${slug}`;
}

async function textSearchPlace(
  query: string,
  apiKey: string,
): Promise<string | null> {
  const response = await axios.get(
    "https://maps.googleapis.com/maps/api/place/textsearch/json",
    {
      params: { query, key: apiKey },
    },
  );

  const data = response.data as {
    status: string;
    results?: Array<{ place_id: string; name: string }>;
    error_message?: string;
  };

  if (data.status !== "OK" || !data.results?.length) {
    if (data.status === "ZERO_RESULTS") return null;
    throw new Error(data.error_message ?? `Text Search status: ${data.status}`);
  }

  return data.results[0].place_id;
}

async function fetchPlaceDetails(
  placeId: string,
  apiKey: string,
): Promise<PlaceDetails> {
  const response = await axios.get(
    "https://maps.googleapis.com/maps/api/place/details/json",
    {
      params: {
        place_id: placeId,
        fields:
          "place_id,name,formatted_address,geometry,rating,user_ratings_total,photos,types,opening_hours",
        key: apiKey,
      },
    },
  );

  const data = response.data as {
    status: string;
    result?: PlaceDetails;
    error_message?: string;
  };

  if (data.status !== "OK" || !data.result) {
    throw new Error(data.error_message ?? `Place Details status: ${data.status}`);
  }

  return data.result;
}

async function resolvePhotoUrl(
  photoReference: string,
  apiKey: string,
): Promise<string | null> {
  try {
    await axios.get("https://maps.googleapis.com/maps/api/place/photo", {
      params: {
        maxwidth: 1200,
        photo_reference: photoReference,
        key: apiKey,
      },
      maxRedirects: 0,
      validateStatus: (status) => status === 302,
    });
    return null;
  } catch (error) {
    const axiosError = error as AxiosError;
    if (axiosError.response?.status === 302) {
      const location = axiosError.response.headers.location;
      return typeof location === "string" ? location : null;
    }
    throw error;
  }
}

async function fetchPlaceData(
  target: BeachTarget,
  apiKey: string,
  cache: PlacesCache,
): Promise<CacheEntry> {
  console.log(`  🔍 Google Places: ${target.searchQuery}`);

  try {
    const placeId = await textSearchPlace(target.searchQuery, apiKey);
    if (!placeId) {
      const entry: CacheEntry = {
        place_id: null,
        fetched_at: new Date().toISOString(),
        search_query: target.searchQuery,
        place_details: null,
        photo_urls: [],
        error: "place not found",
      };
      cache[target.cacheKey] = entry;
      saveCache(cache);
      return entry;
    }

    const placeDetails = await fetchPlaceDetails(placeId, apiKey);
    const photoUrls: string[] = [];
    const photos = placeDetails.photos?.slice(0, MAX_PHOTOS) ?? [];

    for (const photo of photos) {
      const url = await resolvePhotoUrl(photo.photo_reference, apiKey);
      if (url) photoUrls.push(url);
      await sleep(150);
    }

    const entry: CacheEntry = {
      place_id: placeDetails.place_id,
      fetched_at: new Date().toISOString(),
      search_query: target.searchQuery,
      place_details: placeDetails,
      photo_urls: photoUrls,
    };

    cache[target.cacheKey] = entry;
    saveCache(cache);
    console.log(
      `  💾 Cache actualizado: ${target.cacheKey} (${photoUrls.length} fotos)`,
    );

    return entry;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.log(`  ⚠️  Places API falló: ${message.split("\n")[0]}`);
    const entry: CacheEntry = {
      place_id: null,
      fetched_at: new Date().toISOString(),
      search_query: target.searchQuery,
      place_details: null,
      photo_urls: [],
      error: message,
    };
    cache[target.cacheKey] = entry;
    saveCache(cache);
    return entry;
  }
}

async function uploadPhotosToStorage(
  placeId: string,
  photoUrls: string[],
): Promise<string[]> {
  if (!bucket) {
    throw new Error(
      "Storage no disponible sin service account. Configura GOOGLE_APPLICATION_CREDENTIALS.",
    );
  }

  const uploaded: string[] = [];

  for (let i = 0; i < photoUrls.length; i++) {
    const sourceUrl = photoUrls[i];
    console.log(`  📥 Descargando foto ${i + 1}/${photoUrls.length}...`);

    const response = await axios.get(sourceUrl, {
      responseType: "arraybuffer",
      headers: { "X-Ios-Bundle-Identifier": "com.playasrd.playasrd" },
      maxRedirects: 5,
    });

    const buffer = Buffer.from(response.data);
    const storagePath = `beaches/${placeId}/photo_${i}.jpg`;
    const file = bucket.file(storagePath);

    await file.save(buffer, {
      metadata: { contentType: "image/jpeg" },
    });

    uploaded.push(publicStorageUrl(storagePath));
    console.log(`  📤 Subida: ${storagePath}`);
  }

  return uploaded;
}

function buildBeachDocument(
  target: BeachTarget,
  entry: CacheEntry,
  imageUrls: string[],
): FirebaseFirestore.DocumentData {
  const desc = beachDescriptions[target.descriptionKey];
  if (!desc) {
    throw new Error(`Falta descripción hardcodeada para: ${target.descriptionKey}`);
  }

  const details = entry.place_details;
  const placeNotFound = !entry.place_id || !details;
  const inferredAmenities = inferAmenitiesFromPlace(details);
  const amenities = mergeAmenities(desc.amenities, inferredAmenities);
  const activities = mergeActivities(
    desc.activities,
    inferActivitiesFromPlace(details),
  );

  const latitude = placeNotFound ? 0 : (details.geometry?.location.lat ?? 0);
  const longitude = placeNotFound ? 0 : (details.geometry?.location.lng ?? 0);
  const address = details?.formatted_address ?? "";
  const displayName = details?.name ?? target.name;

  return {
    name: displayName,
    province: target.province,
    municipality: target.municipality,
    address,
    description: desc.es,
    descriptionEn: desc.en,
    latitude,
    longitude,
    imageUrls,
    rating: 0.0,
    reviewCount: 0,
    currentCondition: "Desconocido",
    amenities,
    activities,
    needsReview: placeNotFound,
    source: "google_places_import",
  };
}

async function processBeach(
  target: BeachTarget,
  apiKey: string,
  cache: PlacesCache,
): Promise<void> {
  stats.processed++;

  try {
    let entry = cache[target.cacheKey];

    if (entry && !FORCE) {
      console.log(`  📦 Usando cache: ${target.cacheKey}`);
    } else if (DRY_RUN && !entry) {
      console.log(`  [dry-run] Sin cache — en ejecución real se llamaría: ${target.searchQuery}`);
      stats.added++;
      console.log(`✅ ${target.name} → se agregaría (requiere fetch Places)`);
      return;
    } else if (DRY_RUN && FORCE) {
      console.log(`  [dry-run] --force re-fetch omitido en dry-run`);
      entry = cache[target.cacheKey];
      if (!entry) {
        stats.errors++;
        console.log(`❌ ${target.name} → error: sin cache para simular --force`);
        return;
      }
    } else {
      if (FORCE && entry) {
        console.log(`  🔄 --force: re-fetch ${target.cacheKey}`);
      }
      entry = await fetchPlaceData(target, apiKey, cache);
    }

    if (!entry) {
      throw new Error("No hay datos de Places ni en cache");
    }

    const placeId = entry.place_id;
    const docId = placeId ?? generateManualId(target.cacheKey);

    if (await documentExists(docId)) {
      console.log(`⏭️  ${target.name} → ya existe, omitida (${docId})`);
      stats.skipped++;
      return;
    }

    let imageUrls: string[] = [];

    if (placeId && entry.photo_urls.length > 0) {
      if (DRY_RUN) {
        console.log(
          `  [dry-run] Subiría ${entry.photo_urls.length} fotos a beaches/${placeId}/`,
        );
        imageUrls = entry.photo_urls.map(
          (_, i) => publicStorageUrl(`beaches/${placeId}/photo_${i}.jpg`),
        );
      } else {
        imageUrls = await uploadPhotosToStorage(placeId, entry.photo_urls);
      }
    } else if (!placeId) {
      const reason = entry.error?.includes("Billing")
        ? "sin Places (billing no habilitado) — coords 0, needsReview"
        : "Place not found — coords 0, needsReview";
      console.log(`  ⚠️  ${reason}`);
    }

    const document = buildBeachDocument(target, entry, imageUrls);

    if (DRY_RUN) {
      console.log(`  [dry-run] Crearía doc ${docId}:`, {
        name: document.name,
        province: document.province,
        latitude: document.latitude,
        longitude: document.longitude,
        photos: imageUrls.length,
        needsReview: document.needsReview,
      });
    } else {
      await writeDocument(docId, document);
    }

    console.log(`✅ ${target.name} → ${DRY_RUN ? "se agregaría" : "agregada"} (${docId})`);
    stats.added++;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.log(`❌ ${target.name} → error: ${message}`);
    stats.errors++;
  }
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main(): Promise<void> {
  console.log(`\n=== Importar nuevas playas — ${PROJECT_ID} ===\n`);
  if (DRY_RUN) console.log("Modo: DRY-RUN (sin escrituras)\n");
  if (FORCE) console.log("Modo: FORCE (ignorar cache de Places)\n");

  loadEnvironment();
  const apiKey = getPlacesApiKey();
  initFirebase();
  await ensureWriteConnection();

  const cache = loadCache();

  for (const target of BEACH_TARGETS) {
    console.log(`\n--- ${target.name} (${target.province}) ---`);
    await processBeach(target, apiKey, cache);
    await sleep(200);
  }

  console.log("\n=== Resumen ===");
  console.log(
    `Total: ${stats.processed} procesadas | ${stats.added} agregadas | ${stats.skipped} omitidas | ${stats.errors} errores`,
  );
  console.log(`Cache guardado en ${CACHE_PATH}`);

  if (!DRY_RUN && stats.added > 0) {
    console.log(
      "\nRegenerar beach_service.dart:\n  dart run lib/scripts/sync_firestore_to_beach_service.dart",
    );
  }
}

main().catch((error) => {
  console.error("\nError fatal:", error);
  process.exit(1);
});
