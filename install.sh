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
    "dataforseo": false
  }
}
EOF
    echo -e "  ${GREEN}✓${NC} Created config.json"
fi

# Initialize SQLite database
if command -v sqlite3 &>/dev/null && [[ ! -f "$DATA_DIR/metrics.db" ]]; then
    if [[ -f "$SCRIPT_DIR/scripts/init-db.sql" ]]; then
        sqlite3 "$DATA_DIR/metrics.db" < "$SCRIPT_DIR/scripts/init-db.sql"
        echo -e "  ${GREEN}✓${NC} Created metrics.db"
    fi
fi

echo ""

# ============================================================================
# CLAUDE.MD INJECTION
# ============================================================================

echo "Configuring Claude Code..."

CLAUDE_MD="CLAUDE.md"

if [[ -f "$CLAUDE_MD" ]]; then
    if grep -q "cleo-web" "$CLAUDE_MD" 2>/dev/null; then
        echo -e "  ${YELLOW}⚠${NC} cleo-web already configured in CLAUDE.md"
    else
        echo "" >> "$CLAUDE_MD"
        echo "<!-- cleo-web -->" >> "$CLAUDE_MD"
        echo "@$SCRIPT_DIR/commands/start.md" >> "$CLAUDE_MD"
        echo "<!-- /cleo-web -->" >> "$CLAUDE_MD"
        echo -e "  ${GREEN}✓${NC} Added cleo-web to CLAUDE.md"
    fi
else
    cat > "$CLAUDE_MD" << EOF
# Project Configuration

<!-- cleo-web -->
@$SCRIPT_DIR/commands/start.md
<!-- /cleo-web -->

## Commands

- \`/start\` - Begin cleo-web session
- \`/task add "title"\` - Create a task
- \`/audit content /path\` - Audit a page
- \`/seo wins\` - Find quick win opportunities
EOF
    echo -e "  ${GREEN}✓${NC} Created CLAUDE.md"
fi

echo ""

# ============================================================================
# MCP SETUP GUIDANCE
# ============================================================================

echo -e "${BLUE}MCP Setup (Optional but Recommended)${NC}"
echo "────────────────────────────────────────"
echo ""
echo "For full SEO features, configure these MCPs:"
echo ""
echo "1. Google Search Console (gsc)"
echo "   npm install -g gsc-mcp-server"
echo "   See: $SCRIPT_DIR/docs/mcp-setup.md#gsc"
echo ""
echo "2. DataForSEO"
echo "   export DATAFORSEO_USERNAME=your_username"
echo "   export DATAFORSEO_PASSWORD=your_password"
echo "   See: $SCRIPT_DIR/docs/mcp-setup.md#dataforseo"
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
