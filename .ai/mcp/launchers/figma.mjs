import { spawn } from "node:child_process";
import { getNpxCommand, loadRepoEnv, requireEnv } from "../lib/env-loader.mjs";

loadRepoEnv();
requireEnv("FIGMA_ACCESS_TOKEN");

const child = spawn(
  getNpxCommand(),
  ["-y", "figma-mcp"],
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
  console.error("[mcp/figma] Failed to start:", error);
  process.exit(1);
});
