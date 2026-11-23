#!/usr/bin/env bash
# Check that Anthropic's canvas-design skill is installed for OpenCode.

set -euo pipefail

NAME="canvas-design"
MINIMUM_FONTS=50
SKILLS_DIR="${1:-${OPENCODE_SKILLS_DIR:-$HOME/.config/opencode/skills}}"
TARGET="$SKILLS_DIR/$NAME"

if [[ ! -d "$TARGET" ]]; then
    echo "FAIL  $NAME is not installed at $TARGET"
    echo "      Run install.sh first."
    exit 1
fi

MISSING=0
for required in "SKILL.md" "LICENSE.txt"; do
    if [[ ! -f "$TARGET/$required" ]]; then
        echo "FAIL  Missing $required"
        MISSING=1
    fi
done
if [[ ! -d "$TARGET/canvas-fonts" ]]; then
    echo "FAIL  Missing canvas-fonts/"
    MISSING=1
fi

if [[ "$MISSING" -ne 0 ]]; then
    echo "      The installation is incomplete. Re-run install.sh --force."
    exit 1
fi

FRONTMATTER="$(awk 'BEGIN { fences = 0 } /^---[[:space:]]*$/ { fences++; if (fences == 1) next; if (fences == 2) exit } fences == 1 { print }' "$TARGET/SKILL.md")"
if [[ -z "$FRONTMATTER" ]]; then
    echo "FAIL  SKILL.md has no YAML frontmatter."
    exit 1
fi

if ! printf '%s\n' "$FRONTMATTER" | grep -Eq "^name:[[:space:]]*$NAME[[:space:]]*$"; then
    echo "FAIL  SKILL.md has an unexpected 'name' field."
    exit 1
fi

if ! printf '%s\n' "$FRONTMATTER" | grep -Eq "^description:[[:space:]]*[^[:space:]]"; then
    echo "FAIL  SKILL.md has no description, so OpenCode will not list the skill."
    exit 1
fi

FONT_COUNT="$(find "$TARGET/canvas-fonts" -type f -name '*.ttf' | wc -l | tr -d ' ')"
if [[ "$FONT_COUNT" -lt "$MINIMUM_FONTS" ]]; then
    echo "FAIL  canvas-fonts has only $FONT_COUNT TTF files (expected at least $MINIMUM_FONTS)."
    echo "      Re-run install.sh --force."
    exit 1
fi

FILE_COUNT="$(find "$TARGET" -type f | wc -l | tr -d ' ')"
echo "OK  $NAME is installed at $TARGET ($FILE_COUNT files, $FONT_COUNT fonts)."
