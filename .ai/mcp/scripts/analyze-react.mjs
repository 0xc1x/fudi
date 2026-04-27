#!/usr/bin/env node

/**
 * Script para analizar código React existente y extraer patrones
 * Útil para migración React → Flutter
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuración
const CONFIG = {
  sourceDir: process.argv[2] || 'src',
  outputFile: process.argv[3] || 'react-analysis.json'
};

// Patrones a buscar
const PATTERNS = {
  useState: /useState\s*<([^>]*)>/g,
  useEffect: /useEffect\s*\(/g,
  useContext: /useContext\s*<([^>]*)>/g,
  useSelector: /useSelector\s*\(/g,
  useDispatch: /useDispatch\s*\(/g,
  useNavigate: /useNavigate\s*\(/g,
  useParams: /useParams\s*\(/g,
  useMemo: /useMemo\s*\(/g,
  useCallback: /useCallback\s*\(/g,
  useRef: /useRef\s*<([^>]*)>/g,
  component: /export\s+(default\s+)?(const|function)\s+(\w+)/g,
  hook: /use\w+\s*=/g
};

function findReactFiles(dir) {
  const files = [];
  
  function traverse(currentDir) {
    const items = fs.readdirSync(currentDir);
    
    for (const item of items) {
      const fullPath = path.join(currentDir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory()) {
        // Ignorar node_modules y carpetas de build
        if (!['node_modules', 'dist', 'build', '.next'].includes(item)) {
          traverse(fullPath);
        }
      } else if (stat.isFile() && /\.(jsx|js|tsx|ts)$/.test(item)) {
        files.push(fullPath);
      }
    }
  }
  
  traverse(dir);
  return files;
}

function analyzeFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const relativePath = path.relative(process.cwd(), filePath);
    
    const analysis = {
      file: relativePath,
      patterns: {},
      components: [],
      imports: [],
      exports: []
    };
    
    // Analizar patrones de hooks
    for (const [patternName, regex] of Object.entries(PATTERNS)) {
      const matches = content.match(regex);
      if (matches) {
        analysis.patterns[patternName] = matches.length;
      }
    }
    
    // Extraer componentes
    const componentMatches = content.matchAll(PATTERNS.component);
    for (const match of componentMatches) {
      analysis.components.push({
        name: match[3],
        isDefault: !!match[2]
      });
    }
    
    // Extraer imports
    const importRegex = /import\s+.*from\s+['"]([^'"]+)['"]/g;
    const importMatches = content.matchAll(importRegex);
    for (const match of importMatches) {
      analysis.imports.push(match[1]);
    }
    
    // Extraer exports
    const exportRegex = /export\s+(default\s+)?(?:const|function|class)\s+(\w+)/g;
    const exportMatches = content.matchAll(exportRegex);
    for (const match of exportMatches) {
      analysis.exports.push({
        name: match[2],
        isDefault: !!match[1]
      });
    }
    
    return analysis;
  } catch (error) {
    console.error(`Error analyzing ${filePath}:`, error.message);
    return null;
  }
}

function generateReport(analyses) {
  const report = {
    timestamp: new Date().toISOString(),
    summary: {
      totalFiles: analyses.length,
      totalComponents: 0,
      patterns: {}
    },
    files: analyses,
    recommendations: []
  };
  
  // Calcular resumen
  for (const analysis of analyses) {
    report.summary.totalComponents += analysis.components.length;
    
    for (const [pattern, count] of Object.entries(analysis.patterns)) {
      report.summary.patterns[pattern] = (report.summary.patterns[pattern] || 0) + count;
    }
  }
  
  // Generar recomendaciones
  if (report.summary.patterns.useState > 0) {
    report.recommendations.push({
      type: 'state',
      message: `Found ${report.summary.patterns.useState} useState calls - consider using Riverpod StateProvider`,
      priority: 'high'
    });
  }
  
  if (report.summary.patterns.useEffect > 0) {
    report.recommendations.push({
      type: 'effects',
      message: `Found ${report.summary.patterns.useEffect} useEffect calls - map to ProviderListener or ref.onDispose`,
      priority: 'high'
    });
  }
  
  if (report.summary.patterns.useSelector > 0 || report.summary.patterns.useDispatch > 0) {
    report.recommendations.push({
      type: 'redux',
      message: `Found Redux patterns - consider StateNotifierProvider for complex state`,
      priority: 'medium'
    });
  }
  
  if (report.summary.patterns.useNavigate > 0) {
    report.recommendations.push({
      type: 'routing',
      message: `Found ${report.summary.patterns.useNavigate} useNavigate calls - configure go_router`,
      priority: 'high'
    });
  }
  
  return report;
}

function main() {
  console.log('🔍 Analyzing React code...');
  console.log(`📁 Source directory: ${CONFIG.sourceDir}`);
  
  if (!fs.existsSync(CONFIG.sourceDir)) {
    console.error(`❌ Source directory not found: ${CONFIG.sourceDir}`);
    process.exit(1);
  }
  
  const files = findReactFiles(CONFIG.sourceDir);
  console.log(`📄 Found ${files.length} React files`);
  
  const analyses = [];
  for (const file of files) {
    const analysis = analyzeFile(file);
    if (analysis) {
      analyses.push(analysis);
    }
  }
  
  const report = generateReport(analyses);
  
  // Guardar reporte
  fs.writeFileSync(CONFIG.outputFile, JSON.stringify(report, null, 2));
  console.log(`✅ Report saved to: ${CONFIG.outputFile}`);
  
  // Mostrar resumen
  console.log('\n📊 Summary:');
  console.log(`   Total files: ${report.summary.totalFiles}`);
  console.log(`   Total components: ${report.summary.totalComponents}`);
  console.log('\n🔢 Patterns found:');
  for (const [pattern, count] of Object.entries(report.summary.patterns)) {
    console.log(`   ${pattern}: ${count}`);
  }
  
  console.log('\n💡 Recommendations:');
  for (const rec of report.recommendations) {
    console.log(`   [${rec.priority.toUpperCase()}] ${rec.message}`);
  }
}

main();
