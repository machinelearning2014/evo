<div align="center">

# EVO Skill

An explicit-assumption, non-redundant workflow packaged as an **Agent Skill** for **Codex CLI** and **Claude Code**.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Type: Agent Skill](https://img.shields.io/badge/Type-Agent%20Skill-blue)
![Works with: Codex CLI](https://img.shields.io/badge/Works%20with-Codex%20CLI-black)
![Works with: Claude Code](https://img.shields.io/badge/Works%20with-Claude%20Code-6E56CF)

[![Install: Project](https://img.shields.io/badge/Install-Project%20local-2ea44f)](#option-a-recommended-project-local)
[![Install: Global](https://img.shields.io/badge/Install-Global-2ea44f)](#option-b-global-install)
[![Sync](https://img.shields.io/badge/Maintain-Sync%20copies-9cf)](#maintaining)
[![Contributing](https://img.shields.io/badge/Contribute-Guidelines-orange)](CONTRIBUTING.md)

</div>

## What EVO does 

EVO ("Explicit-assumption Verification Orchestrator") is a disciplined operating mode for coding agents. It makes the agent behave more like a careful engineer:

- **States assumptions** whenever requirements or context are ambiguous.
- **Validates assumptions** using the smallest possible evidence (repo files, minimal commands, targeted tests).
- **Avoids redundant work** (no "double solving", no repeated commands just for confidence).
- **Optimizes for root-cause fixes** rather than surface patches.
- **Defaults to safe actions** and asks before destructive or irreversible operations.
- **Stops when done** (implementation + validation), instead of over-building.

This repo packages that workflow as a `SKILL.md` prompt so Codex CLI and Claude Code can apply it consistently.

## Behavior checklist (what you should notice)

When EVO is active, the agent should:

1. Clarify goal and success criteria (what "done" means).
2. List high-impact assumptions (and how it will verify them).
3. Search/inspect minimally (prefer fast search over opening many files).
4. Implement the smallest change that fixes the root cause.
5. Validate with the most targeted command available (single test, narrow build, etc.).
6. Report what changed, what was run, and what remains (if anything).

## What's included

- `.claude/skills/evo/` - Claude Code project skill
- `.codex/skills/evo/` - Codex CLI project skill
- `.claude/commands/evo.md` - optional Claude Code slash command (`/evo`)
- `.claude/agents/evo.md` - optional Claude Code sub-agent definition for "EVO"
- `skills/evo/` - canonical skill source (edit here first)

## Agent definitions (EVO)

For this repo's setup, the **agent-definition files are required** (not optional). They define the "EVO" agent entrypoint that loads and applies the workflow in `skills/evo/SKILL.md`.

- `skills/evo/agents/openai.yaml` - OpenAI/Codex-oriented agent manifest for "EVO" (points at `skills/evo/SKILL.md`).
- `.claude/agents/evo.md` - Claude Code CLI sub-agent definition for "EVO" (Markdown with YAML frontmatter).

If your environment expects a different schema for agent manifests, keep the intent the same: the "EVO" agent should reference and enforce the rules in `skills/evo/SKILL.md`.

## Quick start

If you want this skill **available in a specific project repo**, copy these folders into that repo root:

- `.claude/`
- `.codex/`

If you want it **available globally** for your user account, copy `skills/evo/` into your CLI's global skills directory.

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
|- skills/evo/               # canonical source (edit here)
|- .claude/skills/evo/       # Claude Code project skill copy
|- .codex/skills/evo/        # Codex CLI project skill copy
`- scripts/                  # install + sync helpers
```

## Customizing EVO

Edit `skills/evo/SKILL.md`. Common tweaks:

- Make it stricter about asking questions vs making assumptions.
- Add your org's coding standards and security rules.
- Add project-specific "definition of done" (tests, formatting, CI).

Then sync copies (below).

## Maintaining

Only edit `skills/evo/` directly, then sync copies:

- PowerShell: `scripts/sync.ps1`
- Bash: `scripts/sync.sh`

## Where the rules live

- Skill definition (canonical): `skills/evo/SKILL.md`
- Examples: `skills/evo/EXAMPLES.md`
- Maintenance notes: `MAINTAINING.md`

