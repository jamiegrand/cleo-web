-- cleo-web Migration 003: Extended Audit Features
-- Adds mobile, international, social, budget, and competitor audit capabilities
-- Run with: sqlite3 .cleo-web/metrics.db < scripts/migrate-003-extended-audits.sql

-- ============================================================================
-- VERSION CHECK
-- ============================================================================

INSERT INTO schema_version (version, description)
VALUES (3, 'Extended audits - mobile, international, social, budgets, competitors');

-- ============================================================================
-- UPDATE SITE_AUDITS TABLE (add new category columns)
-- ============================================================================

-- Add new score columns to site_audits
ALTER TABLE site_audits ADD COLUMN mobile_score INTEGER CHECK(mobile_score >= 0 AND mobile_score <= 100);
ALTER TABLE site_audits ADD COLUMN international_score INTEGER CHECK(international_score >= 0 AND international_score <= 100);
ALTER TABLE site_audits ADD COLUMN competitor_score INTEGER CHECK(competitor_score >= 0 AND competitor_score <= 100);

-- ============================================================================
-- MOBILE AUDITS
-- ============================================================================

CREATE TABLE IF NOT EXISTS mobile_audits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,
    page_url TEXT NOT NULL,

    -- Mobile Lighthouse scores
    mobile_performance_score INTEGER CHECK(mobile_performance_score >= 0 AND mobile_performance_score <= 100),
    mobile_accessibility_score INTEGER CHECK(mobile_accessibility_score >= 0 AND mobile_accessibility_score <= 100),
    mobile_seo_score INTEGER CHECK(mobile_seo_score >= 0 AND mobile_seo_score <= 100),

    -- Mobile Core Web Vitals
    mobile_lcp_ms INTEGER,
    mobile_inp_ms INTEGER,
    mobile_cls REAL,
    mobile_fcp_ms INTEGER,
    mobile_ttfb_ms INTEGER,

    -- Mobile-specific checks
    has_viewport_meta BOOLEAN DEFAULT FALSE,
    viewport_content TEXT,
    tap_targets_adequate BOOLEAN,
    tap_target_issues TEXT,  -- JSON array of issues
    font_size_legible BOOLEAN,
    font_size_issues TEXT,  -- JSON array of issues
    content_width_fits BOOLEAN,

    -- Mobile-first indexing
    mobile_first_ready BOOLEAN,
    mobile_content_parity BOOLEAN,  -- Same content as desktop

    -- Raw data
    raw_json TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE CASCADE
);

-- ============================================================================
-- INTERNATIONAL SEO (HREFLANG ANALYSIS)
-- ============================================================================

CREATE TABLE IF NOT EXISTS hreflang_analysis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,
    page_url TEXT NOT NULL,

    -- hreflang tags found
    hreflang_tags TEXT,  -- JSON array of {lang, url} objects
    hreflang_count INTEGER DEFAULT 0,
    has_x_default BOOLEAN DEFAULT FALSE,

    -- Validation results
    reciprocal_valid BOOLEAN,
    invalid_urls TEXT,  -- JSON array of non-reciprocating URLs
    invalid_count INTEGER DEFAULT 0,

    -- Language/region
    html_lang TEXT,
    content_language_header TEXT,

    -- Geo-targeting signals
    geo_targeting_type TEXT CHECK(geo_targeting_type IN ('cctld', 'subdirectory', 'subdomain', 'parameter', 'none')),
    detected_regions TEXT,  -- JSON array of detected regions

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE CASCADE
);

-- ============================================================================
-- SOCIAL META ANALYSIS
-- ============================================================================

CREATE TABLE IF NOT EXISTS social_meta_analysis (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,
    page_url TEXT NOT NULL,

    -- Open Graph tags
    og_title TEXT,
    og_description TEXT,
    og_image TEXT,
    og_url TEXT,
    og_type TEXT,
    og_site_name TEXT,

    -- Twitter Card tags
    twitter_card TEXT,  -- summary, summary_large_image, app, player
    twitter_title TEXT,
    twitter_description TEXT,
    twitter_image TEXT,
    twitter_site TEXT,  -- @username

    -- Image validation
    og_image_valid BOOLEAN,
    og_image_width INTEGER,
    og_image_height INTEGER,
    twitter_image_valid BOOLEAN,
    twitter_image_width INTEGER,
    twitter_image_height INTEGER,

    -- Overall scores
    og_score INTEGER CHECK(og_score >= 0 AND og_score <= 100),
    twitter_score INTEGER CHECK(twitter_score >= 0 AND twitter_score <= 100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE CASCADE
);

-- ============================================================================
-- PERFORMANCE BUDGETS
-- ============================================================================

CREATE TABLE IF NOT EXISTS performance_budgets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_url TEXT NOT NULL,

    -- Budget name and type
    budget_name TEXT NOT NULL,
    budget_type TEXT CHECK(budget_type IN ('time', 'resource', 'quantity')),

    -- Metric and threshold
    metric TEXT NOT NULL,  -- 'lcp_ms', 'fcp_ms', 'total_size_kb', 'request_count', etc.
    threshold_value REAL NOT NULL,
    threshold_operator TEXT CHECK(threshold_operator IN ('<', '<=', '>', '>=', '=')) DEFAULT '<',

    -- Severity when exceeded
    severity_if_exceeded TEXT CHECK(severity_if_exceeded IN ('critical', 'high', 'medium', 'low')) DEFAULT 'high',

    -- Status
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(site_url, metric)
);

