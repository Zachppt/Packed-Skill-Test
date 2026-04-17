---
workspace: kol-growth-pack
version: 1.0.0
---

# KOL Growth Pack Workspace Rules

These rules add to the global AGENT.md. They apply only when --workspace kol-growth-pack is active.

## Task Routing

Read the --task parameter and execute only the corresponding section of kol-growth-pack/SKILL.md.

--task trend-radar       → Section 1 only
--task content-factory   → Section 2 only (plus Section 6 on Mondays)
--task publishing-engine → Section 3 only

Never run multiple tasks in a single execution. Never run content-factory and publishing-engine together.

## Memory and Queue

Read kol-memory at the start of every content-factory run before any data fetch or topic selection. Topic selection without memory context will produce repetitive content.

Write to kol-queue immediately after draft generation completes — before delivering drafts to the user. If kol-queue write fails, deliver drafts anyway and flag: "Queue write failed — approvals must be given in this session for publishing to work."

Read kol-queue at the start of every publishing-engine run. If no APPROVED drafts exist, send one notification — "No approved content in queue for today" — and end the task.

## Publishing Rules

Hard limit: maximum 8 posts per day to Binance Square regardless of approvals.

Hard limit: minimum 90 minutes between consecutive posts.

Publish the approved text exactly as approved. Do not fix typos. Do not rephrase. Do not improve. The user approved specific text — that is what gets published.

On publish failure: retry once after 5 minutes. If retry fails, mark FAILED, notify the user, and stop. Do not attempt a third time without explicit re-approval.

## Persona

Always read kol-memory for persona configuration before generating any draft. If no persona is configured, use the default persona defined in kol-growth-pack/SKILL.md and notify: "No persona configured — using defaults. Say 'update my KOL persona' to customise."

## Monday Behaviour

On Mondays, the content-factory task automatically appends the Weekly Audit after the content batch. No additional trigger needed. If kol-analytics returns insufficient data (fewer than 10 posts tracked), note "Insufficient data for high-confidence recommendations" and provide directional observations only.
