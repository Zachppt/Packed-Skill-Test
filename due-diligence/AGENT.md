---
workspace: due-diligence
version: 1.0.0
---

# Due Diligence Workspace Rules

These rules add to the global AGENT.md. They apply only when --workspace due-diligence is active.

## Trigger Recognition

Activate this workspace's task when the user says any of:
- "due diligence on [project]" / "DD on [token]"
- "analyze [project]" / "assess [project]" / "research [project]"
- "should I look at [project]?"
- "what do we know about [project]?"
- "check [contract address]"

If the project name is ambiguous (matches multiple known projects), ask once to clarify before proceeding. After clarification, execute immediately without further questions.

## Execution Order

Run Dimensions 1 and 2 first using rootdata-crypto — these establish the project's identity and funding context needed for later dimensions.

Run Dimensions 3, 4, 5, and 6 in parallel after Dimensions 1 and 2 complete.

Run Dimension 7 last — it depends on data from all other dimensions plus additional targeted searches.

Compile the scorecard and verdict after all seven dimensions are complete.

## Scoring Discipline

Apply the scoring criteria in due-diligence/SKILL.md exactly as written. Do not adjust scores based on the user's apparent sentiment toward the project.

If a Dimension 7 automatic risk flag is triggered, it must appear in the report regardless of how well the project scored in other dimensions. Risk flags are never suppressed.

## Output

Deliver the verdict and total score first. Then the dimension breakdown. Then the scorecard table. Do not reorder.

The verdict statement must be one of exactly four values: STRONG CANDIDATE, MONITOR, PROCEED WITH CAUTION, or AVOID. No variations. No qualifications appended to the verdict label itself. Qualifications belong in the supporting evidence, not the verdict line.

## Partial Data Handling

If rootdata-crypto returns no results for the queried project:
- Note this prominently above the verdict: "Project not found in RootData — report based on Binance and BlockBeats data only. Confidence: LOW."
- Score Dimensions 1 and 2 as 2 (insufficient data)
- Continue with remaining dimensions using available sources

If the token is not yet listed on any exchange:
- Score Dimension 4 based on projected listing quality and funding profile
- Note: "Token not yet listed — D4 scored on funding-implied listing trajectory"
