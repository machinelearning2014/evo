<div align="center">

# EVO Skill

EVO (Explicit-assumption Verification Orchestrator) is a Prolog-first reasoning workflow packaged for **Codex CLI (OpenAI)** and **Claude Code CLI**.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Type: Agent Skill](https://img.shields.io/badge/Type-Agent%20Skill-blue)
![Works with: Codex CLI](https://img.shields.io/badge/Works%20with-Codex%20CLI-black)
![Works with: Claude Code](https://img.shields.io/badge/Works%20with-Claude%20Code-6E56CF)

</div>

## What EVO does

EVO's `default_prompt` (in `.codex/skills/evo/agents/openai.yaml`) enforces a strict Prolog-first workflow:

- **No "from memory" answers**: responses must be grounded in tool execution outputs.
- **Formalize in Prolog**: encode observations/claims, rules, explicit assumptions, and constraints into a KB with a `conclusion/1` goal.
- **Derive with proofs**: conclusions must be derivable with a proof trace (not just explained or enumerated).
- **Consistency first**: always check `inconsistent` and never answer from an inconsistent KB.
- **Assumption-dependence testing**: re-derive conclusions with assumptions removed; label conclusions as robust vs assumption-dependent.
- **Tool usage is fact acquisition only**: other tools can supply facts/primitive computations, but Prolog remains the reasoner.
- **Strict result labels**: every task is classified as `SOLVED`, `CANDIDATE`, or `MAPPED` (uniqueness requires proof).
- **Natural-language output**: final answers must not include raw Prolog; include a `Sources:` section when external sources are used.

## Codex CLI (OpenAI) implementation

In Codex CLI, EVO is implemented as a skill folder plus an agent definition and a small Prolog execution toolchain.

### Installation (Codex CLI)

EVO is fully automated only when Codex can execute local commands and both required skills are installed.

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

##### Global install (recommended)

Install into your global Codex skills directory:

- Windows:
  - `%USERPROFILE%\.codex\skills\evo\` (e.g. `C:\Users\<you>\.codex\skills\evo\`)
  - `%USERPROFILE%\.codex\skills\prolog-runner\`
- macOS/Linux:
  - `~/.codex/skills/evo/`
  - `~/.codex/skills/prolog-runner/`

From this repo, copy these folders into your global location:

- `.codex/skills/evo/`
- `.codex/skills/prolog-runner/`

#### Step 3: Confirm files are present

After installing, you should have (either globally or in your project):

```text
.codex/skills/
|- evo/
`- prolog-runner/
```

EVO uses `prolog-runner` under the hood to execute Prolog and return results as JSON.

### File roles

- `.codex/skills/evo/SKILL.md`
  - The skill entrypoint you install into Codex (`~/.codex/skills/evo/` or project-local).
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
python ~/.codex/skills/evo/scripts/evo_run.py --kb-file path/to/task.pl --assumption some_assumption
```

Pass KB content inline (base64 avoids shell quoting issues):

```bash
python ~/.codex/skills/evo/scripts/evo_run.py --kb-b64 <BASE64_UTF8_KB>
```

## Claude Code CLI implementation

Claude Code can use the same EVO workflow via a global (recommended) or project-local install.

### Installation (Claude Code)

#### Global install (recommended)

Install into your global Claude directories:

- Windows:
  - Skills: `%USERPROFILE%\.claude\skills\evo\` and `%USERPROFILE%\.claude\skills\prolog-runner\`
  - Agent: `%USERPROFILE%\.claude\agents\evo.md`
- macOS/Linux:
  - Skills: `~/.claude/skills/evo/` and `~/.claude/skills/prolog-runner/`
  - Agent: `~/.claude/agents/evo.md`

From this repo, copy:

- `.claude/skills/evo/` and `.claude/skills/prolog-runner/` into your global skills directory
- `.claude/agents/evo.md` into your global agents directory

EVO's harness runner (`scripts/evo_run.py`) expects `prolog-runner` to be installed in the **same** `skills/` directory tree (so it can find `prolog-runner/scripts/run_prolog.py`).

#### Project-local (optional)

Copy this repo's `.claude/` folder into your project root.

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
