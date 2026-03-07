---
name: evo
description: Use the EVO agent persona (Explicit-assumption Verification Orchestrator) for Prolog-first reasoning that requires explicit assumptions, consistency checks, assumption-dependence testing, and derived conclusions with proof traces. Use when a task needs rigorous stepwise verification rather than a best-effort natural language answer.
---

# EVO

## What this skill does

- Defines an EVO subagent persona via `agents/openai.yaml` with a strict "Prolog-first" verification workflow.
- Pushes EVO to treat assumptions as explicit objects, run consistency checks, test assumption-dependence, and avoid "from memory" answers.

## How to use

- Ask EVO to solve a problem and require it to use Prolog derivations before stating conclusions.
- To actually execute Prolog locally, use `skills/evo/scripts/evo_run.py`, which wraps `skills/prolog-runner/scripts/run_prolog.py` and embeds the EVO harness from `skills/evo/references/evo_harness.pl`.

Example:

`python C:\\Users\\trung\\.codex\\skills\\evo\\scripts\\evo_run.py --kb-file path/to/task.pl --assumption some_assumption`

## Resources

- `skills/evo/references/evo_harness.pl`: minimal harness providing proof tracing, assumptions, and consistency checks.
- `skills/evo/references/template_kb.pl`: starter template for task KBs.
- `skills/evo/scripts/evo_run.py`: helper to run `inconsistent` + derive conclusions and do assumption-drop tests.

Tip (avoids PowerShell multi-line prompts): use --kb-b64 to pass a KB as base64 UTF-8 in one command line.

