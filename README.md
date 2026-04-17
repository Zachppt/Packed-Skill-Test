# AethirClaw Intelligence Skills Pack
## Complete Deployment Package

Three production-ready workspaces for crypto intelligence, KOL content automation, and project due diligence.

---

## What Is in This Package

```
.openclaw/
├── SOUL.md                    Global identity (minimal)
├── AGENT.md                   Global behaviour rules
├── HEARTBEAT.md               All cron entries
│
├── skills/                    Partner Skills (install via ClawHub)
│   └── INSTALL.md             Installation instructions
│
└── workspaces/
    ├── daily-briefing/        Workspace 1 — Market Intelligence Analyst
    ├── kol-growth-pack/       Workspace 2 — Content Strategist
    └── due-diligence/         Workspace 3 — Investment Research Analyst
```

---

## Deployment Steps

### 1. Copy the package to your container

```bash
cp -r .openclaw ~/
```

### 2. Install Partner Skills

```bash
npx clawhub@latest install blockbeats-skill
npx clawhub@latest install rdquanyu/rootdata-crypto
npx clawhub@latest install binance/binance-skills-hub
```

### 3. Set environment variables

```bash
nano ~/.openclaw/secrets.env
```

Add:
```
BLOCKBEATS_API_KEY=your_key_here
BINANCE_SQUARE_API_KEY=your_key_here
```

| Key | Required for | How to get |
|---|---|---|
| BLOCKBEATS_API_KEY | Daily Briefing + KOL Content Factory | theblockbeats.info — paid Pro subscription |
| BINANCE_SQUARE_API_KEY | KOL Publishing Engine only | Binance Square → Creator Center → Create API Key |

### 4. Configure cron

```bash
crontab -e
```

Copy the entries from `HEARTBEAT.md`.

### 5. Set up KOL persona (first time only)

Tell the Agent:
```
Update my KOL persona:
Voice: [your style]
Topics I own: [your focus areas]
Topics I avoid: [what you will not post about]
Audience: [who follows you on Binance Square]
Tone: [your preferred tone]
```

The persona is saved to `~/.openclaw/kol-memory.json` and used in all future Content Factory runs.

---

## Daily Workflow

### Workspaces 1 and 3 — fully automatic

Daily Briefing runs at 06:30 UTC with no user input needed.
Due Diligence triggers when you ask the Agent to research a project.

### Workspace 2 — one daily approval step

```
08:00 UTC  Content Factory delivers 6 draft pairs to your notification channel
           ↓
           You reply with approvals (takes ~10 minutes):
           APPROVE 1A  |  APPROVE 2B  |  SKIP 3  |  APPROVE 4A  ...
           ↓
09:30 UTC  Publishing Engine publishes approved posts throughout the day
22:00 UTC  End-of-day summary delivered
```

---

## Skill Load Order

OpenClaw loads Skills in this priority order (highest first):

1. `workspaces/<name>/skills/` — workspace-specific Skills
2. `~/.openclaw/skills/` — global Partner Skills
3. OpenClaw built-ins

SOUL.md and AGENT.md follow the same order. Workspace versions override global versions when a workspace is active. The global versions apply for direct conversation with no workspace.

---

## Runtime Files (auto-created)

These files are created automatically on first run. Do not edit them manually.

```
~/.openclaw/kol-memory.json          Content history and persona
~/.openclaw/kol-queue.json           Today's draft queue and approval state
~/.openclaw/kol-analytics.json       Publishing performance data
~/.openclaw/kol-queue-archive/       Daily queue archives (30 days)
```

---

## File Count Summary

| Category | Files |
|---|---|
| Global config (SOUL, AGENT, HEARTBEAT) | 3 |
| Workspace SOUL.md × 3 | 3 |
| Workspace AGENT.md × 3 | 3 |
| Composite Skill SKILL.md × 3 | 3 |
| Infrastructure Skill SKILL.md × 3 | 3 |
| Partner Skills (installed by ClawHub) | 3 |
| **Total** | **18** |
