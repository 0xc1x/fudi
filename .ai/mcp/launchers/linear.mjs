import { spawn } from "node:child_process";
import { getNpxCommand, loadRepoEnv, requireEnv } from "../lib/env-loader.mjs";

loadRepoEnv();
requireEnv("LINEAR_API_KEY");

const child = spawn(
  getNpxCommand(),
  ["-y", "@mseep/linear-mcp"],
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
  console.error("[mcp/linear] Failed to start:", error);
  process.exit(1);
});
