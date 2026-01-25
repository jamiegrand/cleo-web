---
description: Manage cached keyword research data
parent: seo
type: implementation
requires: [dataforseo]
---

# /seo keywords

Research keywords and manage cached keyword data.

## Usage

```
/seo keywords "topic"
/seo keywords list
/seo keywords search "keyword"
/seo keywords refresh "keyword"
/seo keywords clear
```

## Subcommands

### Research Keywords

```
/seo keywords "react hooks"
```

Output:
```
KEYWORD RESEARCH: "react hooks"
────────────────────────────────────────

PRIMARY KEYWORDS:
  Keyword                  Volume   KD    CPC    Intent
  react hooks tutorial     12,000   42    $2.50  informational
  usestate react           8,500    38    $1.80  informational
  react custom hooks       4,200    35    $2.20  informational
  useeffect examples       3,100    32    $1.60  informational

RELATED KEYWORDS:
  react hooks cheat sheet  2,800    28    $1.40
  react hooks best practices 1,900  30    $1.90
  when to use useeffect    1,500    25    $1.20

QUESTIONS (PAA):
  • What are React hooks?
  • How do you use useState in React?
  • What is the useEffect hook for?
  • When should I create a custom hook?

SERP FEATURES:
  ✓ Featured Snippet (how-to)
  ✓ People Also Ask (4 questions)
  ✓ Video carousel
  ✗ Knowledge panel

Cached at: 2026-01-25 10:30
Expires: 2026-02-01 10:30
```

### List Cached Keywords

```
/seo keywords list
```

Output:
```
CACHED KEYWORDS (45 entries)
────────────────────────────────────────

Recently Accessed:
  react hooks          12,000/mo  cached 2h ago
  astro framework      8,100/mo   cached 1d ago
  next.js tutorial     15,000/mo  cached 3d ago

Expiring Soon:
  vue composition api  4,200/mo   expires in 1d
  typescript generics  2,800/mo   expires in 2d

Cache Stats:
  Total entries: 45
  Cache size: 128 KB
  Oldest: 6 days ago
```

### Search Cache

```
/seo keywords search "react"
```

Output:
```
CACHE SEARCH: "react" (8 matches)
────────────────────────────────────────

react hooks          12,000/mo  KD:42  cached 2h ago
react tutorial       18,000/mo  KD:48  cached 5d ago
react vs vue         6,500/mo   KD:35  cached 3d ago
react components     9,200/mo   KD:40  cached 4d ago
...
```

### Refresh Keyword

```
/seo keywords refresh "react hooks"
```

Forces refresh of cached data from DataForSEO API.

### Clear Cache

```
/seo keywords clear
/seo keywords clear --expired
```

- `clear` - Clear all cached keywords
- `clear --expired` - Clear only expired entries

## Cache TTL

| Data Type | TTL |
|-----------|-----|
| Search volume | 7 days |
| SERP features | 24 hours |
| PAA questions | 3 days |
| Keyword difficulty | 14 days |

## Required MCP

- **DataForSEO**: Keyword data, search volume, SERP features

## Data Storage

Cached in `.cleo-web/metrics.db` keyword_cache table.

## Related Commands

- `/seo gaps` - Find keyword opportunities
- `/audit content` - Use keywords in audit
