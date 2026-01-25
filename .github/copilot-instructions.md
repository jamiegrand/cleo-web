# cleo-web: AI Agent Instructions

**Project Type**: Claude Code Plugin combining CLEO task management with SEO workflows  
**Architecture**: Bash-based command router → Skills-based execution → MCP integrations

## Core Architecture

### Plugin Anatomy

- **Commands** ([commands/](commands/)): Markdown-fronted command definitions with YAML metadata
- **Skills** ([skills/manifest.json](skills/manifest.json)): Capability-based modules with dispatch triggers
- **Libraries** ([lib/](lib/)): Shared bash utilities (file-ops, MCP checks, validation)
- **Adapters** ([adapters/](adapters/)): Framework-specific integrations (Astro, Next.js, Nuxt)

### Data Directory: `.cleo-web/`

- `todo.json` - Task hierarchy (epics/tasks/subtasks) with atomic operations
- `config.json` - Plugin + framework configuration
- `metrics.db` - SQLite time-series for SEO metrics and audit history
- `backups/` - Automatic rotation (max 5) for atomic file operations

## Critical Patterns

### 1. Atomic File Operations

**All JSON writes MUST use** [lib/file-ops.sh](lib/file-ops.sh) functions:

```bash
source "${CLEO_WEB_LIB_DIR}/file-ops.sh"
save_json "$data" "$file"  # Uses temp file + atomic move + backup
```

Never write directly to `todo.json` or `config.json`. The library provides:

- `atomic_write()` - Write with temp file swap
- `lock_file()` / `unlock_file()` - Multi-agent coordination (flock on Linux, mkdir fallback on macOS)
- Auto-rotation of 5 backups in `.cleo-web/backups/`

### 2. MCP Fail-Fast Pattern

**Always verify MCP availability before executing** commands that depend on external data:

```bash
source "${CLEO_WEB_LIB_DIR}/mcp-check.sh"
check_required_mcps "gsc dataforseo scraperapi" || {
    get_mcp_setup_instructions "gsc"
    exit 1
}
```

See [/start](commands/start.md#step-1-verify-mcp-availability) for canonical implementation.

### 3. Skills as Capabilities

Skills register dispatch triggers in [skills/manifest.json](skills/manifest.json). When Claude receives a command:

1. Parse command syntax → Identify intent
2. Match intent to skill's `dispatch_triggers`
3. Execute skill's SKILL.md instructions
4. Store results in `metrics.db` if persistent

Example: `"/audit content /blog/post"` → `ct-seo-auditor` skill → SQLite metrics + task creation for critical issues.

### 4. Framework Adapters

Activated by detection files ([adapters/astro/ADAPTER.md](adapters/astro/ADAPTER.md#detection)):

- **Astro**: Requires `astro-docs` and `astro-mcp` for route enumeration and content collection queries
- **Next.js/Nuxt**: Placeholders for future implementation

When framework detected:

- Loads adapter-specific best practices
- Enables framework MCP requirement checks
- Augments audit recommendations with framework-specific fixes

## Developer Workflows

### Installation Flow

```bash
./install.sh  # From target project directory
```

1. Checks prerequisites: `jq` (required), `sqlite3` (required), `flock` (optional)
2. Detects framework via config file presence
3. Creates `.cleo-web/` with initialized files
4. Runs SQLite schema migrations from [scripts/init-db.sql](scripts/init-db.sql)
5. Updates project's `CLAUDE.md` with plugin reference

### Session Lifecycle

1. **Start**: `/start` → MCP verification → Site health check → Priority generation
2. **Work**: Task CRUD via `/task` → Auto-backup on each modification
3. **Audit**: `/audit site` or `/audit content` → Results to `metrics.db` + auto-task creation
4. **End**: `/session end` → Summary with time tracking

### Debugging MCPs

```bash
# Test MCP availability
source lib/mcp-check.sh
check_mcp_available "gsc" && echo "GSC working"

# View MCP requirements for a skill
jq '.skills[] | select(.name == "ct-site-auditor") | .capabilities.requires_mcp' skills/manifest.json
```

## Key Conventions

### Task Hierarchy

- **Epic**: Large feature/initiative (e.g., "Improve Core Web Vitals")
- **Task**: Concrete deliverable (e.g., "Optimize LCP on homepage")
- **Subtask**: Implementation step (e.g., "Lazy-load hero image")

All tasks have `source` field for traceability (manual, audit, gsc, etc.).

### Audit Severity → Task Priority

```
critical → critical (site-breaking)
high     → high     (SEO impact)
medium   → medium   (nice-to-have)
low      → low      (informational)
```

### Shell Scripting Standards

- Use `set -euo pipefail` at script top (not in sourced libraries)
- Exit codes: 0 (success), 1-10 (semantic errors from file-ops.sh)
- Always sanitize paths via `sanitize_path()` before file operations
- Quote variables: `"${var}"` not `$var`

## External Dependencies

**Required MCP Servers** (fail-fast if missing):

- `gsc` - Google Search Console rankings/CTR
- `dataforseo` - Keyword research, Lighthouse, backlinks
- `scraperapi` - HTML fetching for schema/security checks

**Optional MCPs**:

- `playwright` - Visual testing (screenshots, mobile rendering)
- `astro-docs`, `astro-mcp` - Astro-specific integrations

Setup guides: [docs/mcp-setup.md](docs/mcp-setup.md)

## Testing & Validation

- **JSON validation**: [lib/validation.sh](lib/validation.sh) with schema checks (future: schemas/ directory)
- **Backup recovery**: `.cleo-web/backups/*.json` rotated automatically
- **Metrics queries**: SQLite CLI on `metrics.db` for trend analysis

## Common Gotchas

1. **MacOS flock**: Not built-in. Install via `brew install discoteq/discoteq/flock` or accept mkdir fallback
2. **Concurrent writes**: Lock files properly using `lock_file()` before JSON operations
3. **MCP timeouts**: GSC MCP can be slow; implement progress indicators for long-running audits
4. **Path handling**: Always use absolute paths in bash. Relative paths break when sourcing libraries.
