---
name: kol-queue
title: KOL Content Queue
description: Shared state layer connecting the Content Factory and Publishing Engine across separate cron job executions. Stores all draft content, manages approval status, holds the publishing schedule, and logs execution results. The only authoritative source of truth for what has been approved and what has been published.
version: 1.0.0
author: AethirClaw CN Team
metadata:
  openclaw:
    emoji: "📋"
    requires:
      bins:
        - jq
    tags:
      - kol
      - queue
      - content-automation
      - state-management
---

# KOL Content Queue

This Skill is the state bridge between two separate cron job executions: the Content Factory (08:00 UTC) and the Publishing Engine (09:30 UTC). Without it, approvals made after Content Factory runs cannot be read by the Publishing Engine.

The queue is backed by a local JSON file at `~/.openclaw/kol-queue.json`. All reads and writes go through this file.

This Skill does not run independently. It is called by `kol-growth-pack` tasks.

---

## Storage Schema

```json
{
  "date": "YYYY-MM-DD",
  "generated_at": "",
  "drafts": [
    {
      "id": "post-001",
      "topic": "",
      "format_type": "",
      "timing": "",
      "engagement_prediction": "",
      "audience": "",
      "risk_flag": "",
      "draft_a": {
        "angle": "",
        "text": "",
        "character_count": 0
      },
      "draft_b": {
        "angle": "",
        "text": "",
        "character_count": 0
      },
      "approved_version": null,
      "approved_text": null,
      "status": "PENDING",
      "scheduled_time": null,
      "published_at": null,
      "publish_result": null,
      "retry_count": 0,
      "failure_reason": null
    }
  ],
  "schedule": [],
  "summary": {
    "total_drafts": 0,
    "approved": 0,
    "skipped": 0,
    "published": 0,
    "failed": 0,
    "carried_to_tomorrow": 0
  }
}
```

**Status values and transitions:**

```
PENDING → APPROVED (user approves)
PENDING → SKIPPED (user skips)
APPROVED → SCHEDULED (Publishing Engine assigns time)
SCHEDULED → PUBLISHED (square-post succeeds)
SCHEDULED → FAILED (square-post fails after retry)
FAILED → APPROVED (user re-approves after failure)
APPROVED → CARRIED (daily post limit reached, moved to next day)
```

---

## Operations

### WRITE — Initialise queue with today's drafts

**Trigger:** Called by Content Factory immediately after draft generation, before delivering to the user.

**Input:** All 6 draft packages from the current Content Factory run.

**Steps:**

1. Check if `~/.openclaw/kol-queue.json` exists and has today's date
   - If today's queue already exists: append new drafts (do not overwrite existing approvals)
   - If no queue or different date: create fresh queue with today's date

2. Write each draft package with status PENDING:

```json
{
  "id": "post-001",
  "topic": "[topic name]",
  "format_type": "[DATA/NARRATIVE/EDUCATIONAL/ALPHA]",
  "timing": "[IMMEDIATE/MORNING/AFTERNOON/EVENING]",
  "engagement_prediction": "[HIGH/MEDIUM/LOW]",
  "audience": "[audience type]",
  "risk_flag": "[NONE/MILD/SENSITIVE]",
  "draft_a": {
    "angle": "[angle label]",
    "text": "[full draft text]",
    "character_count": [N]
  },
  "draft_b": {
    "angle": "[angle label]",
    "text": "[full draft text]",
    "character_count": [N]
  },
  "approved_version": null,
  "approved_text": null,
  "status": "PENDING",
  "scheduled_time": null,
  "published_at": null,
  "publish_result": null,
  "retry_count": 0,
  "failure_reason": null
}
```

3. Update `summary.total_drafts`

4. Write file and confirm:
   `Queue initialised — [N] drafts written with status PENDING for [date].`

---

### WRITE — Record user approval

**Trigger:** User sends an approval message. Content Factory detects the approval pattern and calls this operation.

**Approval pattern recognition:**

| User says | Action |
|---|---|
| "APPROVE 1A" / "approve 1a" / "1a" | Approve post 1, Draft A |
| "APPROVE 2B" / "approve 2b" / "2b" | Approve post 2, Draft B |
| "post 3A" / "use 3a" / "go with 3a" | Approve post 3, Draft A |
| "SKIP 4" / "skip 4" / "pass on 4" | Skip post 4 |
| "EDIT 5" + new text | Approve post 5 with edited text |
| "approve all A" | Approve Draft A for all PENDING posts |
| "approve all B" | Approve Draft B for all PENDING posts |

**Steps:**

1. Read `~/.openclaw/kol-queue.json`

2. Find the draft matching the post number

3. For approval:
   - Set `approved_version` to "A" or "B"
   - Set `approved_text` to the exact text of the approved draft (or the edited text if EDIT was used)
   - Set `status` to "APPROVED"

4. For skip:
   - Set `status` to "SKIPPED"
   - Set `approved_version` to null
   - Set `approved_text` to null

5. Update `summary.approved` or `summary.skipped`

6. Write back and confirm:

For approval:
```
Queued for publishing:
Post [N] — [topic] — Draft [A/B] approved
Scheduled: [timing window]
Engagement: [prediction]

[N] posts approved so far today. Publishing Engine runs at 09:30 UTC.
```

For skip:
```
Post [N] — [topic] — skipped.
```

