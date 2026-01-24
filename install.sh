#!/usr/bin/env bash
# install.sh - cleo-web installer
#
# Installs cleo-web plugin in the current project directory

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    cleo-web installer                        ║"
echo "║     Task Management + SEO Workflows for Web Developers       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ============================================================================
# PREREQUISITE CHECKS
# ============================================================================

echo "Checking prerequisites..."

# Check jq
if ! command -v jq &>/dev/null; then
    echo -e "${RED}ERROR: jq is required but not installed${NC}"
    echo "  Install: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi
echo -e "  ${GREEN}✓${NC} jq installed"

# Check flock (recommended)
if command -v flock &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} flock installed"
else
    echo -e "  ${YELLOW}⚠${NC} flock not found (using mkdir fallback)"
    echo "    Recommended: brew install discoteq/discoteq/flock"
fi

# Check sqlite3 (for metrics)
if command -v sqlite3 &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} sqlite3 installed"
else
    echo -e "  ${YELLOW}⚠${NC} sqlite3 not found (metrics storage disabled)"
fi

echo ""

# ============================================================================
# FRAMEWORK DETECTION
# ============================================================================

echo "Detecting framework..."

FRAMEWORK="generic"
if [[ -f "astro.config.mjs" ]] || [[ -f "astro.config.js" ]] || [[ -f "astro.config.ts" ]]; then
    FRAMEWORK="astro"
elif [[ -f "next.config.js" ]] || [[ -f "next.config.mjs" ]] || [[ -f "next.config.ts" ]]; then
    FRAMEWORK="nextjs"
elif [[ -f "nuxt.config.js" ]] || [[ -f "nuxt.config.ts" ]]; then
    FRAMEWORK="nuxt"
fi

echo -e "  Framework: ${GREEN}$FRAMEWORK${NC}"
echo ""

# ============================================================================
# CREATE DATA DIRECTORY
# ============================================================================

echo "Setting up cleo-web..."

DATA_DIR=".cleo-web"

if [[ -d "$DATA_DIR" ]]; then
    echo -e "  ${YELLOW}⚠${NC} $DATA_DIR already exists"
    read -p "  Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "  Keeping existing data directory"
    else
        rm -rf "$DATA_DIR"
    fi
fi

mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/backups"
echo -e "  ${GREEN}✓${NC} Created $DATA_DIR/"

# ============================================================================
# INITIALIZE FILES
# ============================================================================

# Create todo.json
if [[ ! -f "$DATA_DIR/todo.json" ]]; then
    cat > "$DATA_DIR/todo.json" << 'EOF'
{
  "_meta": {
    "schemaVersion": "1.0.0",
    "generation": 0,
    "createdAt": "TIMESTAMP",
    "framework": "FRAMEWORK"
  },
  "tasks": []
}
EOF
    # Replace placeholders
    sed -i.bak "s/TIMESTAMP/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$DATA_DIR/todo.json"
    sed -i.bak "s/FRAMEWORK/$FRAMEWORK/" "$DATA_DIR/todo.json"
    rm -f "$DATA_DIR/todo.json.bak"
    echo -e "  ${GREEN}✓${NC} Created todo.json"
fi

# Create config.json
if [[ ! -f "$DATA_DIR/config.json" ]]; then
    cat > "$DATA_DIR/config.json" << EOF
{
  "framework": "$FRAMEWORK",
  "siteUrl": null,
  "mcps": {
    "gsc": false,
    "dataforseo": false,
    "scraperapi": false
  }
}
EOF
    echo -e "  ${GREEN}✓${NC} Created config.json"
fi

