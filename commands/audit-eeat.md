---
description: Deep E-E-A-T (Experience, Expertise, Authority, Trust) audit
parent: audit
type: implementation
---

# /audit eeat

Perform a deep dive audit focused on E-E-A-T signals (Experience, Expertise, Authority, Trust).

## Usage

```
/audit eeat /path
/audit eeat /blog/my-post
/audit eeat https://example.com/page
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `/path` or URL | Yes | Page to audit |

## E-E-A-T Scoring (25 points total)

### Experience (6 points)
- First-person anecdotes and stories
- Screenshots, photos, or original media
- Specific details and measurable outcomes
- "I tested this" or "In my experience" language

### Expertise (7 points)
- Technical depth appropriate for topic
- Industry terminology used correctly
- Author credentials mentioned
- Data, statistics, and research cited

### Authority (6 points)
- Internal links from other authority pages
- External citations from authoritative sources
- Author bio with credentials
- Brand/site reputation signals

### Trust (6 points)
- HTTPS enabled
- Privacy policy linked
- Contact information visible
- Last updated date shown
- Factual accuracy (no outdated info)

## Output

```
E-E-A-T AUDIT: /blog/my-post
────────────────────────────────────────

OVERALL E-E-A-T SCORE: 19/25 (Good)

EXPERIENCE (5/6)
  ✓ First-person anecdotes present
  ✓ Screenshots/examples included
  ✓ Specific details and outcomes
  ✗ Missing "tested on" or date context

EXPERTISE (5/7)
  ✓ Technical depth appropriate
  ✓ Industry terminology used correctly
  ✗ No author credentials mentioned
  ✗ Missing supporting data/statistics
  ✓ Topic comprehensively covered

AUTHORITY (4/6)
  ✓ Internal links from authority pages (3 links)
  ✗ No external citations to authoritative sources
  ✗ Author bio incomplete (no credentials)
  ✓ Brand mentioned in industry context

TRUST (5/6)
  ✓ HTTPS enabled
  ✓ Privacy policy linked in footer
  ✓ Contact page accessible
  ✗ No "last updated" date visible
  ✓ Information appears accurate

────────────────────────────────────────
RECOMMENDATIONS:

[HIGH] Add author credentials
  Current: "Written by John Smith"
  Recommended: "Written by John Smith, Senior Developer with 10+ years experience"
  Impact: +2 points

[HIGH] Add external citations
  No links to authoritative sources found
  Recommended: Add 2-3 links to documentation, research, or industry leaders
  Impact: +2 points

[MEDIUM] Add "last updated" date
  Helps establish content freshness for Trust signals
  Impact: +1 point

[MEDIUM] Include supporting statistics
  Add data points, benchmarks, or research to support claims
  Impact: +1 point

────────────────────────────────────────
Tasks created: 4

Comparison to site average:
  Your E-E-A-T: 19/25 (76%)
  Site average: 16/25 (64%)
  This page is above average ✓
```

## E-E-A-T by Content Type

Different content types have different E-E-A-T priorities:

| Content Type | Priority Signals |
|--------------|------------------|
| YMYL (health, finance) | Trust, Expertise |
| Technical tutorials | Expertise, Experience |
| Product reviews | Experience, Trust |
| News/journalism | Authority, Trust |
| How-to guides | Experience, Expertise |

## Related Commands

- `/audit content` - Full 6-category audit
- `/audit quick` - Rapid surface check
- `/audit batch` - E-E-A-T audit multiple pages
