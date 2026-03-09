<div align="center">

# EVO - Logical AI
**(Explicit-assumption Verification Orchestrator)**

EVO is a Prolog-first reasoning workflow packaged as skills for **Codex CLI (OpenAI)** and **Claude Code CLI**.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Type: Agent Skill](https://img.shields.io/badge/Type-Agent%20Skill-blue)
![Works with: Codex CLI](https://img.shields.io/badge/Works%20with-Codex%20CLI-black)
![Works with: Claude Code](https://img.shields.io/badge/Works%20with-Claude%20Code-6E56CF)

</div>

<img width="1338" height="728" alt="image" src="https://github.com/user-attachments/assets/f8adace3-17f0-4391-897c-d5281ed7d458" />
<br>
<img width="1417" height="160" alt="image" src="https://github.com/user-attachments/assets/18d65ba1-9dd5-4b7c-9282-df541d41eb8d" />
<br>
<img width="873" height="420" alt="image" src="https://github.com/user-attachments/assets/802f56b9-951b-4f3c-97a8-d6cd4a0300ae" />


## What EVO does

EVO is a skill that gives Codex or Claude a Prolog-first reasoning workflow plus the local files needed to execute that workflow. Functionally, it does three things:

- **It supplies the EVO agent behavior** through `.codex/skills/evo/agents/openai.yaml` for Codex and `skills/evo/agents/claude.md` for Claude (installed as `.claude/agents/evo.md`), telling the model to reason by derivation, make assumptions explicit, check consistency, and translate results into plain language.
- **It supplies a reusable Prolog harness** in `.codex/skills/evo/references/evo_harness.pl`, which defines the proof-tracing and consistency predicates the reasoning workflow depends on.
- **It supplies a runnable helper** in `.codex/skills/evo/scripts/evo_run.py`, which loads the harness, combines it with a task KB, calls `prolog-runner`, and returns structured JSON with conclusions, proofs, and assumption-dependence results.

In practice, EVO helps an agent take a task, represent it as a Prolog knowledge base, derive `conclusion(...)` answers with proof traces, check whether the KB is inconsistent, and optionally test whether conclusions still hold when named assumptions are removed. It does not automatically convert arbitrary prose into a KB on its own; the agent or user still has to provide that formalization.

### What the EVO skill provides

- **Prompted reasoning rules** so the agent treats reasoning as derivation rather than unsupported explanation.
- **A standard KB shape** based on observations, claims, premises, rules, assumptions, constraints, contradictions, and `conclusion/1`.
- **Proof-producing derivation** through `prove/2` and `conclusion_with_proof/2`.
- **Consistency checking** through `inconsistent/0`.
- **Optional assumption-drop analysis** when assumptions are explicitly enabled on the runner command line.
- **A lightweight solved gate** through `solved/2`, which checks only that a conclusion is derivable with a proof and that the KB is consistent.

### How it operates (end-to-end)

1. **The CLI loads the EVO skill files.**
   Codex reads `.codex/skills/evo/SKILL.md` and `.codex/skills/evo/agents/openai.yaml`. Claude uses `.claude/skills/evo/SKILL.md` together with the EVO agent file at `.claude/agents/evo.md`, which is copied from the canonical source `skills/evo/agents/claude.md`. This gives the model the EVO workflow instructions and points it at the local runner and harness files.

2. **The task is expressed as a Prolog KB.**
   The agent or user writes a KB containing facts and rules for the task. In EVO terms, that usually means some combination of `observation/1`, `claim/1`, `premise/1`, `rule/3`, `assumption/2`, `constraint/2`, `contradiction/2`, and a `conclusion/1` goal. The starter file in `references/template_kb.pl` shows the expected shape.

3. **`evo_run.py` builds the executable Prolog program.**
   The runner reads the harness from `references/evo_harness.pl`, then appends KB content from `--kb-file`, `--kb`, `--kb-b64`, and/or `--kb-stdin`. If `--assumption name` is provided, it injects `enabled_assumption(name).` facts into the generated program before execution.

4. **The runner delegates execution to `prolog-runner`.**
   `evo_run.py` locates `skills/prolog-runner/scripts/run_prolog.py` in the same skills tree and calls it as a subprocess. `prolog-runner` is the component that actually shells out to SWI-Prolog (`swipl`) and returns query results as JSON.

5. **The harness runs the core EVO queries.**
   The first query is `inconsistent.`, which checks whether any declared constraint is violated or any declared contradiction pair is simultaneously derivable. The second query is `conclusion_with_proof(Answer, Proof).`, which derives each conclusion and emits the proof steps that support it.

6. **Optional assumption-dependence checks are run.**
   If assumptions were enabled on the command line and conclusions were found, `evo_run.py` re-runs the derivation query multiple times, each time removing one enabled assumption from the injected set. It then records whether each conclusion still survives without that assumption. This test only covers assumptions explicitly passed to the runner.

7. **The runner returns a single JSON payload.**
   The output includes:
   - `inconsistent`
   - `inconsistent_raw`
   - `conclusions_raw`
   - `conclusions`
   - `assumption_dependence`

8. **The agent turns the JSON into the final response.**
   EVO then uses the prompt rules to explain the derived conclusions in natural language, mention important assumptions, note whether conclusions look robust or assumption-dependent, and include sources when external web material was used.

## Install Scripts (recommended project setup)

Use the repo `install` scripts in `scripts/` for project-level setup. This is the recommended way to install EVO into a target project from this repo.

- Purpose: copy canonical skill content from `skills/evo/` plus `skills/prolog-runner/` into project `.claude` and/or `.codex` folders.
- Also copies the Claude sub-agent file (`skills/evo/agents/claude.md`) to `.claude/agents/evo.md` when the install target includes Claude.
- Use `install` for project-level setup. For global installs, use the manual copy commands in the Codex or Claude sections below.

Both scripts take the same two inputs:
- install mode: `codex`, `claude`, or `both`
- project root: the directory where `.claude/` and/or `.codex/` will be created

The script is run from the EVO repo, but it installs files into the target project root.
If you use the examples below as written, first change into the target project directory so `Get-Location` and `$PWD` resolve to the correct destination.

Interface forms:
- PowerShell: `install.ps1 -Target <install_mode> -ProjectRoot <project_root>`
- Bash: `install.sh <install_mode> <project_root>`

Recommended project-level workflow:
1. Change into the target project directory.
2. Run the install script from the EVO repo path.
3. Restart Codex CLI and/or Claude Code so the new files are loaded.

PowerShell:

```powershell
# Run from the target project directory
$evoRepo = Join-Path $env:USERPROFILE "evo"
$projectRoot = (Get-Location).Path
powershell -ExecutionPolicy Bypass -File (Join-Path $evoRepo "scripts\\install.ps1") `
  -Target both `
  -ProjectRoot $projectRoot
```

Bash:

```bash
# Run from the target project directory
EVO_REPO=~/evo
PROJECT_ROOT="$PWD"
bash "$EVO_REPO/scripts/install.sh" both "$PROJECT_ROOT"
```

Targets:
- `codex`: install only `.codex` skill folders
- `claude`: install only `.claude` skill folders + `.claude/agents/evo.md`
- `both`: install both layouts

## Codex CLI (OpenAI) implementation

In Codex CLI, EVO is implemented as a skill folder plus an agent definition and a small Prolog execution toolchain.

### Installation (Codex CLI)

EVO is fully automated only when Codex can execute local commands and both required skills are installed.

> Warning: choose one install scope per skill (`project` or `global`), not both. Installing the same skill in both places creates duplicate copies and can cause stale/conflicting behavior.

#### Step 1: Install SWI-Prolog (required by `prolog-runner`)

`prolog-runner` shells out to SWI-Prolog (`swipl`). Install it and make sure `swipl` is on your `PATH`.

- Windows (choose one):
  - Winget: `winget install --id SWI-Prolog.SWI-Prolog -e`
  - Chocolatey: `choco install swi-prolog`
  - Installer: install from the SWI-Prolog website and enable "add to PATH" (or add it manually).
- macOS:
  - Homebrew: `brew install swi-prolog`

Verify:

```bash
swipl --version
```

#### Step 2: Install the required Codex skills (`evo` + `prolog-runner`)

You must have **both** skill folders installed for the automated EVO workflow:

- `evo` (the workflow + harness runner)
- `prolog-runner` (executes `swipl` and returns JSON bindings)

For a project-level install from this repo, use the recommended `Install Scripts` section above.
That is the canonical project-level setup path and avoids manual copy drift.

Expected project-level result inside the target project directory:

- `.codex/skills/evo/`
- `.codex/skills/prolog-runner/`

##### Global-level install (optional)

Install into your global Codex skills directory:

- Windows:
  - `$env:USERPROFILE\.codex\skills\evo\`
  - `$env:USERPROFILE\.codex\skills\prolog-runner\`
- macOS/Linux:
  - `~/.codex/skills/evo/`
  - `~/.codex/skills/prolog-runner/`

From this repo, copy these folders into your global skills directory:

- `.codex/skills/evo/`
- `.codex/skills/prolog-runner/`

Example copy commands from the EVO repo:

- Windows (PowerShell, run from `$env:USERPROFILE\\evo`):

```powershell
$repo = Join-Path $env:USERPROFILE "evo"
Set-Location $repo
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.codex\skills" | Out-Null
Copy-Item -Recurse -Force ".\.codex\skills\evo" "$env:USERPROFILE\.codex\skills\"
Copy-Item -Recurse -Force ".\.codex\skills\prolog-runner" "$env:USERPROFILE\.codex\skills\"
```

- macOS/Linux (bash/zsh, run from `~/evo`):

```bash
REPO=~/evo
cd "$REPO"
mkdir -p ~/.codex/skills
cp -R ./.codex/skills/evo ~/.codex/skills/
cp -R ./.codex/skills/prolog-runner ~/.codex/skills/
```

Restart Codex CLI after installing or updating skills.

#### Step 3: Confirm install

For a project-level install, the target project directory should contain:

```text
.codex/skills/
|- evo/
`- prolog-runner/
```

EVO uses `prolog-runner` under the hood to execute Prolog and return results as JSON.

### File roles

- `.codex/skills/evo/SKILL.md`
  - The skill entrypoint you install into Codex (project-level or global-level).
  - Explains what EVO is and how the EVO agent uses the local harness (`scripts/evo_run.py`) to produce tool-grounded derivations.

- `.codex/skills/evo/agents/openai.yaml`
  - Defines the "EVO" agent card used by OpenAI/Codex integrations.
  - Contains the **default_prompt** (the full EVO workflow rules) that instructs Prolog-first derivation, proof tracing, consistency checks, assumption testing, and output formatting constraints.

- `.codex/skills/evo/scripts/evo_run.py`
  - A Python helper that runs Prolog queries through the `prolog-runner` skill (`skills/prolog-runner/scripts/run_prolog.py`).
  - It builds a temporary Prolog program by concatenating:
    1) the EVO harness (`references/evo_harness.pl`)
    2) your task KB (from `--kb-file`, `--kb`, and/or `--kb-b64`)
    3) injected enabled assumptions (`enabled_assumption(Name).`)
  - Outputs a single JSON object containing:
    - `inconsistent` (whether a constraint/contradiction is derivable)
    - `conclusions` (answers with proof traces)
    - `assumption_dependence` (whether each conclusion survives removing assumptions)

