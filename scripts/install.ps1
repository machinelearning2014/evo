Param(
  [Parameter(Mandatory = $false)]
  [ValidateSet("codex", "claude", "both")]
  [string]$Target = "both",

  [Parameter(Mandatory = $false)]
  [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceEvo = Join-Path $repoRoot "skills\evo"
$sourcePrologRunner = Join-Path $repoRoot "skills\\prolog-runner"

if (-not (Test-Path $sourceEvo)) {
  throw "Expected skill source at: $sourceEvo"
}

if (-not (Test-Path $sourcePrologRunner)) {
  throw "Expected skill source at: $sourcePrologRunner"
}

function Copy-Skill($dest) {
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item -Recurse -Force -Path (Join-Path $sourceEvo "*") -Destination $dest
  Write-Host "Installed EVO skill to: $dest"
}

function Copy-PrologRunner($dest) {
  New-Item -ItemType Directory -Force -Path $dest | Out-Null
  Copy-Item -Recurse -Force -Path (Join-Path $sourcePrologRunner "*") -Destination $dest
  Write-Host "Installed prolog-runner skill to: $dest"
}

function Copy-ClaudeAgent($projectRoot) {
  $agentSource = Join-Path $sourceEvo "agents\\claude.md"
  if (Test-Path $agentSource) {
    $agentDestDir = Join-Path $projectRoot ".claude\\agents"
    New-Item -ItemType Directory -Force -Path $agentDestDir | Out-Null
    Copy-Item -Force -Path $agentSource -Destination (Join-Path $agentDestDir "evo.md")
    Write-Host "Installed Claude sub-agent to: $(Join-Path $agentDestDir 'evo.md')"
  }
}

if ($Target -eq "claude" -or $Target -eq "both") {
  Copy-Skill (Join-Path $ProjectRoot ".claude\skills\evo")
  Copy-PrologRunner (Join-Path $ProjectRoot ".claude\skills\prolog-runner")
  Copy-ClaudeAgent $ProjectRoot
}

if ($Target -eq "codex" -or $Target -eq "both") {
  Copy-Skill (Join-Path $ProjectRoot ".codex\skills\evo")
  Copy-PrologRunner (Join-Path $ProjectRoot ".codex\skills\prolog-runner")
}
