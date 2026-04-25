import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const CURRENT_FILE = fileURLToPath(import.meta.url);
const CURRENT_DIR = path.dirname(CURRENT_FILE);
const REPO_ROOT = path.resolve(CURRENT_DIR, "..", "..", "..");

const ENV_FILES_IN_PRECEDENCE_ORDER = [
  ".env",
  ".env.local",
  ".env.mcp",
  ".env.mcp.local"
];

function stripMatchingQuotes(value) {
  if (
    (value.startsWith('"') && value.endsWith('"')) ||
    (value.startsWith("'") && value.endsWith("'"))
  ) {
    return value.slice(1, -1);
  }

  return value;
}

function parseEnvFile(rawContents) {
  const result = {};
  const lines = rawContents.split(/\r?\n/);

  for (const rawLine of lines) {
    const line = rawLine.trim();

    if (!line || line.startsWith("#")) {
      continue;
    }

    const normalized = line.startsWith("export ")
      ? line.slice("export ".length)
      : line;

    const separatorIndex = normalized.indexOf("=");

    if (separatorIndex <= 0) {
      continue;
    }

    const key = normalized.slice(0, separatorIndex).trim();
    const value = normalized.slice(separatorIndex + 1).trim();

    if (!key) {
      continue;
    }

    result[key] = stripMatchingQuotes(value)
      .replace(/\\n/g, "\n")
      .replace(/\\r/g, "\r");
  }

  return result;
}

export function loadRepoEnv() {
  const mergedFromFiles = {};

  for (const fileName of ENV_FILES_IN_PRECEDENCE_ORDER) {
    const fullPath = path.join(REPO_ROOT, fileName);

    if (!fs.existsSync(fullPath)) {
      continue;
    }

    const fileContents = fs.readFileSync(fullPath, "utf8");
    Object.assign(mergedFromFiles, parseEnvFile(fileContents));
  }

  for (const [key, value] of Object.entries(mergedFromFiles)) {
    if (process.env[key] === undefined || process.env[key] === "") {
      process.env[key] = value;
    }
  }

  return process.env;
}

export function requireEnv(varName) {
  const value = process.env[varName];

  if (!value) {
    throw new Error(
      `Missing required environment variable: ${varName}. ` +
        `Configure it in process env, .env.mcp.local, .env.mcp, .env.local or .env`
    );
  }

  return value;
}

export function getNpxCommand() {
  return process.platform === "win32" ? "npx.cmd" : "npx";
}
