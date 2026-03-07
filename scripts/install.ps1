Param(
  [Parameter(Mandatory = $false)]
  [ValidateSet("codex", "claude", "both")]
  [string]$Target = "both",

  [Parameter(Mandatory = $false)]
  [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot "skills\evo"

if (-not (Test-Path $source)) {
  throw "Expected skill source at: $source"
}

function Copy-Skill($dest) {
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item -Recurse -Force -Path (Join-Path $source "*") -Destination $dest
  Write-Host "Installed EVO skill to: $dest"
}

if ($Target -eq "claude" -or $Target -eq "both") {
  Copy-Skill (Join-Path $ProjectRoot ".claude\skills\evo")
}

if ($Target -eq "codex" -or $Target -eq "both") {
  Copy-Skill (Join-Path $ProjectRoot ".codex\skills\evo")
}

