#!/bin/bash

set -e

source ./test-utils.sh

echo "User: $(whoami)"
echo "Home: $HOME"
echo "Shell: $SHELL"

# .bashrc exists
check ".bashrc exists" bash -c 'test -f ~/.bashrc && exit 0 || exit 1'

# fzf
check "fzf installed" fzf --version
check "fzf integration" bash -c 'grep -q "fzf" ~/.bashrc && exit 0 || exit 1'
# eza
check "eza installed" eza --version
# zoxide
check "zoxide installed" zoxide --version
check "zoxide integration" bash -c 'grep -q "zoxide" ~/.bashrc && exit 0 || exit 1'
# mise
check "mise installed" mise --version
check "mise integration" bash -c 'grep -q "mise" ~/.bashrc && exit 0 || exit 1'
activateMiseShims
# starship (installStarship=true in this scenario)
check "starship installed" starship --version
check "starship integration" bash -c 'grep -q "starship" ~/.bashrc && exit 0 || exit 1'
# httpie (installHttpie=true in this scenario)
check "httpie installed" http --version
# yazi (installYazi=true in this scenario)
check "yazi installed" yazi --version
# pnpmCompletion=true — verify configured (ok to skip if pnpm absent)
check "pnpm completion configured" bash -c '
  if command -v pnpm &>/dev/null; then
    grep -qF "completion-for-pnpm" ~/.bashrc && exit 0 || exit 1
  else
    exit 0
  fi
'

reportResults
