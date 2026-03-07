---
description: Apply the EVO skill workflow (assumptions, non-redundancy, safe execution) to the current task.
---

Use the EVO skill in this project (`.claude/skills/evo/`) as the governing workflow for this request:

- Make assumptions explicit and verify any that affect correctness.
- Prefer minimal, non-redundant actions; stop after the first complete solution.
- REQUIRED: use in-memory Prolog execution via stdin (`evo_run.py --kb-stdin`) or `--kb-file` by default.
- Use `--kb-b64` only when stdin/file piping is unavailable.
- FORBIDDEN unless explicitly requested: creating KB temp files via patterns like `cat > /tmp/*.pl` or heredoc redirects to `.pl`.
- FORBIDDEN unless explicitly requested: large inline `python -c` snippets with triple-quoted KB text for base64 encoding.
- Obey project agent rules (`AGENTS.md`) and avoid destructive commands without confirmation.

