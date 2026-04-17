---
name: kol-memory
title: KOL Content Memory
description: Persistent memory layer for the KOL Growth Pack. Stores and retrieves the creator's content history, persona configuration, topic coverage log, performance patterns, and blacklist across all sessions. Must be read before every Content Factory run and written after every successful publish.
version: 1.0.0
author: AethirClaw CN Team
metadata:
  openclaw:
    emoji: "🧠"
    requires:
      bins:
        - jq
    tags:
      - kol
      - memory
      - content-automation
      - persistence
---

# KOL Content Memory

This Skill provides persistent storage and retrieval for the KOL Growth Pack. It operates as a structured key-value store backed by a local JSON file at `~/.openclaw/kol-memory.json`. All reads and writes go through this file.

This Skill is called by other Skills — it does not run independently. It has no cron trigger.

---

## Storage Schema

The memory file uses this structure:

```json
{
  "persona": {
    "voice": "",
    "topics_own": [],
    "topics_avoid": [],
    "audience": "",
    "format": "",
    "tone": "",
    "language": "English",
    "last_updated": ""
  },
  "topic_history": [
    {
      "topic": "",
      "category": "",
      "published_at": "",
      "draft_version": ""
    }
  ],
  "published_posts": [
    {
      "id": "",
      "text": "",
      "topic": "",
      "format_type": "",
      "window": "",
      "day_of_week": "",
      "published_at": "",
      "character_count": 0
    }
  ],
  "performance_patterns": {
    "best_format": "",
    "best_window": "",
    "best_day": "",
    "last_audit_date": "",
    "notes": ""
  },
  "blacklist": [
    {
      "topic": "",
      "reason": "",
      "added_at": ""
    }
  ],
  "weekly_stats": {
    "week_start": "",
    "posts_published": 0,
    "formats_used": {},
    "windows_used": {}
  }
}
```

---

## Operations

### READ — Retrieve persona and context before Content Factory

**Trigger:** Called at the start of every `--task content-factory` execution.

**Steps:**

1. Check if `~/.openclaw/kol-memory.json` exists
   - If not: initialise with empty schema, return default persona, log "Memory initialised — no prior history"
   - If yes: read and parse the file

2. Return the following to the calling Skill:

```
MEMORY CONTEXT LOADED

Persona:
  Voice: [value or "not configured"]
  Topics own: [list or "not configured"]
  Topics avoid: [list or "not configured"]
  Audience: [value or "not configured"]
  Format: [value or "not configured"]
  Tone: [value or "not configured"]
  Language: [value, default "English"]

Recent topics (last 7 days — do not repeat):
  [date]: [topic] ([category])
  [date]: [topic] ([category])
  ...

Recent topics (last 3 days — especially avoid):
  [date]: [topic] ([category])
  ...

Blacklisted topics (never propose):
  [topic]: [reason]
  ...

Performance patterns:
  Best format: [value or "insufficient data"]
  Best window: [value or "insufficient data"]
  Best day: [value or "insufficient data"]
  Last audit: [date or "never"]
```

3. If persona is not configured (all fields empty), append this warning:
   `WARNING: No persona configured. Using defaults. Tell the agent "update my KOL persona" to customise.`

---

### READ — Retrieve performance data for Weekly Audit

**Trigger:** Called on Monday by `--task content-factory` for the Weekly Audit section.

**Steps:**

1. Read `~/.openclaw/kol-memory.json`

2. Filter `published_posts` to entries from the last 7 days

3. Compute and return:

```
WEEKLY PERFORMANCE DATA

Period: [start date] to [end date]
Total posts: [N]

By format:
  DATA posts: [N] published
  NARRATIVE posts: [N] published
  EDUCATIONAL posts: [N] published
  ALPHA posts: [N] published

By window:
  MORNING (09:30-11:00): [N] posts
  AFTERNOON (13:00-14:30): [N] posts
  EVENING (19:00-21:00): [N] posts

By day:
  Monday: [N] | Tuesday: [N] | Wednesday: [N]
  Thursday: [N] | Friday: [N] | Saturday: [N] | Sunday: [N]

Topics covered this week:
  [list of topics with category and date]

Performance notes (from last audit):
  [value or "no audit data yet — kol-analytics needed for engagement metrics"]
```

---

### WRITE — Record a published post

