import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createServer } from "chrome-devtools-mcp";
import { loadRepoEnv } from "../lib/env-loader.mjs";

loadRepoEnv();

try {
  const server = await createServer();
  const transport = new StdioServerTransport();

  await server.connect(transport);
  process.stdin.resume();
  console.error("[mcp/chrome-devtools] Chrome DevTools MCP server running on stdio");
} catch (error) {
  console.error("[mcp/chrome-devtools] Failed to start:", error);
  process.exit(1);
}
