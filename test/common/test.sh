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
check "starship not installed" bash -c 'if ! command -v starship &> /dev/null; then exit 0; else exit 1; fi'

reportResults
