---
description: Pre-deployment Astro project validation
requires: [astro-mcp, astro-docs]
---

# /astro-check

Validates your Astro project configuration and code against current best practices before deployment.

## Prerequisites

This command requires Astro-specific MCPs:
- **astro-mcp** - Project state (routes, config, collections)
- **astro-docs** - Documentation lookup for best practices

Run `/start` to verify MCP availability.

## Syntax

```
/astro-check [--fix] [--category=NAME]
```

## Options

| Option | Description |
|--------|-------------|
| (none) | Run all checks |
| `--fix` | Attempt automatic fixes where possible |
| `--category=NAME` | Run specific category only |

### Categories

| Name | Checks |
|------|--------|
| `config` | astro.config.* validation |
| `routing` | Route structure and dynamic routes |
| `hydration` | Client directive usage |
| `images` | Image optimization |
| `content` | Content collections |
| `integrations` | Integration configuration |
| `seo` | SEO-related settings |

## Execution Flow

### Step 1: Query Project State

Use `astro-mcp` to gather:
```
- Astro version
- Output mode (static/server/hybrid)
- Configured integrations
- Route count and types
- Content collections
```

### Step 2: Run Checks

#### Configuration Checks

| Check | Code | What to Verify |
|-------|------|----------------|
| Output mode | ASTRO-CFG-001 | Matches hosting environment |
| Base URL | ASTRO-CFG-002 | Set if deploying to subdirectory |
| Trailing slash | ASTRO-CFG-003 | Consistent handling |
| Build output | ASTRO-CFG-004 | Correct output directory |
| Adapter | ASTRO-CFG-005 | Present if using SSR |

#### Hydration Checks

| Check | Code | What to Verify |
|-------|------|----------------|
| Unnecessary client:load | ASTRO-HYD-001 | Static components using client:load |
| Missing hydration | ASTRO-HYD-002 | Interactive components without directive |
| client:only misuse | ASTRO-HYD-003 | Overuse of client:only |

#### Image Checks

| Check | Code | What to Verify |
|-------|------|----------------|
| Using astro:assets | ASTRO-IMG-001 | Images imported from astro:assets |
| Alt text | ASTRO-IMG-002 | All images have alt attributes |
| Responsive images | ASTRO-IMG-003 | Large images use responsive sizing |
| Format optimization | ASTRO-IMG-004 | WebP/AVIF for supported browsers |

#### Content Collection Checks

| Check | Code | What to Verify |
|-------|------|----------------|
| Schema defined | ASTRO-COL-001 | Collections have schemas |
| Required fields | ASTRO-COL-002 | Frontmatter matches schema |
| Draft handling | ASTRO-COL-003 | Drafts filtered in production |

#### Integration Checks

| Check | Code | What to Verify |
|-------|------|----------------|
| Sitemap configured | ASTRO-INT-001 | @astrojs/sitemap present |
| Image service | ASTRO-INT-002 | Image optimization enabled |
| MDX if using .mdx | ASTRO-INT-003 | @astrojs/mdx present if needed |

#### SEO Checks

| Check | Code | What to Verify |
|-------|------|----------------|
| robots.txt | ASTRO-SEO-001 | Exists at public/robots.txt |
| 404 page | ASTRO-SEO-002 | Custom 404.astro exists |
| Meta component | ASTRO-SEO-003 | Using consistent meta pattern |
| Canonical URLs | ASTRO-SEO-004 | Canonical tags present |

### Step 3: Check for Deprecations

Query `astro-docs` for:
- Deprecated APIs in use
- Breaking changes from Astro 4 → 5
- Removed features

### Step 4: Output Results

## Output Format

### All Checks Passed

```
ASTRO CHECK: project-name
════════════════════════════════════════════════════════════════

Astro Version: 5.0.0
Output Mode: static
Integrations: 4 configured
Routes: 47 (44 static, 3 dynamic)
Collections: 2 (blog, docs)

All checks passed! ✓

Your Astro project is ready for deployment.
```

### Issues Found

```
ASTRO CHECK: project-name
════════════════════════════════════════════════════════════════

Astro Version: 5.0.0
Output Mode: static

CHECK RESULTS:

Configuration (5/5) ✓
Hydration (2/3) ⚠
  ✗ ASTRO-HYD-001: Unnecessary client:load on <Footer />
    File: src/components/Footer.astro
    Issue: Footer has no interactive elements
    Fix: Remove client:load directive

Images (3/4) ⚠
  ✗ ASTRO-IMG-001: Not using astro:assets
    Files: src/pages/about.astro, src/pages/team.astro
    Issue: Using <img> instead of <Image />
    Fix: Import from 'astro:assets' and use <Image />

Content Collections (4/4) ✓
Integrations (3/3) ✓
SEO (3/4) ⚠
  ✗ ASTRO-SEO-002: Missing 404 page
    Issue: No src/pages/404.astro found
    Fix: Create custom 404 page

────────────────────────────────────────────────────────────────
SUMMARY: 3 issues found

Run /astro-check --fix to auto-fix 2 issues
```

### Auto-Fix Mode

```
/astro-check --fix

ASTRO CHECK: Auto-Fix Mode
════════════════════════════════════════════════════════════════

Fixing 2 auto-fixable issues...

1. ASTRO-HYD-001: Remove client:load from Footer
   File: src/components/Footer.astro
   Action: Removed client:load directive
   Status: ✓ Fixed

2. ASTRO-SEO-002: Create 404 page
   File: src/pages/404.astro
   Action: Created basic 404 page template
   Status: ✓ Created

────────────────────────────────────────────────────────────────
Fixed: 2 issues
Remaining: 1 issue (requires manual fix)

Re-run /astro-check to verify fixes
```

## Best Practice Recommendations

After checks pass, the command may suggest optimizations:

```
RECOMMENDATIONS:

Performance:
• Consider using client:visible instead of client:idle for
  below-fold components (Newsletter, Comments)

SEO:
• Add @astrojs/sitemap integration for automatic sitemap

Content:
• Add image field to blog collection schema for social sharing

These are suggestions, not requirements.
```

## Integration with Other Commands

### /start Integration

When `/start` detects an Astro project:
1. Shows Astro version and output mode
2. Suggests running `/astro-check` if not run recently

### /audit site Integration

Site audit includes Astro-specific checks when adapter is active:
- ASTRO category in audit results
- Astro-specific issues create tasks

### /feature Integration

Before completing a feature, `/feature` can run `/astro-check` to verify no regressions.

## Error Handling

### MCP Not Available

```
ERROR: astro-mcp required for /astro-check

The Astro MCP integration is not available.

Setup:
1. Ensure you're in an Astro project
2. Install: npm install astro-mcp
3. Add to your Astro config
4. Restart Claude Code

Alternative: Run /audit site for general checks
```

### Not an Astro Project

```
ERROR: No Astro project detected

This command requires an Astro project.

Looking for: astro.config.mjs, astro.config.js, or astro.config.ts

If this is an Astro project, ensure the config file exists
in the project root.
```

## Related Commands

- `/start` - Session start with Astro detection
- `/audit site` - Site-wide audit including Astro checks
- `/feature` - Feature development with Astro best practices
