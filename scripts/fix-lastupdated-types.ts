/**
 * Detecta lastUpdated con tipo incorrecto (string en vez de timestamp).
 *   npx ts-node fix-lastupdated-types.ts --dry-run
 *   npx ts-node fix-lastupdated-types.ts
 */
import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import { OAuth2Client } from "google-auth-library";

const PROJECT = "playas-rd-2b475";
const COLLECTION = "beaches";
const DRY_RUN = process.argv.includes("--dry-run");

const FIREBASE_CLI_CLIENT_ID =
  "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com";
const FIREBASE_CLI_CLIENT_SECRET = "j9iVZfS8kkCEFUPaAeJV0sAi";

const options = fs.readFileSync(
  path.join(__dirname, "..", "lib", "firebase_options.dart"),
  "utf8",
);
const webApiKey = options.match(/apiKey:\s*'([^']+)'/)?.[1]!;

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

async function getToken(): Promise<string> {
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
  const token = (await client.getAccessToken()).token;
  if (!token) throw new Error("No OAuth token");
  return token;
}

type Kind = "timestamp" | "string" | "missing" | "other";

function kindOf(field: Record<string, unknown> | undefined): Kind {
  if (!field) return "missing";
  if ("timestampValue" in field) return "timestamp";
  if ("stringValue" in field) return "string";
  return "other";
}

async function main() {
  const bad: Array<{ id: string; name: string; value: string }> = [];
  const counts = { timestamp: 0, string: 0, missing: 0, other: 0 };
  let pageToken = "";

  do {
    const q = pageToken
      ? `${COLLECTION}?pageSize=300&pageToken=${encodeURIComponent(pageToken)}&key=${webApiKey}`
      : `${COLLECTION}?pageSize=300&key=${webApiKey}`;
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/${q}`;
    const res = await fetch(url);
    if (!res.ok) throw new Error(`list ${res.status}`);
    const payload = (await res.json()) as any;

    for (const doc of payload.documents ?? []) {
      const id = doc.name.split("/").pop();
      const f = doc.fields ?? {};
      const k = kindOf(f.lastUpdated);
      counts[k]++;
      if (k === "string") {
        bad.push({
          id,
          name: f.name?.stringValue ?? id,
          value: String(f.lastUpdated.stringValue),
        });
      } else if (k === "other") {
        console.log("other lastUpdated", id, JSON.stringify(f.lastUpdated));
      }
    }
    pageToken = payload.nextPageToken ?? "";
  } while (pageToken);

  console.log("lastUpdated kinds:", counts);
  console.log(`Bad (string): ${bad.length}`);
  for (const b of bad) console.log(`  [${b.id}] ${b.name} = ${b.value}`);

  if (!bad.length) {
    console.log("Nada que corregir.");
    return;
  }

  if (DRY_RUN) {
    console.log("\n[dry-run] No se escribió nada.");
    return;
  }

  const token = await getToken();
  let fixed = 0;
  for (const b of bad) {
    const iso = Number.isNaN(Date.parse(b.value))
      ? new Date().toISOString()
      : new Date(b.value).toISOString();
    const body = {
      fields: {
        lastUpdated: { timestampValue: iso },
      },
    };
    const url =
      `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/` +
      `${COLLECTION}/${encodeURIComponent(b.id)}?updateMask.fieldPaths=lastUpdated`;
    const res = await fetch(url, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      console.log(`❌ ${b.id}: ${res.status} ${await res.text()}`);
      continue;
    }
    fixed++;
    console.log(`✅ ${b.id} → Timestamp ${iso}`);
  }
  console.log(`\nCorregidos: ${fixed}/${bad.length}`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
