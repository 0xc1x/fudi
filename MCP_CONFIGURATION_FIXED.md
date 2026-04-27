# MCP Configuration Fixed

## ✅ Paquetes MCP Actualizados

He actualizado los paquetes MCP para usar los nombres correctos que existen en npm:

### Paquetes Actualizados

| MCP | Paquete Anterior | Paquete Correcto |
|-----|------------------|------------------|
| GitHub | @modelcontextprotocol/server-github | github-mcp |
| Supabase DB | @modelcontextprotocol/server-postgres | postgres-mcp |
| Figma | @modelcontextprotocol/server-figma | figma-mcp |
| Linear | @modelcontextprotocol/server-linear | @mseep/linear-mcp |
| Slack | @modelcontextprotocol/server-slack | @aaronsb/slack-mcp |

### Archivos Actualizados

- ✅ `.ai/mcp/package.json` - Dependencias actualizadas
- ✅ `.ai/mcp/launchers/github.mjs` - Launcher actualizado
- ✅ `.ai/mcp/launchers/supabase-postgres.mjs` - Launcher actualizado
- ✅ `.ai/mcp/launchers/figma.mjs` - Launcher actualizado
- ✅ `.ai/mcp/launchers/linear.mjs` - Launcher actualizado
- ✅ `.ai/mcp/launchers/slack.mjs` - Launcher actualizado

## 🚀 Pasos Siguientes

### 1. Ejecutar Setup
```bash
cd .ai/mcp
npm run setup
```

### 2. Configurar Variables de Entorno
```bash
cp .env.mcp.example .env.mcp.local
# Editar con tus tokens
nano .env.mcp.local
```

### 3. Verificar Configuración
```bash
npm run verify
```

## 📦 Paquetes MCP Reales

Los paquetes MCP que realmente existen en npm son:

1. **github-mcp** - GitHub MCP Server con OAuth support
2. **postgres-mcp** - PostgreSQL MCP Server para AI agents
3. **figma-mcp** - Figma MCP Server
4. **@mseep/linear-mcp** - Linear MCP Server
5. **@aaronsb/slack-mcp** - Slack MCP Server

## ✅ Estado

**Configuración de MCPs: Actualizada y corregida**

Todos los paquetes ahora usan los nombres correctos que existen en npm. El setup debería funcionar correctamente ahora.

---

**Última actualización:** 2024-04-27
**Versión:** 1.1.0
**Total MCPs:** 11 (2 requeridos + 3 opcionales + 6 HTTP)
