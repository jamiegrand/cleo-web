-- cleo-web Migration 002: Site Audit System
-- Adds comprehensive site-wide auditing based on 25-section Website Audit Checklist
-- Run with: sqlite3 .cleo-web/metrics.db < scripts/migrate-002-site-audit.sql

-- ============================================================================
-- VERSION CHECK
-- ============================================================================

INSERT INTO schema_version (version, description)
VALUES (2, 'Site audit system - 25-section comprehensive audit');

-- ============================================================================
-- SITE-WIDE AUDIT RESULTS
-- ============================================================================

-- Site-wide audit results (runs at /start and /audit site)
CREATE TABLE IF NOT EXISTS site_audits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_url TEXT NOT NULL,
    audit_type TEXT DEFAULT 'full' CHECK(audit_type IN ('full', 'quick', 'category')),
    category_filter TEXT,  -- If audit_type='category', which category was run

    -- Overall score (0-100)
    overall_score INTEGER CHECK(overall_score >= 0 AND overall_score <= 100),

    -- 8 category scores (0-100 each, normalized)
    technical_score INTEGER CHECK(technical_score >= 0 AND technical_score <= 100),
    schema_score INTEGER CHECK(schema_score >= 0 AND schema_score <= 100),
    eeat_score INTEGER CHECK(eeat_score >= 0 AND eeat_score <= 100),
    onpage_score INTEGER CHECK(onpage_score >= 0 AND onpage_score <= 100),
    ai_score INTEGER CHECK(ai_score >= 0 AND ai_score <= 100),
    performance_score INTEGER CHECK(performance_score >= 0 AND performance_score <= 100),
    accessibility_score INTEGER CHECK(accessibility_score >= 0 AND accessibility_score <= 100),
    security_score INTEGER CHECK(security_score >= 0 AND security_score <= 100),
    backlink_score INTEGER CHECK(backlink_score >= 0 AND backlink_score <= 100),

    -- Issue counts by severity
    issues_critical INTEGER DEFAULT 0,
    issues_high INTEGER DEFAULT 0,
    issues_medium INTEGER DEFAULT 0,
    issues_low INTEGER DEFAULT 0,

    -- Tasks auto-created
    tasks_created INTEGER DEFAULT 0,

    -- Raw data
    raw_results TEXT,  -- JSON with full audit results

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDIVIDUAL CHECK RESULTS
-- ============================================================================

-- Individual audit check results
CREATE TABLE IF NOT EXISTS audit_checks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    audit_id INTEGER NOT NULL,

    -- Check identification
    category TEXT NOT NULL CHECK(category IN (
        'technical', 'schema', 'eeat', 'onpage',
        'ai', 'performance', 'accessibility', 'security', 'backlinks'
    )),
    section TEXT,  -- Sub-section within category (e.g., "robots.txt", "meta-tags")
    check_name TEXT NOT NULL,
    check_code TEXT,  -- Machine-readable check identifier (e.g., "TECH001")

    -- Results
    status TEXT CHECK(status IN ('pass', 'fail', 'warn', 'skip', 'error')),
    score INTEGER,  -- Points awarded
    max_score INTEGER,  -- Maximum possible points

    -- Details
    details TEXT,  -- JSON with specifics (found value, expected value, etc.)
    affected_pages TEXT,  -- JSON array of affected page paths
    affected_count INTEGER DEFAULT 0,  -- Number of affected items

    -- Fix information
    fix_suggestion TEXT,
    fix_code TEXT,  -- Code snippet to fix (if applicable)
    auto_fixable BOOLEAN DEFAULT FALSE,

    -- Linking
    cleo_task_id TEXT,  -- Task created for this issue
    fixed_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (audit_id) REFERENCES site_audits(id) ON DELETE CASCADE
);

-- ============================================================================
-- LIGHTHOUSE PERFORMANCE SNAPSHOTS
-- ============================================================================

