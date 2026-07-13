/**
 * Enriquece las 19 playas `manual-*` en Firestore con datos de Google Places.
 *
 * Actualiza el documento existente (no crea uno nuevo ni cambia el ID),
 * para no romper favoritos ni referencias.
 *
 * Ejecutar desde scripts/:
 *   npx ts-node enrich-manual-beaches.ts --dry-run
 *   npx ts-node enrich-manual-beaches.ts
 *   npx ts-node enrich-manual-beaches.ts --force
 *   npx ts-node enrich-manual-beaches.ts --delete-duplicate
 *   npx ts-node enrich-manual-beaches.ts --only=manual-playa-cabo-rojo
 *
 * Variables de entorno (.env en la raíz del repo):
 *   GOOGLE_MAPS_API_KEY
 *   GOOGLE_APPLICATION_CREDENTIALS  (opcional; necesario para subir fotos a Storage)
 *
 * Credenciales Firestore (una de estas):
 *   1. firebase login
 *   2. GOOGLE_APPLICATION_CREDENTIALS
 *   3. gcloud auth application-default login
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
const DELETE_DUPLICATE = process.argv.includes("--delete-duplicate");
const ONLY = process.argv.find((arg) => arg.startsWith("--only="))?.split("=")[1];
const MAX_PHOTOS = 5;

const DUPLICATE_DOC_ID = "manual-playa-diamante";
const DUPLICATE_KEEP_ID = "manual-playa-diamante-nagua";

interface Amenities {
  baños: boolean;
  duchas: boolean;
  parking: boolean;
  restaurantes: boolean;
  sombrillas: boolean;
  salvavidas: boolean;
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

interface ManualBeachTarget {
  docId: string;
  cacheKey: string;
  searchQuery: string;
  name: string;
  province: string;
  municipality: string;
}

/** Configuración de búsqueda Places por docId (18 playas + duplicado). */
const MANUAL_BEACH_CONFIG: Record<string, Omit<ManualBeachTarget, "docId">> = {
  "manual-playa-grande-del-sur": {
    cacheKey: "Playa Grande del Sur",
    searchQuery: "Playa Grande Barahona Dominican Republic",
    name: "Playa Grande del Sur",
    province: "Barahona",
    municipality: "Barahona",
  },
  "manual-playa-quita-coraza": {
    cacheKey: "Playa Quita Coraza",
    searchQuery: "Playa Quita Coraza Barahona Dominican Republic",
    name: "Playa Quita Coraza",
    province: "Barahona",
    municipality: "Barahona",
  },
  "manual-playa-bavaro-miches": {
    cacheKey: "Playa Bavaro Miches",
    searchQuery: "Playa Honda El Seibo Dominican Republic",
    name: "Playa Bavaro Miches",
    province: "El Seibo",
    municipality: "El Seibo",
  },
  "manual-playa-esmeralda": {
    cacheKey: "Playa Esmeralda",
    searchQuery: "Playa Esmeralda El Seibo Dominican Republic",
    name: "Playa Esmeralda",
    province: "El Seibo",
    municipality: "El Seibo",
  },
  "manual-playa-miches": {
    cacheKey: "Playa Miches",
    searchQuery: "Playa Miches Hato Mayor Dominican Republic",
    name: "Playa Miches",
    province: "Hato Mayor",
    municipality: "Miches",
  },
  "manual-playa-blanca-bayahibe": {
    cacheKey: "Playa Blanca Bayahibe",
    searchQuery: "Playa Blanca Bayahibe Dominican Republic",
    name: "Playa Blanca Bayahibe",
    province: "La Romana",
    municipality: "Bayahibe",
  },
  "manual-playa-dominicus-americanus": {
    cacheKey: "Playa Dominicus Americanus",
    searchQuery: "Playa Dominicus Americanus La Romana Dominican Republic",
    name: "Playa Dominicus Americanus",
    province: "La Romana",
    municipality: "Bayahibe",
  },
  "manual-playa-diamante-nagua": {
    cacheKey: "Playa Diamante Nagua",
    searchQuery: "Playa Diamante Nagua Dominican Republic",
    name: "Playa Diamante",
    province: "María Trinidad Sánchez",
    municipality: "Nagua",
  },
  "manual-playa-jackson": {
    cacheKey: "Playa Jackson",
    searchQuery: "Playa Jackson Cabrera Dominican Republic",
    name: "Playa Jackson",
    province: "María Trinidad Sánchez",
    municipality: "Cabrera",
  },
  "manual-playa-magante": {
    cacheKey: "Playa Magante",
    searchQuery: "Playa Magante Rio San Juan Dominican Republic",
    name: "Playa Magante",
    province: "María Trinidad Sánchez",
    municipality: "Río San Juan",
  },
  "manual-playa-juan-de-bolanos": {
    cacheKey: "Playa Juan de Bolaños",
    searchQuery: "Playa Juan de Bolanos Monte Cristi Dominican Republic",
    name: "Playa Juan de Bolaños",
    province: "Monte Cristi",
    municipality: "Monte Cristi",
  },
  "manual-playa-manzanillo": {
    cacheKey: "Playa Manzanillo",
    searchQuery: "Playa Manzanillo Monte Cristi Dominican Republic",
    name: "Playa Manzanillo",
    province: "Monte Cristi",
    municipality: "Monte Cristi",
  },
  "manual-playa-cabo-rojo": {
    cacheKey: "Playa Cabo Rojo",
    searchQuery: "Playa Cabo Rojo Pedernales Dominican Republic",
    name: "Playa Cabo Rojo",
    province: "Pedernales",
    municipality: "Pedernales",
  },
  "manual-playa-trudille": {
    cacheKey: "Playa Trudillé",
    searchQuery: "Playa Trudillé Pedernales Dominican Republic",
    name: "Playa Trudillé",
    province: "Pedernales",
    municipality: "Pedernales",
  },
  "manual-bahia-de-portillo": {
    cacheKey: "Bahía de Portillo",
    searchQuery: "Bahia de Portillo Dominican Republic",
    name: "Bahía de Portillo",
    province: "Samaná",
    municipality: "Samaná",
  },
  "manual-playa-diamante-samana": {
    cacheKey: "Playa Diamante Samaná",
    searchQuery: "Playa Diamante Samana Dominican Republic",
    name: "Playa Diamante",
    province: "Samaná",
    municipality: "Samaná",
  },
  "manual-playa-limon": {
    cacheKey: "Playa Limón",
    searchQuery: "Playa Limon Samana Dominican Republic",
    name: "Playa Limón",
    province: "Samaná",
    municipality: "Samaná",
  },
  "manual-playa-moron": {
    cacheKey: "Playa Morón",
    searchQuery: "Playa Moron Samana Dominican Republic",
    name: "Playa Morón",
    province: "Samaná",
    municipality: "Samaná",
  },
};

