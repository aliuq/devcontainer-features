#!/bin/bash

set -e

source ./test-utils.sh

echo "User: $(whoami)"
echo "Home: $HOME"
echo "Shell: $SHELL"

# .zshrc exists
check ".zshrc exists" bash -c 'test -f ~/.zshrc && exit 0 || exit 1'

# fzf
check "fzf installed" fzf --version
check "fzf integration" bash -c 'grep -q "fzf" ~/.zshrc && exit 0 || exit 1'
# eza
check "eza installed" eza --version
# zoxide
check "zoxide installed" zoxide --version
check "zoxide integration" bash -c 'grep -q "zoxide" ~/.zshrc && exit 0 || exit 1'
# mise
check "mise installed" mise --version
check "mise integration" bash -c 'grep -q "mise" ~/.zshrc && exit 0 || exit 1'
# starship
check "starship not installed" bash -c 'if ! command -v starship &> /dev/null; then exit 0; else exit 1; fi'

reportResults