-- Core Web Vitals and Lighthouse metrics
CREATE TABLE IF NOT EXISTS lighthouse_snapshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,  -- Optional link to site audit
    page_url TEXT NOT NULL,
    device TEXT CHECK(device IN ('mobile', 'desktop')),

    -- Lighthouse scores (0-100)
    performance_score INTEGER CHECK(performance_score >= 0 AND performance_score <= 100),
    accessibility_score INTEGER CHECK(accessibility_score >= 0 AND accessibility_score <= 100),
    best_practices_score INTEGER CHECK(best_practices_score >= 0 AND best_practices_score <= 100),
    seo_score INTEGER CHECK(seo_score >= 0 AND seo_score <= 100),

    -- Core Web Vitals
    lcp_ms INTEGER,  -- Largest Contentful Paint (milliseconds)
    fid_ms INTEGER,  -- First Input Delay (milliseconds)
    inp_ms INTEGER,  -- Interaction to Next Paint (milliseconds, replaced FID)
    cls REAL,  -- Cumulative Layout Shift (decimal)

    -- Additional metrics
    ttfb_ms INTEGER,  -- Time to First Byte
    fcp_ms INTEGER,  -- First Contentful Paint
    si_ms INTEGER,  -- Speed Index
    tbt_ms INTEGER,  -- Total Blocking Time

    -- Resource metrics
    total_size_kb INTEGER,  -- Total page size
    request_count INTEGER,  -- Number of requests

    -- Status
    lcp_status TEXT CHECK(lcp_status IN ('good', 'needs-improvement', 'poor')),
    fid_status TEXT CHECK(fid_status IN ('good', 'needs-improvement', 'poor')),
    cls_status TEXT CHECK(cls_status IN ('good', 'needs-improvement', 'poor')),

    -- Raw data
    raw_json TEXT,  -- Full Lighthouse JSON response

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE SET NULL
);

-- ============================================================================
-- BACKLINK PROFILE SNAPSHOTS
-- ============================================================================

-- Backlink profile tracking over time
CREATE TABLE IF NOT EXISTS backlink_snapshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,  -- Optional link to site audit
    domain TEXT NOT NULL,

    -- Overall metrics
    total_backlinks INTEGER,
    referring_domains INTEGER,
    domain_rank INTEGER,  -- DataForSEO Domain Rank
    spam_score REAL,  -- 0-100 spam score

    -- Link quality
    dofollow_count INTEGER,
    nofollow_count INTEGER,
    edu_gov_count INTEGER,  -- High authority links

    -- Changes
    new_backlinks_30d INTEGER,
    lost_backlinks_30d INTEGER,
    new_referring_domains_30d INTEGER,
    lost_referring_domains_30d INTEGER,

    -- Anchor text diversity
    anchor_diversity REAL,  -- 0-100 diversity score
    top_anchors TEXT,  -- JSON array of top anchor texts

    -- Raw data
    raw_json TEXT,  -- Full API response

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE SET NULL
);

-- ============================================================================
-- SCHEMA VALIDATION RESULTS
-- ============================================================================

-- Schema.org markup validation
CREATE TABLE IF NOT EXISTS schema_validations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,
    page_path TEXT NOT NULL,

    -- Schema types found
    schema_types TEXT,  -- JSON array of schema types (Organization, Person, etc.)

    -- Validation results
    is_valid BOOLEAN,
    errors TEXT,  -- JSON array of validation errors
    warnings TEXT,  -- JSON array of warnings

    -- Rich results eligibility
    rich_results_eligible BOOLEAN,
    eligible_features TEXT,  -- JSON array of eligible features

    -- Raw data
    raw_json TEXT,  -- Extracted JSON-LD

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE CASCADE
);

-- ============================================================================
-- SECURITY HEADER CHECKS
-- ============================================================================

