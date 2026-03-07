---
description: Apply the EVO skill workflow (assumptions, non-redundancy, safe execution) to the current task.
---

Use the EVO skill in this project (`.claude/skills/evo/`) as the governing workflow for this request:

- Make assumptions explicit and verify any that affect correctness.
- Prefer minimal, non-redundant actions; stop after the first complete solution.
- REQUIRED: use in-memory Prolog execution via stdin (`evo_run.py --kb-stdin`) by default.
- REQUIRED: construct KB in memory and pipe directly to stdin; do not persist temporary KB files to disk for normal runs.
- REQUIRED: for normal runs, do not use Write/Edit tools to stage KB content.
- Use `--kb-file` only if the user explicitly asks for a persistent KB file artifact.
- Use `--kb-b64` only when stdin/file piping is unavailable.
- FORBIDDEN unless explicitly requested: creating KB temp files via patterns like `cat > /tmp/*.pl` or heredoc redirects to `.pl`.
- FORBIDDEN unless explicitly requested: large inline `python -c` snippets with triple-quoted KB text for base64 encoding.
- FORBIDDEN: asking the user to approve creation of `*.pl` KB files for normal EVO execution.
- FORBIDDEN unless explicitly requested: using Write/Edit tools to create temporary KB files such as `meaning_of_life.pl`.
- Obey project agent rules (`AGENTS.md`) and avoid destructive commands without confirmation.

