#Requires -Version 5.1
<#
.SYNOPSIS
    Install Anthropic's canvas-design skill for OpenCode.

.DESCRIPTION
    Downloads the skill from the official anthropics/skills repository and
    copies it to the OpenCode global skills directory, so OpenCode discovers
    it automatically. Nothing is vendored or re-hosted by this project.

.PARAMETER SkillDir
    OpenCode skills root. Defaults to $env:OPENCODE_SKILLS_DIR, or
    ~/.config/opencode/skills.

.PARAMETER Ref
    Branch, tag, or commit of the upstream repository. Defaults to "main".

.PARAMETER Force
    Replace an existing installation. Without it, the installer leaves the
    current copy untouched.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1

.EXAMPLE
    .\install.ps1 -Force -Ref main
#>
[CmdletBinding()]
param(
    [string]$SkillDir,
    [string]$Ref = "main",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

if ($env:CANVAS_DESIGN_REF -and -not $PSBoundParameters.ContainsKey("Ref")) {
    $Ref = $env:CANVAS_DESIGN_REF
}
if ($env:CANVAS_DESIGN_FORCE -eq "1") {
    $Force = $true
}

$Repo = "anthropics/skills"
$Name = "canvas-design"
$MinimumFonts = 50

function Write-Step([string]$Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok([string]$Message) {
    Write-Host "OK  $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "!!  $Message" -ForegroundColor Yellow
}

function Get-TtfCount([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return 0
    }
    return @(Get-ChildItem -LiteralPath $Path -Recurse -File -Filter "*.ttf").Count
}

if (-not $SkillDir) {
    if ($env:OPENCODE_SKILLS_DIR) {
        $SkillDir = $env:OPENCODE_SKILLS_DIR
    }
    else {
        $HomeDir = if ($HOME) { $HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { $null }
        if (-not $HomeDir) {
            throw "Could not find your home directory. Pass -SkillDir explicitly."
        }
        $SkillDir = Join-Path $HomeDir ".config\opencode\skills"
    }
}

$Target = Join-Path $SkillDir $Name

if ((Split-Path -Leaf $Target) -ne $Name) {
    throw "Refusing to install to an unexpected path: $Target"
}

if ((Test-Path -LiteralPath $Target) -and -not $Force) {
    Write-Warn "$Name is already installed at:"
    Write-Host "    $Target"
    Write-Host "    Re-run with -Force to update it."
    exit 0
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("canvas-design-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TempDir | Out-Null

try {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    }
    catch {
        # PowerShell 7 / .NET Core does not need (and may reject) this setting.
    }

    $Url = "https://codeload.github.com/$Repo/tar.gz/$Ref"
    $ArchivePath = Join-Path $TempDir "skills.tar.gz"

    Write-Step "Downloading $Url"
    Invoke-WebRequest -Uri $Url -OutFile $ArchivePath -UseBasicParsing

    $TarCommand = Get-Command tar -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($TarCommand) {
        Write-Step "Extracting"
        & $TarCommand.Source -xzf $ArchivePath -C $TempDir
        if ($LASTEXITCODE -ne 0) {
            throw "Could not extract the downloaded archive (tar exited with $LASTEXITCODE)."
        }
    }
    else {
        Write-Warn "tar was not found; falling back to the ZIP archive."
        $ZipPath = Join-Path $TempDir "skills.zip"
        Invoke-WebRequest -Uri "https://codeload.github.com/$Repo/zip/$Ref" -OutFile $ZipPath -UseBasicParsing
        Write-Step "Extracting"
        Expand-Archive -LiteralPath $ZipPath -DestinationPath $TempDir -Force
    }

    $SkillMd = Get-ChildItem -LiteralPath $TempDir -Recurse -File -Filter "SKILL.md" |
        Where-Object { $_.Directory.Name -eq $Name -and $_.Directory.Parent.Name -eq "skills" } |
        Select-Object -First 1

    if (-not $SkillMd) {
        $SkillMd = Get-ChildItem -LiteralPath $TempDir -Recurse -File -Filter "SKILL.md" |
            Where-Object { $_.Directory.Name -eq $Name } |
            Select-Object -First 1
    }

    if (-not $SkillMd) {
        throw "Could not find $Name/SKILL.md in the downloaded archive. The upstream layout may have changed."
    }

    $Source = $SkillMd.Directory.FullName
    $SkillText = Get-Content -LiteralPath $SkillMd.FullName -Raw

    $FrontMatter = $null
    if ($SkillText -match "(?s)\A---[ \t]*\r?\n(.*?)\r?\n---[ \t]*(\r?\n|\z)") {
        $FrontMatter = $Matches[1]
    }
    if (-not $FrontMatter) {
        throw "SKILL.md has no YAML frontmatter."
    }
    if ($FrontMatter -notmatch "(?m)^name:\s*$([regex]::Escape($Name))\s*$") {
        throw "SKILL.md does not look like Anthropic's canvas-design skill (missing 'name: $Name')."
    }
    if ($FrontMatter -notmatch "(?m)^description:\s*\S") {
        throw "SKILL.md has no description, so OpenCode would not list the skill."
    }
    if (-not (Test-Path -LiteralPath (Join-Path $Source "LICENSE.txt"))) {
        throw "The downloaded skill is missing LICENSE.txt."
    }

    $SourceFonts = Get-TtfCount (Join-Path $Source "canvas-fonts")
    if ($SourceFonts -lt $MinimumFonts) {
        throw "The downloaded skill has only $SourceFonts TTF fonts (expected at least $MinimumFonts). The upstream layout may have changed."
    }

    if (Test-Path -LiteralPath $Target) {
        Write-Step "Removing the existing installation"
        Remove-Item -LiteralPath $Target -Recurse -Force
    }

    Write-Step "Installing to $Target"
    New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Target -Recurse -Force

    foreach ($RelativePath in @("SKILL.md", "LICENSE.txt", "canvas-fonts")) {
        if (-not (Test-Path -LiteralPath (Join-Path $Target $RelativePath))) {
            throw "Installation is incomplete: missing $RelativePath."
        }
    }

    $InstalledFonts = Get-TtfCount (Join-Path $Target "canvas-fonts")
    if ($InstalledFonts -lt $MinimumFonts) {
        throw "Installation is incomplete: only $InstalledFonts TTF fonts were copied."
    }

    $FileCount = @(Get-ChildItem -LiteralPath $Target -Recurse -File).Count
    Write-Ok "Installed $FileCount files ($InstalledFonts fonts) to $Target"
}
finally {
    Remove-Item -LiteralPath $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Start a new OpenCode session and ask for a poster, cover, or visual artwork." -ForegroundColor Green
Write-Host "The skill is picked up automatically. Examples:"
Write-Host '  - "Design a print-ready poster for a jazz festival in Lisbon."'
Write-Host '  - "Make a museum-quality cover about slow cities, exported as PDF."'
Write-Host '  - "Crea un poster minimalista sobre el silencio, en PNG."'
Write-Host ""
Write-Host "Source and license: https://github.com/$Repo/tree/main/skills/$Name"