-- Security headers analysis
CREATE TABLE IF NOT EXISTS security_headers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    site_audit_id INTEGER,
    url TEXT NOT NULL,

    -- Header presence (TRUE/FALSE)
    has_csp BOOLEAN DEFAULT FALSE,
    has_xframe_options BOOLEAN DEFAULT FALSE,
    has_xcontent_type BOOLEAN DEFAULT FALSE,
    has_hsts BOOLEAN DEFAULT FALSE,
    has_referrer_policy BOOLEAN DEFAULT FALSE,
    has_permissions_policy BOOLEAN DEFAULT FALSE,

    -- Header values
    csp_value TEXT,
    xframe_value TEXT,
    hsts_value TEXT,
    referrer_policy_value TEXT,

    -- SSL/TLS
    ssl_valid BOOLEAN,
    ssl_grade TEXT,  -- A+, A, B, C, D, F
    ssl_expiry DATE,

    -- Overall score
    security_score INTEGER CHECK(security_score >= 0 AND security_score <= 100),

    -- Raw headers
    raw_headers TEXT,  -- JSON with all headers

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (site_audit_id) REFERENCES site_audits(id) ON DELETE CASCADE
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Site audits indexes
CREATE INDEX IF NOT EXISTS idx_site_audits_site_url ON site_audits(site_url);
CREATE INDEX IF NOT EXISTS idx_site_audits_created_at ON site_audits(created_at);
CREATE INDEX IF NOT EXISTS idx_site_audits_overall_score ON site_audits(overall_score);

-- Audit checks indexes
CREATE INDEX IF NOT EXISTS idx_audit_checks_audit_id ON audit_checks(audit_id);
CREATE INDEX IF NOT EXISTS idx_audit_checks_category ON audit_checks(category);
CREATE INDEX IF NOT EXISTS idx_audit_checks_status ON audit_checks(status);
CREATE INDEX IF NOT EXISTS idx_audit_checks_cleo_task ON audit_checks(cleo_task_id);

-- Lighthouse indexes
CREATE INDEX IF NOT EXISTS idx_lighthouse_page_url ON lighthouse_snapshots(page_url);
CREATE INDEX IF NOT EXISTS idx_lighthouse_device ON lighthouse_snapshots(device);
CREATE INDEX IF NOT EXISTS idx_lighthouse_created_at ON lighthouse_snapshots(created_at);

-- Backlink indexes
CREATE INDEX IF NOT EXISTS idx_backlinks_domain ON backlink_snapshots(domain);
CREATE INDEX IF NOT EXISTS idx_backlinks_created_at ON backlink_snapshots(created_at);

-- Schema validation indexes
CREATE INDEX IF NOT EXISTS idx_schema_page_path ON schema_validations(page_path);

-- Security headers indexes
CREATE INDEX IF NOT EXISTS idx_security_url ON security_headers(url);

-- ============================================================================
-- VIEWS
-- ============================================================================

-- Latest site audit with trend
CREATE VIEW IF NOT EXISTS latest_site_audit AS
SELECT
    sa.*,
    (SELECT overall_score FROM site_audits
     WHERE site_url = sa.site_url AND id < sa.id
     ORDER BY created_at DESC LIMIT 1) as previous_score,
    sa.overall_score - (SELECT overall_score FROM site_audits
     WHERE site_url = sa.site_url AND id < sa.id
     ORDER BY created_at DESC LIMIT 1) as score_change
FROM site_audits sa
WHERE sa.id = (
    SELECT id FROM site_audits
    WHERE site_url = sa.site_url
    ORDER BY created_at DESC
    LIMIT 1
);

-- Site audit trends over time
CREATE VIEW IF NOT EXISTS site_audit_trends AS
SELECT
    site_url,
    date(created_at) as audit_date,
    overall_score,
    technical_score,
    schema_score,
    eeat_score,
    onpage_score,
    ai_score,
    performance_score,
    accessibility_score,
    security_score,
    issues_critical,
    issues_high,
    LAG(overall_score) OVER (PARTITION BY site_url ORDER BY created_at) as prev_overall,
    overall_score - LAG(overall_score) OVER (PARTITION BY site_url ORDER BY created_at) as score_change
FROM site_audits
ORDER BY site_url, created_at;

-- Failing checks summary
CREATE VIEW IF NOT EXISTS failing_checks_summary AS
SELECT
    ac.category,
    ac.check_name,
    ac.check_code,
    ac.status,
    ac.score,
    ac.max_score,
    ac.affected_count,
    ac.fix_suggestion,
    ac.auto_fixable,
    ac.cleo_task_id,
    sa.site_url,
    sa.created_at as audit_date