---

### READ — Load approved drafts for Publishing Engine

**Trigger:** Called at the start of every `--task publishing-engine` execution.

**Steps:**

1. Read `~/.openclaw/kol-queue.json`

2. Check the date field — if it is not today's date, return:
   `No queue found for today ([date]). Content Factory may not have run yet.`

3. Filter drafts with status APPROVED

4. Apply daily limit: if more than 8 posts are APPROVED, sort by engagement_prediction (HIGH first, then MEDIUM, then LOW), take the top 8, set the rest to CARRIED status

5. Build and return the publishing schedule:

```
QUEUE LOADED — [DATE]

Approved for publishing today: [N]
[If any carried]: [N] posts carried to tomorrow

PUBLISHING SCHEDULE

IMMEDIATE:
  Post [N] — [topic] — [first 60 chars of approved text]...
  Scheduled: 09:30 UTC

MORNING WINDOW (09:30-11:00):
  Post [N] — [topic] — [first 60 chars]...
  Scheduled: [specific time]

AFTERNOON WINDOW (13:00-14:30):
  Post [N] — [topic] — [first 60 chars]...
  Scheduled: [specific time]

EVENING WINDOW (19:00-21:00):
  Post [N] — [topic] — [first 60 chars]...
  Scheduled: [specific time]
```

**Schedule assignment logic:**
- IMMEDIATE posts → 09:30 UTC (first available slot)
- MORNING posts → staggered across 09:30-11:00, minimum 90 minutes apart
- If IMMEDIATE and MORNING posts conflict → IMMEDIATE takes priority, MORNING shifts to first available slot after 90-minute gap
- AFTERNOON and EVENING posts → assigned to midpoint of their window
- If multiple posts in same window → stagger by 90 minutes, overflow to next window

---

### WRITE — Update post status after publish attempt

**Trigger:** Called by Publishing Engine after every `square-post` call attempt.

**Input parameters:**
- `post_id`: the post ID
- `result`: SUCCESS or FAILURE
- `published_at`: timestamp (if success)
- `failure_reason`: error message (if failure)
- `is_retry`: boolean

**Steps:**

1. Read `~/.openclaw/kol-queue.json`

2. Find the draft by `post_id`

3. On SUCCESS:
   - Set `status` to "PUBLISHED"
   - Set `published_at` to the timestamp
   - Set `publish_result` to "SUCCESS"
   - Update `summary.published`

4. On FAILURE (first attempt):
   - Set `retry_count` to 1
   - Set `failure_reason` to the error message
   - Do not change status yet — Publishing Engine will retry

5. On FAILURE (retry, `is_retry=true`):
   - Set `status` to "FAILED"
   - Set `publish_result` to "FAILED"
   - Set `failure_reason` to the error message
   - Update `summary.failed`

6. Write back and confirm status update.

---

### READ — Generate end-of-day summary

**Trigger:** Called by Publishing Engine at 22:00 UTC or after all scheduled posts are processed.

**Steps:**

1. Read `~/.openclaw/kol-queue.json`

2. Compile and return:

```
QUEUE SUMMARY — [DATE]

Total drafted: [N]
Approved: [N]
Skipped: [N]
Published: [N]
Failed: [N]
Carried to tomorrow: [N]

STATUS BREAKDOWN
Post 1 — [topic] — [PUBLISHED at HH:MM / SKIPPED / FAILED]
Post 2 — [topic] — [PUBLISHED at HH:MM / SKIPPED / FAILED]
...

CARRIED TO TOMORROW
[topic] — [timing window] — will appear in tomorrow's Publishing Engine run

FAILED POSTS (require re-approval)
[topic] — failed at [time] — reason: [error]
To retry: reply "re-approve [N]" to queue this post again
```

---

### WRITE — Queue carried posts for next day

**Trigger:** Called at end of Publishing Engine run when posts have CARRIED status.

**Steps:**

1. Read `~/.openclaw/kol-queue.json`

2. For each CARRIED post:
   - Keep `approved_text` and all metadata
   - Update `status` back to APPROVED
   - Update the date to tomorrow
   - Keep `timing` recommendation unchanged

3. Write to tomorrow's queue file: `~/.openclaw/kol-queue-[tomorrow's date].json`

4. Confirm: `[N] posts carried to tomorrow's queue.`

---

### UTILITY — Daily queue rotation

**Trigger:** Automatic, runs at the start of every Content Factory execution.

**Logic:**
- Archive the previous day's queue to `~/.openclaw/kol-queue-archive/kol-queue-[date].json`
- Keep archives for 30 days, delete older files
- Create a fresh queue file for today
- If carried posts exist from yesterday, pre-populate today's queue with them

---

## Error Handling

**File not found:** Create fresh queue for today. Log: "No queue found for today — initialised new queue."

**JSON parse error:** Attempt to recover from archive. Log error and notify: "Queue file corrupted — attempting recovery from yesterday's archive."

**Approval for post that does not exist:** Log: "Approval received for post [N] but post [N] is not in today's queue. Current queue has [M] posts." List available post numbers.

**Approval after Publishing Engine has already run:** Log: "Post [N] approved after Publishing Engine completed. This post will be added to tomorrow's queue." Move to carried status.

**Before every WRITE:** Create a timestamped backup at `~/.openclaw/kol-queue.backup.json`.
