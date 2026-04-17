---
name: daily-briefing
title: AethirClaw Daily Intelligence Briefing
description: A comprehensive daily crypto market intelligence report combining BlockBeats macro and news data, RootData funding intelligence, and Binance market signals into a single structured briefing. Triggered automatically at 06:30 UTC. No user input required.
version: 1.0.0
author: AethirClaw CN Team
metadata:
  openclaw:
    emoji: "📊"
    requires:
      env:
        - BLOCKBEATS_API_KEY
      skills:
        - blockbeats-skill
        - rootdata-crypto
        - binance-skills-hub
    tags:
      - market-intelligence
      - daily-briefing
      - automation
      - crypto
---

# Daily Intelligence Briefing

Run this Skill when triggered by the `briefing` task in HEARTBEAT.md. Execute all six sections completely and in order. Fetch all independent data sources in parallel within each section. Never skip a section. If a data source fails, mark it `[unavailable]` and continue.

This Skill coordinates three partner Skills: **blockbeats-skill** for macro data and news, **rootdata-crypto** for funding intelligence, and **binance-skills-hub** for market signals and rankings.

---

## Pre-Execution Checklist

Before beginning, confirm:
- BLOCKBEATS_API_KEY is set in the environment
- blockbeats-skill, rootdata-crypto, and binance-skills-hub are installed
- Output delivery channel is available (default system notification)

If BLOCKBEATS_API_KEY is missing, abort the task and notify: "Daily Briefing cannot run — BLOCKBEATS_API_KEY not set. Please add it to ~/.openclaw/secrets.env."

---

## Section 1 — Macro Environment

**Fetch in parallel using blockbeats-skill:**
- Global M2 supply → `GET /v1/data/m2_supply?type=1Y`
- US 10Y Treasury yield → `GET /v1/data/us10y?type=1M`
- DXY Dollar Index → `GET /v1/data/dxy?type=1M`
- Compliant exchange total assets → `GET /v1/data/compliant_total`

**Interpret each indicator using these exact criteria:**

M2 Supply:
- YoY change > 5% → EXPANSIONARY — loose liquidity, favorable for risk assets
- YoY change 0% to 5% → NEUTRAL — watch for direction change
- YoY change < 0% → CONTRACTIONARY — tightening liquidity, risk assets under pressure

US 10Y Yield:
- Rising vs prior month → RISING — higher risk-free rate, capital pressure on crypto
- Flat (within 0.1%) → FLAT — no immediate pressure signal
- Falling vs prior month → FALLING — reducing rate pressure, permissive for risk assets

DXY Dollar Index:
- DXY > prior month reading → STRONG DOLLAR — constrains crypto performance
- DXY flat (within 0.5) → CONSOLIDATING — neutral signal
- DXY < prior month reading → WEAK DOLLAR — permissive for crypto performance

Compliant Exchange Assets:
- Rising vs prior reading → INSTITUTIONAL INFLOW — growing allocation appetite
- Flat → STABLE
- Falling → INSTITUTIONAL OUTFLOW — reduced institutional participation

**Overall macro verdict — derive from the combination of all four indicators:**
- 3 or more bullish signals → RISK-ON
- 3 or more bearish signals → RISK-OFF
- Mixed → MIXED — note which signals are conflicting

---

## Section 2 — Sentiment and Capital Flow

**Fetch in parallel using blockbeats-skill:**
- Market sentiment index → `GET /v1/data/bottom_top_indicator`
- BTC ETF net inflow → `GET /v1/data/btc_etf`
- IBIT and FBTC net inflow → `GET /v1/data/ibit_fbtc`
- Daily on-chain transaction volume → `GET /v1/data/daily_tx`
- Stablecoin market cap → `GET /v1/data/stablecoin_marketcap`
- Top 10 on-chain net inflow — Solana → `GET /v1/data/top10_netflow?network=solana`
- Top 10 on-chain net inflow — Ethereum → `GET /v1/data/top10_netflow?network=ethereum`
- Top 10 on-chain net inflow — Base → `GET /v1/data/top10_netflow?network=base`
- Bitfinex BTC longs → `GET /v1/data/bitfinex_long?symbol=btc&type=h24`

**Interpret:**

