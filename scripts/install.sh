#!/usr/bin/env bash
set -euo pipefail

target="${1:-both}" # codex | claude | both
project_root="${2:-$(pwd)}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_evo="$repo_root/skills/evo"
source_prolog_runner="$repo_root/skills/prolog-runner"

if [[ ! -d "$source_evo" ]]; then
  echo "Expected skill source at: $source_evo" >&2
  exit 1
fi

if [[ ! -d "$source_prolog_runner" ]]; then
  echo "Expected skill source at: $source_prolog_runner" >&2
  exit 1
fi

copy_skill() {
  local dest="$1"
  mkdir -p "$dest"
  # Copy contents, not the directory itself
  cp -R "$source_evo/"* "$dest/"
  echo "Installed EVO skill to: $dest"
}

copy_claude_agent() {
  local agent_source="$source_evo/agents/claude.md"
  if [[ -f "$agent_source" ]]; then
    local dest_dir="$project_root/.claude/agents"
    mkdir -p "$dest_dir"
    cp "$agent_source" "$dest_dir/evo.md"
    echo "Installed Claude sub-agent to: $dest_dir/evo.md"
  fi
}

copy_prolog_runner() {
  local dest="$1"
  mkdir -p "$dest"
  cp -R "$source_prolog_runner/"* "$dest/"
  echo "Installed prolog-runner skill to: $dest"
}

case "$target" in
  claude)
    copy_skill "$project_root/.claude/skills/evo"
    copy_prolog_runner "$project_root/.claude/skills/prolog-runner"
    copy_claude_agent
    ;;
  codex)
    copy_skill "$project_root/.codex/skills/evo"
    copy_prolog_runner "$project_root/.codex/skills/prolog-runner"
    ;;
  both)
    copy_skill "$project_root/.claude/skills/evo"
    copy_prolog_runner "$project_root/.claude/skills/prolog-runner"
    copy_claude_agent
    copy_skill "$project_root/.codex/skills/evo"
    copy_prolog_runner "$project_root/.codex/skills/prolog-runner"
    ;;
  *)
    echo "Usage: install.sh [codex|claude|both] [project_root]" >&2
    exit 2
    ;;
esac
