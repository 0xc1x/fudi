#!/usr/bin/env node

/**
 * MCP Setup Script
 * 
 * Este script configura todos los MCPs para el proyecto Fudi.
 * Instala dependencias, verifica configuración y crea archivos de ejemplo.
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
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function logStep(step, message) {
  log(`\n${colors.cyan}[${step}] ${message}${colors.reset}`);
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

// MCPs configurados
const MCPs = {
  required: [
    {
      name: 'github',
      package: 'github-mcp',
      envVar: 'GITHUB_PERSONAL_ACCESS_TOKEN',
      description: 'GitHub API para gestión de repositorios'
    },
    {
      name: 'supabase-db',
      package: 'postgres-mcp',
      envVar: 'SUPABASE_DB_URL',
      description: 'Supabase PostgreSQL para introspección de base de datos'
    }
  ],
  optional: [
    {
      name: 'figma-api',
      package: 'figma-mcp',
      envVar: 'FIGMA_ACCESS_TOKEN',
      description: 'Figma API para extraer designs y componentes'
    },
    {
      name: 'linear',
      package: '@mseep/linear-mcp',
      envVar: 'LINEAR_API_KEY',
      description: 'Linear API para gestión de tareas'
    },
    {
      name: 'slack-notifications',
      package: '@aaronsb/slack-mcp',
      envVar: 'SLACK_WEBHOOK_URL',
      description: 'Slack webhooks para notificaciones'
    }
  ],
  http: [
    {
      name: 'openaiDeveloperDocs',
      url: 'https://developers.openai.com/mcp',
      description: 'Documentación oficial de OpenAI'
    },
    {
      name: 'react-docs',
      url: 'https://react.dev/learn',
      description: 'Documentación oficial de React'
    },
    {
      name: 'flutter-docs',
      url: 'https://docs.flutter.dev',
      description: 'Documentación oficial de Flutter'
    },
    {
      name: 'flutter-testing',
      url: 'https://docs.flutter.dev/cookbook/testing',
      description: 'Documentación de testing de Flutter'
    },
    {
      name: 'jest-docs',
      url: 'https://jestjs.io/docs/getting-started',
      description: 'Documentación de Jest'
    },
    {
      name: 'github-actions',
      url: 'https://docs.github.com/en/actions',
      description: 'Documentación de GitHub Actions'
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

// Verificar si Node.js está instalado
function checkNodeVersion() {
  try {
    const version = execSync('node --version', { encoding: 'utf-8' }).trim();
    const majorVersion = parseInt(version.slice(1).split('.')[0]);
    
    if (majorVersion < 18) {
      logError(`Node.js versión ${version} detectada. Se requiere Node.js 18 o superior.`);
      return false;
    }
    
    logSuccess(`Node.js ${version} detectado`);
    return true;
  } catch (error) {
    logError('Node.js no está instalado');
    return false;
  }
}

// Verificar si npm está instalado
function checkNpmVersion() {
  try {
    const version = execSync('npm --version', { encoding: 'utf-8' }).trim();
    logSuccess(`npm ${version} detectado`);
    return true;
  } catch (error) {
    logError('npm no está instalado');
    return false;
  }
}

// Instalar dependencias de npm
function installDependencies() {
  logStep('1', 'Instalando dependencias de npm...');
  
  try {
    logInfo('Ejecutando: npm install');
    execSync('npm install', { 
      cwd: path.join(__dirname, '..'),
      stdio: 'inherit'
    });
    logSuccess('Dependencias instaladas correctamente');
    return true;
  } catch (error) {
    logError('Error al instalar dependencias');
    logInfo('Intenta ejecutar manualmente: npm install');
    return false;
  }
}

// Verificar launchers
function verifyLaunchers() {
  logStep('2', 'Verificando launchers de MCP...');
  
  const launchersDir = path.join(__dirname, '..', 'launchers');
  const requiredLaunchers = ['github.mjs', 'supabase-postgres.mjs'];
  const optionalLaunchers = ['figma.mjs', 'linear.mjs', 'slack.mjs'];
  
  let allRequiredPresent = true;
  
  logInfo('Verificando launchers requeridos:');
  for (const launcher of requiredLaunchers) {
    const launcherPath = path.join(launchersDir, launcher);
    if (fs.existsSync(launcherPath)) {
      logSuccess(`${launcher} encontrado`);
    } else {
      logError(`${launcher} no encontrado`);
      allRequiredPresent = false;
    }
  }
  
  logInfo('Verificando launchers opcionales:');
  for (const launcher of optionalLaunchers) {
    const launcherPath = path.join(launchersDir, launcher);
    if (fs.existsSync(launcherPath)) {
      logSuccess(`${launcher} encontrado`);
    } else {
      logWarning(`${launcher} no encontrado (opcional)`);
    }
  }
  
  return allRequiredPresent;
}

// Verificar archivo de entorno
function verifyEnvFile() {
  logStep('3', 'Verificando archivos de entorno...');
  
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
    logInfo('Se creará .env.mcp.example con variables de ejemplo');
    createEnvExample();
  }
  
  return envFileExists;
}

// Crear archivo de ejemplo
function createEnvExample() {
  const envExamplePath = path.join(REPO_ROOT, '.env.mcp.example');
  
  const envContent = `# MCP Environment Variables Example
# Copy this file to .env.mcp.local and fill in your actual values

# Required MCPs
GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token_here
SUPABASE_DB_URL=postgresql://postgres:password@db.supabase.co:5432/postgres

# Optional MCPs - Uncomment if needed

# Figma API (for design integration)
# FIGMA_ACCESS_TOKEN=your_figma_token_here

# Linear (for task management)
# LINEAR_API_KEY=your_linear_api_key_here

# Slack Notifications (for build/deployment notifications)
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
`;
  
  try {
    fs.writeFileSync(envExamplePath, envContent);
    logSuccess('.env.mcp.example creado');
    logInfo('Copia este archivo a .env.mcp.local y completa los valores');
  } catch (error) {
    logError('Error al crear .env.mcp.example');
  }
}

// Verificar variables de entorno
function verifyEnvVars() {
  logStep('4', 'Verificando variables de entorno...');
  
  // Cargar variables de entorno desde archivos
  loadRepoEnv();
  
  let allRequiredPresent = true;
  
  logInfo('Verificando variables requeridas:');
  for (const mcp of MCPs.required) {
    const value = process.env[mcp.envVar];
    if (value) {
      logSuccess(`${mcp.envVar} configurada`);
    } else {
      logWarning(`${mcp.envVar} no configurada`);
      allRequiredPresent = false;
    }
  }
  
  logInfo('Verificando variables opcionales:');
  for (const mcp of MCPs.optional) {
    const value = process.env[mcp.envVar];
    if (value) {
      logSuccess(`${mcp.envVar} configurada`);
    } else {
      logWarning(`${mcp.envVar} no configurada (opcional)`);
    }
  }
  
  return allRequiredPresent;
}

// Mostrar resumen de MCPs
function showMcpSummary() {
  logStep('5', 'Resumen de MCPs configurados...');
  
  logInfo('\n📦 MCPs Requeridos (stdio):');
  for (const mcp of MCPs.required) {
    const configured = process.env[mcp.envVar] ? '✅' : '❌';
    log(`   ${configured} ${mcp.name.padEnd(20)} - ${mcp.description}`);
  }
  
  logInfo('\n📦 MCPs Opcionales (stdio):');
  for (const mcp of MCPs.optional) {
    const configured = process.env[mcp.envVar] ? '✅' : '❌';
    log(`   ${configured} ${mcp.name.padEnd(20)} - ${mcp.description}`);
  }
  
  logInfo('\n📦 MCPs HTTP (sin configuración):');
  for (const mcp of MCPs.http) {
    log(`   ✅ ${mcp.name.padEnd(20)} - ${mcp.description}`);
  }
}

// Mostrar instrucciones siguientes
function showNextSteps() {
  logStep('6', 'Instrucciones siguientes...');
  
  logInfo('\n📋 Pasos para completar la configuración:\n');
  
  log('1. Configurar variables de entorno requeridas:', colors.cyan);
  log('   cp .env.mcp.example .env.mcp.local');
  log('   # Editar .env.mcp.local con tus valores reales\n');
  
  log('2. Obtener tokens necesarios:', colors.cyan);
  log('   - GitHub Personal Access Token:');
  log('     https://github.com/settings/tokens');
  log('   - Supabase Database URL:');
  log('     https://supabase.com/dashboard/project/_/settings/database\n');
  
  log('3. (Opcional) Configurar MCPs adicionales:', colors.cyan);
  log('   - Figma Access Token:');
  log('     https://www.figma.com/developers/api#access-tokens');
  log('   - Linear API Key:');
  log('     https://linear.app/settings/api');
  log('   - Slack Webhook URL:');
  log('     https://api.slack.com/messaging/webhooks\n');
  
  log('4. Verificar configuración:', colors.cyan);
  log('   npm run verify\n');
  
  log('5. Usar MCPs en tu herramienta:', colors.cyan);
  log('   Consulta la documentación de tu herramienta para configurar MCPs\n');
}

// Función principal
async function main() {
  log('\n🚀 MCP Setup para Fudi', colors.magenta);
  log('═'.repeat(50), colors.magenta);
  
  // Verificar prerequisitos
  if (!checkNodeVersion() || !checkNpmVersion()) {
    logError('Prerequisitos no cumplidos. Abortando.');
    process.exit(1);
  }
  
  // Instalar dependencias
  if (!installDependencies()) {
    logError('No se pudieron instalar dependencias. Abortando.');
    process.exit(1);
  }
  
  // Verificar configuración
  verifyLaunchers();
  verifyEnvFile();
  verifyEnvVars();
  
  // Mostrar resumen
  showMcpSummary();
  
  // Mostrar instrucciones
  showNextSteps();
  
  log('\n✨ Setup completado', colors.green);
  log('═'.repeat(50), colors.magenta);
}

// Ejecutar
main().catch(error => {
  logError(`Error: ${error.message}`);
  process.exit(1);
});
