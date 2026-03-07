---
name: evo
description: A rigorous, assumption-explicit, non-redundant coding workflow for agents. Use for tricky tasks, refactors, debugging, or when correctness and safety matter.
---

# EVO (Explicit-assumption Verification Orchestrator)

This skill defines a strict workflow for coding-agent tasks where correctness, safety, and clarity matter. It is designed to work across Codex CLI and Claude Code.

## When to use

Use this workflow when the user asks for any of the following (or the task obviously requires it):

- Non-trivial debugging, multi-step refactors, migrations
- Anything safety-sensitive (secrets, auth, destructive operations)
- Tooling-heavy work (tests/build/lint, CI failures)
- Ambiguous requirements (where assumptions could break the result)

## Core rules (EVO)

### 1) Make assumptions explicit

Before acting on missing details, write down:

- **What you assume**
- **Why it's reasonable**
- **How you will validate it** (from repo context or by running a targeted command)

If an assumption is *risky* or *user-preference-dependent*, ask a concise clarifying question instead of guessing.

### 2) Non-redundancy (do not "double solve")

- Don't run multiple tools/commands to compute the same thing.
- Don't repeat a command that already produced sufficient evidence.
- Prefer the smallest command that answers the question (e.g., `rg` before opening many files).
- Stop once the problem is solved end-to-end (implementation + validation).

### 3) Purpose-first tool choice

Choose tools/commands by purpose, not habit:

- **Locate**: `rg`, file globs, directory listing
- **Understand**: open the smallest relevant files first
- **Change**: minimal edits; avoid unrelated refactors
- **Verify**: run the most specific test/build step that validates your change

### 4) Safety by default

- Never expose secrets; avoid printing tokens/keys.
- Avoid destructive operations (`rm`, `reset`, force pushes) unless the user explicitly asked.
- If a command could be destructive or irreversible, **ask first**.
- Prefer reversible changes and clear rollback steps.

### 5) Obey repository rules

If the repo contains agent instructions (e.g., `AGENTS.md`, `CONTRIBUTING`, tool policies), treat them as binding within scope.

## Standard workflow (repeatable)

1. **Triage**
   - Identify the exact goal, success criteria, and constraints.
2. **Discover**
   - Find the minimal set of files/places involved.
3. **Plan (only if needed)**
   - Use a short plan when there are multiple dependent steps.
4. **Implement**
   - Make the smallest change that solves the root cause.
5. **Validate**
   - Run targeted tests/builds; expand scope only if necessary.
6. **Report**
   - Summarize changes, what was validated, and what remains (if anything).

## Output style requirements

- Be concise and information-dense.
- Prefer actionable next steps and exact commands.
- Include concrete paths and identifiers (file paths, symbols, commands).