Sentiment Index:
- 0-20 → EXTREME FEAR — historically correlated with medium-term bottoms
- 21-40 → FEAR
- 41-59 → NEUTRAL
- 60-79 → GREED
- 80-100 → EXTREME GREED — historically correlated with medium-term tops

BTC ETF signal flags:
- Daily inflow > $500M → flag as INSTITUTIONAL ACCUMULATION SIGNAL
- Daily outflow > $300M → flag as INSTITUTIONAL DISTRIBUTION SIGNAL
- 3 consecutive days of inflow → flag as SUSTAINED ACCUMULATION

Stablecoin market cap:
- Rising vs prior reading → EXPANDING — dry powder increasing, more capital entering
- Falling → CONTRACTING — capital exiting the ecosystem

On-chain net inflow — cross-chain convergence:
- If the same token appears in the top 5 of two or more chains simultaneously → flag as CROSS-CHAIN CONVERGENCE SIGNAL

Bitfinex BTC longs:
- Rising vs prior reading → ACCUMULATING — large players adding leverage long
- Falling → DISTRIBUTING — large players reducing leveraged exposure

---

## Section 3 — Derivatives and Leverage

**Fetch in parallel using blockbeats-skill:**
- Derivatives platform comparison → `GET /v1/data/contract?dataType=1D`
- Exchange snapshot → `GET /v1/data/exchanges?size=10`

**Output:**
- Binance OI, Bybit OI, Hyperliquid OI — side by side with day-over-day change for each
- Top 5 exchanges by volume with OI — flag any shift in rankings vs prior day
- Leverage risk assessment:
  - OI rising + sentiment > 70 → HIGH LEVERAGE RISK — overleveraged market, vulnerable to flush
  - OI rising + sentiment 40-70 → MEDIUM — healthy growth with some risk
  - OI flat or falling → LOW — deleveraging in progress

---

## Section 4 — News and Funding Intelligence

**Fetch in parallel using blockbeats-skill:**
- Important newsflashes → `GET /v1/newsflash/important?size=10&lang=en`
- Financing newsflashes → `GET /v1/newsflash/financing?size=8&lang=en`
- On-chain newsflashes → `GET /v1/newsflash/onchain?size=5&lang=en`
- AI sector newsflashes → `GET /v1/newsflash/ai?size=5&lang=en`
- Prediction market newsflashes → `GET /v1/newsflash/prediction?size=5&lang=en`
- Important articles (24h) → `GET /v1/article/important?size=5&lang=en`

**Filter all results to the last 24 hours only. Discard anything older.**

**Select and output:**
- Top 5 most important headlines: title + one-sentence summary + URL + relative time
- Top 3 financing deals today: project name, amount, round, lead investor, URL
  - For each deal, cross-reference with **rootdata-crypto** to add investor tier classification
- Top 2 on-chain data highlights: what the data shows + one-sentence implication
- Top 2 AI sector developments: what happened + why it matters
- Top 2 prediction market movements: which markets shifted + direction
- Featured article: title + two-sentence summary + URL
- One editorial flag per category: the single most actionable insight from that category

---

## Section 5 — Keyword Radar

**Run searches in parallel using blockbeats-skill for each term:**
`GET /v1/search?name=[KEYWORD]&size=5&lang=en`

Keywords: BlackRock, ETF, SEC, Liquidation, Hack, Exploit, Airdrop, Listing, Layer2, Stablecoin, Whale, Regulation

**Filter to results published in the last 24 hours only.**

For each keyword with at least one fresh result:
- Output keyword as a header
- List up to 2 headlines with title and URL
- Add a one-line significance note: why does this keyword appearing today matter?

Skip keywords with no fresh results entirely. Do not output them.

---

## Section 6 — RootData Funding Pulse

**Using rootdata-crypto, retrieve:**
- Top 5 most recent funding announcements across all sectors (last 48 hours)
- Top trending project in the AI sector today
- Top trending project in the DeFi sector today
- Top trending project in the Layer 2 sector today

**For each funded project, output:**
- Project name, sector, amount raised, round name, lead investor
- Investor tier: Tier 1 (a16z, Paradigm, Sequoia, Multicoin, Pantera, Binance Labs) / Tier 2 / Emerging
- Token status: listed / not yet listed
- If listed: pull current price and 24h change from **binance query-token-info**
- One-sentence assessment: does this deal represent a meaningful signal for the sector?

