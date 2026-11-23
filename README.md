# opencode-canvas-design-skill

[![CI](https://github.com/MaxiGP0/opencode-canvas-design-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/MaxiGP0/opencode-canvas-design-skill/actions/workflows/ci.yml)

[English](README.md) | [Español](README.es.md)

One-command installer that makes Anthropic's **[canvas-design](https://github.com/anthropics/skills/tree/main/skills/canvas-design)** skill available in [OpenCode](https://opencode.ai).

The upstream skill documents Claude Code, Claude.ai, and API usage. OpenCode discovers global skills in `~/.config/opencode/skills/<name>/`, so this repository adds a small installer and verifier for that layout. It **downloads the skill from the official repository at install time**; it does not re-host, vendor, or modify the skill's content or its fonts.

> This is an unofficial installer. It is not affiliated with Anthropic.

## What the skill does

The canvas-design skill makes OpenCode produce original visual art instead of generic layouts. It works in two steps:

1. Writes a short design philosophy (an aesthetic movement, not a template) as a `.md` file.
2. Expresses that philosophy on a single canvas, exported as a `.pdf` or `.png`: strong composition, restrained typography, limited palette, and museum-quality attention to detail.

It is aimed at posters, covers, editorial art, album artwork, invitations, and other static design pieces. A subtle conceptual reference to the user's subject is woven into the artwork rather than stated literally.

Upstream ships:

- `SKILL.md` with the full design method.
- `LICENSE.txt` (Apache License 2.0).
- `canvas-fonts/` with **54 TTF font files** and their OFL license files (81 files total), so the skill can pick real typefaces instead of default system fonts.

## Requirements

- [OpenCode](https://opencode.ai) with skills support.
- **Windows:** PowerShell 5.1 or newer (built into Windows 10/11). `tar.exe` is included on current Windows; if it is missing, the installer falls back to the ZIP archive automatically.
- **macOS / Linux:** `bash`, `curl`, and `tar`.
- **Optional:** Python 3 with a PDF/PNG library (for example Pillow or ReportLab), or any other PDF/PNG generation tool, to render the artwork the skill designs. The bundled fonts are ready to use. Nothing beyond the installer is required to install the skill itself.

## Install

### Windows (PowerShell)

Download, inspect, and run:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Or run it directly:

```powershell
irm https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.ps1 | iex
```

To update:

```powershell
# If you saved install.ps1:
.\install.ps1 -Force

# Or without saving it:
$env:CANVAS_DESIGN_FORCE=1; irm https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.ps1 | iex
```

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.sh | bash
```

To update:

```bash
curl -fsSL https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.sh | bash -s -- --force
```

Read the script first if you prefer:

```bash
curl -fsSL https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.sh -o install.sh
bash install.sh
```

### Options

| PowerShell | Bash | Description |
| --- | --- | --- |
| `-SkillDir PATH` | `--dir PATH` | OpenCode skills root. Default: `~/.config/opencode/skills` |
| `-Ref REF` | `--ref REF` | Branch, tag, or commit of the upstream repo. Default: `main` |
| `-Force` | `--force` | Replace an existing installation |

Environment variables `OPENCODE_SKILLS_DIR`, `CANVAS_DESIGN_REF`, and `CANVAS_DESIGN_FORCE=1` work too.

The skill is installed to:

- Windows: `%USERPROFILE%\.config\opencode\skills\canvas-design`
- macOS / Linux: `~/.config/opencode/skills/canvas-design`

The install contains `SKILL.md`, `LICENSE.txt`, and the complete `canvas-fonts/` folder. Font files are copied as binary data, byte for byte.

## Verify the installation

```powershell
.\verify.ps1
```

```bash
bash verify.sh
```

The verifier checks that `SKILL.md` exists, that its frontmatter has `name: canvas-design` and a non-empty description, that `LICENSE.txt` exists, and that `canvas-fonts/` contains at least 50 TTF files.

Or check manually:

```bash
ls ~/.config/opencode/skills/canvas-design/SKILL.md
```

After installing, **start a new OpenCode session** so it picks up the skill.

## Use it

Just ask for a piece of visual work. The skill triggers automatically:

- *"Design a print-ready poster for a jazz festival in Lisbon."*
- *"Make a museum-quality cover about slow cities, exported as PDF."*
- *"Create an editorial illustration about deep time. Minimal text, limited palette."*
- *"Diseña un póster para una obra de teatro sobre el silencio. Formato A2."*
- *"Here is my album concept. Turn it into cover art that feels meticulously crafted."*

Ask for a PDF or PNG and, if you want it, the design philosophy `.md` alongside it.

## Optional: rendering the artwork

The skill's instructions describe the design and the canvas; the actual export is done with tools available in your environment. A Python 3 toolchain with Pillow or ReportLab is a common choice, and the bundled fonts can be referenced directly from `canvas-fonts/`. Any other PDF/PNG generation tool, or an HTML/SVG-to-PDF workflow, works too. There is no extra setup step required by this installer.

## Manual installation

If you prefer not to run an installer:

```bash
git clone --depth 1 https://github.com/anthropics/skills.git
mkdir -p ~/.config/opencode/skills
cp -R skills/skills/canvas-design ~/.config/opencode/skills/
```

On Windows, replace `~/.config/opencode/skills` with `%USERPROFILE%\.config\opencode\skills`.

## Update and uninstall

Update by re-running the installer with `-Force` / `--force`. It always fetches the current upstream revision, so updates arrive as soon as Anthropic publishes them.

Uninstall:

```powershell
Remove-Item -Recurse -Force "$HOME\.config\opencode\skills\canvas-design"
```

```bash
rm -rf ~/.config/opencode/skills/canvas-design
```

## How it works

1. Download `https://codeload.github.com/anthropics/skills/tar.gz/<ref>` into a temporary directory.
2. Extract the archive.
3. Locate `skills/canvas-design` and validate its `SKILL.md`, `LICENSE.txt`, and fonts.
4. Copy the whole subtree into the OpenCode global skills folder and check the result.

Nothing is vendored in this repository: the installer is a thin downloader plus a verifier.

## Licenses and attribution

- **This installer:** MIT. See [LICENSE](LICENSE).
- **canvas-design skill:** Apache License 2.0, Copyright Anthropic. The full terms are in the upstream [LICENSE.txt](https://github.com/anthropics/skills/blob/main/skills/canvas-design/LICENSE.txt) and are installed alongside the skill. This repository does not redistribute the skill.
- **Fonts:** each bundled font keeps its own license file inside `canvas-fonts/` (OFL files shipped upstream). Review those files before redistributing or embedding a font.
- **Anthropic and Claude:** names and marks belong to Anthropic, PBC. This project is unofficial and not affiliated with Anthropic.

See [NOTICE](NOTICE) for the attribution summary.

If you find the skill useful, star the original repository: [anthropics/skills](https://github.com/anthropics/skills).

## Troubleshooting

**The skill does not appear in OpenCode.** Confirm the path with `verify.ps1` / `verify.sh`, then start a new session. OpenCode reads the skills folder when a session starts.

**PowerShell blocks the script.** Use `powershell -ExecutionPolicy Bypass -File .\install.ps1`.

**`tar` is missing on Windows.** Current Windows 10/11 includes `tar.exe`. If yours does not, the installer automatically downloads the ZIP archive and uses PowerShell's built-in `Expand-Archive` instead.

**`curl` is missing on Linux.** Install it (`sudo apt install curl`, `sudo dnf install curl`, or your distribution's equivalent).

**The download fails.** The installer needs access to `github.com` and `codeload.github.com`. Check your proxy or firewall.

**The verifier reports too few fonts.** The download was incomplete or an old copy is present. Re-run the installer with `-Force` / `--force`.

**No PDF/PNG toolchain.** Install Python 3 with Pillow or ReportLab, use a browser-based export, or use any other renderer you already have. The skill itself only requires a way to produce the final file.
