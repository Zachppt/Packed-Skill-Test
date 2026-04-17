---
name: kol-analytics
title: KOL Content Analytics
description: Tracks publishing outcomes and content performance over time. Records every published post with its metadata, stores engagement data from Binance Square where available, and provides the evidence base for the weekly audit's recommendations. The system gets more accurate with every week of data.
version: 1.0.0
author: AethirClaw CN Team
metadata:
  openclaw:
    emoji: "📈"
    requires:
      bins:
        - jq
    tags:
      - kol
      - analytics
      - performance-tracking
      - content-automation
---

# KOL Content Analytics

This Skill records what was published, when, and how it performed. It is the long-term intelligence layer that makes the weekly audit produce specific, data-backed recommendations rather than generic advice.

Data is stored at `~/.openclaw/kol-analytics.json`. Engagement data is pulled from Binance Square's public API where available. All writes happen after publishing. All reads happen during the Weekly Audit.

This Skill does not run independently. It is called by the Publishing Engine (on write) and the Content Factory Weekly Audit (on read).

---

## Storage Schema

```json
{
  "account": {
    "baseline_engagement": null,
    "last_calculated": null,
    "total_posts_tracked": 0
  },
  "posts": [
    {
      "id": "",
      "topic": "",
      "format_type": "",
      "window": "",
      "day_of_week": "",
      "published_at": "",
      "character_count": 0,
      "opening_hook_type": "",
      "had_specific_data": true,
      "engagement": {
        "fetched_at": null,
        "views": null,
        "likes": null,
        "comments": null,
        "shares": null,
        "engagement_score": null,
        "performance_tier": null
      }
    }
  ],
  "weekly_summaries": [
    {
      "week_start": "",
      "week_end": "",
      "posts_published": 0,
      "by_format": {},
      "by_window": {},
      "by_day": {},
      "top_performer": {},
      "bottom_performer": {},
      "recommendations": []
    }
  ],
  "patterns": {
    "best_format": null,
    "best_window": null,
    "best_day": null,
    "worst_format": null,
    "worst_window": null,
    "sample_size": 0,
    "confidence": "LOW"
  }
}
```

---

## Operations

### WRITE — Record a published post

**Trigger:** Called by Publishing Engine immediately after a successful `square-post` call, after kol-memory has been updated.

**Input parameters:**
- `post_id`, `topic`, `format_type`, `window`, `published_at`
- `post_text` (to derive character count and classify opening hook)
- `had_specific_data`: boolean — did this post contain a specific cited number?

**Steps:**

1. Read `~/.openclaw/kol-analytics.json`. Initialise if not present.

2. Classify the opening hook type by reading the first sentence of `post_text`:
   - STATISTIC: opens with a number or percentage
   - QUESTION: opens with a question
   - CLAIM: opens with a direct assertion or opinion
   - NARRATIVE: opens with a scene or story element
   - DATA_POINT: opens with a named data point (e.g. "BTC ETF saw...")

3. Append to `posts`:
```json
{
  "id": "[post_id]",
  "topic": "[topic]",
  "format_type": "[format_type]",
  "window": "[window]",
  "day_of_week": "[day derived from published_at]",
  "published_at": "[published_at]",
  "character_count": [length of post_text],
  "opening_hook_type": "[classified type]",
  "had_specific_data": [true/false],
  "engagement": {
    "fetched_at": null,
    "views": null,
    "likes": null,
    "comments": null,
    "shares": null,
    "engagement_score": null,
    "performance_tier": null
  }
}
```

4. Update `account.total_posts_tracked`

5. Write back. Confirm: `Analytics updated — post recorded ([topic], [format_type], [window]).`

---

### WRITE — Fetch and record engagement data

**Trigger:** Called 48 hours after a post is published (engagement stabilises within 48 hours on Square).

**Note:** This operation depends on Binance Square providing engagement data via their API. If engagement data is not available from the API, this operation records only the structural post metadata and marks engagement fields as null. The analytics still function with structural data alone — it simply cannot rank posts by engagement.

**Steps:**

1. Read `~/.openclaw/kol-analytics.json`

2. Find all posts where `engagement.fetched_at` is null AND `published_at` is more than 48 hours ago

3. For each such post:
   - Attempt to retrieve engagement data from Binance Square (views, likes, comments, shares)
   - If data available:
     - Calculate engagement score: `(likes × 3) + (comments × 5) + (shares × 10) + (views × 0.1)`
     - This weights comments and shares higher than passive views — they represent active engagement
   - If data not available: record all engagement fields as null, set `fetched_at` to now with note "data unavailable"

4. After updating all posts, recalculate `account.baseline_engagement`:
   - Take the median engagement score across all posts with non-null scores
   - Update `account.baseline_engagement` and `account.last_calculated`

5. Classify performance tier for each post with a score:
   - Above 1.5× baseline → HIGH
   - 0.8× to 1.5× baseline → MEDIUM
   - Below 0.8× baseline → LOW
   - No data → UNTRACKED

6. Write back. Confirm: `Engagement data updated for [N] posts.`

---

### READ — Generate weekly audit report

**Trigger:** Called every Monday by `--task content-factory` during the Weekly Audit step.

**Steps:**

1. Read `~/.openclaw/kol-analytics.json`

2. Filter posts to the last 7 days (Sunday to Saturday)

3. Compute all of the following:

**Volume metrics:**
- Total posts published
- Posts per day average

