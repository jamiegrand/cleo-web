---
description: Find content opportunities from GSC data
parent: seo
type: implementation
requires: [gsc, dataforseo]
---

# /seo gaps

Identify content gaps and keyword opportunities by analyzing GSC data against competitor coverage.

## Usage

```
/seo gaps
/seo gaps --competitor example.com
/seo gaps --min-volume 1000
/seo gaps --topic "react"
```

## Arguments

| Argument | Description |
|----------|-------------|
| `--competitor` | Specific competitor domain to compare |
| `--min-volume` | Minimum monthly search volume (default: 500) |
| `--topic` | Filter to specific topic area |
| `--limit` | Maximum gaps to show (default: 20) |

## Gap Detection Methods

1. **Query gaps**: High-impression queries without dedicated content
2. **Competitor gaps**: Keywords competitors rank for that you don't
3. **Topic gaps**: Related topics not covered by existing content
4. **Declining coverage**: Areas where rankings have dropped

## Output

```
CONTENT GAPS (8 opportunities found)
────────────────────────────────────────

MISSING TOPICS:

1. "next.js tutorial" - 12,000/mo, KD: 42
   Competitors ranking: example.com (#3), other.com (#7)
   Your coverage: None
   Recommendation: Create comprehensive guide
   Estimated traffic: 1,200/mo at #5

2. "react vs vue 2025" - 8,500/mo, KD: 35
   No content covering this comparison
   Recommendation: Comparison article with code examples
   Estimated traffic: 850/mo at #5

QUERY GAPS (impressions without clicks):

3. "astro components tutorial" - 890 impressions, 0 clicks
   Current page: /blog/astro-intro (not matching intent)
   Recommendation: Create dedicated components guide

4. "sveltekit vs astro" - 650 impressions, 2 clicks
   No dedicated comparison content
   Recommendation: Framework comparison article

────────────────────────────────────────
Total Opportunity: +4,500 potential clicks/mo

Tasks created: 4 (for actionable gaps)
```

## Required MCPs

- **GSC**: Query and impression data
- **DataForSEO**: Search volume, keyword difficulty, competitor data

## Related Commands

- `/seo wins` - Quick optimization opportunities
- `/seo keywords` - Detailed keyword research
- `/audit content` - Audit existing pages