const MANUAL_BEACHES: ManualBeachTarget[] = Object.entries(MANUAL_BEACH_CONFIG).map(
  ([docId, config]) => ({ docId, ...config }),
);

const stats = {
  processed: 0,
  enriched: 0,
  skipped: 0,
  errors: 0,
  deleted: 0,
};

let db: FirebaseFirestore.Firestore | null = null;
let bucket: ReturnType<admin.storage.Storage["bucket"]> | null = null;
let useAdminSdk = false;
let restAccessToken: string | null = null;
let placesApiKey = "";
let webApiKey: string | null = null;

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
    "No se encontró API key. Define GOOGLE_MAPS_API_KEY en .env",
  );
}

function getWebApiKey(): string {
  if (webApiKey) return webApiKey;
  const optionsPath = path.join(__dirname, "..", "lib", "firebase_options.dart");
  const content = fs.readFileSync(optionsPath, "utf8");
  const match = content.match(/apiKey:\s*'([^']+)'/);
  if (!match) {
    throw new Error("No se encontró apiKey en lib/firebase_options.dart");
  }
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

async function listManualDocIdsInFirestore(): Promise<string[]> {
  const apiKey = getWebApiKey();
  const ids: string[] = [];
  let pageToken = "";

  do {
    const query = pageToken
      ? `${COLLECTION}?pageSize=300&pageToken=${encodeURIComponent(pageToken)}&key=${apiKey}`
      : `${COLLECTION}?pageSize=300&key=${apiKey}`;
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${query}`;
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`REST list failed: ${response.status} ${await response.text()}`);
    }
    const payload = (await response.json()) as {
      documents?: Array<{ name: string }>;
      nextPageToken?: string;
    };
    for (const doc of payload.documents ?? []) {
      const id = doc.name.split("/").pop() ?? "";
      if (id.startsWith("manual-")) ids.push(id);
    }
    pageToken = payload.nextPageToken ?? "";
  } while (pageToken);

  return ids.sort();
}

function resolveTargets(existingManualIds: string[]): ManualBeachTarget[] {
  const inFirestore = new Set(existingManualIds);
  const configuredIds = new Set(MANUAL_BEACHES.map((b) => b.docId));

  const missingInFirestore = MANUAL_BEACHES.filter((b) => !inFirestore.has(b.docId));
  if (missingInFirestore.length > 0) {
    console.log(
      `⚠️  ${missingInFirestore.length} playa(s) en config pero no en Firestore (importar primero con add-new-beaches.ts):`,
    );
    for (const beach of missingInFirestore) {
      console.log(`   - ${beach.docId} (${beach.name})`);
    }
    console.log("");
  }

  const unknownInFirestore = existingManualIds.filter(
    (id) => !configuredIds.has(id) && id !== DUPLICATE_DOC_ID,
  );
  if (unknownInFirestore.length > 0) {
    console.log(
      `⚠️  ${unknownInFirestore.length} doc(s) manual-* en Firestore sin config de Places:`,
    );
    for (const id of unknownInFirestore) console.log(`   - ${id}`);
    console.log("");
  }

  let targets = MANUAL_BEACHES.filter((b) => inFirestore.has(b.docId));
  if (ONLY) {
    targets = targets.filter((t) => t.docId === ONLY);
    if (targets.length === 0) {
      throw new Error(
        `--only=${ONLY} no existe en Firestore o no tiene config de búsqueda`,
      );
    }
  }
  return targets;
}

async function getDocumentPublic(
  docId: string,
): Promise<FirebaseFirestore.DocumentData | null> {
  const apiKey = getWebApiKey();
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${COLLECTION}/${encodeURIComponent(docId)}?key=${apiKey}`;
  const response = await fetch(url);
  if (response.status === 404) return null;
  if (!response.ok) {
    throw new Error(`REST read failed: ${response.status} ${await response.text()}`);
  }

  const doc = (await response.json()) as {
    fields?: Record<string, Record<string, unknown>>;
  };
  const result: FirebaseFirestore.DocumentData = {};
  for (const [key, wrapped] of Object.entries(doc.fields ?? {})) {
    result[key] = parseFirestoreValue(wrapped);
  }
  return result;
}

async function getDocument(
  docId: string,
): Promise<FirebaseFirestore.DocumentData | null> {
  return getDocumentPublic(docId);
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
    for (const [k, v] of Object.entries(mapFields)) {
      obj[k] = parseFirestoreValue(v);
    }
    return obj;
  }
  return null;
}

