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

EVO is a strict verification protocol for coding/reasoning tasks. The `default_prompt` in `.codex/skills/evo/agents/openai.yaml` forces the agent to treat "reasoning" as **derivation** (not explanation) and to follow a mandatory Prolog-first workflow.

At a high level, EVO turns your task into a Prolog knowledge base (KB), derives conclusions with proofs, verifies the KB is consistent, stress-tests which assumptions the conclusions depend on, and only then produces a natural-language answer.

### The essence of EVO (what it enforces)

- **Reasoning = derivation with proofs**: a task is only "solved" if a `conclusion(...)` can be derived from facts and rules with a proof trace; listing/guessing/explaining without derivation is not accepted.
- **No "from memory" authority**: conclusions must be grounded in tool execution outputs (and when Prolog is used, grounded in Prolog derivations), not intuition/training-data recall.
- **Assumptions are first-class**: any inference that is not strictly entailed must be declared as an assumption; hidden inference bridges are forbidden.
- **Consistency before answers**: EVO must check for contradictions/constraint violations (`inconsistent`) and never answer from an inconsistent KB.
- **Assumption-dependence testing is mandatory**: for each key conclusion, EVO re-derives it while disabling assumptions one-by-one, then labels conclusions as robust vs assumption-dependent.
- **Tools are subordinate to Prolog**: other tools may be used only to acquire missing facts or primitive computations requested by the Prolog reasoning; they must not replace the derivation step.
- **Strict outcome labeling**: every result must be labeled `SOLVED`, `CANDIDATE`, or `MAPPED`. Uniqueness claims are disallowed unless proven (e.g., exhaustive search or a completeness proof).
- **Human-readable final output**: even though EVO reasons in Prolog internally, it must output plain English (no raw Prolog) and include a `Sources:` list when it used external URLs.

### What it achieves
* logical reasoning for AI Agents
* surfaces all assumptions
* proof traces for all conclusions
* reduces hallucinations

### The mandatory workflow (condensed)

1. **Formalize** the task into a Prolog KB: observations/claims/premises, inference rules, explicit assumptions, and constraints/contradictions, plus a `conclusion/1` goal.
2. **Derive** conclusions as `conclusion(Answer)` together with a proof trace.
3. **Check consistency** (`inconsistent`) and repair/report if inconsistent.
4. **Test assumption-dependence** by disabling assumptions and re-deriving conclusions.
5. **Classify** the outcome (`SOLVED`/`CANDIDATE`/`MAPPED`) and avoid uniqueness claims without proof.
6. **Respond in natural language** with assumptions and (if applicable) a `Sources:` section.

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

##### Project-level install (recommended)

From this repo, copy these folders into your project root:

- `.codex/skills/evo/`
- `.codex/skills/prolog-runner/`

Example copy commands:

- Windows (PowerShell, run from `$env:USERPROFILE\\evo`):

```powershell
$repo = Join-Path $env:USERPROFILE "evo"
Set-Location $repo
New-Item -ItemType Directory -Force -Path ".\.codex\skills" | Out-Null
Copy-Item -Recurse -Force ".\.codex\skills\evo" ".\.codex\skills\"
Copy-Item -Recurse -Force ".\.codex\skills\prolog-runner" ".\.codex\skills\"
```

- macOS/Linux (bash/zsh, run from `~/evo`):

```bash
REPO=~/evo
cd "$REPO"
mkdir -p ./.codex/skills
cp -R ./.codex/skills/evo ./.codex/skills/
cp -R ./.codex/skills/prolog-runner ./.codex/skills/
```

Restart Codex CLI after installing/updating skills.

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

Example copy commands:

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

#### Step 3: Confirm install

After installing, you should have:

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

### How it operates (end-to-end)

1. Codex loads the EVO agent definition (`.codex/skills/evo/agents/openai.yaml`) and applies its `default_prompt` (the mandatory EVO workflow).
2. EVO formalizes the task into a Prolog knowledge base (KB): observations/claims, rules, explicit assumptions, constraints/contradictions, and a `conclusion/1` goal (often starting from `references/template_kb.pl`).
3. EVO **automatically runs the local harness** by invoking `.codex/skills/evo/scripts/evo_run.py` via the CLI's command/tool execution.
4. `evo_run.py` embeds `references/evo_harness.pl` + the KB + enabled assumptions, then runs:
   - `inconsistent.` (consistency check)
   - `conclusion_with_proof(Answer, Proof).` (derivations with proof traces)
   - assumption-drop rechecks (assumption-dependence testing) when assumptions were enabled
5. EVO converts the JSON result into a natural-language response, including: conclusions, key assumptions, whether conclusions are robust vs assumption-dependent, and sources when web tools were used.

If command/tool execution is not available in your Codex environment, EVO should fall back to asking you to run the same `evo_run.py` commands manually and paste the JSON output.

### Manual usage (debugging / offline)

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

#### Project-level install (recommended)

From this repo, keep or copy these into your project root:

- `.claude/skills/evo/`
- `.claude/skills/prolog-runner/`
- `.claude/agents/evo.md`

EVO's harness runner (`scripts/evo_run.py`) expects `prolog-runner` to be installed in the **same** `skills/` directory tree (so it can find `prolog-runner/scripts/run_prolog.py`).

Example copy commands:

- Windows (PowerShell, run from `$env:USERPROFILE\\evo`):

```powershell
$repo = Join-Path $env:USERPROFILE "evo"
Set-Location $repo
New-Item -ItemType Directory -Force -Path ".\.claude\skills" | Out-Null
New-Item -ItemType Directory -Force -Path ".\.claude\agents" | Out-Null
Copy-Item -Recurse -Force ".\.claude\skills\evo" ".\.claude\skills\"
Copy-Item -Recurse -Force ".\.claude\skills\prolog-runner" ".\.claude\skills\"
Copy-Item -Force ".\.claude\agents\evo.md" ".\.claude\agents\evo.md"
```

- macOS/Linux (bash/zsh, run from `~/evo`):

```bash
REPO=~/evo
cd "$REPO"
mkdir -p ./.claude/skills ./.claude/agents
cp -R ./.claude/skills/evo ./.claude/skills/
cp -R ./.claude/skills/prolog-runner ./.claude/skills/
cp ./.claude/agents/evo.md ./.claude/agents/evo.md
```

Restart Claude Code after installing/updating skills and agents.

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

Example copy commands:

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

## Install and Sync Scripts

Use the repo scripts in `scripts/` to avoid manual copy drift.

### `install` scripts (initial setup)

- Purpose: copy canonical skill content from `skills/evo/` plus `skills/prolog-runner/` into project `.claude` and/or `.codex` folders.
- Also copies the Claude sub-agent file (`skills/evo/agents/claude.md`) to `.claude/agents/evo.md` when target includes Claude.

PowerShell:

```powershell
$repo = Join-Path $env:USERPROFILE "evo"
powershell -ExecutionPolicy Bypass -File (Join-Path $repo "scripts\\install.ps1") -Target both -ProjectRoot $repo
```

Bash:

```bash
REPO=~/evo
bash "$REPO/scripts/install.sh" both "$REPO"
```

Targets:
- `codex`: install only `.codex` skill folders
- `claude`: install only `.claude` skill folders + `.claude/agents/evo.md`
- `both`: install both layouts

### `sync` scripts (after editing canonical files)

- Purpose: re-copy canonical `skills/evo/` into both `.claude/skills/evo/` and `.codex/skills/evo/`, and refresh `.claude/agents/evo.md`.
- Use this after any change under `skills/evo/`.

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
