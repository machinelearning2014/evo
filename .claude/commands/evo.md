---
description: Apply the EVO skill workflow (assumptions, non-redundancy, safe execution) to the current task.
---

Use the EVO skill in this project (`.claude/skills/evo/`) as the governing workflow for this request:

- Make assumptions explicit and verify any that affect correctness.
- Prefer minimal, non-redundant actions; stop after the first complete solution.
- Prefer in-memory Prolog execution (`evo_run.py --kb-b64`) and do not create ad-hoc `*.pl` KB files unless explicitly requested.
- Obey project agent rules (`AGENTS.md`) and avoid destructive commands without confirmation.

