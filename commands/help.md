---
description: Show all available commands
---

# /help

Display all available cleo-web commands organized by category.

## Usage

```
/help
/help seo
/help audit
/help task
```

## Output

```
CLEO-WEB COMMANDS
────────────────────────────────────────

SESSION MANAGEMENT
  /start          Begin session with MCP verification
  /status         Show current project and session status
  /session        Session lifecycle (pause, resume, end)

TASK MANAGEMENT
  /task           Task management router
  /task add       Add a new task
  /task list      List tasks with filters
  /task complete  Mark task as complete

SEO & ANALYTICS (requires MCPs)
  /seo            SEO tools router
  /seo wins       Find quick-win opportunities (GSC)
  /seo gaps       Find content gaps (GSC + DataForSEO)
  /seo roi        Calculate ROI projections (GSC)
  /seo refresh    Find declining pages (GSC)
  /seo impact     Measure before/after effect (GSC)
  /seo keywords   Keyword research (DataForSEO)

QUALITY & AUDITING
  /audit          Content auditing router
  /audit content  Full SEO audit with 0-100 scoring
  /audit quick    Rapid 10-point assessment
  /audit eeat     Deep E-E-A-T analysis
  /audit batch    Audit multiple pages

DEVELOPMENT (Astro projects)
  /astro-check    Pre-deployment validation
  /feature        Spec-driven feature development

SETUP & HELP
  /setup          Configuration tools
  /setup verify   Check prerequisites and MCPs
  /setup init     Initialize data directory
  /setup mcps     MCP configuration guide
  /help           Show this help

────────────────────────────────────────
MCP STATUS:
  ✓ gsc          Required for SEO commands
  ✓ dataforseo   Required for keyword research
  ✗ scraperapi   Required for competitor analysis

Run /setup verify for detailed status.
```

## Category Help

### /help seo

```
SEO COMMANDS
────────────────────────────────────────

/seo wins [options]
  Find quick-win optimization opportunities
  Options:
    --min-impressions N   Minimum impressions (default: 100)
    --path /section/      Filter to URL section
    --limit N             Max results (default: 20)

/seo gaps [options]
  Identify content gaps and keyword opportunities
  Options:
    --competitor domain   Compare against specific competitor
    --min-volume N        Minimum search volume (default: 500)

/seo roi /path ["keyword"]
  Calculate ROI projections for a page
  Options:
    --top N               Analyze top N pages
    --section /path/      Analyze section

/seo refresh [options]
  Find declining pages needing content refresh
  Options:
    --days N              Comparison period (default: 90)
    --threshold N         Min position drop (default: 3)

/seo impact /path [options]
  Measure before/after effect of changes
  Options:
    --since YYYY-MM-DD    Start date for comparison
    --task ID             Link to task

/seo keywords "topic"
  Research keywords for a topic
  Subcommands:
    list                  Show cached keywords
    search "term"         Search cache
    refresh "keyword"     Force refresh
    clear                 Clear cache
```

### /help audit

```
AUDIT COMMANDS
────────────────────────────────────────

/audit content /path ["keyword"]
  Full 100-point SEO audit
  Categories: On-Page, E-E-A-T, Content, AI, Links, Media

/audit quick /path
  Rapid 10-point essential check
  No keyword required

/audit eeat /path
  Deep dive into E-E-A-T signals
  25-point focused analysis

/audit batch collection [options]
  Audit multiple pages
  Options:
    --limit N             Max pages (default: 10)
    --type full|quick|eeat  Audit type (default: quick)
    --sort score|date     Sort results
```

## Quick Reference

| Command | Purpose | MCP Required |
|---------|---------|--------------|
| `/start` | Begin session | None |
| `/task add` | Create task | None |
| `/seo wins` | Quick wins | gsc |
| `/audit content` | Full audit | None |
| `/seo keywords` | Research | dataforseo |

## Documentation

Full documentation: docs/USER-GUIDE.md
Getting started: docs/GETTING-STARTED.md
MCP setup: docs/mcp-setup.md