**Format performance** (where engagement data exists):
- For each format type: count published, average engagement score, performance tier distribution
- If no engagement data: count published only, note engagement unavailable

**Window performance:**
- For each window: count published, average engagement score (where available)
- Flag the window with consistently highest engagement

**Day of week performance:**
- For each day: count published, average engagement score (where available)
- Flag the day with consistently highest engagement

**Content attribute analysis:**
- Posts with specific cited data vs posts without: engagement comparison
- Posts by opening hook type: engagement comparison
- Posts by character count bucket (under 180 / 180-250 / over 250): engagement comparison

**Top and bottom performers this week:**
- Highest engagement score post: topic, format, window, score
- Lowest engagement score post: topic, format, window, score

4. Generate recommendations using this logic:

If sample size < 10 posts total:
- Note: insufficient data for high-confidence recommendations
- Still provide directional observations

If sample size ≥ 10 posts:
Apply this framework to generate specific recommendations:

```
DO MORE recommendation:
  If one format type has average performance tier consistently HIGH → recommend it
  If one window shows >1.3× average engagement → recommend it
  If posts with specific data consistently outperform → recommend always citing data

DO LESS recommendation:
  If one format type has average performance tier consistently LOW → recommend reducing it
  If one window shows <0.7× average engagement → recommend avoiding it
  If very long posts (>250 chars) underperform → recommend shorter format
```

5. Update `patterns` with best/worst values from this week's analysis

6. Store this week's summary in `weekly_summaries`

7. Return the full audit report:

```
ANALYTICS REPORT — [WEEK RANGE]
━━━━━━━━━━━━━━━━━━━━━━━

VOLUME
Posts published: [N] | Daily average: [X]
Total tracked (all time): [N] | Baseline engagement score: [X or "not yet calculated"]

FORMAT PERFORMANCE
DATA:        [N] posts | Avg score: [X] | Tier: [HIGH/MED/LOW] [or "no engagement data"]
NARRATIVE:   [N] posts | Avg score: [X] | Tier: [HIGH/MED/LOW]
EDUCATIONAL: [N] posts | Avg score: [X] | Tier: [HIGH/MED/LOW]
ALPHA:       [N] posts | Avg score: [X] | Tier: [HIGH/MED/LOW]

WINDOW PERFORMANCE
MORNING:   [N] posts | Avg score: [X]
AFTERNOON: [N] posts | Avg score: [X]
EVENING:   [N] posts | Avg score: [X]

DAY PERFORMANCE
Mon:[X] Tue:[X] Wed:[X] Thu:[X] Fri:[X] Sat:[X] Sun:[X]

CONTENT ATTRIBUTES
Posts with specific data cited: [N] — avg score [X]
Posts without specific data: [N] — avg score [X]
Best performing hook type: [type] — avg score [X]

TOP PERFORMER THIS WEEK
[topic] | [format] | [window] | Score: [X] ([N]× baseline)

BOTTOM PERFORMER THIS WEEK
[topic] | [format] | [window] | Score: [X] ([X]× baseline)

━━━━━━━━━━━━━━━━━━━━━━━

RECOMMENDATIONS
DO MORE: [specific recommendation with data rationale]
DO LESS: [specific recommendation with data rationale]
TIMING: [best window and day recommendation with data rationale]

Confidence: [HIGH (≥20 posts, engagement data available) / MEDIUM (10-19 posts or partial data) / LOW (<10 posts or no engagement data)]

━━━━━━━━━━━━━━━━━━━━━━━
```

---

### READ — On-demand performance query

**Trigger:** User asks "how is my content performing?" or "show me my analytics" or "what's working?"

**Steps:**

1. Read `~/.openclaw/kol-analytics.json`

2. Return a concise summary:

```
CONTENT PERFORMANCE SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━

All time: [N] posts tracked
Last 7 days: [N] posts | Avg engagement: [X or "tracking"]
Last 30 days: [N] posts | Avg engagement: [X or "tracking"]

Best performing format: [type or "insufficient data"]
Best performing window: [window or "insufficient data"]
Best performing day: [day or "insufficient data"]

Last week recommendations: [DO MORE: X | DO LESS: Y]
Confidence: [HIGH/MEDIUM/LOW]

Next weekly audit: Monday [date]
━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Data Availability Notes

The accuracy of this Skill's recommendations depends directly on engagement data from Binance Square.

**If Binance Square engagement data is available via API:**
All metrics are fully operational. Recommendations are based on actual measured engagement.

**If Binance Square engagement data is not available:**
The Skill still functions with structural data alone:
- Format, window, and day distribution are tracked
- Character count and hook type patterns are tracked
- Performance tier and engagement scores will show as null
- Recommendations will be based on posting pattern analysis only, not engagement outcomes
- The audit will note: "Engagement data unavailable — recommendations based on structural patterns only. For engagement-based recommendations, connect Binance Square analytics access."

In either case, the system provides value. With engagement data it provides optimisation. Without it, it provides consistency tracking and pattern awareness.

---

## Error Handling

**File not found:** Initialise with empty schema. Log: "kol-analytics.json not found — initialised new analytics file."

**Insufficient data for recommendations:** Return available data with explicit note on confidence level. Never fabricate patterns from insufficient data.

**Engagement fetch failure:** Mark as null, continue. Do not block the weekly audit because engagement data could not be retrieved.

**Before every WRITE:** Backup to `~/.openclaw/kol-analytics.backup.json`.
