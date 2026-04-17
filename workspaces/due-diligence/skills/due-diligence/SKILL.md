---
name: due-diligence
title: AethirClaw New Project Due Diligence Pipeline
description: A systematic seven-dimension project assessment triggered on demand. Given a project name, token symbol, or contract address, produces a complete research report with a scored verdict within a single Agent session. No scheduled trigger — runs when the user requests it.
version: 1.0.0
author: AethirClaw CN Team
metadata:
  openclaw:
    emoji: "🔍"
    requires:
      skills:
        - rootdata-crypto
        - binance-skills-hub
        - blockbeats-skill
    tags:
      - due-diligence
      - research
      - project-analysis
      - investment-research
---

# New Project Due Diligence Pipeline

**Trigger phrases** (any of these activates this Skill):
- "due diligence on [project]"
- "analyze [project]"
- "research [project / token]"
- "should I look at [project]?"
- "assess [project]"
- "DD on [token]"
- "what do we know about [project]?"
- "check [contract address]"

When triggered, confirm the project name with the user if it is ambiguous, then execute all seven dimensions completely. Do not skip any dimension. Do not wait for user input between dimensions.

**The verdict comes first.** Deliver the one-line verdict at the top of the report, before the supporting evidence. Readers need to know the conclusion before reading the detail.

---

## Scoring Framework

Each dimension is scored 1-5. The total score determines the verdict.

| Score Range | Verdict |
|---|---|
| 30-35 | STRONG CANDIDATE — high conviction, proceed with full attention |
| 23-29 | MONITOR — solid fundamentals with identified risks, watchlist worthy |
| 15-22 | PROCEED WITH CAUTION — meaningful concerns, requires specific risk mitigation |
| 7-14 | AVOID — fundamental problems outweigh potential, not worth the risk |

---

## Dimension 1 — Project Fundamentals

**Source: rootdata-crypto**

Retrieve:
- Project full name, token symbol, official website, social links
- One-paragraph project description
- Sector and ecosystem tags
- Development stage: pre-launch / testnet / mainnet / live with token
- Mainnet or TGE launch date
- Team background: founder names, prior roles, notable credentials, doxxed or anonymous
- Advisory relationships and strategic backers

**Score this dimension 1-5:**
- 5: Clear problem solved, experienced doxxed team with relevant credentials, active mainnet or credible timeline
- 4: Solid fundamentals with minor gaps (anonymous team with strong track record counts as 4)
- 3: Average — generic problem statement, mixed team credentials, pre-mainnet
- 2: Weak fundamentals — vague use case, unverifiable team, no clear competitive advantage
- 1: Red flags — plagiarised whitepaper, no verifiable team, completely pre-product

---

## Dimension 2 — Funding and Investor Intelligence

**Source: rootdata-crypto**

Retrieve:
- Complete round-by-round funding history: round name, amount, date, all investors, lead investor, valuation where disclosed
- Total capital raised
- Days since most recent round
- All participating investors with tier classification

**Investor tier classification:**
- Tier 1: a16z, Paradigm, Sequoia, Multicoin, Pantera, Binance Labs, Coinbase Ventures, Polychain
- Tier 2: Dragonfly, Delphi, Framework, Jump, Galaxy, OKX Ventures
- Tier 3: Regional or emerging funds
- Unclassified: unknown or unverifiable

**Score this dimension 1-5:**
- 5: Tier 1 lead investor, total raise > $20M, recent round within 12 months
- 4: Tier 1 or multiple Tier 2 investors, total raise > $5M
- 3: Tier 2 investors, total raise $1M-$5M
- 2: Tier 3 only, raise < $1M, or round data unverifiable
- 1: No disclosed investors, no funding history, or raise from unknown entities only

---

## Dimension 3 — Token Economics

**Source: rootdata-crypto + binance query-token-info**

Retrieve:
- Token name, symbol, total supply, circulating supply percentage
- Current price (if listed)
- Fully diluted valuation and market cap
- Allocation breakdown: team, investors, ecosystem, public sale percentages
- Vesting schedule: cliff and duration for team and investor tranches
- Next major unlock: date, amount, percentage of total supply
- Token utility: what the token does within the protocol

**Flag automatically:**
- Team + investor allocation > 40% of total supply → HIGH CONCENTRATION RISK
- Unlock event in the next 30 days releasing > 5% of supply → NEAR-TERM SELL PRESSURE
- No lockup or cliff for team tokens → MISALIGNED INCENTIVES
- Token utility = fee payment only with no value accrual → WEAK TOKEN DESIGN

