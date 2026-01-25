---
description: Setup and configuration tools
type: router
---

# /setup

Setup and configuration commands for cleo-web.

## Subcommands

### /setup verify

Verify all prerequisites and MCP connections.

```
/setup verify
```

Output:
```
CLEO-WEB SETUP VERIFICATION
────────────────────────────────────────

PREREQUISITES:
  ✓ jq installed (v1.7)
  ✓ sqlite3 installed (v3.40)
  ⚠ flock not found (using mkdir fallback)

DATA DIRECTORY:
  ✓ .cleo-web/ exists
  ✓ todo.json valid (15 tasks)
  ✓ config.json valid
  ✓ metrics.db accessible (245 KB)

MCP SERVERS:
  ✓ gsc - Connected
      Site: https://example.com/
      Last sync: 2h ago
  ✓ dataforseo - Connected
      API calls remaining: 9,850
  ✗ scraperapi - Not configured
      Missing: SCRAPERAPI_KEY environment variable
  ⚠ astro-docs - Available (optional)
  ⚠ astro-mcp - Available (optional)

FRAMEWORK:
  Detected: astro
  Adapter: adapters/astro/ADAPTER.md ✓

────────────────────────────────────────
Status: READY (optional MCPs missing)

To fix scraperapi:
  export SCRAPERAPI_KEY=your_api_key
```

### /setup init

Initialize or reinitialize cleo-web data directory.

```
/setup init
/setup init --force
```

Output:
```
INITIALIZING CLEO-WEB
────────────────────────────────────────

Creating directories:
  ✓ .cleo-web/
  ✓ .cleo-web/backups/

Creating files:
  ✓ todo.json (empty task list)
  ✓ config.json (default settings)
  ✓ metrics.db (initialized schema)

Detecting framework:
  Found: astro.config.mjs
  Framework: astro

Configuration saved.

Run /start to begin your first session.
```

### /setup mcps

Show MCP configuration guide.

```
/setup mcps
```

Output:
```
MCP CONFIGURATION GUIDE
────────────────────────────────────────

REQUIRED MCPs:

1. Google Search Console (gsc)
   Purpose: Ranking data, impressions, clicks, CTR
   Required for: /seo wins, /seo gaps, /seo roi, /seo refresh

   Setup:
   1. Create service account in Google Cloud Console
   2. Add to Search Console as user
   3. Set environment variables:
      export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
      export GSC_SITE_URL=https://yoursite.com/

2. DataForSEO
   Purpose: Keyword research, search volume, SERP data
   Required for: /seo keywords, /audit content

   Setup:
   export DATAFORSEO_USERNAME=your_username
   export DATAFORSEO_PASSWORD=your_password

3. ScraperAPI
   Purpose: HTML fetching, competitor analysis
   Required for: /audit site, competitor features

   Setup:
   export SCRAPERAPI_KEY=your_api_key

OPTIONAL MCPs (for Astro projects):

4. astro-docs
   Purpose: Official Astro documentation search
   URL: https://mcp.docs.astro.build/mcp

5. astro-mcp
   Purpose: Astro project integration
   Package: astro-mcp

Full documentation: docs/mcp-setup.md
```

### /setup maintenance

Run maintenance tasks.

```
/setup maintenance
/setup maintenance --clear-cache
/setup maintenance --backup
/setup maintenance --vacuum
```

Options:
- `--clear-cache` - Clear expired keyword cache
- `--backup` - Create full backup of data
- `--vacuum` - Optimize SQLite database
- `--prune` - Remove old audit history (>90 days)

Output:
```
MAINTENANCE COMPLETE
────────────────────────────────────────

Cache cleanup:
  Expired entries removed: 23
  Cache size: 128 KB → 98 KB

Database optimization:
  metrics.db vacuumed
  Size: 512 KB → 445 KB

Backup created:
  .cleo-web/backups/backup-2026-01-25.tar.gz
```

## Related Commands

- `/start` - Begin session with verification
- `/status` - Show current state
- `/help` - Show all commands
