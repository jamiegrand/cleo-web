-- cleo-web Metrics Database Schema
-- Location: .cleo-web/metrics.db
-- Initialize with: sqlite3 .cleo-web/metrics.db < scripts/init-db.sql

-- ============================================================================
-- SCHEMA VERSION TRACKING
-- ============================================================================

CREATE TABLE IF NOT EXISTS schema_version (
  version INTEGER PRIMARY KEY,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  description TEXT
);

INSERT OR IGNORE INTO schema_version (version, description) VALUES (1, 'Initial cleo-web metrics schema');

-- ============================================================================
-- AUDIT RESULTS
-- ============================================================================

-- Audit results over time (from Astro SEO Agency)
CREATE TABLE IF NOT EXISTS audits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  page_path TEXT NOT NULL,
  url TEXT,
  target_keyword TEXT,
  audit_type TEXT CHECK(audit_type IN ('full', 'quick', 'eeat', 'batch')),
  overall_score INTEGER CHECK(overall_score >= 0 AND overall_score <= 100),
  -- 6-category scoring (0-100 total)
  onpage_score INTEGER CHECK(onpage_score >= 0 AND onpage_score <= 20),
  eeat_score INTEGER CHECK(eeat_score >= 0 AND eeat_score <= 25),
  content_score INTEGER CHECK(content_score >= 0 AND content_score <= 20),
  ai_overview_score INTEGER CHECK(ai_overview_score >= 0 AND ai_overview_score <= 15),
  linking_score INTEGER CHECK(linking_score >= 0 AND linking_score <= 10),
  multimedia_score INTEGER CHECK(multimedia_score >= 0 AND multimedia_score <= 10),
  findings TEXT, -- JSON object with detailed findings
  recommendations TEXT, -- JSON array of recommendations
  cleo_task_id TEXT, -- Link to cleo-web task if issues created
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit issues tracking
CREATE TABLE IF NOT EXISTS audit_issues (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  audit_id INTEGER NOT NULL,
  category TEXT NOT NULL, -- 'onpage', 'eeat', 'content', 'ai_overview', 'linking', 'multimedia'
  severity TEXT CHECK(severity IN ('critical', 'high', 'medium', 'low')),
  issue TEXT NOT NULL,
  current_value TEXT,
  recommended_value TEXT,
  file_path TEXT,
  line_number INTEGER,
  cleo_task_id TEXT, -- Link to cleo-web task
  fixed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (audit_id) REFERENCES audits(id) ON DELETE CASCADE
);

-- ============================================================================
-- KEYWORD RESEARCH CACHE
-- ============================================================================

-- Keyword research data (from DataForSEO)
CREATE TABLE IF NOT EXISTS keywords (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword TEXT NOT NULL UNIQUE,
  search_volume INTEGER,
  difficulty INTEGER CHECK(difficulty >= 0 AND difficulty <= 100),
  cpc REAL,
  competition_level TEXT,
  serp_features TEXT, -- JSON array of SERP features
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- People Also Ask questions
CREATE TABLE IF NOT EXISTS paa_questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword_id INTEGER NOT NULL,
  question TEXT NOT NULL,
  answer_snippet TEXT,
  source_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
);

-- Related keywords
CREATE TABLE IF NOT EXISTS related_keywords (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword_id INTEGER NOT NULL,
  related_keyword TEXT NOT NULL,
  search_volume INTEGER,
  difficulty INTEGER,
  relevance_score REAL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (keyword_id) REFERENCES keywords(id) ON DELETE CASCADE
);

-- ============================================================================
-- GSC PERFORMANCE DATA
-- ============================================================================

