#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
EMACS_DIR="${EMACS_DIR:-$HOME/.emacs.d}"
STAMP="$(date +%Y%m%d-%H%M%S)"
INSTALL_EMACS=0
SKIP_TANGLE=0

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [options]

Options:
  --install-emacs  Install the stable GUI Emacs cask with Homebrew when needed.
  --skip-tangle    Only create links; do not run Emacs in batch mode.
  -h, --help       Show this help.

Environment:
  EMACS_DIR        Emacs configuration directory. Default: ~/.emacs.d
EOF
}

while (($#)); do
  case "$1" in
    --install-emacs) INSTALL_EMACS=1 ;;
    --skip-tangle)   SKIP_TANGLE=1 ;;
    -h|--help)       usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

say()  { printf '\n==> %s\n' "$*"; }
die()  { printf 'Error: %s\n' "$*" >&2; exit 1; }

find_emacs() {
  if command -v emacs >/dev/null 2>&1; then
    command -v emacs
  elif [[ -x /Applications/Emacs.app/Contents/MacOS/Emacs ]]; then
    printf '%s\n' /Applications/Emacs.app/Contents/MacOS/Emacs
  elif [[ -x "$HOME/Applications/Emacs.app/Contents/MacOS/Emacs" ]]; then
    printf '%s\n' "$HOME/Applications/Emacs.app/Contents/MacOS/Emacs"
  else
    return 1
  fi
}

backup_path() {
  local path="$1"
  if [[ -e "$path" || -L "$path" ]]; then
    local backup="${path}.backup-${STAMP}"
    mv "$path" "$backup"
    printf 'Backed up %s -> %s\n' "$path" "$backup"
  fi
}

link_file() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    printf 'Already linked: %s\n' "$target"
    return
  fi

  backup_path "$target"
  ln -s "$source" "$target"
  printf 'Linked %s -> %s\n' "$target" "$source"
}

[[ -d "$ROOT/.git" ]] ||
  printf 'Note: this directory is not currently a Git worktree.\n'

if [[ "$(uname -s)" != Darwin ]]; then
  printf 'Warning: this starter is designed for macOS, but the core is portable.\n'
fi

if ! EMACS_BIN="$(find_emacs)"; then
  if ((INSTALL_EMACS)); then
    command -v brew >/dev/null 2>&1 ||
      die "Homebrew is required for --install-emacs"
    say "Installing Emacs"
    brew install --cask emacs-app
    EMACS_BIN="$(find_emacs)" ||
      die "Emacs was installed but no executable was found"
  else
    die "Emacs not found. Install it first, or run ./bootstrap.sh --install-emacs"
  fi
fi

say "Preparing $EMACS_DIR"
mkdir -p "$EMACS_DIR" "$EMACS_DIR/var"

# Legacy init files take precedence in some startup paths. Preserve them, but
# move them out of the way so this repository is the single source of truth.
backup_path "$HOME/.emacs"
backup_path "$HOME/.emacs.el"

link_file "$ROOT/bootstrap/early-init.el" "$EMACS_DIR/early-init.el"
link_file "$ROOT/bootstrap/init.el" "$EMACS_DIR/init.el"

if ((SKIP_TANGLE == 0)); then
  say "Tangling Org modules"
  "$EMACS_BIN" --batch -Q --load "$ROOT/scripts/tangle-all.el"
fi

say "Bootstrap complete"
cat <<EOF
Repository : $ROOT
Emacs dir  : $EMACS_DIR
Emacs      : $EMACS_BIN

Next:
  1. Start /Applications/Emacs.app
  2. Open $ROOT/README.org
  3. Run M-x maeiee-reload-current-module after editing a module
  4. Run $ROOT/scripts/doctor.sh when something looks wrong
EOF
