#!/bin/bash

set -e

source dev-container-features-test-lib

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
