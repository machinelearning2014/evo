# EVO Skill (Codex CLI + Claude Code)

This repository packages the **EVO** workflow as an **Agent Skill** (a `SKILL.md`-based prompt package) so it can be used in:

- **OpenAI Codex CLI** (project or global skills)
- **Claude Code CLI** (project skills)

The skill content is duplicated into both tool-specific project folders so you can git-clone this repo into a project and have it “just work”.

## What you get

- `.claude/skills/evo/` — Claude Code project skill
- `.codex/skills/evo/` — Codex CLI project skill
- `.claude/commands/evo.md` — optional Claude Code slash command (`/evo`) that tells Claude to apply the EVO skill

## Install / Use

### Option A (recommended): Project-local (commit to your project repo)

Copy the directories into your target project repository root:

- Copy `.claude/` to `<your-project>/.claude/`
- Copy `.codex/` to `<your-project>/.codex/`

Now:

- Claude Code: start `claude` in that project; it will detect `.claude/skills/evo/`.
- Codex: start `codex` in that project; it will detect `.codex/skills/evo/`.

### Option B: Global install (per-user)

#### Claude Code

Copy the skill folder to:

- macOS/Linux: `~/.claude/skills/evo/`
- Windows: `%USERPROFILE%\.claude\skills\evo\`

#### Codex CLI

Copy the skill folder to:

- macOS/Linux: `~/.codex/skills/evo/`
- Windows: `%USERPROFILE%\.codex\skills\evo\`

### Scripts (optional)

- PowerShell: `scripts/install.ps1`
- Bash: `scripts/install.sh`

They copy `skills/evo/` into your chosen destinations.

## Notes

- The skill follows the open `SKILL.md` YAML-frontmatter convention (required by Claude Skills).
- `name: evo` matches the required directory name `evo`.
- The instructions are written to be **tool-agnostic** (work across both CLIs).

## Maintaining

Edit `skills/evo/` and run:

- PowerShell: `scripts/sync.ps1`
- Bash: `scripts/sync.sh`
