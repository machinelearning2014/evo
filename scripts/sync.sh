#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$repo_root/skills/evo"
claude_agent_source="$source_dir/agents/claude.md"

if [[ ! -d "$source_dir" ]]; then
  echo "Expected canonical skill source at: $source_dir" >&2
  exit 1
fi

sync_to() {
  local dest="$1"
  mkdir -p "$dest"
  # Clear to avoid stale files.
  rm -rf "$dest/"*
  cp -R "$source_dir/"* "$dest/"
  echo "Synced: $dest"
}

sync_to "$repo_root/.claude/skills/evo"
sync_to "$repo_root/.codex/skills/evo"

if [[ -f "$claude_agent_source" ]]; then
  mkdir -p "$repo_root/.claude/agents"
  cp "$claude_agent_source" "$repo_root/.claude/agents/evo.md"
  echo "Synced: $repo_root/.claude/agents/evo.md"
fi
