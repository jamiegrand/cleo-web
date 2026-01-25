---
description: Batch audit multiple pages
parent: audit
type: implementation
---

# /audit batch

Audit multiple pages from a content collection or URL list.

## Usage

```
/audit batch collection
/audit batch blog --limit 10
/audit batch products --type quick
/audit batch /path/to/urls.txt
```

## Arguments

| Argument | Description |
|----------|-------------|
| `collection` | Content collection name (blog, products, etc.) |
| `--limit` | Maximum pages to audit (default: 10) |
| `--type` | Audit type: full, quick, eeat (default: quick) |
| `--sort` | Sort results: score, date, path (default: score) |
| `--min-score` | Only show pages below threshold |

## Output

```
BATCH AUDIT: blog collection
────────────────────────────────────────
Type: quick | Audited: 10 pages | Time: 45s

SCORE DISTRIBUTION:
  90-100 Excellent  █          1 (10%)
  75-89  Good       ███        3 (30%)
  60-74  Fair       ████       4 (40%)
  40-59  Poor       ██         2 (20%)
  0-39   Critical   ░          0 (0%)

RESULTS BY SCORE:

Score | Page                      | Issues
------|---------------------------|--------
  92  | /blog/best-post           | 0
  85  | /blog/good-guide          | 2
  82  | /blog/another-good        | 2
  78  | /blog/decent-article      | 3
  68  | /blog/needs-work          | 4
  65  | /blog/fair-post           | 4
  62  | /blog/update-needed       | 5
  61  | /blog/refresh-this        | 5
  48  | /blog/old-content         | 7
  42  | /blog/poor-page           | 8

LOWEST SCORING DETAILS:

1. /blog/poor-page (42/100)
   Issues: Missing H1, no meta description, thin content,
           no schema, no internal links, no author bio,
           outdated information, no images
   Priority: CRITICAL

2. /blog/old-content (48/100)
   Issues: Missing schema, thin content, no E-E-A-T signals,
           outdated stats, no internal links, poor formatting
   Priority: HIGH

COMMON ISSUES ACROSS COLLECTION:
  • 7/10 missing author bios
  • 5/10 have thin content (<500 words)
  • 4/10 missing schema markup
  • 3/10 have no internal links
  • 2/10 missing meta descriptions

────────────────────────────────────────
SUMMARY:
  Average Score: 68/100
  Median Score: 66/100

  Pages needing attention: 6 (below 75)
  Pages in good shape: 4 (75+)

Tasks created: 8 (for high/critical issues)

Export: .cleo-web/reports/batch-audit-2026-01-25.json
```

## Full Audit Mode

```
/audit batch blog --type full --limit 5
```

Runs complete 100-point audit on each page (slower but more detailed).

## E-E-A-T Batch Mode

```
/audit batch blog --type eeat --limit 10
```

Focuses on E-E-A-T signals across all pages.

## URL File Input

```
/audit batch /path/to/urls.txt
```

File format (one URL per line):
```
/blog/post-1
/blog/post-2
https://example.com/page
```

## Comparison Over Time

```
BATCH COMPARISON: blog collection
────────────────────────────────────────
Current vs 30 days ago

  Average Score: 68 → 72 (+4)
  Pages improved: 6
  Pages declined: 2
  Pages unchanged: 2
```

## Data Storage

Results stored in `.cleo-web/metrics.db`:
- Individual page scores
- Collection averages
- Trend data over time

## Related Commands

- `/audit content` - Single page full audit
- `/audit quick` - Single page quick check
- `/seo refresh` - Find declining pages
