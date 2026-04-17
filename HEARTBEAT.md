---
name: AethirClaw Intelligence Agent — Heartbeat
version: 1.0.0
---

# Cron Schedule

All times are UTC. Adjust offsets to match your timezone if needed.

## Crontab Entries

Open with `crontab -e` inside the container and add:

```
# ── AethirClaw Intelligence Agent ─────────────────────────────────────

# Workspace 1: Daily Intelligence Briefing — every day at 06:30 UTC
30 6 * * * openclaw run --workspace daily-briefing --task briefing

# Workspace 2: KOL Trend Radar — five times per day, every 4 hours
0 6,10,14,18,22 * * * openclaw run --workspace kol-growth-pack --task trend-radar

# Workspace 2: KOL Content Factory — every day at 08:00 UTC
0 8 * * * openclaw run --workspace kol-growth-pack --task content-factory

# Workspace 2: KOL Publishing Engine — every day at 09:30 UTC
30 9 * * * openclaw run --workspace kol-growth-pack --task publishing-engine

# Workspace 3: Due Diligence — on demand only, no cron entry needed
# Trigger manually: openclaw run --workspace due-diligence --task analyze --input "PROJECT NAME"
```

## Environment Variables

Set in `~/.openclaw/secrets.env` before first run:

```
BLOCKBEATS_API_KEY=your_blockbeats_pro_key
BINANCE_SQUARE_API_KEY=your_square_creator_api_key
```

How to get each key:
- BLOCKBEATS_API_KEY → apply at theblockbeats.info (paid Pro subscription)
- BINANCE_SQUARE_API_KEY → Binance Square → Creator Center → Create API Key (free, post-only)

RootData and all Binance public data Skills require no key.