# Initialize SQLite database with all migrations
if command -v sqlite3 &>/dev/null; then
    DB_EXISTS=false
    [[ -f "$DATA_DIR/metrics.db" ]] && DB_EXISTS=true

    # Run initial schema if database doesn't exist
    if [[ "$DB_EXISTS" == "false" ]] && [[ -f "$SCRIPT_DIR/scripts/init-db.sql" ]]; then
        sqlite3 "$DATA_DIR/metrics.db" < "$SCRIPT_DIR/scripts/init-db.sql"
        echo -e "  ${GREEN}✓${NC} Created metrics.db"
    fi

    # Run all migrations in order
    if [[ -f "$DATA_DIR/metrics.db" ]]; then
        for migration in "$SCRIPT_DIR"/scripts/migrate-*.sql; do
            if [[ -f "$migration" ]]; then
                migration_name=$(basename "$migration")
                # Extract version number from filename (e.g., migrate-002-site-audit.sql -> 2)
                version_num=$(echo "$migration_name" | grep -oE '[0-9]+' | head -1)
                if [[ -n "$version_num" ]]; then
                    # Remove leading zeros for comparison
                    version_num=$((10#$version_num))
                    already_applied=$(sqlite3 "$DATA_DIR/metrics.db" "SELECT COUNT(*) FROM schema_version WHERE version = $version_num;" 2>/dev/null || echo "0")
                    if [[ "$already_applied" == "0" ]]; then
                        if sqlite3 "$DATA_DIR/metrics.db" < "$migration" 2>/dev/null; then
                            echo -e "  ${GREEN}✓${NC} Applied migration: $migration_name"
                        else
                            echo -e "  ${YELLOW}⚠${NC} Migration may have partially applied: $migration_name"
                        fi
                    fi
                fi
            fi
        done
    fi
fi

echo ""

# ============================================================================
# CLAUDE.MD INJECTION
# ============================================================================

echo "Configuring Claude Code..."

CLAUDE_MD="CLAUDE.md"

# Generate CLAUDE.md content (embedded to avoid path issues with spaces)
generate_claude_md() {
    cat << 'CLAUDEMD'
# Project Configuration

This project uses **cleo-web** for task management and SEO workflows.

## Available Commands

### Session Management
- `/start` - Begin cleo-web session with MCP verification and site health check
- `/session pause` - Pause current session
- `/session resume` - Resume paused session
- `/session end` - End session with summary
- `/session status` - Show current session status

### Task Management
- `/task add "title"` - Create a task
- `/task list` - List all tasks
- `/task complete ID` - Mark task as done

### SEO Analysis (Requires MCPs)
- `/seo wins` - Quick win opportunities from GSC
- `/seo gaps` - Content gap analysis
- `/seo roi` - Performance analysis
- `/seo refresh` - Find declining pages

### Site Auditing
- `/audit site` - Full site audit (60+ checks, 8 categories)
- `/audit site --category=performance` - Category-specific audit
- `/audit content /path` - Single page content audit
- `/audit quick /path` - 10-point quick check

## /start Command

When you run `/start`, execute these steps:

### Step 1: Verify MCP Availability
Check that required MCP servers are responding:
- **gsc** (required) - Google Search Console data
- **dataforseo** (required) - Keyword research, Lighthouse, backlinks
- **scraperapi** (required) - HTML fetching, header analysis

Use ToolSearch to verify each MCP is available before proceeding.

### Step 2: Check Configuration
Read `.cleo-web/config.json` for site settings:
- `siteUrl` - The site URL for GSC queries
- `framework` - Detected framework (astro, nextjs, nuxt, generic)

### Step 3: Load Tasks
Read `.cleo-web/todo.json` for current tasks.

### Step 4: Display Session Summary
Show:
- MCP status (connected/missing)
- Site health score (if available from last audit)
- Active tasks count
- Quick win opportunities

### Step 5: Offer Priorities
Suggest what to work on based on:
1. Critical site audit issues
2. Quick wins from GSC (position 4-15 pages)
3. Active tasks

## Data Storage

All data stored in `.cleo-web/`:
- `todo.json` - Task state
- `config.json` - Configuration
- `metrics.db` - SQLite database for audit history, keywords, GSC data

## MCP Setup

If MCPs are missing, guide user to setup:
- GSC: Configure OAuth credentials for Google Search Console
- DataForSEO: Set DATAFORSEO_USERNAME and DATAFORSEO_PASSWORD
- ScraperAPI: Set SCRAPERAPI_KEY
CLAUDEMD
}

if [[ -f "$CLAUDE_MD" ]]; then
    if grep -q "cleo-web" "$CLAUDE_MD" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC} cleo-web already configured in CLAUDE.md"
    else
        echo "" >> "$CLAUDE_MD"
        echo "<!-- cleo-web -->" >> "$CLAUDE_MD"
        generate_claude_md >> "$CLAUDE_MD"
        echo "<!-- /cleo-web -->" >> "$CLAUDE_MD"
        echo -e "  ${GREEN}✓${NC} Added cleo-web to CLAUDE.md"
    fi
else
    generate_claude_md > "$CLAUDE_MD"
    echo -e "  ${GREEN}✓${NC} Created CLAUDE.md"
fi

echo ""

# ============================================================================
# MCP SETUP GUIDANCE
# ============================================================================

echo -e "${BLUE}MCP Setup (Required for SEO Features)${NC}"
echo "────────────────────────────────────────"
echo ""
echo "cleo-web requires these 3 MCPs for full functionality:"
echo ""
echo "1. Google Search Console (gsc)"
echo "   See: $SCRIPT_DIR/docs/mcp-setup.md#gsc"
echo ""
echo "2. DataForSEO"
echo "   export DATAFORSEO_USERNAME=your_username"
echo "   export DATAFORSEO_PASSWORD=your_password"
echo "   See: $SCRIPT_DIR/docs/mcp-setup.md#dataforseo"
echo ""
echo "3. ScraperAPI"
echo "   export SCRAPERAPI_KEY=your_api_key"
echo "   See: $SCRIPT_DIR/docs/mcp-setup.md#scraperapi"
echo ""

# ============================================================================
# COMPLETION
# ============================================================================

echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 Installation Complete!                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "Quick Start:"
echo "  1. Run /start in Claude Code to begin"
echo "  2. Create tasks with /task add \"title\""
echo "  3. Audit pages with /audit content /path"
echo ""
echo "Data stored in: $DATA_DIR/"
echo ""
