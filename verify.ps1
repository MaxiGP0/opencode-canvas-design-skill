#Requires -Version 5.1
<#
.SYNOPSIS
    Check that Anthropic's canvas-design skill is installed for OpenCode.

.PARAMETER SkillDir
    OpenCode skills root. Defaults to $env:OPENCODE_SKILLS_DIR, or
    ~/.config/opencode/skills.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\verify.ps1
#>
[CmdletBinding()]
param(
    [string]$SkillDir
)

$ErrorActionPreference = "Stop"

$Name = "canvas-design"
$MinimumFonts = 50

if (-not $SkillDir) {
    if ($env:OPENCODE_SKILLS_DIR) {
        $SkillDir = $env:OPENCODE_SKILLS_DIR
    }
    else {
        $HomeDir = if ($HOME) { $HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { $null }
        if (-not $HomeDir) {
            Write-Host "FAIL  Could not find your home directory. Pass -SkillDir explicitly." -ForegroundColor Red
            exit 1
        }
        $SkillDir = Join-Path $HomeDir ".config\opencode\skills"
    }
}

$Target = Join-Path $SkillDir $Name

if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    Write-Host "FAIL  $Name is not installed at $Target" -ForegroundColor Red
    Write-Host "      Run install.ps1 first." -ForegroundColor Yellow
    exit 1
}

$Missing = @()
foreach ($RelativePath in @("SKILL.md", "LICENSE.txt")) {
    if (-not (Test-Path -LiteralPath (Join-Path $Target $RelativePath) -PathType Leaf)) {
        $Missing += $RelativePath
    }
}
if (-not (Test-Path -LiteralPath (Join-Path $Target "canvas-fonts") -PathType Container)) {
    $Missing += "canvas-fonts"
}

if ($Missing.Count -gt 0) {
    Write-Host "FAIL  The installation is incomplete. Missing:" -ForegroundColor Red
    $Missing | ForEach-Object { Write-Host "      - $_" }
    Write-Host "      Re-run install.ps1 -Force." -ForegroundColor Yellow
    exit 1
}

$SkillText = Get-Content -LiteralPath (Join-Path $Target "SKILL.md") -Raw
$FrontMatter = $null
if ($SkillText -match "(?s)\A---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(\r?\n|\z)") {
    $FrontMatter = $Matches[1]
}
if (-not $FrontMatter) {
    Write-Host "FAIL  SKILL.md has no YAML frontmatter." -ForegroundColor Red
    exit 1
}
if ($FrontMatter -notmatch "(?m)^name:\s*$([regex]::Escape($Name))\s*$") {
    Write-Host "FAIL  SKILL.md has an unexpected 'name' field." -ForegroundColor Red
    exit 1
}
if ($FrontMatter -notmatch "(?m)^description:\s*\S") {
    Write-Host "FAIL  SKILL.md has no description, so OpenCode will not list the skill." -ForegroundColor Red
    exit 1
}

$FontCount = @(Get-ChildItem -LiteralPath (Join-Path $Target "canvas-fonts") -Recurse -File -Filter "*.ttf").Count
if ($FontCount -lt $MinimumFonts) {
    Write-Host "FAIL  canvas-fonts has only $FontCount TTF files (expected at least $MinimumFonts)." -ForegroundColor Red
    Write-Host "      Re-run install.ps1 -Force." -ForegroundColor Yellow
    exit 1
}

$FileCount = @(Get-ChildItem -LiteralPath $Target -Recurse -File).Count
Write-Host "OK  $Name is installed at $Target ($FileCount files, $FontCount fonts)." -ForegroundColor Green
