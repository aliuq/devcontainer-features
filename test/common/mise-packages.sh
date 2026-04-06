#!/bin/bash
# mise-packages scenario: verify misePackages option installs tools via mise

set -e

source ./test-utils.sh

echo "User: $(whoami)"
echo "Home: $HOME"
echo "Shell: $SHELL"

# mise must be installed
check "mise installed" mise --version
check "mise integration" bash -c 'grep -q "mise" ~/.zshrc && exit 0 || exit 1'

# Activate mise shims so installed tools are on PATH
activateMiseShims

# node should be installed via misePackages=node@lts
check "node installed via mise" bash -c 'mise which node &>/dev/null && exit 0 || exit 1'
check "node executable" node --version

reportResults