- `.codex/skills/evo/references/evo_harness.pl`
  - The core Prolog harness implementing:
    - `prove/2` proof tracing
    - `conclusion_with_proof/2` to derive `conclusion(Answer)` with proof steps
    - `inconsistent/0` to detect violated constraints or explicit contradictions
    - a lightweight `solved/2` gate (derivable conclusion + consistent)

- `.codex/skills/evo/references/template_kb.pl`
  - A starter knowledge base template showing the expected predicates (observations, rules, assumptions, constraints, and `conclusion/1`).

- `.codex/skills/prolog-runner/`
  - Companion skill required by EVO for local Prolog execution.
  - Provides `.codex/skills/prolog-runner/scripts/run_prolog.py`, which runs `swipl` and returns JSON bindings.

If command/tool execution is not available in your Codex environment, EVO should fall back to asking you to run the same `evo_run.py` commands manually and paste the JSON output.

### Manual usage (debugging / offline)

From the target project directory, run one of the following:

Run a KB file and enable an assumption:

```bash
python ./.codex/skills/evo/scripts/evo_run.py --kb-file path/to/task.pl --assumption some_assumption
```

Pass KB content inline (base64 avoids shell quoting issues):

```bash
python ./.codex/skills/evo/scripts/evo_run.py --kb-b64 <BASE64_UTF8_KB>
```

