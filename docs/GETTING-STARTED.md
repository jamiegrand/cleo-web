# Getting Started with cleo-web

Get cleo-web running in your project in 5 steps.

## Step 1: Prerequisites

Ensure you have these tools installed:

```bash
# Check jq (required)
jq --version
# If missing: brew install jq (macOS) or apt-get install jq (Linux)

# Check sqlite3 (for metrics)
sqlite3 --version
# Usually pre-installed on macOS and Linux

# Check flock (optional, for multi-agent support)
flock --version
# macOS: brew install discoteq/discoteq/flock
```

## Step 2: Clone cleo-web

```bash
# Clone to a permanent location
cd ~/tools  # or wherever you keep tools
git clone https://github.com/jamiegrand/cleo-web.git
```

## Step 3: Install in Your Project

Navigate to your web project and run the installer:

```bash
cd /path/to/your-project
~/tools/cleo-web/install.sh
```

The installer will:
- Verify prerequisites
- Detect your framework (Astro, Next.js, Nuxt)
- Create `.cleo-web/` data directory
- Initialize configuration files
- Update your `CLAUDE.md`

**Expected output:**
```
╔══════════════════════════════════════════════════════════════╗
║                    cleo-web installer                        ║
║     Task Management + SEO Workflows for Web Developers       ║
╚══════════════════════════════════════════════════════════════╝

Checking prerequisites...
  ✓ jq installed
  ✓ flock installed
  ✓ sqlite3 installed

Detecting framework...
  Framework: astro

Setting up cleo-web...
  ✓ Created .cleo-web/
  ✓ Created todo.json
  ✓ Created config.json
  ✓ Created metrics.db

Configuring Claude Code...
  ✓ Added cleo-web to CLAUDE.md

╔══════════════════════════════════════════════════════════════╗
║                 Installation Complete!                       ║
╚══════════════════════════════════════════════════════════════╝
```

## Step 4: Configure MCPs

cleo-web requires MCP servers for full SEO functionality.

### Google Search Console MCP

1. **Install the MCP server:**
   ```bash
   npm install -g gsc-mcp-server
   ```

2. **Create OAuth credentials:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
   - Create OAuth 2.0 Client ID (Desktop application)
   - Download the credentials JSON

3. **Configure in Claude Code settings:**
   ```json
   {
     "mcpServers": {
       "gsc": {
         "command": "gsc-mcp-server",
         "args": ["--credentials", "/path/to/credentials.json"],
         "env": {
           "GSC_PROPERTY": "https://your-site.com/"
         }
       }
     }
   }
   ```

### DataForSEO MCP

1. **Create account** at [DataForSEO](https://dataforseo.com/)

2. **Set environment variables:**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export DATAFORSEO_USERNAME="your_username"
   export DATAFORSEO_PASSWORD="your_api_key"
   ```

3. **Configure in Claude Code settings:**
   ```json
   {
     "mcpServers": {
       "dataforseo": {
         "command": "npx",
         "args": ["-y", "dataforseo-mcp-server"],
         "env": {
           "DATAFORSEO_USERNAME": "your_username",
           "DATAFORSEO_PASSWORD": "your_api_key"
         }
       }
     }
   }
   ```

4. **Restart Claude Code** after configuration.

## Step 5: Verify Setup

Start Claude Code and run:

```
/start
```

**Expected output:**
```
Verifying MCP servers...
- [x] gsc: Connected (site: your-site.com)
- [x] dataforseo: Connected

Session Started

Framework: Astro 5.0
Site: https://your-site.com
MCPs: gsc, dataforseo

Today's Priorities:
...
```

If MCPs are not configured, you'll see:
```
ERROR: Required MCP server not available: gsc

Setup instructions:
1. Install: npm install -g gsc-mcp-server
2. Configure credentials
3. Restart Claude Code
```

## What's Next?

### Create Your First Task
```
/task add "Audit homepage SEO"
```

### Run an SEO Audit
```
/audit content / "main keyword"
```

### Find Quick Wins
```
/seo wins
```

### View All Tasks
```
/task list
```

## Project Structure After Setup

```
your-project/
├── .cleo-web/           # cleo-web data directory
│   ├── todo.json        # Task state
│   ├── config.json      # Configuration
│   ├── metrics.db       # SQLite database
│   └── backups/         # Automatic backups
├── CLAUDE.md            # Updated with cleo-web reference
└── ... your project files
```

## Troubleshooting

### "jq not found"
```bash
# macOS
brew install jq

# Ubuntu/Debian
apt-get install jq

# Fedora
dnf install jq
```

### "Permission denied" on install.sh
```bash
chmod +x ~/tools/cleo-web/install.sh
```

### MCPs not connecting
1. Restart Claude Code after configuration
2. Check MCP server is installed globally
3. Verify environment variables are exported

### Need more help?
- Full documentation: [USER-GUIDE.md](USER-GUIDE.md)
- MCP setup details: [mcp-setup.md](mcp-setup.md)

---

## Quick Reference

| Command | Description |
|---------|-------------|
| `/start` | Begin session |
| `/task add "title"` | Create task |
| `/task list` | View tasks |
| `/task complete ID` | Complete task |
| `/audit content /path "keyword"` | Full SEO audit |
| `/seo wins` | Quick opportunities |
| `/seo keywords "topic"` | Keyword research |