-- Budget compliance history
CREATE TABLE IF NOT EXISTS budget_compliance (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    budget_id INTEGER NOT NULL,
    site_audit_id INTEGER,
    page_url TEXT,

    -- Compliance status
    is_compliant BOOLEAN,
    actual_value REAL,
    threshold_value REAL,
    variance REAL,  -- How far over/under budget (actual - threshold)
    variance_pct REAL,  -- Percentage variance

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (budget_id) REFERENCES performance_budgets(id) ON DELETE CASCADE,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE SET NULL
);

-- ============================================================================
-- COMPETITORS
-- ============================================================================

CREATE TABLE IF NOT EXISTS competitors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_url TEXT NOT NULL,  -- Our site
    competitor_domain TEXT NOT NULL,
    competitor_name TEXT,  -- Friendly name

    -- Classification
    competitor_type TEXT CHECK(competitor_type IN ('direct', 'indirect', 'aspirational')) DEFAULT 'direct',
    priority INTEGER DEFAULT 3 CHECK(priority >= 1 AND priority <= 5),  -- 1=highest

    -- Status
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(site_url, competitor_domain)
);

-- Competitor snapshots (periodic comparisons)
CREATE TABLE IF NOT EXISTS competitor_snapshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,
    competitor_id INTEGER NOT NULL,

    -- Domain metrics
    domain_rank INTEGER,
    organic_traffic_estimate INTEGER,
    organic_keywords_count INTEGER,

    -- Backlink metrics
    total_backlinks INTEGER,
    referring_domains INTEGER,

    -- Keyword overlap
    keyword_overlap_count INTEGER,
    keyword_overlap_pct REAL,
    keywords_we_rank TEXT,  -- JSON array
    keywords_they_rank TEXT,  -- JSON array (gap opportunities)

    -- Performance comparison (if available)
    avg_lcp_ms INTEGER,
    avg_cls REAL,

    -- Raw data
    raw_json TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE SET NULL,
    FOREIGN KEY (competitor_id) REFERENCES competitors(id) ON DELETE CASCADE
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_mobile_audits_site_audit ON mobile_audits(site_audit_id);
CREATE INDEX IF NOT EXISTS idx_mobile_audits_page ON mobile_audits(page_url);
CREATE INDEX IF NOT EXISTS idx_hreflang_site_audit ON hreflang_analysis(site_audit_id);
CREATE INDEX IF NOT EXISTS idx_hreflang_page ON hreflang_analysis(page_url);
CREATE INDEX IF NOT EXISTS idx_social_meta_site_audit ON social_meta_analysis(site_audit_id);
CREATE INDEX IF NOT EXISTS idx_social_meta_page ON social_meta_analysis(page_url);
CREATE INDEX IF NOT EXISTS idx_perf_budgets_site ON performance_budgets(site_url);
CREATE INDEX IF NOT EXISTS idx_perf_budgets_metric ON performance_budgets(metric);
CREATE INDEX IF NOT EXISTS idx_budget_compliance_budget ON budget_compliance(budget_id);
CREATE INDEX IF NOT EXISTS idx_budget_compliance_audit ON budget_compliance(site_audit_id);
CREATE INDEX IF NOT EXISTS idx_competitors_site ON competitors(site_url);
CREATE INDEX IF NOT EXISTS idx_competitor_snapshots_audit ON competitor_snapshots(site_audit_id);
CREATE INDEX IF NOT EXISTS idx_competitor_snapshots_competitor ON competitor_snapshots(competitor_id);

-- ============================================================================
-- NEW CHECK DEFINITIONS (45 new checks)
-- ============================================================================

