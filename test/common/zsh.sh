#!/bin/bash

set -e

source dev-container-features-test-lib

# check the default shell is zsh
check "default shell is zsh" bash -c 'echo $SHELL' | grep -q 'zsh$'
# check .zshrc exists
check "zshrc exists" bash -c 'test -f ~/.zshrc'

# fzf
check "fzf installed" fzf --version
# eza
check "eza installed" eza --version
# zoxide
check "zoxide installed" zoxide --version
# mise
check "mise installed" mise --version
# starship
check "starship installed" starship --version

reportResults
