import { spawn } from "node:child_process";
import { getNpxCommand, loadRepoEnv, requireEnv } from "../lib/env-loader.mjs";

loadRepoEnv();
requireEnv("SLACK_WEBHOOK_URL");

const child = spawn(
  getNpxCommand(),
  ["-y", "@aaronsb/slack-mcp"],
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
  console.error("[mcp/slack] Failed to start:", error);
  process.exit(1);
});