-- Mobile-Specific Checks (MOBILE001-MOBILE010)
INSERT OR IGNORE INTO check_definitions (check_code, category, section, check_name, description, max_score, auto_fixable, severity_if_fail, fix_template) VALUES
('MOBILE001', 'mobile', 'cwv', 'Mobile LCP good', 'Mobile Largest Contentful Paint < 2.5s', 15, FALSE, 'critical', NULL),
('MOBILE002', 'mobile', 'cwv', 'Mobile INP good', 'Mobile Interaction to Next Paint < 200ms', 12, FALSE, 'high', NULL),
('MOBILE003', 'mobile', 'cwv', 'Mobile CLS good', 'Mobile Cumulative Layout Shift < 0.1', 12, FALSE, 'high', NULL),
('MOBILE004', 'mobile', 'viewport', 'Viewport meta configured', 'Viewport meta tag present with proper settings', 10, TRUE, 'critical', '<meta name="viewport" content="width=device-width, initial-scale=1">'),
('MOBILE005', 'mobile', 'touch', 'Tap targets sized correctly', 'Touch targets at least 48x48px with adequate spacing', 10, FALSE, 'high', NULL),
('MOBILE006', 'mobile', 'text', 'Font sizes legible', 'Text is readable without zooming (>=16px base)', 8, FALSE, 'high', NULL),
('MOBILE007', 'mobile', 'content', 'Content fits viewport', 'No horizontal scrolling required', 8, FALSE, 'medium', NULL),
('MOBILE008', 'mobile', 'indexing', 'Mobile-first ready', 'Page renders complete content for mobile crawlers', 10, FALSE, 'critical', NULL),
('MOBILE009', 'mobile', 'parity', 'Mobile content parity', 'Mobile and desktop have equivalent content', 8, FALSE, 'high', NULL),
('MOBILE010', 'mobile', 'resources', 'Mobile resources optimized', 'Images and assets appropriately sized for mobile', 7, FALSE, 'medium', NULL);

-- International SEO Checks (INTL001-INTL008)
INSERT OR IGNORE INTO check_definitions (check_code, category, section, check_name, description, max_score, auto_fixable, severity_if_fail, fix_template) VALUES
('INTL001', 'international', 'hreflang', 'hreflang tags present', 'Pages have hreflang tags for language/region targeting', 15, TRUE, 'high', '<link rel="alternate" hreflang="{{lang}}" href="{{url}}">'),
('INTL002', 'international', 'hreflang', 'hreflang x-default exists', 'x-default hreflang defined for fallback', 10, TRUE, 'medium', '<link rel="alternate" hreflang="x-default" href="{{url}}">'),
('INTL003', 'international', 'hreflang', 'hreflang reciprocal valid', 'All hreflang links have valid reciprocal references', 15, FALSE, 'critical', NULL),
('INTL004', 'international', 'hreflang', 'hreflang codes valid', 'Language and region codes follow ISO standards', 10, FALSE, 'high', NULL),
('INTL005', 'international', 'lang', 'HTML lang attribute set', 'HTML element has valid lang attribute', 10, TRUE, 'high', '<html lang="{{lang}}">'),
('INTL006', 'international', 'lang', 'Content-Language header', 'HTTP Content-Language header matches content', 8, FALSE, 'medium', NULL),
('INTL007', 'international', 'geo', 'Geo-targeting consistent', 'URL structure matches geo-targeting strategy', 12, FALSE, 'medium', NULL),
('INTL008', 'international', 'geo', 'Regional content localized', 'Content appropriately localized for target regions', 10, FALSE, 'medium', NULL);

