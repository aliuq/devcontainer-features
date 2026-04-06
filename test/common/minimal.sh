#!/bin/bash
# Minimal scenario: default options only
# installStarship=false, installHttpie=false, installYazi=false, pnpmCompletion=false

set -e

source ./test-utils.sh

echo "User: $(whoami)"
echo "Home: $HOME"
echo "Shell: $SHELL"

# .zshrc exists (default shell is zsh)
check ".zshrc exists" bash -c 'test -f ~/.zshrc && exit 0 || exit 1'

# fzf (installFzf=true by default)
check "fzf installed" fzf --version
check "fzf integration" bash -c 'grep -q "fzf" ~/.zshrc && exit 0 || exit 1'
# eza (installEza=true by default)
check "eza installed" eza --version
# zoxide (installZoxide=true by default)
check "zoxide installed" zoxide --version
check "zoxide integration" bash -c 'grep -q "zoxide" ~/.zshrc && exit 0 || exit 1'
# mise (installMise=true by default)
check "mise installed" mise --version
check "mise integration" bash -c 'grep -q "mise" ~/.zshrc && exit 0 || exit 1'

# Optional tools should NOT be installed
check "starship not installed" bash -c 'if ! command -v starship &>/dev/null; then exit 0; else exit 1; fi'
check "httpie not installed" bash -c 'if ! command -v http &>/dev/null; then exit 0; else exit 1; fi'
check "yazi not installed" bash -c 'if ! command -v yazi &>/dev/null; then exit 0; else exit 1; fi'

reportResults