**Score this dimension 1-5:**
- 5: Balanced allocation (<30% team+investors), long vesting (>2 years), strong token utility, no near-term unlock pressure
- 4: Reasonable allocation, standard vesting, functional utility
- 3: Slightly concentrated or short vesting, basic utility
- 2: High concentration or very short vesting, or weak utility
- 1: Any of the automatic red flags above present

---

## Dimension 4 — Market and Liquidity Position

**Source: binance query-token-info + rootdata-crypto**

Retrieve:
- All CEX listings with tier classification
- DEX liquidity pools and approximate depth
- 24h, 7d, 30d price performance
- 24h trading volume across all venues
- All-time high price and current drawdown from ATH
- Recent price trend: uptrend / downtrend / consolidation / recovering

**Score this dimension 1-5:**
- 5: Listed on Tier 1 exchange, daily volume > $10M, healthy liquidity depth, less than 50% below ATH
- 4: Tier 1 or Tier 2 listing, daily volume > $1M
- 3: Tier 2-3 listings, daily volume $100K-$1M
- 2: DEX only or single small CEX, daily volume < $100K, high slippage risk
- 1: Not yet listed, or extremely thin liquidity making price easily manipulated
- Note: Not yet listed is not automatically negative — score on projected listing quality and timeline

---

## Dimension 5 — Community and Ecosystem Health

**Source: rootdata-crypto + blockbeats-skill keyword search**

Retrieve:
- Twitter/X follower count
- Discord and Telegram community size
- GitHub activity: recent commit frequency (active / inactive / archived)
- Key ecosystem integrations and major protocol partnerships
- Developer activity classification

**Run a blockbeats-skill keyword search for the project name:**
- `GET /v1/search?name=[PROJECT]&size=10&lang=en`
- Filter to last 30 days
- Count: how many articles? how many newsflashes? Coverage frequency = community signal strength

**Score this dimension 1-5:**
- 5: Twitter > 100K, active Discord > 10K, active GitHub, multiple protocol integrations, regular media coverage
- 4: Twitter > 20K, engaged community, active development
- 3: Twitter 5K-20K, moderate community, some media coverage
- 2: Twitter < 5K, small or bot-inflated community, minimal coverage
- 1: No verifiable community, dead GitHub, no media coverage in last 30 days

---

## Dimension 6 — Competitive Positioning

**Source: rootdata-crypto**

Retrieve:
- Top 3 direct competitors in the same sector
- For each competitor: funding status, key metric (TVL, volume, users), exchange listings
- Differentiation analysis: what makes this project meaningfully different

**Score this dimension 1-5:**
- 5: Clear differentiation with defensible moat, competitors are weaker or in different niches
- 4: Solid differentiation, competitive but not obviously losing
- 3: Similar to competitors with incremental advantages
- 2: Feature parity with established competitors, no clear reason to switch
- 1: Clearly inferior to existing solutions with no compelling differentiation

---

## Dimension 7 — Risk Assessment

**Source: all available data + blockbeats-skill keyword search**

**Automatically check for each risk factor:**

Token unlock risk:
- Check next unlock date and amount from Dimension 3
- If unlock within 30 days releasing > 5% of supply → flag NEAR-TERM SELL PRESSURE

Smart money behaviour:
- Check binance trading-signal for any signals on this token
- Active SELL signals from smart money → flag SMART MONEY EXITING

Security risk:
- Run binance query-token-audit on the contract address
- Any honeypot detection, malicious function, or dangerous permission → flag CONTRACT RISK

Recent negative coverage:
- Run blockbeats-skill keyword search for: "[PROJECT NAME] hack", "[PROJECT NAME] exploit", "[PROJECT NAME] rug", "[PROJECT NAME] scam", "[PROJECT NAME] SEC"
- Any results in last 90 days → flag NEGATIVE PRESS RISK

Price deterioration:
- If 30-day price change < -40% → flag SIGNIFICANT DRAWDOWN
- If price is more than 80% below ATH → flag DEEP ATH DISCOUNT (note: can be opportunity or value trap)

Centralisation risk:
- If top 10 holders control > 60% of supply → flag CONCENTRATION RISK

Regulatory exposure:
- If project is US-facing, involves securities-like token, or has received regulatory attention → flag REGULATORY RISK

**Score this dimension 1-5:**
- 5: No flags triggered
- 4: One minor flag (e.g., modest unlock, no current smart money signals)
- 3: One moderate flag or two minor flags
- 2: Two moderate flags or one critical flag
- 1: Three or more flags, or any combination including CONTRACT RISK or SMART MONEY EXITING

