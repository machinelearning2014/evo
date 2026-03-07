# Maintaining the duplicated skill copies

This repo intentionally contains three copies of the EVO skill:

- Canonical source: `skills/evo/`
- Claude Code project copy: `.claude/skills/evo/`
- Codex CLI project copy: `.codex/skills/evo/`

It also contains a Claude Code sub-agent definition:

- `.claude/agents/evo.md` (synced from `skills/evo/agents/claude.md`)

## Rule

Only edit `skills/evo/` directly. Then sync to the other locations.

## Sync

- PowerShell: `scripts/sync.ps1`
- Bash: `scripts/sync.sh`

## Why duplicates?

So users can git-clone this repo into a project and have both CLIs detect the skill without extra setup.
