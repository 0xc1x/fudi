import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { GitHubMCPServer } from "github-mcp/dist/server.js";
import {
  buildGitHubRuntimeEnv,
  loadRepoEnv,
  requireEnv
} from "../lib/env-loader.mjs";

Object.assign(process.env, buildGitHubRuntimeEnv(loadRepoEnv()));
requireEnv("GITHUB_ACCESS_TOKEN");

try {
  const server = new GitHubMCPServer({
    token: process.env.GITHUB_ACCESS_TOKEN
  });
  const transport = new StdioServerTransport();

  await server.connect(transport);
  process.stdin.resume();
  console.error("[mcp/github] GitHub MCP server running on stdio");
} catch (error) {
  console.error("[mcp/github] Failed to start:", error);
  process.exit(1);
}
