#!/bin/bash

# ─────────────────────────────────────────────────────────
# AethirClaw Intelligence Skills Pack — Installer
# ─────────────────────────────────────────────────────────

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCLAW_DIR="$HOME/.openclaw"
PACKAGE_DIR="$REPO_DIR/package/.openclaw"

echo ""
echo "AethirClaw Intelligence Skills Pack"
echo "───────────────────────────────────"
echo ""

# ── Check OpenClaw is installed ──────────────────────────
if ! command -v openclaw &> /dev/null; then
  echo "ERROR: openclaw is not installed or not in PATH."
  echo "Please install OpenClaw first: https://docs.openclaw.ai"
  exit 1
fi

echo "OpenClaw found: $(openclaw --version 2>/dev/null || echo 'version unknown')"
echo ""

# ── Backup existing config if present ────────────────────
if [ -d "$OPENCLAW_DIR" ]; then
  BACKUP="$HOME/.openclaw.backup.$(date +%Y%m%d_%H%M%S)"
  echo "Existing ~/.openclaw found — backing up to $BACKUP"
  cp -r "$OPENCLAW_DIR" "$BACKUP"
  echo "Backup created."
  echo ""
fi

# ── Create target directory ───────────────────────────────
mkdir -p "$OPENCLAW_DIR"

# ── Copy all files ────────────────────────────────────────
echo "Installing files to ~/.openclaw/ ..."
cp -r "$PACKAGE_DIR/." "$OPENCLAW_DIR/"
echo "Files installed."
echo ""

# ── Install Partner Skills ────────────────────────────────
echo "Installing Partner Skills via ClawHub..."
echo ""

npx clawhub@latest install blockbeats-skill
echo ""

npx clawhub@latest install rdquanyu/rootdata-crypto
echo ""

npx clawhub@latest install binance/binance-skills-hub
echo ""

echo "Partner Skills installed."
echo ""

# ── Set up secrets.env if not present ────────────────────
SECRETS_FILE="$OPENCLAW_DIR/secrets.env"

if [ ! -f "$SECRETS_FILE" ]; then
  echo "Creating secrets.env ..."
  cat > "$SECRETS_FILE" << 'EOF'
# AethirClaw Intelligence Skills Pack — API Keys
# Fill in your keys below. This file is never committed to Git.

# Required for Daily Briefing and KOL Content Factory
# Apply at: https://www.theblockbeats.info/
BLOCKBEATS_API_KEY=

# Required for KOL Publishing Engine (Binance Square posting)
# Get from: Binance Square → Creator Center → Create API Key
BINANCE_SQUARE_API_KEY=
EOF
  echo "secrets.env created at ~/.openclaw/secrets.env"
  echo ""
  echo "ACTION REQUIRED: Open the file and add your API keys:"
  echo "  nano ~/.openclaw/secrets.env"
  echo ""
else
  echo "secrets.env already exists — skipping. Your existing keys are preserved."
  echo ""
fi

# ── Set up crontab ────────────────────────────────────────
echo "Setting up cron jobs..."
echo ""

# Read existing crontab, remove any previous AethirClaw entries, add new ones
(crontab -l 2>/dev/null | grep -v "AethirClaw\|daily-briefing\|kol-growth-pack\|due-diligence"; cat << 'CRON'
# ── AethirClaw Intelligence Agent ─────────────────────────
# Daily Intelligence Briefing — 06:30 UTC
30 6 * * * openclaw agent --workspace daily-briefing --message "run briefing task" --deliver

# KOL Trend Radar — every 4 hours
0 6,10,14,18,22 * * * openclaw agent --workspace kol-growth-pack --message "run trend-radar task" --deliver

# KOL Content Factory — 08:00 UTC
0 8 * * * openclaw agent --workspace kol-growth-pack --message "run content-factory task" --deliver

# KOL Publishing Engine — 09:30 UTC
30 9 * * * openclaw agent --workspace kol-growth-pack --message "run publishing-engine task" --deliver
CRON
) | crontab -

echo "Cron jobs configured."
echo ""

# ── Verify installation ───────────────────────────────────
echo "───────────────────────────────────"
echo "Verifying installation..."
echo ""

echo "Files in ~/.openclaw/:"
ls "$OPENCLAW_DIR"
echo ""

echo "Workspaces:"
ls "$OPENCLAW_DIR/workspaces/"
echo ""

echo "───────────────────────────────────"
echo "Installation complete."
echo ""
echo "Next steps:"
echo ""
echo "1. Add your API keys:"
echo "   nano ~/.openclaw/secrets.env"
echo ""
echo "2. Make sure the OpenClaw gateway is running:"
echo "   openclaw gateway status"
echo ""
echo "3. Set your KOL persona (first time only):"
echo "   Tell the Agent: 'Update my KOL persona: Voice: [your style] ...'"
echo ""
echo "4. Test the daily briefing manually:"
echo "   openclaw agent --workspace daily-briefing --message 'run briefing task' --deliver"
echo ""
echo "Docs: see README.md for full usage guide."
echo "───────────────────────────────────"
