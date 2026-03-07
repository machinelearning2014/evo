# Contributing

## Quick start

1. Edit the canonical skill files in `skills/evo/`.
2. Run the sync script to update the tool-specific copies:
   - PowerShell: `scripts/sync.ps1`
   - Bash: `scripts/sync.sh`

## What to change

- Skill behavior and text: `skills/evo/SKILL.md`
- Examples: `skills/evo/EXAMPLES.md`
- Install helpers: `scripts/install.ps1`, `scripts/install.sh`

## Style

- Keep instructions tool-agnostic (work in both Codex CLI and Claude Code).
- Prefer short, enforceable rules over long explanations.
- Avoid vendor-specific APIs or features unless clearly optional.

