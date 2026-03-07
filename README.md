<div align="center">

# EVO Skill

Explicit-assumption, non-redundant coding workflow packaged as an **Agent Skill** for **Codex CLI** and **Claude Code**.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Type: Agent Skill](https://img.shields.io/badge/Type-Agent%20Skill-blue)
![Works with: Codex CLI](https://img.shields.io/badge/Works%20with-Codex%20CLI-black)
![Works with: Claude Code](https://img.shields.io/badge/Works%20with-Claude%20Code-6E56CF)

[![Install: Project](https://img.shields.io/badge/Install-Project%20local-2ea44f)](#option-a-recommended-project-local)
[![Install: Global](https://img.shields.io/badge/Install-Global-2ea44f)](#option-b-global-install)
[![Sync](https://img.shields.io/badge/Maintain-Sync%20copies-9cf)](#maintaining)
[![Contributing](https://img.shields.io/badge/Contribute-Guidelines-orange)](CONTRIBUTING.md)

</div>

## What’s included

- `.claude/skills/evo/` — Claude Code project skill
- `.codex/skills/evo/` — Codex CLI project skill
- `.claude/commands/evo.md` — optional Claude Code slash command (`/evo`)
- `skills/evo/` — canonical skill source (edit here first)

## Quick start

If you want this skill **available in a specific project repo**, copy these folders into that repo root:

- `.claude/`
- `.codex/`

If you want it **available globally** for your user account, copy `skills/evo/` into your CLI’s global skills directory.

## Install / Use

### Option A (recommended): Project-local

Copy the tool folders into your target project repository root:

- Copy `.claude/` to `<your-project>/.claude/`
- Copy `.codex/` to `<your-project>/.codex/`

Then:

- Claude Code: run `claude` in that project; it will detect `.claude/skills/evo/`.
- Codex CLI: run `codex` in that project; it will detect `.codex/skills/evo/`.

### Option B: Global install

#### Claude Code

Copy `skills/evo/` to:

- macOS/Linux: `~/.claude/skills/evo/`
- Windows: `%USERPROFILE%\.claude\skills\evo\`

#### Codex CLI

Copy `skills/evo/` to:

- macOS/Linux: `~/.codex/skills/evo/`
- Windows: `%USERPROFILE%\.codex\skills\evo\`

### Install scripts (optional)

- PowerShell: `scripts/install.ps1`
- Bash: `scripts/install.sh`

They copy `skills/evo/` into `.claude/skills/evo/` and/or `.codex/skills/evo/` under your chosen project root.

## Layout

```text
.
├─ skills/evo/               # canonical source (edit here)
├─ .claude/skills/evo/       # Claude Code project skill copy
├─ .codex/skills/evo/        # Codex CLI project skill copy
└─ scripts/                  # install + sync helpers
```

## Maintaining

Only edit `skills/evo/` directly, then sync copies:

- PowerShell: `scripts/sync.ps1`
- Bash: `scripts/sync.sh`

## Notes

- The skill uses `SKILL.md` frontmatter (`name: evo`) and works as a project-local skill for both CLIs.
- Keep the content tool-agnostic so behavior stays consistent across Codex and Claude.