**Trigger:** Called by Publishing Engine immediately after every successful `square-post` call.

**Input parameters:**
- `post_text`: the exact published text
- `topic`: the topic name
- `format_type`: DATA / NARRATIVE / EDUCATIONAL / ALPHA
- `window`: MORNING / AFTERNOON / EVENING / IMMEDIATE
- `published_at`: ISO timestamp

**Steps:**

1. Read `~/.openclaw/kol-memory.json`

2. Append to `published_posts`:
```json
{
  "id": "[timestamp-slug]",
  "text": "[post_text]",
  "topic": "[topic]",
  "format_type": "[format_type]",
  "window": "[window]",
  "day_of_week": "[derived from published_at]",
  "published_at": "[published_at]",
  "character_count": [len(post_text)]
}
```

3. Append to `topic_history`:
```json
{
  "topic": "[topic]",
  "category": "[format_type]",
  "published_at": "[published_at]",
  "draft_version": "[A or B]"
}
```

4. Update `weekly_stats`:
   - Increment `posts_published`
   - Increment `formats_used[format_type]`
   - Increment `windows_used[window]`
   - If `week_start` is from a previous week, reset weekly stats first

5. Write updated file back to `~/.openclaw/kol-memory.json`

6. Confirm: `Memory updated — post recorded ([topic], [format_type], [published_at])`

---

### WRITE — Update persona configuration

**Trigger:** User says "update my KOL persona" or "set my persona" or "change my content style".

**Input:** Natural language persona preferences from the user.

**Steps:**

1. Parse the user's input and extract values for:
   - voice, topics_own, topics_avoid, audience, format, tone, language

2. Read current `~/.openclaw/kol-memory.json`

3. Update `persona` fields with new values. Preserve any fields not mentioned by the user.

4. Set `persona.last_updated` to current timestamp

5. Write back and confirm:

```
PERSONA UPDATED

Voice: [new value]
Topics I own: [new value]
Topics I avoid: [new value]
Audience: [new value]
Format: [new value]
Tone: [new value]
Language: [new value]

This persona will be used in all future Content Factory runs.
```

---

### WRITE — Add to blacklist

**Trigger:** User says "never post about [topic]" or "blacklist [topic]" or "add [topic] to my avoid list".

**Steps:**

1. Read `~/.openclaw/kol-memory.json`

2. Append to `blacklist`:
```json
{
  "topic": "[topic]",
  "reason": "[user's stated reason or 'user preference']",
  "added_at": "[timestamp]"
}
```

3. Write back and confirm:
   `Blacklist updated — [topic] will never be proposed in Content Factory.`

---

### WRITE — Update performance patterns (from kol-analytics)

**Trigger:** Called by Weekly Audit after kol-analytics data is processed.

**Input:** Best format, best window, best day, audit date, notes.

**Steps:**

1. Read `~/.openclaw/kol-memory.json`

2. Update `performance_patterns`:
```json
{
  "best_format": "[value]",
  "best_window": "[value]",
  "best_day": "[value]",
  "last_audit_date": "[date]",
  "notes": "[free text from audit]"
}
```

3. Write back and confirm: `Performance patterns updated from weekly audit.`

---

### UTILITY — Prune old history

**Trigger:** Automatic, runs at the end of every WRITE operation.

**Logic:**
- Keep all entries in `topic_history` from the last 30 days. Delete older entries.
- Keep all entries in `published_posts` from the last 90 days. Delete older entries.
- Keep all entries in `blacklist` permanently (never prune).
- Keep `weekly_stats` for the current week only — reset at start of each new week.

This keeps the memory file lean without losing useful recent context.

---

## Error Handling

**File not found:** Initialise with empty schema and continue. Log: "kol-memory.json not found — initialised new memory file."

**JSON parse error:** Log the error, attempt to recover by reading the last known good backup at `~/.openclaw/kol-memory.backup.json`. If no backup exists, initialise fresh. Log: "Memory file corrupted — restored from backup" or "Memory file corrupted — initialised fresh."

**Write failure:** Log the error and notify: "Memory write failed — [error]. Content was published but not recorded in memory. Please run 'sync memory' to manually log recent posts."

**Before every WRITE:** Create a backup copy at `~/.openclaw/kol-memory.backup.json` before modifying the main file.
