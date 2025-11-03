#!/bin/bash

set -e

source dev-container-features-test-lib

# fzf
check "fzf installed" fzf --version
check "fzf shell integration" bash -c "cat ~/.bashrc | grep 'fzf'"
# eza
check "eza installed" eza --version
# zoxide
check "zoxide installed" zoxide --version
check "zoxide shell integration" bash -c "cat ~/.bashrc | grep 'zoxide'"
# mise
check "mise installed" mise --version
check "mise shell integration" bash -c "cat ~/.bashrc | grep 'mise'"
# starship
check "starship installed" starship --version
check "starship shell integration" bash -c "cat ~/.bashrc | grep 'starship'"

reportResults