## Claude Code CLI implementation

Claude Code uses the same EVO workflow via project-level or global-level install.

> Warning: choose one install scope per skill (`project` or `global`), not both. Installing the same skill in both places creates duplicate copies and can cause stale/conflicting behavior.

### Installation (Claude Code)

Claude Code uses the same local `prolog-runner` integration, so SWI-Prolog must also be installed and available on `PATH`.
If you have not already done that, follow Step 1 in the Codex installation section above.

#### Project-level install (recommended)

For a project-level install from this repo, use the recommended `Install Scripts` section above.
That is the canonical project-level setup path and keeps the Claude and Codex layouts aligned.

Expected project-level result inside the target project directory:

- `.claude/skills/evo/`
- `.claude/skills/prolog-runner/`
- `.claude/agents/evo.md`

EVO's harness runner (`scripts/evo_run.py`) expects `prolog-runner` to be installed in the **same** `skills/` directory tree (so it can find `prolog-runner/scripts/run_prolog.py`).

#### Global-level install (optional)

Install into your global Claude directories:

- Windows:
  - Skills: `$env:USERPROFILE\.claude\skills\evo\` and `$env:USERPROFILE\.claude\skills\prolog-runner\`
  - Agent: `$env:USERPROFILE\.claude\agents\evo.md`
- macOS/Linux:
  - Skills: `~/.claude/skills/evo/` and `~/.claude/skills/prolog-runner/`
  - Agent: `~/.claude/agents/evo.md`

From this repo, copy:

- `.claude/skills/evo/` and `.claude/skills/prolog-runner/` into your global skills directory
- `.claude/agents/evo.md` into your global agents directory

Example copy commands from the EVO repo:

- Windows (PowerShell, run from `$env:USERPROFILE\\evo`):

```powershell
$repo = Join-Path $env:USERPROFILE "evo"
Set-Location $repo
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\skills" | Out-Null
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.claude\agents" | Out-Null
Copy-Item -Recurse -Force ".\.claude\skills\evo" "$env:USERPROFILE\.claude\skills\"
Copy-Item -Recurse -Force ".\.claude\skills\prolog-runner" "$env:USERPROFILE\.claude\skills\"
Copy-Item -Force ".\.claude\agents\evo.md" "$env:USERPROFILE\.claude\agents\evo.md"
```

- macOS/Linux (bash/zsh, run from `~/evo`):

```bash
REPO=~/evo
cd "$REPO"
mkdir -p ~/.claude/skills ~/.claude/agents
cp -R ./.claude/skills/evo ~/.claude/skills/
cp -R ./.claude/skills/prolog-runner ~/.claude/skills/
cp ./.claude/agents/evo.md ~/.claude/agents/evo.md
```

Restart Claude Code after installing or updating skills and agents.

### Files and how they work

- `.claude/agents/evo.md`
  - Defines a Claude Code sub-agent named "evo".
  - This is the Claude equivalent of "pick the EVO agent persona": it instructs Claude to follow the EVO workflow when you invoke that agent.

- `.claude/skills/evo/SKILL.md`
  - Ships the same EVO skill text for consistency across CLIs.
  - Useful as a shared, version-controlled source of truth for the workflow rules.

- `.claude/commands/evo.md`
  - Optional convenience command (a slash command) that tells Claude to apply the EVO workflow for the current request.

### Practical note about Prolog execution

Claude Code can follow the EVO workflow instructions and (when command execution is enabled) can also run the same local harness automatically by invoking `scripts/evo_run.py`. If command/tool execution is disabled, it should ask you to run the command manually and provide the JSON output.

## Sync Scripts

Use the repo `sync` scripts in `scripts/` to avoid manual copy drift inside this EVO repo.

### `sync` scripts (after editing canonical files)

- Purpose: re-copy canonical `skills/evo/` into both `.claude/skills/evo/` and `.codex/skills/evo/`, and refresh `.claude/agents/evo.md`.
- Use this after any change under `skills/evo/`.
- `sync` is for this EVO repo itself, not for installing into a separate target project.

PowerShell:

```powershell
$repo = Join-Path $env:USERPROFILE "evo"
powershell -ExecutionPolicy Bypass -File (Join-Path $repo "scripts\\sync.ps1") -RepoRoot $repo
```

Bash:

```bash
REPO=~/evo
bash "$REPO/scripts/sync.sh" "$REPO"
```

Recommended workflow:
1. Edit only `skills/evo/` (canonical source).
2. Run `sync` script.
3. Restart your CLI(s) so updated skills/agents are reloaded.
