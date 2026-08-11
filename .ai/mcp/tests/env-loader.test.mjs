import assert from "node:assert/strict";
import path from "node:path";

import {
	MCP_ROOT,
	REPO_ROOT,
	applyEnvAliases,
	buildFigmaRuntimeEnv,
	buildGitHubRuntimeEnv,
	getEnvLoadPaths,
} from "../lib/env-loader.mjs";

function run(name, fn) {
	try {
		fn();
		console.log(`PASS ${name}`);
	} catch (error) {
		console.error(`FAIL ${name}`);
		throw error;
	}
}

run(
	"getEnvLoadPaths prioritizes repo env files and MCP local overrides",
	() => {
		const paths = getEnvLoadPaths();

		assert.deepEqual(paths, [
			path.join(REPO_ROOT, ".env"),
			path.join(REPO_ROOT, ".env.local"),
			path.join(REPO_ROOT, ".env.mcp"),
			path.join(REPO_ROOT, ".env.mcp.local"),
			path.join(MCP_ROOT, ".env.mcp.local"),
		]);
	},
);

run("applyEnvAliases only fills missing targets", () => {
	const env = applyEnvAliases(
		{
			PRIMARY_TOKEN: "",
			LEGACY_TOKEN: "legacy-value",
			EXPLICIT_TOKEN: "explicit-value",
		},
		{
			PRIMARY_TOKEN: ["LEGACY_TOKEN"],
			EXPLICIT_TOKEN: ["LEGACY_TOKEN"],
		},
	);

	assert.equal(env.PRIMARY_TOKEN, "legacy-value");
	assert.equal(env.EXPLICIT_TOKEN, "explicit-value");
});

run("buildGitHubRuntimeEnv maps the canonical repo token", () => {
	const env = buildGitHubRuntimeEnv({
		GITHUB_PERSONAL_ACCESS_TOKEN: "ghp_example",
	});

	assert.equal(env.GITHUB_ACCESS_TOKEN, "ghp_example");
});

run("buildFigmaRuntimeEnv maps the canonical repo token", () => {
	const env = buildFigmaRuntimeEnv({
		FIGMA_ACCESS_TOKEN: "figd_example",
	});

	assert.equal(env.FIGMA_API_KEY, "figd_example");
});
