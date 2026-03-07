#!/usr/bin/env bash
set -euo pipefail

target="${1:-both}" # codex | claude | both
project_root="${2:-$(pwd)}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$repo_root/skills/evo"

if [[ ! -d "$source_dir" ]]; then
  echo "Expected skill source at: $source_dir" >&2
  exit 1
fi

copy_skill() {
  local dest="$1"
  mkdir -p "$dest"
  # Copy contents, not the directory itself
  cp -R "$source_dir/"* "$dest/"
  echo "Installed EVO skill to: $dest"
}

copy_claude_agent() {
  local agent_source="$source_dir/agents/claude.md"
  if [[ -f "$agent_source" ]]; then
    local dest_dir="$project_root/.claude/agents"
    mkdir -p "$dest_dir"
    cp "$agent_source" "$dest_dir/evo.md"
    echo "Installed Claude sub-agent to: $dest_dir/evo.md"
  fi
}

case "$target" in
  claude)
    copy_skill "$project_root/.claude/skills/evo"
    copy_claude_agent
    ;;
  codex)  copy_skill "$project_root/.codex/skills/evo" ;;
  both)
    copy_skill "$project_root/.claude/skills/evo"
    copy_claude_agent
    copy_skill "$project_root/.codex/skills/evo"
    ;;
  *)
    echo "Usage: install.sh [codex|claude|both] [project_root]" >&2
    exit 2
    ;;
esac
