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

case "$target" in
  claude) copy_skill "$project_root/.claude/skills/evo" ;;
  codex)  copy_skill "$project_root/.codex/skills/evo" ;;
  both)
    copy_skill "$project_root/.claude/skills/evo"
    copy_skill "$project_root/.codex/skills/evo"
    ;;
  *)
    echo "Usage: install.sh [codex|claude|both] [project_root]" >&2
    exit 2
    ;;
esac

