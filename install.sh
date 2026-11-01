#!/bin/sh
# install.sh — installs the `atlas-generate` skill for Pi, Claude Code, Codex, Cursor, ...
#
# Usage:
#   ./install.sh              user install: Pi + Agent Skills standard always; other tools only
#                             if their config dir already exists (~/.claude, ~/.codex, ~/.cursor)
#   ./install.sh --all        force ALL known user locations (creates the dirs if needed)
#   ./install.sh --project    project install: into the current working directory
#   ./install.sh --copy       copy the skill instead of symlinking it
#   ./install.sh --help       show this help
#
# User locations:
#   Pi .................... ~/.pi/agent/skills/atlas-generate
#   Agent Skills standard . ~/.agents/skills/atlas-generate   (also picked up by Pi)
#   Claude Code ........... ~/.claude/skills/atlas-generate
#   Codex CLI ............. ~/.codex/skills/atlas-generate
#   Cursor ................ ~/.cursor/skills/atlas-generate
#
# Project locations (--project, run from the project root):
#   .pi/skills/ .agents/skills/ .claude/skills/ .codex/skills/ .cursor/skills/

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SKILL_SRC="$SCRIPT_DIR/atlas-generate"
SKILL_NAME="atlas-generate"

MODE=user
STRATEGY=link

for arg in "$@"; do
  case "$arg" in
    --all) MODE=all ;;
    --project) MODE=project ;;
    --copy) STRATEGY=copy ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown option: $arg (see --help)" >&2; exit 2 ;;
  esac
done

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "Error: $SKILL_SRC/SKILL.md not found. Run this script from the repo." >&2
  exit 1
fi

install_one() { # $1 = target parent dir
  parent="$1"
  target="$parent/$SKILL_NAME"
  mkdir -p "$parent"
  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "  skip (already exists): $target"
    return 0
  fi
  if [ "$STRATEGY" = copy ]; then
    cp -R "$SKILL_SRC" "$target"
    echo "  copied  -> $target"
  else
    ln -s "$SKILL_SRC" "$target"
    echo "  linked  -> $target -> $SKILL_SRC"
  fi
}

if [ "$MODE" = project ]; then
  echo "Project install into: $PWD"
  for d in .pi/skills .agents/skills .claude/skills .codex/skills .cursor/skills; do
    install_one "$d"
  done
else
  echo "User install:"
  install_one "$HOME/.pi/agent/skills"      # Pi
  install_one "$HOME/.agents/skills"        # Agent Skills standard (also seen by Pi)
  if [ "$MODE" = all ] || [ -d "$HOME/.claude" ];  then install_one "$HOME/.claude/skills";  fi
  if [ "$MODE" = all ] || [ -d "$HOME/.codex" ];   then install_one "$HOME/.codex/skills";   fi
  if [ "$MODE" = all ] || [ -d "$HOME/.cursor" ];  then install_one "$HOME/.cursor/skills";  fi
fi

echo "Done. In Pi, run /reload if a session is already open, then try: /skill:$SKILL_NAME"
