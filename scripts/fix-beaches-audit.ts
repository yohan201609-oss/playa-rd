/**
 * Auditoría y corrección de la colección `beaches` en Firestore.
 *
 * Proyecto: playas-rd-2b475
 *
 * Ejecutar:
 *   cd scripts
 *   npm install
 *   npx ts-node fix-beaches-audit.ts
 *
 * Modo simulación (sin escribir):
 *   npx ts-node fix-beaches-audit.ts --dry-run
 *
 * Credenciales (una de estas):
 *   1. gcloud auth application-default login
 *   2. set GOOGLE_APPLICATION_CREDENTIALS=ruta\service-account.json
 *   3. firebase login  (sesión CLI como respaldo automático)
 */

import * as admin from "firebase-admin";
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import { OAuth2Client } from "google-auth-library";

const PROJECT_ID = "playas-rd-2b475";
const COLLECTION = "beaches";
const BACKUP_PATH = path.join(__dirname, "deleted-beaches-backup.json");
const DRY_RUN = process.argv.includes("--dry-run");
const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

interface BeachRecord {
  id: string;
  data: FirebaseFirestore.DocumentData;
}

interface PendingDelete {
  id: string;
  reason: string;
  keptId: string;
  data: FirebaseFirestore.DocumentData;
}

interface PendingUpdate {
  id: string;
  fields: Record<string, unknown>;
  reason: string;
}

const stats = {
  modified: 0,
  deleted: 0,
  needsReviewMarked: 0,
};

let db: FirebaseFirestore.Firestore | null = null;
let restAccessToken: string | null = null;
let useAdminSdk = false;
let webApiKey: string | null = null;

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

