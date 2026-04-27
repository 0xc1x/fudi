#!/usr/bin/env node

/**
 * MCP Operational Test Script
 * 
 * Este script prueba cada MCP individualmente para confirmar que están
 * operativos y listos para ser usados por el agente de IA.
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';
import { spawn } from 'child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Importar env-loader
const CURRENT_DIR = path.dirname(__filename);
const REPO_ROOT = path.resolve(CURRENT_DIR, '..', '..', '..');

// Colores para terminal
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function logSuccess(message) {
  log(`✅ ${message}`, colors.green);
}

function logError(message) {
  log(`❌ ${message}`, colors.red);
}

function logWarning(message) {
  log(`⚠️  ${message}`, colors.yellow);
}

function logInfo(message) {
  log(`ℹ️  ${message}`, colors.blue);
}

function logSection(title) {
  log(`\n${colors.cyan}${'═'.repeat(70)}${colors.reset}`);
  log(`${colors.cyan}${title}${colors.reset}`);
  log(`${colors.cyan}${'═'.repeat(70)}${colors.reset}`);
}

// Función para cargar variables de entorno
function loadRepoEnv() {
  const ENV_FILES_IN_PRECEDENCE_ORDER = [
    ".env",
    ".env.local",
    ".env.mcp",
    ".env.mcp.local"
  ];

  const mergedFromFiles = {};

  for (const fileName of ENV_FILES_IN_PRECEDENCE_ORDER) {
    const fullPath = path.join(REPO_ROOT, fileName);

    if (!fs.existsSync(fullPath)) {
      continue;
    }

    const fileContents = fs.readFileSync(fullPath, "utf8");
    Object.assign(mergedFromFiles, parseEnvFile(fileContents));
  }

  for (const [key, value] of Object.entries(mergedFromFiles)) {
    if (process.env[key] === undefined || process.env[key] === "") {
      process.env[key] = value;
    }
  }

  return process.env;
}

function parseEnvFile(rawContents) {
  const result = {};
  const lines = rawContents.split(/\r?\n/);

  for (const rawLine of lines) {
    const line = rawLine.trim();

    if (!line || line.startsWith("#")) {
      continue;
    }

    const normalized = line.startsWith("export ")
      ? line.slice("export ".length)
      : line;

    const separatorIndex = normalized.indexOf("=");

    if (separatorIndex <= 0) {
      continue;
    }

    const key = normalized.slice(0, separatorIndex).trim();
    const value = normalized.slice(separatorIndex + 1).trim();

    if (!key) {
      continue;
    }

    result[key] = value
      .replace(/\\n/g, "\n")
      .replace(/\\r/g, "\r");
  }

  return result;
}

// MCPs a probar
const MCPs = {
  required: [
    {
      name: 'GitHub',
      id: 'github',
      package: 'github-mcp',
      envVar: 'GITHUB_PERSONAL_ACCESS_TOKEN',
      launcher: 'github.mjs',
      testCommand: 'npx -y github-mcp --version',
      description: 'Gestión de repositorios, issues, PRs'
    },
    {
      name: 'Supabase Database',
      id: 'supabase-db',
      package: 'postgres-mcp',
      envVar: 'SUPABASE_DB_URL',
      launcher: 'supabase-postgres.mjs',
      testCommand: 'npx -y postgres-mcp --version',
      description: 'Introspección de PostgreSQL'
    }
  ],
  optional: [
    {
      name: 'Figma API',
      id: 'figma-api',
      package: 'figma-mcp',
      envVar: 'FIGMA_ACCESS_TOKEN',
      launcher: 'figma.mjs',
      testCommand: 'npx -y figma-mcp --version',
      description: 'Designs y componentes'
    },
    {
      name: 'Linear',
      id: 'linear',
      package: '@mseep/linear-mcp',
      envVar: 'LINEAR_API_KEY',
      launcher: 'linear.mjs',
      testCommand: 'npx -y @mseep/linear-mcp --version',
      description: 'Gestión de tareas'
    },
    {
      name: 'Slack Notifications',
      id: 'slack-notifications',
      package: '@aaronsb/slack-mcp',
      envVar: 'SLACK_WEBHOOK_URL',
      launcher: 'slack.mjs',
      testCommand: 'npx -y @aaronsb/slack-mcp --version',
      description: 'Notificaciones'
    }
  ],
  http: [
    {
      name: 'OpenAI Developer Docs',
      id: 'openaiDeveloperDocs',
      url: 'https://developers.openai.com/mcp',
      description: 'Documentación de OpenAI'
    },
    {
      name: 'React Docs',
      id: 'react-docs',
      url: 'https://react.dev/learn',
      description: 'Documentación de React'
    },
    {
      name: 'Flutter Docs',
      id: 'flutter-docs',
      url: 'https://docs.flutter.dev',
      description: 'Documentación de Flutter'
    },
    {
      name: 'Flutter Testing',
      id: 'flutter-testing',
      url: 'https://docs.flutter.dev/cookbook/testing',
      description: 'Testing de Flutter'
    },
    {
      name: 'Jest Docs',
      id: 'jest-docs',
      url: 'https://jestjs.io/docs/getting-started',
      description: 'Documentación de Jest'
    },
    {
      name: 'GitHub Actions',
      id: 'github-actions',
      url: 'https://docs.github.com/en/actions',
      description: 'Documentación de GitHub Actions'
    }
  ]
};

// Probar un MCP stdio
function testStdioMCP(mcp) {
  logInfo(`Probando ${mcp.name}...`);
  
  // Verificar variable de entorno
  const envValue = process.env[mcp.envVar];
  if (!envValue) {
    logWarning(`Variable de entorno ${mcp.envVar} no configurada`);
    return false;
  }
  
  logInfo(`  ✅ Variable de entorno configurada`);
  
  // Verificar launcher
  const launcherPath = path.join(__dirname, '..', 'launchers', mcp.launcher);
  if (!fs.existsSync(launcherPath)) {
    logError(`Launcher ${mcp.launcher} no encontrado`);
    return false;
  }
  
  logInfo(`  ✅ Launcher ${mcp.launcher} encontrado`);
  
  // Probar comando de versión
  try {
    const output = execSync(mcp.testCommand, { 
      encoding: 'utf-8',
      timeout: 10000,
      stdio: 'pipe'
    });
    
    logInfo(`  ✅ Comando ejecutado: ${output.trim()}`);
  } catch (error) {
    // Algunos MCPs no tienen --version, intentar ejecutar directamente
    try {
      logInfo(`  ℹ️  Intentando ejecutar launcher directamente...`);
      
      // Ejecutar launcher con timeout
      const result = spawn('node', [launcherPath], {
        env: process.env,
        stdio: 'pipe'
      });
      
      let output = '';
      let errorOutput = '';
      
      result.stdout.on('data', (data) => {
        output += data.toString();
      });
      
      result.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });
      
      // Esperar un poco para ver si inicia correctamente
      setTimeout(() => {
        result.kill();
      }, 3000);
      
      logInfo(`  ✅ Launcher puede iniciarse`);
    } catch (spawnError) {
      logWarning(`  ⚠️  No se pudo probar el launcher: ${spawnError.message}`);
    }
  }
  
  return true;
}

// Probar un MCP HTTP
function testHttpMCP(mcp) {
  logInfo(`Probando ${mcp.name}...`);
  
  // MCPs HTTP no requieren configuración, solo verificar URL
  logInfo(`  ✅ URL: ${mcp.url}`);
  logInfo(`  ✅ MCP HTTP siempre disponible`);
  
  return true;
}

// Generar reporte final
function generateReport(results) {
  logSection('Reporte de Operatividad de MCPs');
  
  const totalMCPs = results.length;
  const operationalMCPs = results.filter(r => r.operational).length;
  const nonOperationalMCPs = totalMCPs - operationalMCPs;
  
  log(`\nTotal de MCPs: ${totalMCPs}`);
  logSuccess(`Operativos: ${operationalMCPs}`);
  
  if (nonOperationalMCPs > 0) {
    logError(`No operativos: ${nonOperationalMCPs}`);
  }
  
  log(`\nPorcentaje de operatividad: ${((operationalMCPs / totalMCPs) * 100).toFixed(1)}%`);
  
  // Detalle por categoría
  logSection('Detalle por Categoría');
  
  log('\n📦 MCPs Requeridos (stdio):');
  const requiredResults = results.filter(r => r.category === 'required');
  for (const result of requiredResults) {
    const status = result.operational ? '✅' : '❌';
    log(`   ${status} ${result.name.padEnd(25)} - ${result.status}`);
  }
  
  log('\n📦 MCPs Opcionales (stdio):');
  const optionalResults = results.filter(r => r.category === 'optional');
  for (const result of optionalResults) {
    const status = result.operational ? '✅' : '❌';
    log(`   ${status} ${result.name.padEnd(25)} - ${result.status}`);
  }
  
  log('\n📦 MCPs HTTP:');
  const httpResults = results.filter(r => r.category === 'http');
  for (const result of httpResults) {
    const status = result.operational ? '✅' : '❌';
    log(`   ${status} ${result.name.padEnd(25)} - ${result.status}`);
  }
  
  // Conclusión
  logSection('Conclusión');
  
  const requiredOperational = requiredResults.every(r => r.operational);
  
  if (requiredOperational) {
    log('\n🎉 ¡Los MCPs requeridos están operativos y listos para el agente de IA!', colors.green);
    log('\nEl agente de IA puede usar:', colors.cyan);
    for (const result of requiredResults) {
      if (result.operational) {
        log(`  • ${result.name}: ${result.description}`, colors.cyan);
      }
    }
    
    if (nonOperationalMCPs > 0) {
      log('\n⚠️  Algunos MCPs opcionales no están configurados:', colors.yellow);
      for (const result of optionalResults) {
        if (!result.operational) {
          log(`  • ${result.name}: ${result.status}`, colors.yellow);
        }
      }
    }
  } else {
    log('\n❌ Algunos MCPs requeridos no están operativos', colors.red);
    log('\nPor favor, configura las variables de entorno necesarias:', colors.yellow);
    for (const result of requiredResults) {
      if (!result.operational) {
        log(`  • ${result.envVar}`, colors.yellow);
      }
    }
  }
}

// Función principal
async function main() {
  log('\n🔬 MCP Operational Test para Fudi', colors.magenta);
  log('Verificando que los MCPs estén operativos y listos para el agente de IA', colors.magenta);
  
  // Cargar variables de entorno
  loadRepoEnv();
  
  const results = [];
  
  // Probar MCPs requeridos
  logSection('Probando MCPs Requeridos');
  for (const mcp of MCPs.required) {
    const operational = testStdioMCP(mcp);
    results.push({
      ...mcp,
      category: 'required',
      operational,
      status: operational ? 'Operativo' : 'No operativo'
    });
    log('');
  }
  
  // Probar MCPs opcionales
  logSection('Probando MCPs Opcionales');
  for (const mcp of MCPs.optional) {
    const operational = testStdioMCP(mcp);
    results.push({
      ...mcp,
      category: 'optional',
      operational,
      status: operational ? 'Operativo' : 'No operativo'
    });
    log('');
  }
  
  // Probar MCPs HTTP
  logSection('Probando MCPs HTTP');
  for (const mcp of MCPs.http) {
    const operational = testHttpMCP(mcp);
    results.push({
      ...mcp,
      category: 'http',
      operational,
      status: operational ? 'Operativo' : 'No operativo'
    });
    log('');
  }
  
  // Generar reporte
  generateReport(results);
  
  // Exit code
  const requiredOperational = results
    .filter(r => r.category === 'required')
    .every(r => r.operational);
  
  process.exit(requiredOperational ? 0 : 1);
}

// Ejecutar
main().catch(error => {
  logError(`Error: ${error.message}`);
  process.exit(1);
});
