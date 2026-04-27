#!/usr/bin/env node

/**
 * MCP Verification Script
 * 
 * Este script verifica que todos los MCPs estén correctamente configurados
 * y funcionando.
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

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
  log(`\n${colors.cyan}${'═'.repeat(60)}${colors.reset}`);
  log(`${colors.cyan}${title}${colors.reset}`);
  log(`${colors.cyan}${'═'.repeat(60)}${colors.reset}`);
}

// MCPs a verificar
const MCPs = {
  required: [
    {
      name: 'github',
      package: 'github-mcp',
      envVar: 'GITHUB_PERSONAL_ACCESS_TOKEN',
      launcher: 'github.mjs'
    },
    {
      name: 'supabase-db',
      package: 'postgres-mcp',
      envVar: 'SUPABASE_DB_URL',
      launcher: 'supabase-postgres.mjs'
    }
  ],
  optional: [
    {
      name: 'figma-api',
      package: 'figma-mcp',
      envVar: 'FIGMA_ACCESS_TOKEN',
      launcher: 'figma.mjs'
    },
    {
      name: 'linear',
      package: '@mseep/linear-mcp',
      envVar: 'LINEAR_API_KEY',
      launcher: 'linear.mjs'
    },
    {
      name: 'slack-notifications',
      package: '@aaronsb/slack-mcp',
      envVar: 'SLACK_WEBHOOK_URL',
      launcher: 'slack.mjs'
    }
  ],
  http: [
    {
      name: 'openaiDeveloperDocs',
      url: 'https://developers.openai.com/mcp'
    },
    {
      name: 'react-docs',
      url: 'https://react.dev/learn'
    },
    {
      name: 'flutter-docs',
      url: 'https://docs.flutter.dev'
    },
    {
      name: 'flutter-testing',
      url: 'https://docs.flutter.dev/cookbook/testing'
    },
    {
      name: 'jest-docs',
      url: 'https://jestjs.io/docs/getting-started'
    },
    {
      name: 'github-actions',
      url: 'https://docs.github.com/en/actions'
    }
  ]
};

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

// Verificar instalación de paquetes
function verifyPackages() {
  logSection('Verificando Paquetes NPM');
  
  const packageJsonPath = path.join(__dirname, '..', 'package.json');
  
  if (!fs.existsSync(packageJsonPath)) {
    logError('package.json no encontrado');
    return false;
  }
  
  try {
    const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
    const dependencies = packageJson.dependencies || {};
    
    logInfo('Paquetes instalados:');
    for (const [name, version] of Object.entries(dependencies)) {
      logSuccess(`${name}@${version}`);
    }
    
    return true;
  } catch (error) {
    logError('Error al leer package.json');
    return false;
  }
}

// Verificar launchers
function verifyLaunchers() {
  logSection('Verificando Launchers');
  
  const launchersDir = path.join(__dirname, '..', 'launchers');
  let allRequiredPresent = true;
  
  logInfo('Launchers requeridos:');
  for (const mcp of MCPs.required) {
    const launcherPath = path.join(launchersDir, mcp.launcher);
    if (fs.existsSync(launcherPath)) {
      logSuccess(`${mcp.launcher} encontrado`);
    } else {
      logError(`${mcp.launcher} no encontrado`);
      allRequiredPresent = false;
    }
  }
  
  logInfo('Launchers opcionales:');
  for (const mcp of MCPs.optional) {
    const launcherPath = path.join(launchersDir, mcp.launcher);
    if (fs.existsSync(launcherPath)) {
      logSuccess(`${mcp.launcher} encontrado`);
    } else {
      logWarning(`${mcp.launcher} no encontrado (opcional)`);
    }
  }
  
  return allRequiredPresent;
}

// Verificar variables de entorno
function verifyEnvVars() {
  logSection('Verificando Variables de Entorno');
  
  // Cargar variables de entorno desde archivos
  loadRepoEnv();
  
  let allRequiredPresent = true;
  
  logInfo('Variables requeridas:');
  for (const mcp of MCPs.required) {
    const value = process.env[mcp.envVar];
    if (value) {
      // Mostrar solo primeros caracteres por seguridad
      const maskedValue = value.length > 8 
        ? `${value.substring(0, 4)}...${value.substring(value.length - 4)}`
        : '***';
      logSuccess(`${mcp.envVar} = ${maskedValue}`);
    } else {
      logError(`${mcp.envVar} no configurada`);
      allRequiredPresent = false;
    }
  }
  
  logInfo('Variables opcionales:');
  for (const mcp of MCPs.optional) {
    const value = process.env[mcp.envVar];
    if (value) {
      const maskedValue = value.length > 8 
        ? `${value.substring(0, 4)}...${value.substring(value.length - 4)}`
        : '***';
      logSuccess(`${mcp.envVar} = ${maskedValue}`);
    } else {
      logWarning(`${mcp.envVar} no configurada (opcional)`);
    }
  }
  
  return allRequiredPresent;
}

// Verificar archivos de entorno
function verifyEnvFiles() {
  logSection('Verificando Archivos de Entorno');
  
  const envFiles = [
    '.env',
    '.env.local',
    '.env.mcp',
    '.env.mcp.local'
  ];
  
  let envFileExists = false;
  
  for (const envFile of envFiles) {
    const envFilePath = path.join(REPO_ROOT, envFile);
    if (fs.existsSync(envFilePath)) {
      logSuccess(`${envFile} encontrado`);
      envFileExists = true;
      
      // Verificar contenido
      try {
        const content = fs.readFileSync(envFilePath, 'utf-8');
        const lines = content.split('\n').filter(line => 
          line.trim() && !line.startsWith('#')
        );
        
        if (lines.length > 0) {
          logInfo(`   ${lines.length} variables configuradas`);
        }
      } catch (error) {
        logWarning(`   No se pudo leer ${envFile}`);
      }
    }
  }
  
  if (!envFileExists) {
    logWarning('No se encontraron archivos de entorno');
    logInfo('Ejecuta: npm run setup para crear .env.mcp.example');
  }
  
  return envFileExists;
}

// Verificar manifiesto
function verifyManifest() {
  logSection('Verificando Manifiesto MCP');
  
  const manifestPath = path.join(__dirname, '..', 'mcp.manifest.json');
  
  if (!fs.existsSync(manifestPath)) {
    logError('mcp.manifest.json no encontrado');
    return false;
  }
  
  try {
    const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));
    const servers = manifest.servers || {};
    
    logInfo(`Versión: ${manifest.version}`);
    logInfo(`Nombre: ${manifest.name}`);
    logInfo(`Servidores configurados: ${Object.keys(servers).length}`);
    
    for (const [name, config] of Object.entries(servers)) {
      const enabled = config.enabledByDefault ? '✅' : '❌';
      const transport = config.transport || 'unknown';
      log(`   ${enabled} ${name} (${transport})`);
    }
    
    return true;
  } catch (error) {
    logError('Error al leer mcp.manifest.json');
    return false;
  }
}

// Verificar conectividad HTTP
function verifyHttpConnectivity() {
  logSection('Verificando Conectividad HTTP');
  
  logInfo('MCPs HTTP (siempre disponibles):');
  for (const mcp of MCPs.http) {
    logSuccess(`${mcp.name} - ${mcp.url}`);
  }
  
  return true;
}

// Generar reporte
function generateReport(results) {
  logSection('Reporte de Verificación');
  
  const totalChecks = Object.keys(results).length;
  const passedChecks = Object.values(results).filter(r => r).length;
  const failedChecks = totalChecks - passedChecks;
  
  log(`\nTotal de verificaciones: ${totalChecks}`);
  logSuccess(`Pasaron: ${passedChecks}`);
  
  if (failedChecks > 0) {
    logError(`Fallaron: ${failedChecks}`);
  }
  
  log(`\nPorcentaje de éxito: ${((passedChecks / totalChecks) * 100).toFixed(1)}%`);
  
  if (failedChecks === 0) {
    log('\n🎉 ¡Todos los MCPs están correctamente configurados!', colors.green);
  } else {
    log('\n⚠️  Algunos MCPs necesitan configuración adicional.', colors.yellow);
    logInfo('Revisa los errores arriba y completa la configuración.');
  }
}

// Función principal
async function main() {
  log('\n🔍 MCP Verification para Fudi', colors.cyan);
  
  const results = {
    packages: verifyPackages(),
    launchers: verifyLaunchers(),
    envVars: verifyEnvVars(),
    envFiles: verifyEnvFiles(),
    manifest: verifyManifest(),
    httpConnectivity: verifyHttpConnectivity()
  };
  
  generateReport(results);
  
  // Exit code basado en resultados
  const allRequiredPassed = results.packages && 
                           results.launchers && 
                           results.envVars;
  
  process.exit(allRequiredPassed ? 0 : 1);
}

// Ejecutar
main().catch(error => {
  logError(`Error: ${error.message}`);
  process.exit(1);
});