FROM audit_checks ac
JOIN site_audits sa ON ac.audit_id = sa.id
WHERE ac.status IN ('fail', 'warn')
AND sa.id = (
    SELECT id FROM site_audits
    WHERE site_url = sa.site_url
    ORDER BY created_at DESC
    LIMIT 1
)
ORDER BY
    CASE ac.status
        WHEN 'fail' THEN 1
        WHEN 'warn' THEN 2
    END,
    ac.max_score DESC;

-- Core Web Vitals history
CREATE VIEW IF NOT EXISTS cwv_history AS
SELECT
    page_url,
    device,
    date(created_at) as snapshot_date,
    lcp_ms,
    fid_ms,
    inp_ms,
    cls,
    lcp_status,
    fid_status,
    cls_status,
    performance_score
FROM lighthouse_snapshots
ORDER BY page_url, device, created_at;

-- Backlink growth
CREATE VIEW IF NOT EXISTS backlink_growth AS
SELECT
    domain,
    date(created_at) as snapshot_date,
    total_backlinks,
    referring_domains,
    domain_rank,
    new_backlinks_30d,
    lost_backlinks_30d,
    new_backlinks_30d - lost_backlinks_30d as net_growth,
    LAG(referring_domains) OVER (PARTITION BY domain ORDER BY created_at) as prev_referring_domains
FROM backlink_snapshots
ORDER BY domain, created_at;

-- Category score breakdown (latest)
CREATE VIEW IF NOT EXISTS category_scores AS
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

-- ============================================================================
-- CHECK DEFINITIONS (Reference table)
-- ============================================================================

-- Audit check definitions - what each check code means
CREATE TABLE IF NOT EXISTS check_definitions (
    check_code TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    section TEXT,
    check_name TEXT NOT NULL,
    description TEXT,
    max_score INTEGER,
    auto_fixable BOOLEAN DEFAULT FALSE,
    fix_template TEXT,  -- Template for auto-fix
    severity_if_fail TEXT CHECK(severity_if_fail IN ('critical', 'high', 'medium', 'low'))
);

-- Insert check definitions for the 25-section audit
INSERT OR IGNORE INTO check_definitions (check_code, category, section, check_name, description, max_score, auto_fixable, severity_if_fail) VALUES
-- Technical SEO (Section 1, 7, 20)
('TECH001', 'technical', 'robots', 'robots.txt exists', 'Check if robots.txt file exists and is accessible', 5, FALSE, 'high'),
('TECH002', 'technical', 'robots', 'robots.txt not blocking important pages', 'Verify robots.txt allows indexing of important content', 5, FALSE, 'critical'),
('TECH003', 'technical', 'sitemap', 'XML sitemap exists', 'Check if sitemap.xml exists and is valid', 5, FALSE, 'high'),
('TECH004', 'technical', 'sitemap', 'Sitemap submitted to GSC', 'Verify sitemap is registered in Google Search Console', 5, FALSE, 'medium'),
('TECH005', 'technical', 'canonical', 'Canonical tags present', 'All pages have proper canonical tags', 5, FALSE, 'high'),
('TECH006', 'technical', 'https', 'HTTPS enabled', 'Site uses HTTPS with valid SSL certificate', 10, FALSE, 'critical'),
('TECH007', 'technical', 'https', 'No mixed content', 'No HTTP resources loaded on HTTPS pages', 5, FALSE, 'high'),
('TECH008', 'technical', 'redirects', 'WWW redirect configured', 'Consistent WWW vs non-WWW handling', 3, FALSE, 'medium'),
('TECH009', 'technical', 'redirects', 'Trailing slash consistency', 'URLs have consistent trailing slash handling', 3, FALSE, 'low'),
('TECH010', 'technical', 'crawlability', 'No noindex on important pages', 'Important pages are not blocked from indexing', 5, FALSE, 'critical'),
('TECH011', 'technical', 'crawlability', 'No crawl errors', 'GSC shows no critical crawl errors', 5, FALSE, 'high'),
('TECH012', 'technical', 'crawlability', 'No orphan pages', 'All pages are linked from site structure', 3, FALSE, 'medium'),

