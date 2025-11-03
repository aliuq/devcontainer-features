#!/bin/bash

set -e

source dev-container-features-test-lib

# fzf
check "fzf installed" fzf --version
# eza
check "eza installed" eza --version
# zoxide
check "zoxide should be not installed" command -v zoxide && exit 1 || exit 0
# mise
check "mise installed" mise --version
# starship
check "starship installed" starship --version

reportResults
