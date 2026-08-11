# MCP Configuration Complete Guide

Esta guía explica paso a paso cómo configurar todos los MCPs (Model Context Protocol) para el proyecto Fudi.

## 📋 Resumen de MCPs

### MCPs Requeridos (2)

| Nombre | Tipo | Paquete | Variable de Entorno | Descripción |
|--------|------|---------|---------------------|-------------|
| `github` | stdio | github-mcp | GITHUB_PERSONAL_ACCESS_TOKEN | GitHub API para gestión de repositorios |
| `supabase` | remote/HTTP | MCP oficial Supabase | (OAuth por harness) | Base de datos, auth, functions, branching |

### MCPs Opcionales (2)

| Nombre | Tipo | Paquete | Variable de Entorno | Descripción |
|--------|------|---------|---------------------|-------------|
| `figma-api` | stdio | figma-mcp | FIGMA_ACCESS_TOKEN | Figma API para designs y componentes |
| `linear` | stdio | @mseep/linear-mcp | LINEAR_API_KEY | Linear API para gestión de tareas |

### MCPs HTTP (6)

| Nombre | URL | Descripción |
| -------- | ----- | ------------- |
| `openaiDeveloperDocs` | <https://developers.openai.com/mcp> | Documentación de OpenAI |
| `react-docs` | <https://react.dev/learn> | Documentación de React |
| `flutter-docs` | <https://docs.flutter.dev> | Documentación de Flutter |
| `flutter-testing` | <https://docs.flutter.dev/cookbook/testing> | Testing de Flutter |
| `jest-docs` | <https://jestjs.io/docs/getting-started> | Documentación de Jest |
| `github-actions` | <https://docs.github.com/en/actions> | Documentación de GitHub Actions |

## 🚀 Configuración Rápida

### Paso 1: Ejecutar Script de Setup

```bash
cd .ai/mcp
npm run setup
```

Este script:

- ✅ Verifica Node.js y npm
- ✅ Instala dependencias necesarias
- ✅ Verifica launchers
- ✅ Crea archivo de ejemplo `.env.mcp.example`
- ✅ Muestra instrucciones siguientes

### Paso 2: Configurar Variables de Entorno

```bash
# Copiar archivo de ejemplo
cp .env.mcp.example .env.mcp.local

# Editar con tus valores
nano .env.mcp.local
```

### Paso 3: Verificar Configuración

```bash
npm run verify
```

## 📝 Configuración Detallada

## 🔁 Traducción de variables runtime

Los launchers del repo traducen variables canónicas a lo que espera cada paquete upstream:

| MCP | Variable canónica | Variable upstream |
| ----- | ------------------- | ------------------ |
| GitHub | `GITHUB_PERSONAL_ACCESS_TOKEN` | `GITHUB_ACCESS_TOKEN` |
| Figma | `FIGMA_ACCESS_TOKEN` | `FIGMA_API_KEY` |

> Supabase usa OAuth por harness — no requiere variables de entorno.

### Requisitos Previos

#### Node.js y npm

```bash
# Verificar Node.js (requerido: 18+)
node --version

# Verificar npm
npm --version

# Si no están instalados, instalar desde:
# https://nodejs.org/
```

### MCPs Requeridos

#### 1. GitHub MCP

**Propósito:** Gestión de repositorios, issues, PRs y metadata.

**Obtener Token:**