-- Schema Markup (Section 2)
('SCHEMA001', 'schema', 'organization', 'Organization schema', 'Organization or Person schema implemented', 15, TRUE, 'high'),
('SCHEMA002', 'schema', 'website', 'WebSite schema', 'WebSite schema with SearchAction', 10, TRUE, 'medium'),
('SCHEMA003', 'schema', 'breadcrumb', 'BreadcrumbList schema', 'Breadcrumb navigation has schema markup', 10, TRUE, 'medium'),
('SCHEMA004', 'schema', 'article', 'Article/BlogPosting schema', 'Blog posts have Article or BlogPosting schema', 15, TRUE, 'high'),
('SCHEMA005', 'schema', 'faq', 'FAQ schema on FAQ pages', 'FAQ pages have FAQPage schema', 10, TRUE, 'medium'),
('SCHEMA006', 'schema', 'validation', 'Schema validates', 'All schema markup passes validation', 10, FALSE, 'high'),
('SCHEMA007', 'schema', 'rich-results', 'Rich results eligible', 'Schema enables Google Rich Results', 10, FALSE, 'medium'),

-- E-E-A-T Signals (Section 3)
('EEAT001', 'eeat', 'author', 'Author bylines present', 'Content pages show author information', 15, FALSE, 'high'),
('EEAT002', 'eeat', 'author', 'Author credentials displayed', 'Author bios include qualifications/experience', 10, FALSE, 'medium'),
('EEAT003', 'eeat', 'about', 'About page exists', 'Comprehensive About page with team information', 15, FALSE, 'high'),
('EEAT004', 'eeat', 'contact', 'Contact information accessible', 'Contact details easily findable', 10, FALSE, 'high'),
('EEAT005', 'eeat', 'dates', 'Published dates visible', 'Content shows publication date', 10, FALSE, 'medium'),
('EEAT006', 'eeat', 'dates', 'Updated dates shown', 'Modified content shows last updated date', 10, FALSE, 'medium'),
('EEAT007', 'eeat', 'social', 'Social proof present', 'Links to professional profiles, testimonials', 10, FALSE, 'low'),
('EEAT008', 'eeat', 'citations', 'External citations used', 'Content cites authoritative sources', 10, FALSE, 'medium'),

-- On-Page SEO (Section 4)
('ONPAGE001', 'onpage', 'title', 'Unique title tags', 'Every page has a unique title', 10, FALSE, 'high'),
('ONPAGE002', 'onpage', 'title', 'Title length optimal', 'Titles are 50-60 characters', 5, FALSE, 'medium'),
('ONPAGE003', 'onpage', 'meta', 'Meta descriptions present', 'All pages have meta descriptions', 10, FALSE, 'high'),
('ONPAGE004', 'onpage', 'meta', 'Meta description length', 'Descriptions are 150-160 characters', 5, FALSE, 'medium'),
('ONPAGE005', 'onpage', 'headings', 'Single H1 per page', 'Each page has exactly one H1', 10, FALSE, 'high'),
('ONPAGE006', 'onpage', 'headings', 'Heading hierarchy correct', 'H1 > H2 > H3 without skipping', 5, FALSE, 'medium'),
('ONPAGE007', 'onpage', 'images', 'Images have alt text', 'All images have descriptive alt attributes', 10, FALSE, 'high'),
('ONPAGE008', 'onpage', 'images', 'Image filenames descriptive', 'Image files have meaningful names', 3, FALSE, 'low'),
('ONPAGE009', 'onpage', 'urls', 'URLs are clean', 'URLs are readable and keyword-rich', 5, FALSE, 'medium'),
('ONPAGE010', 'onpage', 'linking', 'Internal linking strong', 'Important pages well-linked', 7, FALSE, 'medium'),

