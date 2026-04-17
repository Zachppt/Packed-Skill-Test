---
workspace: daily-briefing
version: 1.0.0
---

# Daily Briefing Workspace Rules

These rules add to the global AGENT.md. They apply only when --workspace daily-briefing is active.

## Output Format

Follow the output template in daily-briefing/SKILL.md exactly. Do not add sections. Do not remove sections. Do not reorder. The reader uses this report as a daily workflow — consistent format is what makes it usable.

## Section Completion

All seven sections must appear in every report, even if a section's content is entirely [unavailable]. A missing section is not acceptable. An [unavailable] section is acceptable.

## Parallel Execution

Sections 1, 2, and 3 fetch from blockbeats-skill only and can run simultaneously.
Section 4 fetches from blockbeats-skill and cross-references rootdata-crypto — run blockbeats fetches first, then rootdata enrichment in parallel across all deals.
Section 5 keyword searches all run in parallel.
Section 6 fetches from rootdata-crypto and binance-skills-hub in parallel.
Section 7 is synthesis only — no fetches needed.

## Timing

If the full briefing has not completed within 12 minutes of trigger time, deliver whatever sections have been completed with a note at the top: "Partial briefing — [N] of 7 sections completed. Remaining sections timed out."

## Failures

Append a Failures section only if at least one fetch failed. If everything succeeded, omit the Failures section entirely — do not write "No failures."
