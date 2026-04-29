import { loadRepoEnv, requireEnv } from "../lib/env-loader.mjs";

try {
  loadRepoEnv();
  requireEnv("LINEAR_API_KEY");

  await import("../node_modules/@mseep/linear-mcp/build/index.js");
} catch (error) {
  console.error("[mcp/linear] Failed to start:", error);
  process.exit(1);
}
