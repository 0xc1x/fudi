import {
  buildFigmaRuntimeEnv,
  loadRepoEnv,
  requireEnv
} from "../lib/env-loader.mjs";

try {
  Object.assign(process.env, buildFigmaRuntimeEnv(loadRepoEnv()));
  requireEnv("FIGMA_API_KEY");

  await import("../node_modules/figma-mcp/dist/index.cjs");
} catch (error) {
  console.error("[mcp/figma] Failed to start:", error);
  process.exit(1);
}
