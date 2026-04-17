---
name: kol-growth-pack
title: AethirClaw KOL Growth Pack
description: Full content automation system for Binance Square creators. Three coordinated tasks — Trend Radar (every 4 hours), Content Factory (daily 08:00 UTC), and Publishing Engine (daily 09:30 UTC) — covering trend detection, data-backed content generation, human approval, and scheduled publishing.
version: 1.0.0
author: AethirClaw CN Team
metadata:
  openclaw:
    emoji: "✍️"
    requires:
      env:
        - BLOCKBEATS_API_KEY
        - BINANCE_SQUARE_API_KEY
      skills:
        - blockbeats-skill
        - rootdata-crypto
        - binance-skills-hub
        - kol-memory
        - kol-queue
    tags:
      - kol
      - content-automation
      - binance-square
      - social-media
---

# KOL Growth Pack

This Skill runs three distinct tasks depending on the `--task` parameter passed by HEARTBEAT.md. Read the relevant task section and execute it completely. Do not run all three tasks simultaneously.

```
--task trend-radar       → Execute Section 1
--task content-factory   → Execute Section 2
--task publishing-engine → Execute Section 3
```

---

## Persona Configuration

Before running any task for the first time, read `kol-memory` to retrieve the creator's persona configuration. If no persona has been configured yet, use this default and prompt the user to customise it:

```
VOICE: Data-driven crypto analyst — confident, direct, never vague
TOPICS_OWN: Market analysis, on-chain data, smart money signals, project research
TOPICS_AVOID: Price predictions, financial advice, meme coins without data backing
AUDIENCE: Traders, researchers, and builders on Binance Square
FORMAT: Lead with data, follow with implication, close with a question
TONE: Knowledgeable friend — not a press release, not a professor
LENGTH: 150-280 words per post
LANGUAGE: English
```

To customise: tell the agent "update my KOL persona" followed by your preferences. Changes are saved to kol-memory immediately.

---

## Section 1 — Trend Radar

*Triggered by: `--task trend-radar` | Schedule: 06:00, 10:00, 14:00, 18:00, 22:00 UTC*

**Purpose:** Identify what is worth posting about right now. Deliver a ranked opportunity briefing. Do not generate post drafts in this task.

### Step 1 — Read Memory Filter

Read `kol-memory` and retrieve:
- Topics covered in the last 72 hours → exclude from opportunity list
- Any topics on the permanent blacklist → exclude permanently

### Step 2 — Live Signal Scan

**Fetch in parallel:**

Using **blockbeats-skill**:
- Important newsflashes → `GET /v1/newsflash/important?size=10&lang=en`
- Financing newsflashes → `GET /v1/newsflash/financing?size=5&lang=en`
- AI newsflashes → `GET /v1/newsflash/ai?size=5&lang=en`
- On-chain newsflashes → `GET /v1/newsflash/onchain?size=5&lang=en`
- Keyword searches (parallel, size=3 each): BlackRock, ETF, SEC, hack, exploit, airdrop, listing, partnership, mainnet, unlock, whale, liquidation

Filter all results: surface only items published in the last 4 hours.

Using **binance-skills-hub**:
- Trending tokens + social hype + smart money inflow → `crypto-market-rank`
- Narrative net inflows → `meme-rush Topic Rush`
- BTC and ETH current price and 24h change → `query-token-info`
- Fresh smart money signals (last 6 hours only) → `trading-signal`

### Step 3 — Opportunity Scoring

For each identified opportunity, score on two dimensions:

**Timeliness (1-5):**
- 5 = Published or triggered in last 1 hour
- 4 = Last 1-4 hours
- 3 = Last 4-8 hours
- 2 = Last 8-24 hours
- 1 = Older than 24 hours

**Postability (1-5):**
- 5 = Has a clear take, citable data, and broad audience appeal
- 4 = Good story, one sentence of framing needed
- 3 = Interesting but requires research to make compelling
- 2 = Niche — appeals to specialists only
- 1 = Too complex, too sensitive, or no natural angle

**Priority Score = Timeliness × Postability (max 25)**

Remove any opportunity with a Priority Score below 9.
Remove any opportunity matching topics covered in last 72 hours.
Rank remaining opportunities by Priority Score, highest first.

### Step 4 — Market Pulse Check

Check if BTC or ETH has moved more than 3% in the last 4 hours. If yes, add as a Priority Score 25 override regardless of other scoring — major BTC/ETH moves are always postable.

### Step 5 — Output

```
TREND RADAR  [TIME UTC]
━━━━━━━━━━━━━━━━━━━━━━━

POST NOW (Score: [XX]/25)
Topic: [NAME]
Type: [Breaking / Market Move / Smart Money / Narrative / Funding]
Why now: [one sentence — what makes this time-sensitive]
Angle: [one sentence — the specific take or hook to use]
Source: [URL or data point]

PREPARE NEXT (Score: [XX]/25)
Topic: [NAME]
Why: [one sentence]

WATCH LIST
[Topic] (Score: [X]) | [Topic] (Score: [X]) | [Topic] (Score: [X])

━━━━━━━━━━━━━━━━━━━━━━━

ACTIVE KEYWORD ALERTS
[Keyword]: [Headline] — [URL]

MARKET PULSE
BTC: $[X]  [+/-X%] 4h  [MOVING / STABLE]
ETH: $[X]  [+/-X%] 4h  [MOVING / STABLE]
Smart Money Bias: [BULLISH / BEARISH / NEUTRAL]
Meme Temperature: [HOT / WARM / COOL / DEAD]
━━━━━━━━━━━━━━━━━━━━━━━
KOL Growth Pack — Trend Radar
```