**For each trending project, output:**
- Project name, what it does (one sentence), current development stage
- Why it is trending today if determinable

---

## Section 7 — Daily Verdict

After all six sections are complete, write a verdict covering:

1. **Macro backdrop**: one sentence summarising the M2/DXY/yield combination and its crypto implication today
2. **Sentiment positioning**: one sentence on where retail and institutional sentiment sits
3. **Capital flow direction**: one sentence on where money is actually moving (on-chain + ETF + stablecoin combined)
4. **Key risk**: the single most significant risk factor visible in today's data
5. **One thing to watch**: a specific token, narrative, or event to monitor closely in the next 24 hours — concrete and named, not generic

Total verdict length: 5-7 sentences. No more.

---

## Output Format

Deliver as a single structured notification. Use this exact template:

```
DAILY INTELLIGENCE BRIEFING
[DATE]  [TIME UTC]
━━━━━━━━━━━━━━━━━━━━━━━

MACRO
M2: [value] YoY [+/-X%] | [EXPANSIONARY / NEUTRAL / CONTRACTIONARY]
DXY: [value] | [STRONG DOLLAR / WEAK DOLLAR / CONSOLIDATING]
10Y Yield: [value]% | [RISING / FALLING / FLAT]
Inst. Assets: [INFLOW / OUTFLOW / STABLE]
Verdict: [RISK-ON / RISK-OFF / MIXED] — [one sentence reason]

━━━━━━━━━━━━━━━━━━━━━━━

SENTIMENT AND FLOWS
Sentiment: [value] | [EXTREME FEAR / FEAR / NEUTRAL / GREED / EXTREME GREED]
BTC ETF: Today [+/-$XM] | Cumulative [$XB] [flag if threshold crossed]
IBIT/FBTC: [values]
On-chain Vol: [$X] | [+/-X%] vs yesterday
Stablecoins: [EXPANDING / CONTRACTING] | USDT+USDC [$XB]
Bitfinex Longs: [value] | [ACCUMULATING / DISTRIBUTING]

On-chain Top Inflows:
SOL: [token $X] | [token $X] | [token $X]
ETH: [token $X] | [token $X] | [token $X]
Base: [token $X] | [token $X] | [token $X]
[CROSS-CHAIN CONVERGENCE: token if applicable]

━━━━━━━━━━━━━━━━━━━━━━━

DERIVATIVES
Binance OI: $[X] [+/-X%] | Bybit OI: $[X] [+/-X%] | Hyperliquid OI: $[X] [+/-X%]
Leverage Risk: [HIGH / MEDIUM / LOW]

━━━━━━━━━━━━━━━━━━━━━━━

TOP NEWS
1. [Title] — [URL] ([time])
   [One-sentence summary]
2. [Title] — [URL] ([time])
3. [Title] — [URL] ([time])
4. [Title] — [URL] ([time])
5. [Title] — [URL] ([time])

DEALS TODAY
[Project] — $[X]M [Round] | [Investor] ([Tier]) | Token: [listed at $X / not listed]
[Project] — $[X]M [Round] | [Investor] ([Tier])
[Project] — $[X]M [Round] | [Investor] ([Tier])

━━━━━━━━━━━━━━━━━━━━━━━

KEYWORD RADAR
[Keyword]: [Headline] — [URL]
[Keyword]: [Headline] — [URL]
[Keyword]: [Headline] — [URL]

━━━━━━━━━━━━━━━━━━━━━━━

FUNDING PULSE (RootData)
[Project] | [Sector] | $[X]M [Round] | [Investor] [Tier] | [listed $X / not listed]
Trending AI: [Project] — [one sentence]
Trending DeFi: [Project] — [one sentence]
Trending L2: [Project] — [one sentence]

━━━━━━━━━━━━━━━━━━━━━━━

DAILY VERDICT
[5-7 sentence verdict covering macro, sentiment, capital flow, key risk, one thing to watch]

━━━━━━━━━━━━━━━━━━━━━━━
AethirClaw Daily Briefing | blockbeats-skill x rootdata-crypto x binance-skills-hub
```

---

## Failure Logging

If any fetch failed, append this section after the main output:

```
FETCH FAILURES
[Endpoint]: [Error message or status code]
[Endpoint]: [Error message or status code]
```

If no failures occurred, omit this section entirely.