-- AI & LLM Optimization (Section 5)
('AI001', 'ai', 'structure', 'Clear quotable sections', 'Content has concise, extractable answers', 15, FALSE, 'medium'),
('AI002', 'ai', 'structure', 'FAQ format used', 'Q&A format for common questions', 15, FALSE, 'medium'),
('AI003', 'ai', 'structure', 'Key takeaways section', 'Content summarizes main points', 10, FALSE, 'low'),
('AI004', 'ai', 'data', 'Statistics with attribution', 'Data points properly sourced', 10, FALSE, 'medium'),
('AI005', 'ai', 'definitions', 'Terms defined', 'Technical terms explained', 10, FALSE, 'low'),

-- Performance (Section 6, 10)
('PERF001', 'performance', 'cwv', 'LCP good', 'Largest Contentful Paint < 2.5s', 20, FALSE, 'critical'),
('PERF002', 'performance', 'cwv', 'FID/INP good', 'First Input Delay < 100ms', 15, FALSE, 'high'),
('PERF003', 'performance', 'cwv', 'CLS good', 'Cumulative Layout Shift < 0.1', 15, FALSE, 'high'),
('PERF004', 'performance', 'speed', 'Page load < 3s', 'Total page load under 3 seconds', 10, FALSE, 'high'),
('PERF005', 'performance', 'speed', 'TTFB < 600ms', 'Time to First Byte under 600ms', 10, FALSE, 'medium'),
('PERF006', 'performance', 'assets', 'Images optimized', 'Images use WebP/AVIF, properly sized', 10, FALSE, 'medium'),
('PERF007', 'performance', 'assets', 'CSS/JS minified', 'Assets are minified and concatenated', 5, FALSE, 'medium'),
('PERF008', 'performance', 'loading', 'Lazy loading enabled', 'Below-fold images lazy loaded', 5, FALSE, 'low'),

-- Accessibility (Section 9, 11)
('A11Y001', 'accessibility', 'contrast', 'Color contrast sufficient', 'Text meets WCAG AA contrast ratios', 15, FALSE, 'high'),
('A11Y002', 'accessibility', 'keyboard', 'Keyboard navigable', 'All elements accessible via keyboard', 15, FALSE, 'high'),
('A11Y003', 'accessibility', 'keyboard', 'Focus indicators visible', 'Focused elements clearly indicated', 10, FALSE, 'high'),
('A11Y004', 'accessibility', 'aria', 'ARIA labels present', 'Interactive elements have ARIA labels', 10, FALSE, 'medium'),
('A11Y005', 'accessibility', 'landmarks', 'Landmarks defined', 'Page has header, nav, main, footer landmarks', 10, FALSE, 'medium'),
('A11Y006', 'accessibility', 'forms', 'Form labels associated', 'All form inputs have labels', 10, FALSE, 'high'),
('A11Y007', 'accessibility', 'skip', 'Skip link present', 'Skip to main content link exists', 5, FALSE, 'medium'),
('A11Y008', 'accessibility', 'media', 'Videos have captions', 'Video content has captions/transcripts', 10, FALSE, 'medium'),

-- Security (Section 13, 18)
('SEC001', 'security', 'headers', 'CSP configured', 'Content-Security-Policy header set', 15, FALSE, 'medium'),
('SEC002', 'security', 'headers', 'X-Frame-Options set', 'Clickjacking protection enabled', 10, FALSE, 'medium'),
('SEC003', 'security', 'headers', 'HSTS enabled', 'Strict-Transport-Security header present', 15, FALSE, 'high'),
('SEC004', 'security', 'headers', 'X-Content-Type set', 'MIME sniffing prevented', 5, FALSE, 'low'),
('SEC005', 'security', 'ssl', 'SSL valid', 'SSL certificate valid and not expiring soon', 15, FALSE, 'critical'),
('SEC006', 'security', 'ssl', 'TLS 1.2+', 'Using TLS 1.2 or higher', 10, FALSE, 'high'),
('SEC007', 'security', 'legal', 'Privacy policy exists', 'Privacy policy page present', 10, FALSE, 'high'),
('SEC008', 'security', 'legal', 'Cookie consent', 'GDPR/CCPA cookie consent implemented', 10, FALSE, 'medium');