-- Social Media Meta Tags (ONPAGE011-ONPAGE020, extends onpage category)
INSERT OR IGNORE INTO check_definitions (check_code, category, section, check_name, description, max_score, auto_fixable, severity_if_fail, fix_template) VALUES
('ONPAGE011', 'onpage', 'social', 'og:title present', 'Open Graph title tag defined', 5, TRUE, 'medium', '<meta property="og:title" content="{{title}}">'),
('ONPAGE012', 'onpage', 'social', 'og:description present', 'Open Graph description tag defined', 5, TRUE, 'medium', '<meta property="og:description" content="{{description}}">'),
('ONPAGE013', 'onpage', 'social', 'og:image present', 'Open Graph image tag with valid URL', 8, TRUE, 'high', '<meta property="og:image" content="{{image_url}}">'),
('ONPAGE014', 'onpage', 'social', 'og:image dimensions valid', 'OG image meets minimum 1200x630px', 5, FALSE, 'medium', NULL),
('ONPAGE015', 'onpage', 'social', 'og:url canonical', 'og:url matches canonical URL', 4, TRUE, 'low', '<meta property="og:url" content="{{canonical_url}}">'),
('ONPAGE016', 'onpage', 'social', 'og:type defined', 'Open Graph type appropriate for content', 3, TRUE, 'low', '<meta property="og:type" content="website">'),
('ONPAGE017', 'onpage', 'social', 'twitter:card present', 'Twitter Card type defined', 5, TRUE, 'medium', '<meta name="twitter:card" content="summary_large_image">'),
('ONPAGE018', 'onpage', 'social', 'twitter:title present', 'Twitter Card title defined', 4, TRUE, 'medium', '<meta name="twitter:title" content="{{title}}">'),
('ONPAGE019', 'onpage', 'social', 'twitter:description present', 'Twitter Card description defined', 4, TRUE, 'medium', '<meta name="twitter:description" content="{{description}}">'),
('ONPAGE020', 'onpage', 'social', 'twitter:image valid', 'Twitter Card image meets requirements', 5, FALSE, 'medium', NULL);

-- Performance Budget Checks (PERF009-PERF017, extends performance category)
INSERT OR IGNORE INTO check_definitions (check_code, category, section, check_name, description, max_score, auto_fixable, severity_if_fail, fix_template) VALUES
('PERF009', 'performance', 'budget', 'LCP budget compliance', 'Largest Contentful Paint within defined budget', 10, FALSE, 'critical', NULL),
('PERF010', 'performance', 'budget', 'FCP budget compliance', 'First Contentful Paint within defined budget', 8, FALSE, 'high', NULL),
('PERF011', 'performance', 'budget', 'TTFB budget compliance', 'Time to First Byte within defined budget', 8, FALSE, 'high', NULL),
('PERF012', 'performance', 'budget', 'Page size budget', 'Total page weight within defined budget', 8, FALSE, 'medium', NULL),
('PERF013', 'performance', 'budget', 'JavaScript size budget', 'JavaScript bundle size within budget', 7, FALSE, 'medium', NULL),
('PERF014', 'performance', 'budget', 'CSS size budget', 'CSS file size within budget', 5, FALSE, 'low', NULL),
('PERF015', 'performance', 'budget', 'Image size budget', 'Image assets within budget', 6, FALSE, 'medium', NULL),
('PERF016', 'performance', 'budget', 'Request count budget', 'HTTP requests within defined budget', 6, FALSE, 'medium', NULL),
('PERF017', 'performance', 'budget', 'Third-party script budget', 'Third-party scripts within budget', 7, FALSE, 'high', NULL);

-- Competitor Benchmarking Checks (COMP001-COMP008)
INSERT OR IGNORE INTO check_definitions (check_code, category, section, check_name, description, max_score, auto_fixable, severity_if_fail, fix_template) VALUES
('COMP001', 'competitor', 'ranking', 'Domain authority comparison', 'Domain rank compared to competitors', 15, FALSE, 'medium', NULL),
('COMP002', 'competitor', 'ranking', 'Keyword overlap analysis', 'Keyword intersection with competitors identified', 15, FALSE, 'medium', NULL),
('COMP003', 'competitor', 'ranking', 'Keyword gap opportunities', 'Keywords competitors rank for that we do not', 15, FALSE, 'medium', NULL),
('COMP004', 'competitor', 'backlinks', 'Referring domains comparison', 'Referring domains vs competitors', 12, FALSE, 'medium', NULL),
('COMP005', 'competitor', 'backlinks', 'Backlink quality comparison', 'Backlink profile quality vs competitors', 12, FALSE, 'medium', NULL),
('COMP006', 'competitor', 'backlinks', 'Link gap opportunities', 'Domains linking to competitors but not us', 10, FALSE, 'medium', NULL),
('COMP007', 'competitor', 'performance', 'Performance vs competitors', 'Core Web Vitals compared to competitors', 10, FALSE, 'medium', NULL),
('COMP008', 'competitor', 'content', 'Content coverage analysis', 'Topic coverage compared to competitors', 11, FALSE, 'low', NULL);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Budget compliance summary
CREATE VIEW IF NOT EXISTS budget_compliance_summary AS
SELECT
    pb.site_url,
    pb.budget_name,
    pb.metric,
    pb.threshold_value,
    pb.threshold_operator,
    pb.severity_if_exceeded,
    bc.is_compliant,
    bc.actual_value,
    bc.variance_pct,
    bc.created_at as last_check
