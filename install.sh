#!/usr/bin/env bash
# Install Anthropic's canvas-design skill for OpenCode.
#
# Downloads the skill from the official anthropics/skills repository and
# copies it to the OpenCode global skills directory, so OpenCode discovers
# it automatically. Nothing is vendored or re-hosted by this project.

set -euo pipefail

REPO="anthropics/skills"
NAME="canvas-design"
REF="${CANVAS_DESIGN_REF:-main}"
SKILLS_DIR="${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}"
MINIMUM_FONTS=50
FORCE=0
if [[ "${CANVAS_DESIGN_FORCE:-0}" == "1" ]]; then
    FORCE=1
fi

usage() {
    cat <<EOF
Usage: install.sh [options]

Options:
  --dir PATH    OpenCode skills root (default: ~/.config/opencode/skills)
  --ref REF     Branch, tag, or commit of the upstream repo (default: main)
  --force       Replace an existing installation
  -h, --help    Show this help

Environment:
  OPENCODE_SKILLS_DIR    Same as --dir
  CANVAS_DESIGN_REF      Same as --ref
  CANVAS_DESIGN_FORCE    Set to 1 to replace an existing installation
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)
            [[ $# -ge 2 ]] || { echo "Missing value for --dir" >&2; exit 1; }
            SKILLS_DIR="$2"
            shift 2
            ;;
        --ref)
            [[ $# -ge 2 ]] || { echo "Missing value for --ref" >&2; exit 1; }
            REF="$2"
            shift 2
            ;;
        --force)
            FORCE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

for cmd in curl tar find grep; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: '$cmd' is required but was not found in PATH." >&2
        exit 1
    fi
done

TARGET="$SKILLS_DIR/$NAME"
if [[ "$(basename "$TARGET")" != "$NAME" ]]; then
    echo "Refusing to install to an unexpected path: $TARGET" >&2
    exit 1
fi

if [[ -d "$TARGET" ]]; then
    if [[ "$FORCE" -ne 1 ]]; then
        echo "!!  $NAME is already installed at:"
        echo "    $TARGET"
        echo "    Re-run with --force to update it."
        exit 0
    fi
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/canvas-design.XXXXXX")"
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

URL="https://codeload.github.com/$REPO/tar.gz/$REF"
ARCHIVE="$TMP_DIR/skills.tar.gz"

echo "==> Downloading $URL"
curl -fsSL "$URL" -o "$ARCHIVE"

echo "==> Extracting"
tar -xzf "$ARCHIVE" -C "$TMP_DIR"

SKILL_MD="$(find "$TMP_DIR" -type f -path "*/skills/$NAME/SKILL.md" | head -n 1)"
if [[ -z "$SKILL_MD" ]]; then
    echo "Error: could not find $NAME/SKILL.md in the downloaded archive." >&2
    echo "The upstream layout may have changed." >&2
    exit 1
fi

FRONTMATTER="$(awk 'BEGIN { fences = 0 } /^---[[:space:]]*$/ { fences++; if (fences == 1) next; if (fences == 2) exit } fences == 1 { print }' "$SKILL_MD")"
if [[ -z "$FRONTMATTER" ]]; then
    echo "Error: SKILL.md has no YAML frontmatter." >&2
    exit 1
fi

if ! printf '%s\n' "$FRONTMATTER" | grep -Eq "^name:[[:space:]]*$NAME[[:space:]]*$"; then
    echo "Error: SKILL.md does not look like Anthropic's canvas-design skill." >&2
    exit 1
fi

if ! printf '%s\n' "$FRONTMATTER" | grep -Eq "^description:[[:space:]]*[^[:space:]]"; then
    echo "Error: SKILL.md has no description, so OpenCode would not list the skill." >&2
    exit 1
fi

SOURCE_DIR="$(dirname "$SKILL_MD")"

if [[ ! -f "$SOURCE_DIR/LICENSE.txt" ]]; then
    echo "Error: the downloaded skill is missing LICENSE.txt." >&2
    exit 1
fi

if [[ ! -d "$SOURCE_DIR/canvas-fonts" ]]; then
    echo "Error: the downloaded skill is missing canvas-fonts/." >&2
    exit 1
fi

SOURCE_FONTS="$(find "$SOURCE_DIR/canvas-fonts" -type f -name '*.ttf' | wc -l | tr -d ' ')"
if [[ "$SOURCE_FONTS" -lt "$MINIMUM_FONTS" ]]; then
    echo "Error: the downloaded skill has only $SOURCE_FONTS TTF fonts (expected at least $MINIMUM_FONTS)." >&2
    echo "The upstream layout may have changed." >&2
    exit 1
fi

if [[ -d "$TARGET" ]]; then
    echo "==> Removing the existing installation"
    rm -rf "$TARGET"
fi

echo "==> Installing to $TARGET"
mkdir -p "$SKILLS_DIR" "$TARGET"
cp -R "$SOURCE_DIR"/. "$TARGET"/

for required in "SKILL.md" "LICENSE.txt" "canvas-fonts"; do
    if [[ ! -e "$TARGET/$required" ]]; then
        echo "Error: installation is incomplete: missing $required." >&2
        exit 1
    fi
done

INSTALLED_FONTS="$(find "$TARGET/canvas-fonts" -type f -name '*.ttf' | wc -l | tr -d ' ')"
if [[ "$INSTALLED_FONTS" -lt "$MINIMUM_FONTS" ]]; then
    echo "Error: installation is incomplete: only $INSTALLED_FONTS TTF fonts were copied." >&2
    exit 1
fi

FILE_COUNT="$(find "$TARGET" -type f | wc -l | tr -d ' ')"
echo "OK  Installed $FILE_COUNT files ($INSTALLED_FONTS fonts) to $TARGET"

cat <<EOF

Start a new OpenCode session and ask for a poster, cover, or visual artwork.
The skill is picked up automatically. Examples:
  - "Design a print-ready poster for a jazz festival in Lisbon."
  - "Make a museum-quality cover about slow cities, exported as PDF."
  - "Crea un poster minimalista sobre el silencio, en PNG."

Source and license: https://github.com/$REPO/tree/main/skills/$NAME
EOF
