#!/bin/bash
# zsh-plugins scenario: verify zshPlugins option adds oh-my-zsh plugins

set -e

source ./test-utils.sh

echo "User: $(whoami)"
echo "Home: $HOME"
echo "Shell: $SHELL"

# .zshrc exists
check ".zshrc exists" bash -c 'test -f ~/.zshrc && exit 0 || exit 1'

# oh-my-zsh must be installed
check "oh-my-zsh installed" bash -c 'test -d ~/.oh-my-zsh && exit 0 || exit 1'

# Verify zshPlugins=git,docker are present in .zshrc plugin list
check "git plugin configured" bash -c 'grep -q "git" ~/.zshrc && exit 0 || exit 1'
check "docker plugin configured" bash -c 'grep -q "docker" ~/.zshrc && exit 0 || exit 1'

# Default tools still installed
check "fzf installed" fzf --version
check "mise installed" mise --version

reportResults
