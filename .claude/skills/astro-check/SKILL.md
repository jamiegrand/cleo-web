---
name: astro-check
description: Pre-deployment Astro project validation with best practices checks
disable-model-invocation: true
argument-hint: "[--fix] [--category=NAME]"
---

# Astro Check

Validates your Astro project configuration and code against current best practices before deployment.

## Prerequisites

This command requires Astro-specific MCPs:
- **astro-docs** - Documentation lookup for best practices
- **astro** (or astro-mcp) - Project state (routes, config, collections)

Ensure Astro dev server is running for full project state access:
```bash
npm run dev
```

## Usage

```
/astro-check              # Run all checks
/astro-check --fix        # Auto-fix issues where possible
/astro-check --category=config  # Run specific category only
```

## Categories

| Category | Checks |
|----------|--------|
| `config` | astro.config.* validation, output mode, adapters |
| `routing` | Route structure, dynamic routes, catch-all routes |
| `hydration` | Client directive usage (client:load, client:visible, etc.) |
| `images` | Image optimization with astro:assets |
| `content` | Content collections, schemas, frontmatter |
| `integrations` | Sitemap, MDX, image service configuration |
| `seo` | robots.txt, 404 page, meta patterns, canonical URLs |

## Execution Steps

### Step 1: Check Project State
Query astro MCP (if available) for:
- Astro version
- Output mode (static/server/hybrid)
- Configured integrations
- Route count and types
- Content collections

If astro MCP unavailable, check astro.config.* file directly.

### Step 2: Query Documentation
Use astro-docs MCP to:
- Check for deprecated APIs in codebase
- Verify patterns match current best practices
- Identify breaking changes from Astro 4 → 5

### Step 3: Run Category Checks
For each category, check files and patterns:

**Configuration Checks:**
- ASTRO-CFG-001: Output mode matches hosting
- ASTRO-CFG-002: Base URL set if subdirectory
- ASTRO-CFG-003: Trailing slash consistency
- ASTRO-CFG-004: Correct build output directory
- ASTRO-CFG-005: Adapter present if using SSR

**Hydration Checks:**
- ASTRO-HYD-001: No unnecessary client:load on static components
- ASTRO-HYD-002: Interactive components have directives
- ASTRO-HYD-003: client:only not overused

**Image Checks:**
- ASTRO-IMG-001: Using astro:assets for images
- ASTRO-IMG-002: All images have alt text
- ASTRO-IMG-003: Large images use responsive sizing

**SEO Checks:**
- ASTRO-SEO-001: robots.txt exists
- ASTRO-SEO-002: Custom 404.astro exists
- ASTRO-SEO-003: Consistent meta pattern
- ASTRO-SEO-004: Canonical tags present

### Step 4: Output Results

Display categorized results with:
- Check code (e.g., ASTRO-HYD-001)
- Pass/fail status
- File location for failures
- Fix suggestion
- Auto-fixable indicator

### Step 5: Auto-Fix (if --fix)

For auto-fixable issues:
1. Show what will be changed
2. Apply fix
3. Report success/failure
4. Re-run check to verify

## Output Format

```
ASTRO CHECK: project-name
════════════════════════════════════════════════════════════════

Astro Version: 5.0.0
Output Mode: static
Integrations: 4 configured
Routes: 47 (44 static, 3 dynamic)

CHECK RESULTS:

Configuration (5/5) ✓
Hydration (2/3) ⚠
  ✗ ASTRO-HYD-001: Unnecessary client:load on <Footer />
    File: src/components/Footer.astro
    Fix: Remove client:load directive [auto-fixable]

Images (4/4) ✓
SEO (3/4) ⚠
  ✗ ASTRO-SEO-002: Missing 404 page
    Fix: Create src/pages/404.astro

────────────────────────────────────────────────────────────────
SUMMARY: 2 issues found (1 auto-fixable)

Run /astro-check --fix to auto-fix
```

## Arguments
$ARGUMENTS
