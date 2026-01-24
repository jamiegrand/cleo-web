---
name: competitor
description: Competitor tracking - add, list, remove, analyze competitors
disable-model-invocation: true
argument-hint: [add|list|remove|analyze] [domain]
---

# Competitor Management Command

Usage: `/competitor <subcommand> [args]`

## Subcommands

### `/competitor add <domain>` - Add Competitor

Add a competitor to track:

```
/competitor add competitor.com
/competitor add competitor.com --type=direct
/competitor add industry-leader.com --type=aspirational
/competitor add adjacent.com --type=indirect
```

**Options:**
- `--type=direct` - Direct competitor (same market, similar offerings)
- `--type=indirect` - Indirect competitor (different approach, same audience)
- `--type=aspirational` - Aspirational benchmark (industry leader)
- `--priority=1-5` - Tracking priority (1=highest, default=3)

**Execution Steps:**
1. Validate domain format
2. Check if competitor already exists
3. Insert into `competitors` table
4. Fetch initial metrics via DataForSEO
5. Store snapshot in `competitor_snapshots`

### `/competitor list` - List Competitors

Show all tracked competitors:

```
TRACKED COMPETITORS
────────────────────────────────────────

Domain               Type         Rank    Keywords   Overlap
competitor-a.com     direct       52      1,234      45%
competitor-b.com     direct       38      892        32%
industry-leader.com  aspirational 78      5,678      28%

Your Domain Rank: 45

Last updated: 3 days ago
Run /audit competitors to refresh
```

### `/competitor remove <domain>` - Remove Competitor

Stop tracking a competitor:

```
/competitor remove competitor.com
```

Removes from `competitors` table (keeps historical snapshots).

### `/competitor analyze [domain]` - Deep Analysis

Run detailed competitive analysis:

```
/competitor analyze competitor.com
```

Or analyze all competitors:

```
/competitor analyze
```

**Output:**
```
COMPETITOR ANALYSIS: competitor.com
────────────────────────────────────────

DOMAIN COMPARISON
  Their Rank: 52      Your Rank: 45
  Their Traffic: ~15K  Your Traffic: ~12K
  Their Keywords: 1,234  Your Keywords: 987

KEYWORD ANALYSIS
  Overlap: 445 keywords (45%)
  They rank, you don't: 789 keywords
  You rank, they don't: 542 keywords

  Top Gap Opportunities:
    "high volume keyword"     - They rank #3, search vol: 12,000
    "medium keyword phrase"   - They rank #5, search vol: 8,000
    "long tail keyword"       - They rank #2, search vol: 5,000

BACKLINK COMPARISON
  Their Referring Domains: 234
  Your Referring Domains: 189

  Link Gap Opportunities:
    • techblog.com (DA 65) - links to them, not you
    • industry-news.com (DA 58) - links to them, not you
    • 43 more domains...

PERFORMANCE COMPARISON
  Their Avg LCP: 2.4s   Your LCP: 2.1s  ✓ Better
  Their Avg CLS: 0.12   Your CLS: 0.08  ✓ Better
```

## Data Storage

Competitors stored in `.cleo-web/metrics.db`:

```sql
-- competitors table
site_url, competitor_domain, competitor_name, competitor_type, priority

-- competitor_snapshots table (history)
competitor_id, domain_rank, organic_keywords_count, referring_domains,
keyword_overlap_count, keyword_overlap_pct, created_at
```

## Required MCPs

Competitor analysis uses DataForSEO tools:
- `mcp__dataforseo__dataforseo_labs_google_domain_rank_overview`
- `mcp__dataforseo__dataforseo_labs_google_domain_intersection`
- `mcp__dataforseo__dataforseo_labs_google_ranked_keywords`
- `mcp__dataforseo__backlinks_competitors`
- `mcp__dataforseo__backlinks_bulk_referring_domains`

## Integration with Audits

Competitor data is included in:
- `/audit site` - Competitor category (COMP001-COMP008)
- `/audit competitors` - Standalone competitor analysis

Competitor benchmarking creates tasks when:
- You're significantly behind on domain rank
- Major keyword gaps exist
- Backlink opportunities identified

## Arguments
$ARGUMENTS