1. Ir a [GitHub Settings → Developer Settings → Personal Access Tokens](https://github.com/settings/tokens)
2. Click en "Generate new token" → "Generate new token (classic)"
3. Configurar permisos:
   - ✅ `repo` (full control)
   - ✅ `read:org` (read org data)
   - ✅ `read:user` (read user data)
4. Generar token y **copiarlo inmediatamente** (solo se muestra una vez)

**Configurar:**

```bash
# Agregar a .env.mcp.local
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Verificar:**

```bash
# Test con GitHub CLI
gh auth status

# O test con curl
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
```

#### 2. Supabase MCP (oficial, remoto)

**Propósito:** Introspección de esquema, tablas, columnas, relaciones, migraciones y consultas sobre Supabase.

Usa el **MCP remoto oficial** — no hay launcher local ni `SUPABASE_DB_URL`.

**Configurar:** añade la URL del MCP en la config de tu herramienta:

```json
{
  "mcp": {
    "supabase": {
      "type": "remote",
      "url": "https://mcp.supabase.com/mcp?project_ref=sxqopofoynsqkztozlix&features=docs%2Caccount%2Cdatabase%2Cdebugging%2Cdevelopment%2Cfunctions%2Cbranching",
      "enabled": true
    }
  }
}
```

**Autenticar (OAuth por harness):**

- OpenCode: `opencode mcp auth supabase`
- Codex: `codex mcp login supabase`
- Otras herramientas (Cursor, VS Code, Zed, Gemini, Claude): flujo OAuth del cliente MCP — abre el navegador para completar el login de Supabase.

**Verificar:** tras autenticar, ejecuta una consulta (ej: `list_tables` / `execute_sql`) en tu herramienta.

### MCPs Opcionales

#### 3. Figma API MCP

**Propósito:** Extraer designs, componentes y especificaciones visuales.

**Obtener Token:**

1. Ir a [Figma Developer Settings](https://www.figma.com/developers/api#access-tokens)
2. Click en "Generate new personal access token"
3. Dar un nombre descriptivo (ej: "Fudi MCP")
4. Generar token y **copiarlo**

**Configurar:**

```bash
# Agregar a .env.mcp.local
FIGMA_ACCESS_TOKEN=figd_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Verificar:**

```bash
# Test con curl
curl -H "X-Figma-Token: YOUR_TOKEN" https://api.figma.com/v1/me
```

#### 4. Linear MCP

**Propósito:** Gestión de tareas, issues y proyectos.

**Obtener API Key:**

1. Ir a [Linear Settings → API](https://linear.app/settings/api)
2. Click en "Create personal API key"
3. Dar permisos necesarios:
   - ✅ `Read`
   - ✅ `Write`
   - ✅ `Comments`
4. Crear key y **copiarla**

**Configurar:**

```bash
# Agregar a .env.mcp.local
LINEAR_API_KEY=lin_api_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Verificar:**

```bash
# Test con curl
curl -H "Authorization: YOUR_KEY" https://api.linear.app/graphql
```

## 🔧 Scripts de Automatización

### Setup Script

```bash
cd .ai/mcp
npm run setup
```

**Funciones:**

- Verifica Node.js y npm
- Instala dependencias
- Verifica launchers
- Crea `.env.mcp.example`
- Muestra instrucciones

### Verify Script

```bash
cd .ai/mcp
npm run verify
```

**Funciones:**

- Verifica paquetes instalados
- Verifica launchers
- Verifica variables de entorno
- Verifica archivos de entorno
- Genera reporte

## 📁 Estructura de Archivos

```
.ai/mcp/
├── package.json                          # Dependencias npm
├── mcp.manifest.json                     # Manifiesto de MCPs
├── README.md                             # Esta guía
├── .env.mcp.example                      # Ejemplo de variables
├── .env.mcp.local                        # Tus variables locales MCP (no commits)
├── launchers/                            # Scripts de launchers
│   ├── github.mjs
│   ├── figma.mjs
│   ├── linear.mjs
│   └── slack.mjs
├── lib/                                  # Utilidades compartidas
│   └── env-loader.mjs
└── scripts/                              # Scripts de automatización
    ├── setup.js
    └── verify.js
```

## 🔐 Seguridad

### Best Practices

1. **Nunca commits archivos con secrets**

   ```gitignore
   # .gitignore
   .env
   .env.local
   .env.mcp
   .env.mcp.local
   .ai/mcp/.env.mcp
   .ai/mcp/.env.mcp.local
   ```

2. **Usar tokens con permisos mínimos necesarios**
   - GitHub: Solo permisos `repo`, `read:org`, `read:user`
   - Supabase: OAuth con el alcance mínimo que pida el MCP (por harness)
   - Figma: Solo permisos de lectura
   - Linear: Permisos específicos por equipo
3. **Rotar tokens periódicamente**
   - GitHub: Cada 90 días
   - Supabase: Revoca/reautoriza el acceso OAuth desde Supabase Dashboard si sospechas uso indebido
   - Figma: Cada año
   - Linear: Cada 90 días

4. **Usar variables de entorno en lugar de archivos hardcoded**

   ```bash
   # ❌ MAL
   const token = "ghp_xxxxxxxxxxxx";
   
   # ✅ BIEN
   const token = process.env.GITHUB_PERSONAL_ACCESS_TOKEN;
   ```

5. **Limitar acceso a tokens**
   - GitHub: Revisar "Authorized OAuth Apps" regularmente
   - Supabase: Revisar las sesiones OAuth autorizadas en Supabase Dashboard
   - Figma: Revisar "Personal Access Tokens" en settings
   - Linear: Revisar "API Keys" en settings

## 🐛 Troubleshooting

### Error: "Node.js not found"

**Solución:**

```bash
# Instalar Node.js 18+
# macOS (Homebrew)
brew install node

# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Windows
# Descargar desde https://nodejs.org/
```

### Error: "Package not found"

**Solución:**

```bash
cd .ai/mcp
npm install

# Si falla, limpiar cache e intentar de nuevo
npm cache clean --force
npm install
```

### Error: "Environment variable not set"

**Solución:**

```bash
# Verificar que el archivo existe
ls -la .env.mcp.local

# Verificar contenido
cat .env.mcp.local

# Recargar variables
source .env.mcp.local  # Linux/macOS
# o
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")  # Windows PowerShell
```

### Error: "Launcher not found"

**Solución:**

```bash
# Verificar que los launchers existan
ls -la .ai/mcp/launchers/

# Si faltan, ejecutar setup
cd .ai/mcp
npm run setup
```

### Error: "GitHub token invalid"

**Solución:**

```bash
# Verificar token con GitHub CLI
gh auth status

# Si es inválido, generar nuevo token
# https://github.com/settings/tokens

# Actualizar .env.mcp.local
```

### Error: "Supabase MCP no autenticado"

**Solución:**

```bash
# OpenCode
opencode mcp auth supabase

# Codex
codex mcp login supabase
```

Autentica por OAuth (abre el navegador). No se usa `SUPABASE_DB_URL` ni psql.

## 📖 Referencias

### Documentación Oficial

- [Model Context Protocol](https://modelcontextprotocol.io)
- [GitHub MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [Postgres MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/postgres)
- [Figma API](https://www.figma.com/developers/api)
- [Linear API](https://developers.linear.app/docs)
- [Slack API](https://api.slack.com/)

### Herramientas

- [Node.js](https://nodejs.org/)
- [npm](https://www.npmjs.com/)
- [GitHub CLI](https://cli.github.com/)
- [Supabase CLI](https://supabase.com/docs/guides/cli)

## ✅ Checklist de Configuración

### Requisitos Previos

- [ ] Node.js 18+ instalado
- [ ] npm instalado
- [ ] Git configurado

### MCPs Requeridos

- [ ] GitHub Personal Access Token obtenido
- [ ] GitHub token configurado en `.env.mcp.local`
- [ ] Supabase OAuth autenticado por harness (`opencode mcp auth supabase`)

### MCPs Opcionales

- [ ] Figma Access Token obtenido (si aplica)
- [ ] Figma token configurado (si aplica)
- [ ] Linear API Key obtenida (si aplica)
- [ ] Linear key configurada (si aplica)

### Verificación

- [ ] `npm run setup` ejecutado sin errores
- [ ] `npm run verify` pasa todas las verificaciones
- [ ] Launchers creados correctamente
- [ ] Variables de entorno configuradas
- [ ] Conectividad verificada

### Integración

- [ ] MCPs configurados en tu herramienta (Cursor, VS Code, etc.)
- [ ] MCPs funcionando correctamente
- [ ] Testing de cada MCP completado

## 🎯 Próximos Pasos

1. **Ejecutar setup:**

   ```bash
   cd .ai/mcp
   npm run setup
   ```

2. **Configurar variables requeridas:**

   ```bash
   cp .env.mcp.example .env.mcp.local
   # Editar con tus tokens
   ```

3. **Verificar configuración:**

   ```bash
   npm run verify
   ```

4. **Configurar MCPs en tu herramienta:**
   - Cursor: Settings → MCP Servers
   - VS Code: Settings → MCP
   - Otra herramienta: Consulta su documentación

5. **Probar MCPs:**
   - GitHub: Crear un issue
   - Supabase: Autenticar por OAuth y ejecutar `list_tables` / `execute_sql`
   - HTTP MCPs: Consultar documentación

## 🎉 Estado

**✅ Configuración Completa**

- ✅ Todos los launchers creados
- ✅ Scripts de automatización creados
- ✅ Documentación completa
- ✅ Guía paso a paso
- ✅ Troubleshooting cubierto
- ✅ Best practices de seguridad

---

**Última actualización:** 2024-04-24
**Versión:** 1.0.0
**Total MCPs:** 10 (1 requerido + 3 opcionales + 6 HTTP)
