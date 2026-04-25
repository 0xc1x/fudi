import { spawn } from "node:child_process";
import { getNpxCommand, loadRepoEnv, requireEnv } from "../lib/env-loader.mjs";

loadRepoEnv();
const databaseUrl = requireEnv("SUPABASE_DB_URL");

const child = spawn(
  getNpxCommand(),
  ["-y", "@modelcontextprotocol/server-postgres", databaseUrl],
  {
    stdio: "inherit",
    env: process.env
  }
);

child.on("exit", (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
    return;
  }

  process.exit(code ?? 0);
});

child.on("error", (error) => {
  console.error("[mcp/supabase-db] Failed to start:", error);
  process.exit(1);
});