function initFirebaseAdmin(): void {
  if (admin.apps.length > 0) return;

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
    // Se usará REST OAuth (firebase login) para escrituras.
  }
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
  console.log("Usando sesión firebase login (REST API) para escrituras.\n");
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
    throw new Error(
      "No se encontró firebase-tools.json. Ejecuta: firebase login\n" +
        "O define GOOGLE_APPLICATION_CREDENTIALS / FIRESTORE_ACCESS_TOKEN.",
    );
  }

  const config = JSON.parse(fs.readFileSync(configPath, "utf8")) as {
    tokens?: {
      refresh_token?: string;
      access_token?: string;
      expires_at?: number;
    };
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

async function restFetch(pathSuffix: string, init?: RequestInit): Promise<Response> {
  if (!restAccessToken) {
    throw new Error("REST API no inicializada");
  }
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
    return {
      arrayValue: {
        values: value.map((item) => toFirestoreValue(item)),
      },
    };
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

function parseFirestoreDocument(
  doc: Record<string, unknown>,
): FirebaseFirestore.DocumentData {
  const fields = (doc.fields ?? {}) as Record<string, Record<string, unknown>>;
  const result: FirebaseFirestore.DocumentData = {};
  for (const [key, wrapped] of Object.entries(fields)) {
    result[key] = parseFirestoreValue(wrapped);
  }
  return result;
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

async function loadAllBeachesPublic(): Promise<BeachRecord[]> {
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
      throw new Error(`REST read failed: ${response.status} ${await response.text()}`);
    }
    const payload = (await response.json()) as {
      documents?: Array<{ name: string; fields: Record<string, unknown> }>;
      nextPageToken?: string;
    };
    for (const doc of payload.documents ?? []) {
      const id = doc.name.split("/").pop() ?? "";
      beaches.push({ id, data: parseFirestoreDocument(doc) });
    }
    pageToken = payload.nextPageToken ?? "";
  } while (pageToken);

  return beaches;
}

async function restPatchDocument(
  id: string,
  fields: Record<string, unknown>,
): Promise<void> {
  const fieldPaths = Object.keys(fields);
  const body = {
    fields: Object.fromEntries(
      Object.entries(fields).map(([k, v]) => [k, toFirestoreValue(v)]),
    ),
  };
  const query = fieldPaths.map((f) => `updateMask.fieldPaths=${f}`).join("&");
  const response = await restFetch(`${COLLECTION}/${encodeURIComponent(id)}?${query}`, {
    method: "PATCH",
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    throw new Error(`REST patch ${id} failed: ${response.status} ${await response.text()}`);
  }
}

async function restDeleteDocument(id: string): Promise<void> {
  const response = await restFetch(`${COLLECTION}/${encodeURIComponent(id)}`, {
    method: "DELETE",
  });
  if (!response.ok) {
    throw new Error(`REST delete ${id} failed: ${response.status} ${await response.text()}`);
  }
}

function completenessScore(data: FirebaseFirestore.DocumentData): number {
  let score = 0;
  const description = String(data.description ?? "");
  const descriptionEn = String(data.descriptionEn ?? "");
  const imageUrls = Array.isArray(data.imageUrls) ? data.imageUrls : [];
  const amenities = (data.amenities ?? {}) as Record<string, boolean>;

  if (description && description !== "Hermosa playa en República Dominicana") {
    score += description.length;
  }
  if (descriptionEn && !descriptionEn.includes("[AUTO-TRANSLATED]")) {
    score += descriptionEn.length;
  }
  score += imageUrls.length * 100;
  score += Object.values(amenities).filter(Boolean).length * 10;
  score += Number(data.reviewCount ?? 0) * 5;
  score += Number(data.rating ?? 0) * 10;

  const municipality = String(data.municipality ?? "");
  if (municipality && municipality !== "República Dominicana") {
    score += 50;
  }
  if (data.postalCode) score += 20;
  if (data.address) score += 10;

  return score;
}

function coordsMatch(
  a: FirebaseFirestore.DocumentData,
  b: FirebaseFirestore.DocumentData,
  toleranceMeters = 50,
): boolean {
  const latA = Number(a.latitude);
  const lngA = Number(a.longitude);
  const latB = Number(b.latitude);
  const lngB = Number(b.longitude);
  if ([latA, lngA, latB, lngB].some((v) => Number.isNaN(v))) return false;

  const dLat = ((latB - latA) * Math.PI) / 180;
  const dLng = ((lngB - lngA) * Math.PI) / 180;
  const sinLat = Math.sin(dLat / 2);
  const sinLng = Math.sin(dLng / 2);
  const h =
    sinLat * sinLat +
    Math.cos((latA * Math.PI) / 180) *
      Math.cos((latB * Math.PI) / 180) *
      sinLng *
      sinLng;
  const distanceMeters = 6371000 * 2 * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
  return distanceMeters <= toleranceMeters;
}

function isGenericSpanishDescription(description: unknown): boolean {
  const text = String(description ?? "").trim();
  return text === "Hermosa playa en República Dominicana";
}

function needsAutoTranslationReview(descriptionEn: unknown): boolean {
  const text = String(descriptionEn ?? "");
  return (
    text.includes("[AUTO-TRANSLATED]") ||
    text.includes("Note: This is an automatic placeholder")
  );
}

function normalizeName(name: unknown): string {
  return String(name ?? "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .trim();
}

async function loadAllBeaches(): Promise<BeachRecord[]> {
  return loadAllBeachesPublic();
}

function pickDuplicateWinner(
  a: BeachRecord,
  b: BeachRecord,
): { keep: BeachRecord; remove: BeachRecord } {
  const scoreA = completenessScore(a.data);
  const scoreB = completenessScore(b.data);
  if (scoreA === scoreB) {
    // Prefer numeric IDs over Google Place IDs when tied.
    const aNumeric = /^\d+$/.test(a.id);
    const bNumeric = /^\d+$/.test(b.id);
    if (aNumeric && !bNumeric) return { keep: a, remove: b };
    if (bNumeric && !aNumeric) return { keep: b, remove: a };
    return scoreA >= scoreB ? { keep: a, remove: b } : { keep: b, remove: a };
  }
  return scoreA > scoreB ? { keep: a, remove: b } : { keep: b, remove: a };
}

async function commitBatches(
  updates: PendingUpdate[],
  deletes: PendingDelete[],
): Promise<void> {
  if (DRY_RUN) {
    console.log("\n[DRY-RUN] No se escribió nada en Firestore.\n");
    return;
  }

  if (useAdminSdk && db) {
    const operations: Array<{ type: "update" | "delete"; payload: PendingUpdate | PendingDelete }> =
      [
        ...updates.map((u) => ({ type: "update" as const, payload: u })),
        ...deletes.map((d) => ({ type: "delete" as const, payload: d })),
      ];

    for (let i = 0; i < operations.length; i += 450) {
      const chunk = operations.slice(i, i + 450);
      const batch = db.batch();
      for (const op of chunk) {
        const ref = db.collection(COLLECTION).doc(op.payload.id);
        if (op.type === "update") {
          const update = op.payload as PendingUpdate;
          batch.update(ref, {
            ...update.fields,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          batch.delete(ref);
        }
      }
      await batch.commit();
    }
    return;
  }

  if (!restAccessToken) {
    throw new Error("Sin token de escritura");
  }

  for (const update of updates) {
    await restPatchDocument(update.id, {
      ...update.fields,
      lastUpdated: new Date().toISOString(),
    });
  }
  for (const del of deletes) {
    await restDeleteDocument(del.id);
  }
}

async function main(): Promise<void> {
  console.log(`\n=== Auditoría de playas — ${PROJECT_ID}${DRY_RUN ? " [DRY-RUN]" : ""} ===\n`);

  initFirebaseAdmin();
  await ensureWriteConnection();

  const beaches = await loadAllBeaches();
  const byId = new Map(beaches.map((b) => [b.id, b]));

  const pendingUpdates: PendingUpdate[] = [];
  const pendingDeletes: PendingDelete[] = [];
  const needsReviewIds = new Set<string>();

  const queueUpdate = (
    id: string,
    fields: Record<string, unknown>,
    reason: string,
  ): void => {
    pendingUpdates.push({ id, fields, reason });
    console.log(`[UPDATE] ${id} — ${reason}`);
    for (const [key, value] of Object.entries(fields)) {
      console.log(`         ${key}: ${JSON.stringify(value)}`);
    }
  };

  const queueDelete = (
    remove: BeachRecord,
    keptId: string,
    reason: string,
  ): void => {
    pendingDeletes.push({
      id: remove.id,
      reason,
      keptId,
      data: remove.data,
    });
    console.log(`[DELETE] ${remove.id} (${remove.data.name}) — ${reason}`);
    console.log(`         conservado: ${keptId}`);
  };

  // -------------------------------------------------------------------------
  // 1. DUPLICADOS DE NOMBRE / COORDENADAS
  // -------------------------------------------------------------------------
  console.log("\n--- 1. Duplicados ---\n");

  const rinconA = byId.get("3");
  const rinconB = byId.get("ChIJ14BumiHdro4RvJgeYl2_UT8");
  if (rinconA && rinconB) {
    const { keep, remove } = pickDuplicateWinner(rinconA, rinconB);
    queueDelete(
      remove,
      keep.id,
      `Duplicado de Playa Rincón/Rincon (scores ${completenessScore(rinconA.data)} vs ${completenessScore(rinconB.data)})`,
    );
  } else {
    console.log("[SKIP] Duplicado Playa Rincón — documento(s) no encontrado(s)");
  }

  const sanRafaelA = byId.get("18");
  const sanRafaelB = byId.get("ChIJteUKNQD5uo4RrFGLR4RwG6s");
  if (sanRafaelA && sanRafaelB) {
    if (coordsMatch(sanRafaelA.data, sanRafaelB.data)) {
      const { keep, remove } = pickDuplicateWinner(sanRafaelA, sanRafaelB);
      queueDelete(
        remove,
        keep.id,
        `Duplicado San Rafael por coordenadas (scores ${completenessScore(sanRafaelA.data)} vs ${completenessScore(sanRafaelB.data)})`,
      );
    } else {
      console.log(
        "[SKIP] San Rafael / Playa San Rafael — coordenadas no coinciden, revisión manual",
      );
    }
  }

  const laCaleta17 = byId.get("17");
  const playaLaCaleta = byId.get("ChIJH7tRYNNVr44R0jbcfa9TBfU");
  if (playaLaCaleta) {
    const copiedFrom17 =
      laCaleta17 &&
      String(playaLaCaleta.data.description ?? "") ===
        String(laCaleta17.data.description ?? "");
    const address = String(playaLaCaleta.data.address ?? "");
    const pointsToLaRomana =
      address.includes("La Romana") ||
      Number(playaLaCaleta.data.longitude) > -69.5;

    if (copiedFrom17 && pointsToLaRomana) {
      queueDelete(
        playaLaCaleta,
        "17",
        "Registro corrupto: descripción copiada de La Caleta (17) con coordenadas/dirección en La Romana",
      );
    } else {
      console.log(
        "[SKIP] Playa la Caleta — no cumple criterio de corrupción automática",
      );
    }
  }

  // -------------------------------------------------------------------------
  // 2. DUPLICADOS DE COORDENADAS
  // -------------------------------------------------------------------------
  console.log("\n--- 2. Coordenadas duplicadas / incorrectas ---\n");

  // Valores verificados en historial git (001a0ae) antes de la corrupción por geocoding.
  const coordinateFixes: Array<{
    id: string;
    latitude: number;
    longitude: number;
    reason: string;
  }> = [
    {
      id: "51",
      latitude: 18.415,
      longitude: -69.44,
      reason: "Restaurar ubicación de Playa Metro (distinta de El Embarcadero)",
    },
    {
      id: "59",
      latitude: 18.42,
      longitude: -69.43,
      reason: "Restaurar ubicación de Playa El Embarcadero",
    },
    {
      id: "54",
      latitude: 18.395,
      longitude: -69.37,
      reason: "Restaurar ubicación de Playa Nueva Romana",
    },
    {
      id: "60",
      latitude: 18.375,
      longitude: -69.35,
      reason: "Restaurar ubicación de Playa La Romana Bay",
    },
    {
      id: "55",
      latitude: 18.435,
      longitude: -69.46,
      reason:
        "Corregir coordenadas erróneas (noroeste RD) — Playa Los Coquitos, San Pedro de Macorís",
    },
    {
      id: "58",
      latitude: 18.445,
      longitude: -69.31,
      reason:
        "Corregir coordenadas erróneas (zona Boca Chica) — Playa Los Pescadores, San Pedro de Macorís",
    },
  ];

  for (const fix of coordinateFixes) {
    const doc = byId.get(fix.id);
    if (!doc) {
      console.log(`[SKIP] Coordenadas — no existe ID ${fix.id}`);
      continue;
    }
    queueUpdate(
      fix.id,
      { latitude: fix.latitude, longitude: fix.longitude },
      fix.reason,
    );
  }

  // -------------------------------------------------------------------------
  // 3. PROVINCIA INCORRECTA
  // -------------------------------------------------------------------------
  console.log("\n--- 3. Provincia incorrecta ---\n");

  const provinceFixes: Array<{ id: string; province: string; reason: string }> =
    [
      {
        id: "ChIJ5-k-eZDysY4RgRtCXRbtSKY",
        province: "Puerto Plata",
        reason: "Nombre/dirección/CP 57000 indican Puerto Plata, no Monseñor Nouel",
      },
      {
        id: "ChIJFSR56ZDysY4Rdkf0b0LQQSw",
        province: "Puerto Plata",
        reason: "Dirección Carr Navarrete Puerto Plata indica Puerto Plata",
      },
    ];

  for (const fix of provinceFixes) {
    if (!byId.has(fix.id)) {
      console.log(`[SKIP] Provincia — no existe ID ${fix.id}`);
      continue;
    }
    queueUpdate(fix.id, { province: fix.province }, fix.reason);
  }

  // -------------------------------------------------------------------------
  // 4 y 5. needsReview
  // -------------------------------------------------------------------------
  console.log("\n--- 4/5. Marcar needsReview ---\n");

  const explicitReviewNames = new Set(
    [
      "Malecón De Barahona",
      "Playa La Meseta",
      "Playa El Viejo Óscar",
      "Playa La Ballena",
      "Playa Remy",
      "Playa Teco Maimón Puerto Plata",
      "Acapulco beach",
      "Playa Punta Torrecillas",
      "Playa Montesinos",
    ].map(normalizeName),
  );

  for (const beach of beaches) {
    const nameKey = normalizeName(beach.data.name);
    const description = beach.data.description;
    const descriptionEn = beach.data.descriptionEn;

    const shouldReview =
      explicitReviewNames.has(nameKey) ||
      isGenericSpanishDescription(description) ||
      needsAutoTranslationReview(descriptionEn);

    if (shouldReview) {
      needsReviewIds.add(beach.id);
    }
  }

  // No marcar documentos que se van a eliminar.
  for (const del of pendingDeletes) {
    needsReviewIds.delete(del.id);
  }

  for (const id of needsReviewIds) {
    const existing = byId.get(id);
    if (!existing) continue;
    if (existing.data.needsReview === true) {
      console.log(`[needsReview] ${id} — ya marcado, omitido`);
      continue;
    }
    queueUpdate(id, { needsReview: true }, "Marcar para revisión manual de descripciones");
  }

  // -------------------------------------------------------------------------
  // BACKUP + COMMIT
  // -------------------------------------------------------------------------
  console.log("\n--- Aplicando cambios ---\n");

  if (pendingDeletes.length > 0) {
    const backup = pendingDeletes.map((d) => ({
      id: d.id,
      reason: d.reason,
      keptId: d.keptId,
      deletedAt: new Date().toISOString(),
      data: d.data,
    }));
    fs.writeFileSync(BACKUP_PATH, JSON.stringify(backup, null, 2), "utf8");
    console.log(`Backup de eliminados: ${BACKUP_PATH} (${backup.length} docs)`);
  } else {
    console.log("Sin eliminaciones — no se generó backup.");
  }

  // Deduplicar updates por ID (último gana).
  const mergedUpdates = new Map<string, PendingUpdate>();
  for (const update of pendingUpdates) {
    const prev = mergedUpdates.get(update.id);
    if (prev) {
      mergedUpdates.set(update.id, {
        id: update.id,
        reason: `${prev.reason}; ${update.reason}`,
        fields: { ...prev.fields, ...update.fields },
      });
    } else {
      mergedUpdates.set(update.id, update);
    }
  }

  const finalUpdates = [...mergedUpdates.values()];

  if (finalUpdates.length === 0 && pendingDeletes.length === 0) {
    console.log("\nNo hay cambios pendientes.\n");
    process.exit(0);
  }

  await commitBatches(finalUpdates, pendingDeletes);

  stats.modified = finalUpdates.length;
  stats.deleted = pendingDeletes.length;
  stats.needsReviewMarked = [...needsReviewIds].filter((id) =>
    finalUpdates.some((u) => u.id === id && u.fields.needsReview === true),
  ).length;

  console.log("\n=== Resumen ===");
  console.log(`Documentos modificados: ${stats.modified}`);
  console.log(`Documentos eliminados:  ${stats.deleted}`);
  console.log(`Marcados needsReview:   ${stats.needsReviewMarked}`);
  console.log(`Total needsReview (incl. ya marcados): ${needsReviewIds.size}`);
  console.log("");
}

main().catch((error) => {
  console.error("\nError en auditoría:", error);
  process.exit(1);
});
