import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const CURRENT_FILE = fileURLToPath(import.meta.url);
const CURRENT_DIR = path.dirname(CURRENT_FILE);
export const MCP_ROOT = path.resolve(CURRENT_DIR, "..");
export const REPO_ROOT = path.resolve(CURRENT_DIR, "..", "..", "..");

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

export function getEnvLoadPaths({
  repoRoot = REPO_ROOT,
  mcpRoot = MCP_ROOT
} = {}) {
  return [
    path.join(repoRoot, ".env"),
    path.join(repoRoot, ".env.local"),
    path.join(repoRoot, ".env.mcp"),
    path.join(repoRoot, ".env.mcp.local"),
    path.join(mcpRoot, ".env.mcp.local")
  ];
}

export function applyEnvAliases(env, aliasMap) {
  const nextEnv = { ...env };

  for (const [targetKey, sourceKeys] of Object.entries(aliasMap)) {
    if (nextEnv[targetKey]) {
      continue;
    }

    for (const sourceKey of sourceKeys) {
      if (nextEnv[sourceKey]) {
        nextEnv[targetKey] = nextEnv[sourceKey];
        break;
      }
    }
  }

  return nextEnv;
}

export function buildGitHubRuntimeEnv(env = process.env) {
  return applyEnvAliases(env, {
    GITHUB_ACCESS_TOKEN: ["GITHUB_PERSONAL_ACCESS_TOKEN"]
  });
}

export function buildPostgresRuntimeEnv(env = process.env) {
  const nextEnv = applyEnvAliases(env, {
    DB_MAIN_URL: ["SUPABASE_DB_URL"]
  });

  if (!nextEnv.DB_ALIASES) {
    nextEnv.DB_ALIASES = "main";
  }

  if (!nextEnv.DEFAULT_DB_ALIAS) {
    nextEnv.DEFAULT_DB_ALIAS = "main";
  }

  return nextEnv;
}

export function buildFigmaRuntimeEnv(env = process.env) {
  return applyEnvAliases(env, {
    FIGMA_API_KEY: ["FIGMA_ACCESS_TOKEN"]
  });
}

export function loadRepoEnv() {
  const mergedFromFiles = {};

  for (const fullPath of getEnvLoadPaths()) {
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
