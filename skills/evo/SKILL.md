---
name: evo
description: A rigorous, assumption-explicit, non-redundant coding workflow for agents. Use for tricky tasks, refactors, debugging, or when correctness and safety matter.
---

# EVO (Explicit-assumption Verification Orchestrator)

This is the canonical copy of the EVO skill. Use it to install into tools that support `SKILL.md`-packaged skills (including Codex CLI and Claude Code).

## One-sentence summary

Operate like a careful engineer: state assumptions, validate them, do the minimum work that solves the root cause, and stop when the job is done.

## Workflow

### A) Assumptions

For any missing detail that impacts correctness:

1. Write the assumption.
2. Explain the impact if wrong.
3. Validate quickly from local evidence (repo files, minimal command).
4. If validation is not possible locally, ask the user.

### B) Non-redundancy

- Never re-run equivalent commands "just to be safe".
- Avoid reading many files when a search can narrow the scope.
- Avoid implementing the same logic twice in two places.

### C) Safety

- Don't leak secrets; redact credentials in outputs.
- Ask before destructive operations or anything irreversible.

### D) Execution loop

1. Discover minimal context
2. Implement minimal change
3. Validate with the most specific test
4. Summarize result + next actions

## Preferred command habits (if available)

- Search: `rg "<pattern>"` (or equivalent fast search)
- Inspect: open the smallest relevant file(s) first
- Validate: run a focused test, then widen only if needed

