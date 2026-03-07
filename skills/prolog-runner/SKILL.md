---
name: prolog-runner
description: Run Prolog queries via SWI-Prolog (swipl) from Codex and return solutions as JSON bindings. Use when you need to execute/validate Prolog facts/rules, solve logic problems, or query a Prolog knowledge base (inline program text or .pl files).
---

# Prolog Runner

## Quick start

- Ensure SWI-Prolog is installed and `swipl` is on PATH (or provide `--swipl`).
- Run `scripts/run_prolog.py` with a Prolog goal and optional program text/files.

## Run a query (inline program)

Use this when the Prolog code is small and self-contained.

```bash
python skills/prolog-runner/scripts/run_prolog.py --program "parent(alice,bob). parent(bob,carol). ancestor(X,Y):-parent(X,Y). ancestor(X,Y):-parent(X,Z),ancestor(Z,Y)." --query "ancestor(alice,Who)."
```

## Run a query (from .pl files)

Use this when the code already exists in one or more Prolog files.

```bash
python skills/prolog-runner/scripts/run_prolog.py --file path/to/knowledge_base.pl --query "some_predicate(X)."
```

## Output format

- The script prints a single JSON object on stdout with:
  - `ok`: boolean (true only if swipl exited 0 and stdout parsed as JSON)
  - `exit_code`: swipl exit code (or null on timeout)
  - `timed_out`: boolean
  - `stdout` / `stderr`: raw captured output from swipl
  - `solutions`: list of variable-binding objects (or null on failure)
- `solutions` is a list of dicts keyed by variable name (as written in the query).

Example (shape only):

```json
{"ok":true,"exit_code":0,"timed_out":false,"stdout":"{\"solutions\":[{\"Who\":\"bob\"},{\"Who\":\"carol\"}]}\n","stderr":"","solutions":[{"Who":"bob"},{"Who":"carol"}]}
```

## Tips and gotchas

- Prefer keeping the embedded program to pure facts/rules; avoid `:- initialization(...)` directives in embedded code.
- If you need fewer results, pass `--max-solutions N`.
- If `swipl` isn’t on PATH, pass `--swipl "C:\\Path\\To\\swipl.exe"`.

## Resources

- `scripts/run_prolog.py`: SWI-Prolog runner that returns JSON solutions.
