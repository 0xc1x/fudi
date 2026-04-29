import { inspect } from "node:util";
import {
  REPO_ROOT,
  buildPostgresRuntimeEnv,
  loadRepoEnv,
  requireEnv
} from "../lib/env-loader.mjs";

function redirectConsoleToStderr(methodNames = ["log", "info", "warn"]) {
  for (const methodName of methodNames) {
    const originalMethod = console[methodName];

    console[methodName] = (...args) => {
      const serialized = args
        .map((value) =>
          typeof value === "string" ? value : inspect(value, { depth: 5, colors: false })
        )
        .join(" ");

      process.stderr.write(`${serialized}\n`);
    };
  }
}

try {
  Object.assign(process.env, buildPostgresRuntimeEnv(loadRepoEnv()));
  requireEnv("DB_MAIN_URL");
  process.chdir(REPO_ROOT);
  redirectConsoleToStderr();

  const { startServer } = await import("postgres-mcp");

  startServer();
  process.stdin.resume();
  console.error("[mcp/supabase-db] Postgres MCP server running on stdio");
} catch (error) {
  console.error("[mcp/supabase-db] Failed to start:", error);
  process.exit(1);
}