async function updateDocument(
  docId: string,
  fields: Record<string, unknown>,
): Promise<void> {
  if (DRY_RUN) {
    console.log(`  [dry-run] PATCH ${docId}:`, fields);
    return;
  }

  if (useAdminSdk && db) {
    await db
      .collection(COLLECTION)
      .doc(docId)
      .update({
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
    throw new Error(`REST patch ${docId} failed: ${response.status} ${await response.text()}`);
  }
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
    throw new Error(`REST delete ${docId} failed: ${response.status} ${await response.text()}`);
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

function buildPlacesPhotoUrl(photoReference: string): string {
  const params = new URLSearchParams({
    maxwidth: "1200",
    photo_reference: photoReference,
    key: placesApiKey,
  });
  return `https://maps.googleapis.com/maps/api/place/photo?${params.toString()}`;
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

function mergeAmenities(
  existing: Record<string, boolean>,
  inferred: Partial<Amenities>,
): Record<string, boolean> {
  const defaults: Amenities = {
    baños: false,
    duchas: false,
    parking: false,
    restaurantes: false,
    sombrillas: false,
    salvavidas: false,
  };
  return {
    ...defaults,
    ...existing,
    ...inferred,
  };
}

function mergeActivities(existing: string[], inferred: string[]): string[] {
  return Array.from(new Set([...existing, ...inferred]));
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

function needsEnrichment(data: FirebaseFirestore.DocumentData): boolean {
  const lat = Number(data.latitude ?? 0);
  const lng = Number(data.longitude ?? 0);
  const imageUrls = Array.isArray(data.imageUrls) ? data.imageUrls : [];
  return (lat === 0 && lng === 0) || imageUrls.length === 0;
}

async function textSearchPlace(query: string): Promise<string | null> {
  const response = await axios.get(
    "https://maps.googleapis.com/maps/api/place/textsearch/json",
    { params: { query, key: placesApiKey } },
  );

  const data = response.data as {
    status: string;
    results?: Array<{ place_id: string }>;
    error_message?: string;
  };

  if (data.status !== "OK" || !data.results?.length) {
    if (data.status === "ZERO_RESULTS") return null;
    throw new Error(data.error_message ?? `Text Search status: ${data.status}`);
  }

  return data.results[0].place_id;
}

async function fetchPlaceDetails(placeId: string): Promise<PlaceDetails> {
  const response = await axios.get(
    "https://maps.googleapis.com/maps/api/place/details/json",
    {
      params: {
        place_id: placeId,
        fields:
          "place_id,name,formatted_address,geometry,rating,user_ratings_total,photos,types",
        key: placesApiKey,
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

async function resolvePhotoUrl(photoReference: string): Promise<string | null> {
  try {
    await axios.get("https://maps.googleapis.com/maps/api/place/photo", {
      params: {
        maxwidth: 1200,
        photo_reference: photoReference,
        key: placesApiKey,
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
  target: ManualBeachTarget,
  cache: PlacesCache,
): Promise<CacheEntry> {
  console.log(`  🔍 Google Places: ${target.searchQuery}`);

  try {
    const placeId = await textSearchPlace(target.searchQuery);
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

    const placeDetails = await fetchPlaceDetails(placeId);
    const photoUrls: string[] = [];
    const photos = placeDetails.photos?.slice(0, MAX_PHOTOS) ?? [];

    for (const photo of photos) {
      const url = await resolvePhotoUrl(photo.photo_reference);
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
    console.log(`  💾 Cache: ${photoUrls.length} fotos, place_id=${placeDetails.place_id}`);
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
  docId: string,
  photoUrls: string[],
): Promise<string[]> {
  if (!bucket) return [];

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
    const storagePath = `beaches/${docId}/photo_${i}.jpg`;
    const file = bucket.file(storagePath);

    await file.save(buffer, {
      metadata: { contentType: "image/jpeg" },
    });

    uploaded.push(publicStorageUrl(storagePath));
    console.log(`  📤 Subida: ${storagePath}`);
  }

  return uploaded;
}

function buildImageUrls(
  docId: string,
  entry: CacheEntry,
  uploadedUrls: string[],
): string[] {
  if (uploadedUrls.length > 0) return uploadedUrls;

  const details = entry.place_details;
  if (!details?.photos?.length) return [];

  console.log(
    "  ℹ️  Sin Storage — usando URLs de Google Places (la app las soporta)",
  );
  return details.photos
    .slice(0, MAX_PHOTOS)
    .map((photo) => buildPlacesPhotoUrl(photo.photo_reference));
}

async function processBeach(
  target: ManualBeachTarget,
  cache: PlacesCache,
): Promise<void> {
  stats.processed++;

  try {
    const existing = await getDocument(target.docId);
    if (!existing) {
      console.log(`⏭️  ${target.name} → documento no existe (${target.docId})`);
      stats.skipped++;
      return;
    }

    if (!FORCE && !needsEnrichment(existing)) {
      console.log(`⏭️  ${target.name} → ya enriquecida (${target.docId})`);
      stats.skipped++;
      return;
    }

    let entry = cache[target.cacheKey];
    const cacheHasPlaces =
      entry?.place_id && entry.place_details && !entry.error?.includes("Billing");

    if (FORCE || !cacheHasPlaces) {
      if (DRY_RUN && !FORCE) {
        console.log(
          `  [dry-run] Re-fetch Places omitido (usa --force para simular con cache actual)`,
        );
      } else if (!DRY_RUN || FORCE) {
        entry = await fetchPlaceData(target, cache);
      }
    } else {
      console.log(`  📦 Usando cache: ${target.cacheKey}`);
    }

    if (!entry) {
      throw new Error("Sin datos de Places");
    }

    const details = entry.place_details;
    if (!entry.place_id || !details) {
      console.log(
        `❌ ${target.name} → Places no encontró datos (${entry.error ?? "sin place_id"})`,
      );
      stats.errors++;
      return;
    }

    const latitude = details.geometry?.location.lat ?? 0;
    const longitude = details.geometry?.location.lng ?? 0;
    if (latitude === 0 && longitude === 0) {
      console.log(`❌ ${target.name} → coordenadas inválidas en Places`);
      stats.errors++;
      return;
    }

    let imageUrls: string[] = [];
    if (entry.photo_urls.length > 0) {
      if (DRY_RUN) {
        imageUrls = entry.photo_urls.map((_, i) =>
          publicStorageUrl(`beaches/${target.docId}/photo_${i}.jpg`),
        );
        console.log(`  [dry-run] Subiría ${entry.photo_urls.length} fotos`);
      } else {
        const uploaded = await uploadPhotosToStorage(target.docId, entry.photo_urls);
        imageUrls = buildImageUrls(target.docId, entry, uploaded);
      }
    } else if (details.photos?.length) {
      imageUrls = buildImageUrls(target.docId, entry, []);
    }

    const existingAmenities = (existing.amenities ?? {}) as Record<string, boolean>;
    const existingActivities = Array.isArray(existing.activities)
      ? (existing.activities as string[])
      : [];

    const updateFields: Record<string, unknown> = {
      latitude,
      longitude,
      address: details.formatted_address ?? "",
      rating: details.rating ?? 0,
      reviewCount: details.user_ratings_total ?? 0,
      imageUrls,
      amenities: mergeAmenities(
        existingAmenities,
        inferAmenitiesFromPlace(details),
      ),
      activities: mergeActivities(
        existingActivities,
        inferActivitiesFromPlace(details),
      ),
      needsReview: false,
      enrichedFrom: "google_places",
      googlePlaceId: details.place_id,
    };

    if (details.name && details.name !== target.name) {
      updateFields.name = details.name;
    }

    await updateDocument(target.docId, updateFields);

    console.log(
      `✅ ${target.name} → enriquecida (${target.docId}) | coords: ${latitude}, ${longitude} | fotos: ${imageUrls.length}`,
    );
    stats.enriched++;
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    console.log(`❌ ${target.name} → error: ${message}`);
    stats.errors++;
  }
}

async function deleteDuplicateIfRequested(): Promise<void> {
  if (!DELETE_DUPLICATE) return;

  console.log("\n--- Eliminar duplicado ---\n");
  const duplicate = await getDocument(DUPLICATE_DOC_ID);
  if (!duplicate) {
    console.log(`[SKIP] ${DUPLICATE_DOC_ID} no existe`);
    return;
  }

  const keeper = await getDocument(DUPLICATE_KEEP_ID);
  if (!keeper) {
    console.log(
      `[SKIP] No se elimina ${DUPLICATE_DOC_ID} — falta el documento canónico ${DUPLICATE_KEEP_ID}`,
    );
    return;
  }

  await deleteDocument(DUPLICATE_DOC_ID);
  console.log(
    `🗑️  Eliminado ${DUPLICATE_DOC_ID} (duplicado de ${DUPLICATE_KEEP_ID})`,
  );
  stats.deleted++;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main(): Promise<void> {
  console.log(`\n=== Enriquecer playas manual-* — ${PROJECT_ID} ===\n`);
  if (DRY_RUN) console.log("Modo: DRY-RUN (sin escrituras)\n");
  if (FORCE) console.log("Modo: FORCE (re-fetch Places, ignorar cache con errores)\n");
  if (DELETE_DUPLICATE) {
    console.log(`Modo: DELETE-DUPLICATE (eliminar ${DUPLICATE_DOC_ID})\n`);
  }
  if (ONLY) console.log(`Filtro: solo ${ONLY}\n`);

  loadEnvironment();
  placesApiKey = getPlacesApiKey();
  initFirebase();
  await ensureWriteConnection();

  const cache = loadCache();
  const existingManualIds = await listManualDocIdsInFirestore();
  console.log(
    `En Firestore: ${existingManualIds.length} doc(s) manual-* | Config: ${MANUAL_BEACHES.length} playa(s)\n`,
  );

  const targets = resolveTargets(existingManualIds);

  await deleteDuplicateIfRequested();

  console.log(`\nProcesando ${targets.length} playa(s)...\n`);

  for (const target of targets) {
    console.log(`--- ${target.name} (${target.province}) [${target.docId}] ---`);
    await processBeach(target, cache);
    await sleep(200);
  }

  console.log("\n=== Resumen ===");
  console.log(
    `Procesadas: ${stats.processed} | Enriquecidas: ${stats.enriched} | Omitidas: ${stats.skipped} | Errores: ${stats.errors} | Eliminadas: ${stats.deleted}`,
  );
  console.log(`Cache: ${CACHE_PATH}`);
  if (!bucket && !DRY_RUN) {
    console.log(
      "\nNota: sin GOOGLE_APPLICATION_CREDENTIALS las fotos se guardan como URLs de Google Places.",
    );
  }
  console.log("");
}

main().catch((error) => {
  console.error("\nError:", error);
  process.exit(1);
});
