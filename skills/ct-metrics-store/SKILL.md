---
name: ct-metrics-store
version: 1.0.0
description: SQLite-based metrics storage for SEO time-series data
tags: [data, storage, metrics]
status: active
---

# Metrics Store

SQLite-based metrics storage skill for SEO time-series data. Provides persistent storage for audit results, keyword caches, and GSC snapshots with trend analysis capabilities.

## Capabilities

- **Audit History** (`audit-history`): Store and retrieve audit scores over time
- **Keyword Cache** (`keyword-cache`): Cache keyword research data with TTL
- **GSC Snapshots** (`gsc-snapshots`): Store Search Console data for trending
- **Trend Analysis** (`trend-analysis`): Calculate score trends and changes

## Database Location

```
.cleo-web/metrics.db
```

## Schema

### Audit Results Table

```sql
CREATE TABLE audit_results (
  id INTEGER PRIMARY KEY,
  page_path TEXT NOT NULL,
  url TEXT,
  audit_type TEXT NOT NULL,
  overall_score INTEGER,
  onpage_score INTEGER,
  eeat_score INTEGER,
  content_score INTEGER,
  ai_score INTEGER,
  linking_score INTEGER,
  multimedia_score INTEGER,
  target_keyword TEXT,
  findings_json TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_page ON audit_results(page_path);
CREATE INDEX idx_audit_date ON audit_results(created_at);
```

### Keyword Cache Table

```sql
CREATE TABLE keyword_cache (
  keyword TEXT PRIMARY KEY,
  search_volume INTEGER,
  difficulty INTEGER,
  cpc REAL,
  competition TEXT,
  serp_features_json TEXT,
  paa_json TEXT,
  related_json TEXT,
  cached_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME
);

CREATE INDEX idx_keyword_expires ON keyword_cache(expires_at);
```

### GSC Snapshots Table

```sql
CREATE TABLE gsc_snapshots (
  id INTEGER PRIMARY KEY,
  snapshot_date DATE NOT NULL,
  page_path TEXT NOT NULL,
  query TEXT,
  impressions INTEGER,
  clicks INTEGER,
  position REAL,
  ctr REAL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_gsc_date ON gsc_snapshots(snapshot_date);
CREATE INDEX idx_gsc_page ON gsc_snapshots(page_path);
```

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `AUDIT_DATA` | For store | Audit result object to store |
| `KEYWORD_DATA` | For cache | Keyword data to cache |
| `GSC_DATA` | For snapshot | GSC data to store |
| `PAGE_PATH` | For query | Filter by page path |
| `DATE_RANGE` | No | Date range for queries |

## Outputs

### Audit History

```json
{
  "page_path": "/blog/my-post",
  "history": [
    {
      "date": "2026-01-24",
      "overall_score": 72,
      "scores": { "onpage": 16, "eeat": 18, ... }
    },
    {
      "date": "2026-01-10",
      "overall_score": 65,
      "scores": { "onpage": 14, "eeat": 16, ... }
    }
  ],
  "trend": {
    "direction": "improving",
    "change": +7,
    "period": "14 days"
  }
}
```

### Cache Status

```json
{
  "keyword": "astro framework",
  "cached": true,
  "cached_at": "2026-01-23T10:00:00Z",
  "expires_at": "2026-01-30T10:00:00Z",
  "data": { ... }
}
```

## Cache TTL Configuration

| Data Type | Default TTL | Configurable |
|-----------|-------------|--------------|
| Keyword search volume | 7 days | Yes |
| SERP data | 24 hours | Yes |
| PAA questions | 3 days | Yes |
| Difficulty scores | 14 days | Yes |
| GSC snapshots | Permanent | No |
| Audit results | Permanent | No |

## Operations

### Store Audit Result

```javascript
// Internal operation
storeAudit({
  page_path: "/blog/post",
  overall_score: 72,
  scores: { onpage: 16, ... },
  findings: [...]
});
```

### Get Audit Trend

```javascript
// Returns score history for trend analysis
getAuditTrend("/blog/post", { days: 30 });
```

### Cache Keyword Data

```javascript
// Store with automatic TTL
cacheKeyword("astro framework", {
  volume: 12100,
  difficulty: 45
});
```

### Query GSC History

```javascript
// Get historical GSC data
getGSCHistory("/blog/post", {
  startDate: "2025-12-01",
  endDate: "2026-01-24"
});
```

## Maintenance

### Cleanup Expired Cache

```bash
# Run via /setup maintenance
sqlite3 .cleo-web/metrics.db "DELETE FROM keyword_cache WHERE expires_at < datetime('now')"
```

### Backup Database

```bash
# Automatic backup before modifications
cp .cleo-web/metrics.db .cleo-web/metrics.db.bak
```

## Example Usage

### Get Page Score History
```
/metrics history /blog/my-post
```

### Check Keyword Cache
```
/metrics cache "astro framework"
```

### View Score Trends
```
/metrics trends --days 30
```

### Clear Expired Cache
```
/setup maintenance --clear-cache
```

## Integration

### With ct-seo-auditor

Automatically stores all audit results:
- Enables before/after comparisons
- Powers trend analysis
- Supports batch reporting

### With ct-gsc-analyst

Caches GSC data for:
- Faster repeated queries
- Historical trend analysis
- Offline reference

### With ct-content-strategist

Caches keyword research:
- Reduces API calls
- Enables offline keyword lookup
- Powers suggestion features

## Dependencies

- None (core storage skill)
- Uses SQLite (bundled with system)