FROM performance_budgets pb
LEFT JOIN budget_compliance bc ON bc.id = (
    SELECT id FROM budget_compliance
    WHERE budget_id = pb.id
    ORDER BY created_at DESC
    LIMIT 1
)
WHERE pb.is_active = TRUE;

-- Competitor comparison latest
CREATE VIEW IF NOT EXISTS competitor_comparison AS
SELECT
    c.site_url,
    c.competitor_domain,
    c.competitor_name,
    c.competitor_type,
    c.priority,
    cs.domain_rank,
    cs.organic_traffic_estimate,
    cs.organic_keywords_count,
    cs.referring_domains,
    cs.keyword_overlap_count,
    cs.keyword_overlap_pct,
    cs.created_at as snapshot_date
FROM competitors c
LEFT JOIN competitor_snapshots cs ON cs.id = (
    SELECT id FROM competitor_snapshots
    WHERE competitor_id = c.id
    ORDER BY created_at DESC
    LIMIT 1
)
WHERE c.is_active = TRUE
ORDER BY c.priority ASC, cs.keyword_overlap_count DESC;

-- Mobile vs Desktop performance comparison
CREATE VIEW IF NOT EXISTS mobile_desktop_comparison AS
SELECT
    ma.page_url,
    ma.mobile_performance_score,
    ls.performance_score as desktop_performance_score,
    ma.mobile_performance_score - ls.performance_score as perf_diff,
    ma.mobile_lcp_ms,
    ls.lcp_ms as desktop_lcp_ms,
    ma.mobile_cls,
    ls.cls as desktop_cls,
    ma.has_viewport_meta,
    ma.tap_targets_adequate,
    ma.font_size_legible,
    ma.mobile_first_ready,
    ma.created_at
FROM mobile_audits ma
LEFT JOIN lighthouse_snapshots ls ON ls.page_url = ma.page_url
    AND ls.device = 'desktop'
    AND ls.id = (
        SELECT id FROM lighthouse_snapshots
        WHERE page_url = ma.page_url AND device = 'desktop'
        ORDER BY created_at DESC
        LIMIT 1
    );

-- Social meta coverage
CREATE VIEW IF NOT EXISTS social_meta_coverage AS
SELECT
    sma.page_url,
    CASE WHEN sma.og_title IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN sma.og_description IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN sma.og_image IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN sma.og_url IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN sma.og_type IS NOT NULL THEN 1 ELSE 0 END as og_tags_present,
    CASE WHEN sma.twitter_card IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN sma.twitter_title IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN sma.twitter_description IS NOT NULL THEN 1 ELSE 0 END +
    CASE WHEN sma.twitter_image IS NOT NULL THEN 1 ELSE 0 END as twitter_tags_present,
    sma.og_score,
    sma.twitter_score,
    sma.og_image_valid,
    sma.twitter_image_valid,
    sma.created_at
FROM social_meta_analysis sma;

-- International SEO issues
CREATE VIEW IF NOT EXISTS international_seo_issues AS
SELECT
    ha.page_url,
    ha.hreflang_count,
    ha.has_x_default,
    ha.reciprocal_valid,
    ha.invalid_count,
    ha.html_lang,
    ha.geo_targeting_type,
    CASE
        WHEN ha.hreflang_count = 0 THEN 'No hreflang tags'
        WHEN NOT ha.has_x_default THEN 'Missing x-default'
        WHEN NOT ha.reciprocal_valid THEN 'Invalid reciprocal links'
        WHEN ha.html_lang IS NULL THEN 'Missing HTML lang attribute'
        ELSE 'OK'
    END as primary_issue,
    ha.created_at
FROM hreflang_analysis ha
WHERE ha.hreflang_count = 0
   OR NOT ha.has_x_default
   OR NOT ha.reciprocal_valid
   OR ha.html_lang IS NULL;

-- Extended category scores (updated view)
DROP VIEW IF EXISTS category_scores;
CREATE VIEW category_scores AS
SELECT
    site_url,
    overall_score,
    technical_score,
    schema_score,
    eeat_score,
    onpage_score,
    ai_score,
    performance_score,
    accessibility_score,
    security_score,
    backlink_score,
    mobile_score,
    international_score,
    competitor_score,
    CASE
        WHEN overall_score >= 90 THEN 'Excellent'
        WHEN overall_score >= 75 THEN 'Good'
        WHEN overall_score >= 60 THEN 'Fair'
        WHEN overall_score >= 40 THEN 'Poor'
        ELSE 'Critical'
    END as overall_rating,
    created_at as audit_date
FROM site_audits
WHERE id IN (
    SELECT MAX(id) FROM site_audits GROUP BY site_url
);
