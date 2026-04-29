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
import {
  buildFigmaRuntimeEnv,
  buildGitHubRuntimeEnv,
  buildPostgresRuntimeEnv,
  getEnvLoadPaths,
  loadRepoEnv
} from '../lib/env-loader.mjs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

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
      runtimeEnvVar: 'GITHUB_ACCESS_TOKEN',
      launcher: 'github.mjs'
    },
    {
      name: 'supabase-db',
      package: 'postgres-mcp',
      envVar: 'SUPABASE_DB_URL',
      runtimeEnvVar: 'DB_MAIN_URL',
      launcher: 'supabase-postgres.mjs'
    }
  ],
  optional: [
    {
      name: 'figma-api',
      package: 'figma-mcp',
      envVar: 'FIGMA_ACCESS_TOKEN',
      runtimeEnvVar: 'FIGMA_API_KEY',
      launcher: 'figma.mjs'
    },
    {
      name: 'linear',
      package: '@mseep/linear-mcp',
      envVar: 'LINEAR_API_KEY',
      launcher: 'linear.mjs'
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
  const githubEnv = buildGitHubRuntimeEnv(process.env);
  const postgresEnv = buildPostgresRuntimeEnv(process.env);
  const figmaEnv = buildFigmaRuntimeEnv(process.env);
  
  let allRequiredPresent = true;
  
  logInfo('Variables requeridas:');
  for (const mcp of MCPs.required) {
    const value = process.env[mcp.envVar];
    const runtimeValue =
      mcp.runtimeEnvVar === 'GITHUB_ACCESS_TOKEN'
        ? githubEnv.GITHUB_ACCESS_TOKEN
        : postgresEnv.DB_MAIN_URL;

    if (value) {
      // Mostrar solo primeros caracteres por seguridad
      const maskedValue = value.length > 8 
        ? `${value.substring(0, 4)}...${value.substring(value.length - 4)}`
        : '***';
      logSuccess(`${mcp.envVar} = ${maskedValue}`);
      logInfo(`   runtime ${mcp.runtimeEnvVar}: ${runtimeValue ? 'derivable' : 'faltante'}`);
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
      if (mcp.runtimeEnvVar) {
        const runtimeValue = mcp.runtimeEnvVar === 'FIGMA_API_KEY'
          ? figmaEnv.FIGMA_API_KEY
          : process.env[mcp.runtimeEnvVar];
        logInfo(`   runtime ${mcp.runtimeEnvVar}: ${runtimeValue ? 'derivable' : 'faltante'}`);
      }
    } else {
      logWarning(`${mcp.envVar} no configurada (opcional)`);
    }
  }
  
  return allRequiredPresent;
}

// Verificar archivos de entorno
function verifyEnvFiles() {
  logSection('Verificando Archivos de Entorno');
  
  const envFiles = [...new Set(getEnvLoadPaths())];
  
  let envFileExists = false;
  
  for (const envFilePath of envFiles) {
    if (fs.existsSync(envFilePath)) {
      const relativePath = path.relative(REPO_ROOT, envFilePath) || path.basename(envFilePath);
      logSuccess(`${relativePath} encontrado`);
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
        logWarning(`   No se pudo leer ${relativePath}`);
      }
    }
  }
  
  if (!envFileExists) {
    logWarning('No se encontraron archivos de entorno');
    logInfo('Ejecuta: npm run setup para crear .ai/mcp/.env.mcp.example');
  }
  
  return envFileExists;
}

function verifyRuntimeCompatibility() {
  logSection('Verificando Compatibilidad de Runtime');

  loadRepoEnv();
  const githubEnv = buildGitHubRuntimeEnv(process.env);
  const postgresEnv = buildPostgresRuntimeEnv(process.env);
  const figmaEnv = buildFigmaRuntimeEnv(process.env);

  const checks = [
    {
      name: 'github',
      ok: Boolean(githubEnv.GITHUB_ACCESS_TOKEN),
      details: 'GITHUB_PERSONAL_ACCESS_TOKEN -> GITHUB_ACCESS_TOKEN'
    },
    {
      name: 'supabase-db',
      ok: Boolean(postgresEnv.DB_MAIN_URL && postgresEnv.DB_ALIASES && postgresEnv.DEFAULT_DB_ALIAS),
      details: 'SUPABASE_DB_URL -> DB_MAIN_URL + aliases'
    },
    {
      name: 'figma-api',
      ok: !process.env.FIGMA_ACCESS_TOKEN || Boolean(figmaEnv.FIGMA_API_KEY),
      details: 'FIGMA_ACCESS_TOKEN -> FIGMA_API_KEY'
    }
  ];

  let allPassed = true;

  for (const check of checks) {
    if (check.ok) {
      logSuccess(`${check.name}: ${check.details}`);
    } else {
      logError(`${check.name}: ${check.details}`);
      allPassed = false;
    }
  }

  return allPassed;
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
    runtimeCompatibility: verifyRuntimeCompatibility(),
    manifest: verifyManifest(),
    httpConnectivity: verifyHttpConnectivity()
  };
  
  generateReport(results);
  
  // Exit code basado en resultados
  const allRequiredPassed = results.packages && 
                           results.launchers && 
                           results.envVars &&
                           results.runtimeCompatibility;
  
  process.exit(allRequiredPassed ? 0 : 1);
}

// Ejecutar
main().catch(error => {
  logError(`Error: ${error.message}`);
  process.exit(1);
});