---

## Final Scoring and Verdict

Add scores from all seven dimensions. Maximum possible: 35.

Calculate:
- Total score: [sum]
- Verdict: [STRONG CANDIDATE / MONITOR / PROCEED WITH CAUTION / AVOID]
- Confidence level: HIGH (all 7 dimensions had full data) / MEDIUM (1-2 dimensions had partial data) / LOW (3+ dimensions had unavailable data)

**The verdict statement must be unambiguous.** Do not write "it depends on your risk tolerance." The scoring framework produces a clear verdict. State it.

---

## Output Format

Deliver the report in this exact structure:

```
DUE DILIGENCE REPORT
[PROJECT NAME]  ([TOKEN SYMBOL])
[DATE]  [TIME UTC]
━━━━━━━━━━━━━━━━━━━━━━━

VERDICT: [STRONG CANDIDATE / MONITOR / PROCEED WITH CAUTION / AVOID]
Score: [X]/35  |  Confidence: [HIGH / MEDIUM / LOW]
[One sentence summary of the primary reason for this verdict]

━━━━━━━━━━━━━━━━━━━━━━━

D1 — FUNDAMENTALS  [X/5]
Sector: [tags]  |  Stage: [stage]  |  Team: [doxxed / anon]
[2-3 sentences covering what the project does, team quality, and development status]

D2 — FUNDING  [X/5]
Total Raised: $[X]M across [N] rounds
Latest: $[X]M [Round] — [N] days ago — led by [Investor] ([Tier])
All investors: [list with tiers]
[1 sentence assessment of investor quality signal]

D3 — TOKEN ECONOMICS  [X/5]
Supply: [X]M total | [X]% circulating
FDV: $[X]M  |  Market Cap: $[X]M  |  Price: $[X]
Allocation: Team [X%] | Investors [X%] | Ecosystem [X%] | Public [X%]
Vesting: [cliff] cliff, [duration] duration
Next Unlock: [date] — [X]% of supply ([NEAR-TERM SELL PRESSURE flag if applicable])
Token utility: [one sentence]
[Automatic flags if triggered]

D4 — MARKET POSITION  [X/5]
Listings: [CEX list with tiers] | DEX: [list]
Price: $[X] | 24h [+/-X%] | 7d [+/-X%] | 30d [+/-X%]
Volume 24h: $[X]  |  ATH: $[X]  |  Drawdown: [-X%]
Trend: [UPTREND / DOWNTREND / CONSOLIDATION / RECOVERING]

D5 — COMMUNITY AND ECOSYSTEM  [X/5]
Twitter: [X]K  |  Discord: [X]K  |  GitHub: [ACTIVE / INACTIVE]
Media coverage (30d): [N] articles, [N] newsflashes
Key integrations: [list]
[1 sentence on community health signal]

D6 — COMPETITIVE POSITION  [X/5]
Top competitors:
1. [Name] — [key metric] — [funding status]
2. [Name] — [key metric] — [funding status]
3. [Name] — [key metric] — [funding status]
Differentiation: [one sentence — what makes this project distinctly better or different]

D7 — RISK ASSESSMENT  [X/5]
[List only the flags that were triggered. If none: "No risk flags identified."]
[Flag]: [one sentence explanation]
[Flag]: [one sentence explanation]

━━━━━━━━━━━━━━━━━━━━━━━

SCORECARD
D1 Fundamentals:    [X]/5
D2 Funding:         [X]/5
D3 Token Economics: [X]/5
D4 Market Position: [X]/5
D5 Community:       [X]/5
D6 Competition:     [X]/5
D7 Risk:            [X]/5
─────────────────────────
TOTAL:              [X]/35

VERDICT: [STRONG CANDIDATE / MONITOR / PROCEED WITH CAUTION / AVOID]

━━━━━━━━━━━━━━━━━━━━━━━
AethirClaw Due Diligence | rootdata-crypto x binance-skills-hub x blockbeats-skill
```

---

## Handling Missing Data

If critical data is unavailable for a dimension:
- Score that dimension 2 (not 1 — absence of data is not the same as bad data)
- Mark confidence as MEDIUM or LOW accordingly
- Note specifically what was unavailable and why (e.g., "Token not yet listed — D4 scored on projected listing quality and funding profile")

If the project cannot be found in RootData at all:
- Note this prominently at the top of the report
- Use only Binance and BlockBeats data for available dimensions
- Mark confidence as LOW
- Note that unverified projects with no RootData profile represent elevated baseline risk