---

## Section 2 — Content Factory

*Triggered by: `--task content-factory` | Schedule: 08:00 UTC daily*

**Purpose:** Generate a full day's content batch — six topics, two draft versions each. Deliver to the user for approval. Write all drafts to kol-queue.

### Step 1 — Load Context

Read `kol-memory` and retrieve:
- Creator persona configuration (voice, topics, audience, tone, format)
- Topics covered in the last 7 days → must not be repeated
- High-performing content patterns → bias toward these formats
- If today is Monday: also retrieve last 7 days of performance data for Weekly Audit (Step 6)

### Step 2 — Data Pull

**Fetch in parallel using all three partner Skills:**

**blockbeats-skill:**
- Important newsflashes (15) → `GET /v1/newsflash/important?size=15&lang=en`
- Financing newsflashes (10) → `GET /v1/newsflash/financing?size=10&lang=en`
- AI newsflashes (5) → `GET /v1/newsflash/ai?size=5&lang=en`
- Important articles (24h) → `GET /v1/article/important?size=5&lang=en`
- Market sentiment index → `GET /v1/data/bottom_top_indicator`
- BTC ETF net inflow → `GET /v1/data/btc_etf`
- Top 10 on-chain inflow — Solana → `GET /v1/data/top10_netflow?network=solana`
- Top 10 on-chain inflow — Ethereum → `GET /v1/data/top10_netflow?network=ethereum`

**binance-skills-hub:**
- All ranking dimensions → `crypto-market-rank`
- Top narratives by net inflow → `meme-rush Topic Rush`
- All smart money signals (24h) → `trading-signal`
- BTC, ETH, SOL, BNB price and trend → `query-token-info`

**rootdata-crypto:**
- Top 3 most recently funded projects
- Trending project in AI, DeFi, and Layer 2

### Step 3 — Topic Selection

Select exactly 6 topics from all retrieved data. Apply these rules:

**Must include at least one of each:**
- Data-driven post (leads with a specific number from today's data)
- Narrative/opinion post (takes a clear position on a trend or event)
- Educational post (explains something the audience may not fully understand)
- Alpha/signal post (actionable — smart money signal, funding discovery, listing signal)

**Priority criteria (in order):**
1. Breaking in the last 12 hours AND time-sensitive
2. Has strong opinion potential — can drive genuine replies and debate
3. Has at least one concrete, citable data point from today's fetches
4. Tied to a broader macro narrative that is currently active
5. Not covered by this account in the last 7 days

**For each selected topic, note:** why this topic today, what makes it timely, which format it fits best.

### Step 4 — Draft Generation

For each of the 6 selected topics, generate two complete drafts.

**All drafts must follow these rules:**
- Length: 150-280 words
- Opening: Lead with the most surprising, specific, or provocative point. Never open with "Today", "In the world of crypto", "As we all know", or any variation of scene-setting preamble.
- Structure: hook → context (1-2 sentences maximum) → key insight or specific data → implication or takeaway → closing question
- Data: cite at least one specific number sourced from today's data fetches
- No hashtags
- No emojis unless they serve a clear structural purpose
- Closing question: must be genuinely open and invite specific responses — not "What do you think?" or "Agree?" or any generic engagement-bait
- Voice: must match the persona configuration retrieved from kol-memory

**Draft A — Primary angle (data-driven or direct):**
Write the most straightforward, high-conviction version of this topic. Lead with the data or the strongest claim.

**Draft B — Alternative angle (contrarian, educational, or narrative):**
Write the same topic from a meaningfully different perspective. If Draft A is bullish, Draft B should present the bear case or the risk. If Draft A is data-heavy, Draft B should be more narrative. The difference must be real — not just a reworded version of the same argument.

**For each content package, also output:**
- Timing recommendation: IMMEDIATE (post within 2h), MORNING (09:30-11:00 UTC), AFTERNOON (13:00-14:30 UTC), or EVENING (19:00-21:00 UTC)
- Engagement prediction: HIGH / MEDIUM / LOW
- Primary audience: traders / researchers / retail / builders
- Risk flag: NONE / MILD / SENSITIVE

### Step 5 — Queue and Deliver

Write all 6 draft packages to `kol-queue` with status PENDING. Include: draft A text, draft B text, topic, format type, timing recommendation, engagement prediction, risk flag.

Deliver to the user via notification with the format below. Wait for approval responses. Update kol-queue status when approvals arrive.

Valid approval formats: "APPROVE 1A", "APPROVE 2B", "post 3A", "skip 4", "use the second version of 5", "edit 6" followed by the edited text.

**Output format (one message block per topic):**

```
CONTENT FACTORY  [DATE]
━━━━━━━━━━━━━━━━━━━━━━━
6 POSTS READY FOR APPROVAL
━━━━━━━━━━━━━━━━━━━━━━━

POST 1 of 6  |  [TOPIC NAME]
Format: [DATA / NARRATIVE / EDUCATIONAL / ALPHA]
Timing: [IMMEDIATE / MORNING / AFTERNOON / EVENING]
Engagement: [HIGH / MEDIUM / LOW]  |  Audience: [type]
Risk: [NONE / MILD / SENSITIVE]

DRAFT A — [angle label, e.g. "Data Lead"]
─────────────────────
[Full post text, 150-280 words]
─────────────────────

DRAFT B — [alternative angle label, e.g. "Contrarian Take"]
─────────────────────
[Full post text, 150-280 words]
─────────────────────

Reply: APPROVE 1A  |  APPROVE 1B  |  SKIP 1  |  EDIT 1

━━━━━━━━━━━━━━━━━━━━━━━
[Repeat for posts 2-6]
━━━━━━━━━━━━━━━━━━━━━━━
KOL Growth Pack — Content Factory
```

### Step 6 — Monday Weekly Audit (Mondays only)

If today is Monday, append this section after the content batch delivery.

Read `kol-memory` for the last 7 days of content history and performance data from `kol-analytics` if available.

Output:

```
WEEKLY AUDIT — [DATE RANGE]
━━━━━━━━━━━━━━━━━━━━━━━

LAST WEEK
Posts published: [N]
Best performing format: [type] — avg engagement [HIGH/MED/LOW]
Worst performing format: [type]
Best day/time: [day] [window]
Topics that drove most replies: [list]

THIS WEEK RECOMMENDATIONS
Do more: [specific format or topic type] — because [reason from data]
Do less: [specific format or topic type] — because [reason from data]

7-DAY CONTENT CALENDAR
Mon [date]: [topic suggestion] | [format] | [timing]
Tue [date]: [topic suggestion] | [format] | [timing]
Wed [date]: [topic suggestion] | [format] | [timing]
Thu [date]: [topic suggestion] | [format] | [timing]
Fri [date]: [topic suggestion] | [format] | [timing]
Sat [date]: [topic suggestion] | [format] | [timing]
Sun [date]: [topic suggestion] | [format] | [timing]

Upcoming events to anchor content:
[Event name] — [date] — [why it matters for this audience]
━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Section 3 — Publishing Engine

*Triggered by: `--task publishing-engine` | Schedule: 09:30 UTC daily*

**Purpose:** Publish all APPROVED drafts from kol-queue to Binance Square at optimal times. Update queue and memory after each publish. Report results.

### Step 1 — Load Queue

Read `kol-queue` and retrieve all drafts with status APPROVED. If no APPROVED drafts exist, output "No approved content in queue for today" and end the task.

### Step 2 — Build Schedule

Assign each APPROVED draft to a publishing window based on its timing recommendation:

- IMMEDIATE → publish as soon as this task runs (09:30)
- MORNING → publish between 09:30-11:00 UTC
- AFTERNOON → publish between 13:00-14:30 UTC
- EVENING → publish between 19:00-21:00 UTC

Rules:
- Maximum 8 posts per day total — if more than 8 are APPROVED, prioritise by engagement prediction (HIGH first), then carry the rest to tomorrow
- Minimum 90 minutes between consecutive posts
- If two posts are assigned to the same window, stagger them 90 minutes apart within that window

### Step 3 — Publish

For each post at its scheduled time:

1. Retrieve the approved post text from kol-queue — the exact text, unmodified
2. Invoke `square-post` with that exact text
3. On SUCCESS:
   - Update kol-queue status → PUBLISHED
   - Write to kol-memory: post text, topic, format, publish time, day
   - Write to kol-analytics: topic, format type, window, day of week, timestamp
   - Send per-post confirmation notification
4. On FAILURE:
   - Wait 5 minutes
   - Retry once
   - If retry succeeds: update status → PUBLISHED, proceed as above
   - If retry fails: update status → FAILED, send failure notification, do not retry again

### Step 4 — End of Day Summary

After all scheduled posts are processed (or at 22:00 UTC, whichever is earlier), send:

```
PUBLISHING SUMMARY  [DATE]
━━━━━━━━━━━━━━━━━━━━━━━

Published: [N]  |  Failed: [N]  |  Skipped: [N]  |  Carried to tomorrow: [N]

PUBLISHED TODAY
[Time] Post 1 — [topic] — [first 50 chars]... SUCCESS
[Time] Post 2 — [topic] — [first 50 chars]... SUCCESS
[Time] Post 3 — [topic] — [first 50 chars]... FAILED — retry also failed

CARRIED TO TOMORROW
[Topic] — will publish in [timing window] tomorrow

━━━━━━━━━━━━━━━━━━━━━━━
KOL Growth Pack — Publishing Engine
```
