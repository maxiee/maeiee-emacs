#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
EMACS_DIR="${EMACS_DIR:-$HOME/.emacs.d}"

ok()   { printf '  [OK]   %s\n' "$*"; }
warn() { printf '  [WARN] %s\n' "$*"; }
fail() { printf '  [FAIL] %s\n' "$*"; }

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

printf 'Maeiee Emacs doctor\n\n'

[[ "$(uname -s)" == Darwin ]] && ok "macOS detected" || warn "Not running on macOS"
command -v git >/dev/null 2>&1 && ok "Git: $(git --version)" || fail "Git not found"
command -v brew >/dev/null 2>&1 && ok "Homebrew: $(brew --version | head -n 1)" || warn "Homebrew not found"

if EMACS_BIN="$(find_emacs)"; then
  ok "Emacs: $("$EMACS_BIN" --version | head -n 1)"
else
  fail "Emacs executable not found"
fi

for name in early-init.el init.el; do
  target="$EMACS_DIR/$name"
  expected="$ROOT/bootstrap/$name"
  if [[ -L "$target" && "$(readlink "$target")" == "$expected" ]]; then
    ok "$target -> $expected"
  elif [[ -e "$target" || -L "$target" ]]; then
    warn "$target exists but does not point to this repository"
  else
    fail "$target is missing"
  fi
done

module_count="$(find "$ROOT/modules" -maxdepth 1 -name '[0-9][0-9]*.org' | wc -l | tr -d ' ')"
generated_count="$(find "$ROOT/generated" -maxdepth 1 -name '*.el' | wc -l | tr -d ' ')"

ok "$module_count Org modules found"
if [[ "$generated_count" == "$module_count" ]]; then
  ok "$generated_count generated modules found"
else
  warn "$generated_count generated modules for $module_count Org modules; run make tangle"
fi
