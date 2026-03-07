Param(
  [Parameter(Mandatory = $false)]
  [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = "Stop"

$source = Join-Path $RepoRoot "skills\evo"
$destClaude = Join-Path $RepoRoot ".claude\skills\evo"
$destCodex = Join-Path $RepoRoot ".codex\skills\evo"

if (-not (Test-Path $source)) {
  throw "Expected canonical skill source at: $source"
}

function Sync-To($dest) {
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  # Clear destination contents to avoid stale files.
  Get-ChildItem -Force -Path $dest -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
  Copy-Item -Recurse -Force -Path (Join-Path $source "*") -Destination $dest
  Write-Host "Synced: $dest"
}

Sync-To $destClaude
Sync-To $destCodex

