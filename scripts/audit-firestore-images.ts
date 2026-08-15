/**
 * Auditoría completa: Firestore imageUrls vs HTTP status de Storage.
 *   npx ts-node audit-firestore-images.ts
 */
import * as fs from "fs";
import * as path from "path";

const PROJECT = "playas-rd-2b475";
const options = fs.readFileSync(
  path.join(__dirname, "..", "lib", "firebase_options.dart"),
  "utf8",
);
const key = options.match(/apiKey:\s*'([^']+)'/)?.[1]!;

type BeachRow = {
  id: string;
  name: string;
  urls: string[];
  updated?: string;
};

function parseUrls(fields: Record<string, any>): string[] {
  const values = fields.imageUrls?.arrayValue?.values ?? [];
  return values.map((v: any) => v.stringValue || "").filter(Boolean);
}

function stripToken(url: string): string {
  try {
    const u = new URL(url);
    u.searchParams.delete("token");
    return u.toString();
  } catch {
    return url;
  }
}

function classify(url: string): "storage" | "places" | "other" {
  if (url.includes("firebasestorage") || url.startsWith("beaches/")) return "storage";
  if (url.includes("maps.googleapis.com") || url.includes("googleusercontent")) return "places";
  return "other";
}

async function httpStatus(url: string): Promise<number> {
  try {
    const res = await fetch(url, {
      method: "GET",
      headers: { Range: "bytes=0-1" },
      redirect: "follow",
    });
    return res.status;
  } catch {
    return -1;
  }
}

async function loadBeaches(): Promise<BeachRow[]> {
  const beaches: BeachRow[] = [];
  let pageToken = "";
  do {
    const q = pageToken
      ? `beaches?pageSize=300&pageToken=${encodeURIComponent(pageToken)}&key=${key}`
      : `beaches?pageSize=300&key=${key}`;
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/${q}`;
    const res = await fetch(url);
    if (!res.ok) throw new Error(`list ${res.status}`);
    const payload = (await res.json()) as any;
    for (const doc of payload.documents ?? []) {
      const id = doc.name.split("/").pop();
      const f = doc.fields ?? {};
      beaches.push({
        id,
        name: f.name?.stringValue ?? id,
        urls: parseUrls(f),
        updated: f.lastUpdated?.timestampValue,
      });
    }
    pageToken = payload.nextPageToken ?? "";
  } while (pageToken);
  return beaches;
}

async function main() {
  const beaches = await loadBeaches();
  const empty = beaches.filter((b) => b.urls.length === 0);
  const withUrls = beaches.filter((b) => b.urls.length > 0);

  let places = 0;
  let storage = 0;
  let other = 0;
  let withToken = 0;
  let withoutToken = 0;

  for (const b of withUrls) {
    for (const u of b.urls) {
      const c = classify(u);
      if (c === "places") places++;
      else if (c === "storage") storage++;
      else other++;
      if (u.includes("token=")) withToken++;
      else withoutToken++;
    }
  }

  console.log("=== Firestore imageUrls ===");
  console.log(`Playas: ${beaches.length}`);
  console.log(`Con fotos: ${withUrls.length}`);
  console.log(`Sin fotos: ${empty.length}`);
  if (empty.length) {
    for (const b of empty) console.log(`  - [${b.id}] ${b.name}`);
  }
  console.log(`URLs Storage: ${storage}`);
  console.log(`URLs Places:  ${places}`);
  console.log(`URLs other:   ${other}`);
  console.log(`Con token=:   ${withToken}`);
  console.log(`Sin token=:   ${withoutToken}`);

  // Probar primera URL de TODAS las playas con fotos
  console.log(`\n=== HTTP check (1ª foto de cada playa, ${withUrls.length}) ===`);
  const failures: Array<{
    id: string;
    name: string;
    status: number;
    statusNoToken: number;
    url: string;
  }> = [];
  let ok = 0;

  // concurrency 8
  const queue = [...withUrls];
  async function worker() {
    while (queue.length) {
      const b = queue.shift()!;
      const url = b.urls[0];
      const status = await httpStatus(url);
      const statusNoToken = url.includes("token=")
        ? await httpStatus(stripToken(url))
        : status;
      const good = status === 200 || status === 206;
      const goodAlt = statusNoToken === 200 || statusNoToken === 206;
      if (good || goodAlt) {
        ok++;
        process.stdout.write(".");
      } else {
        failures.push({
          id: b.id,
          name: b.name,
          status,
          statusNoToken,
          url: url.slice(0, 160),
        });
        process.stdout.write("x");
      }
    }
  }
  await Promise.all(Array.from({ length: 8 }, () => worker()));
  console.log(`\nOK: ${ok}  FAIL: ${failures.length}`);
  if (failures.length) {
    console.log("\nFallos:");
    for (const f of failures.slice(0, 40)) {
      console.log(
        `  [${f.id}] ${f.name} → ${f.status}/${f.statusNoToken} ${f.url}`,
      );
    }
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