-- GSC performance snapshots
CREATE TABLE IF NOT EXISTS gsc_snapshots (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  page_path TEXT NOT NULL,
  url TEXT,
  query TEXT, -- The search query if tracking specific query performance
  clicks INTEGER,
  impressions INTEGER,
  ctr REAL,
  position REAL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- CONTENT INVENTORY
-- ============================================================================

-- Content inventory for tracking all auditable pages
CREATE TABLE IF NOT EXISTS content_inventory (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  page_path TEXT NOT NULL UNIQUE,
  url TEXT,
  content_type TEXT, -- 'blog', 'page', 'product', 'service', 'docs', etc.
  framework TEXT, -- 'astro', 'next', 'nuxt', 'static', etc.
  collection_name TEXT, -- For Astro content collections
  title TEXT,
  word_count INTEGER,
  publish_date DATE,
  last_modified DATE,
  last_audited TIMESTAMP,
  latest_score INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_audits_page_path ON audits(page_path);
CREATE INDEX IF NOT EXISTS idx_audits_created_at ON audits(created_at);
CREATE INDEX IF NOT EXISTS idx_audits_overall_score ON audits(overall_score);
CREATE INDEX IF NOT EXISTS idx_audits_cleo_task ON audits(cleo_task_id);

CREATE INDEX IF NOT EXISTS idx_keywords_keyword ON keywords(keyword);
CREATE INDEX IF NOT EXISTS idx_keywords_last_updated ON keywords(last_updated);

CREATE INDEX IF NOT EXISTS idx_gsc_snapshots_page_path ON gsc_snapshots(page_path);
CREATE INDEX IF NOT EXISTS idx_gsc_snapshots_period ON gsc_snapshots(period_start, period_end);

CREATE INDEX IF NOT EXISTS idx_content_inventory_page_path ON content_inventory(page_path);
CREATE INDEX IF NOT EXISTS idx_content_inventory_framework ON content_inventory(framework);

CREATE INDEX IF NOT EXISTS idx_audit_issues_audit_id ON audit_issues(audit_id);
CREATE INDEX IF NOT EXISTS idx_audit_issues_severity ON audit_issues(severity);
CREATE INDEX IF NOT EXISTS idx_audit_issues_cleo_task ON audit_issues(cleo_task_id);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Latest audit score per page
CREATE VIEW IF NOT EXISTS latest_audits AS
SELECT
  ci.page_path,
  ci.url,
  ci.content_type,
  ci.framework,
  ci.title,
  a.overall_score,
  a.audit_type,
  a.created_at as last_audit_date,
  ci.word_count,
  ci.publish_date
FROM content_inventory ci
LEFT JOIN audits a ON a.id = (
  SELECT id FROM audits
  WHERE page_path = ci.page_path
  ORDER BY created_at DESC
  LIMIT 1
);

-- Pages needing attention (low scores or stale audits)
CREATE VIEW IF NOT EXISTS pages_needing_attention AS
SELECT
  page_path,
  url,
  content_type,
  framework,
  title,
  overall_score,
  last_audit_date,
  CASE
    WHEN overall_score < 40 THEN 'critical'
    WHEN overall_score < 60 THEN 'poor'
    WHEN overall_score < 75 THEN 'fair'
    WHEN last_audit_date < date('now', '-30 days') THEN 'stale'
    ELSE 'ok'
  END as status
FROM latest_audits
WHERE overall_score < 75
   OR last_audit_date < date('now', '-30 days')
   OR last_audit_date IS NULL
ORDER BY
  CASE
    WHEN overall_score IS NULL THEN 0
    ELSE overall_score
  END ASC;

-- Keyword cache status
CREATE VIEW IF NOT EXISTS keyword_cache_status AS
SELECT
  keyword,
  search_volume,
  difficulty,
  last_updated,
  CASE
    WHEN last_updated < datetime('now', '-30 days') THEN 'stale'
    WHEN last_updated < datetime('now', '-7 days') THEN 'aging'
    ELSE 'fresh'
  END as cache_status,
  (SELECT COUNT(*) FROM paa_questions WHERE keyword_id = keywords.id) as paa_count,
  (SELECT COUNT(*) FROM related_keywords WHERE keyword_id = keywords.id) as related_count
FROM keywords
ORDER BY last_updated DESC;

-- Score trends by page
CREATE VIEW IF NOT EXISTS score_trends AS
SELECT
  page_path,
  date(created_at) as audit_date,
  overall_score,
  LAG(overall_score) OVER (PARTITION BY page_path ORDER BY created_at) as previous_score,
  overall_score - LAG(overall_score) OVER (PARTITION BY page_path ORDER BY created_at) as score_change
FROM audits
ORDER BY page_path, created_at;

-- Open issues by severity
CREATE VIEW IF NOT EXISTS open_issues AS
SELECT
  ai.id,
  ai.audit_id,
  a.page_path,
  ai.category,
  ai.severity,
  ai.issue,
  ai.cleo_task_id,
  ai.created_at,
  CASE ai.severity
    WHEN 'critical' THEN 1
    WHEN 'high' THEN 2
    WHEN 'medium' THEN 3
    WHEN 'low' THEN 4
  END as severity_order
FROM audit_issues ai
JOIN audits a ON ai.audit_id = a.id
WHERE ai.fixed_at IS NULL
ORDER BY severity_order, ai.created_at;
