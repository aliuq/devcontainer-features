#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) https://github.com/aliuq/devcontainer-features. All rights reserved.
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/aliuq/devcontainer-features/tree/main/src/common
# Maintainer: aliuq

set -e

# Get options
DEFAULT_SHELL="${DEFAULTSHELL:-}"
INSTALL_EZA="${INSTALLEZA:-"true"}"
INSTALL_FZF="${INSTALLFZF:-"true"}"
INSTALL_ZOXIDE="${INSTALLZOXIDE:-"true"}"
INSTALL_MISE="${INSTALLMISE:-"true"}"
INSTALL_STARSHIP="${INSTALLSTARSHIP:-"false"}"
STARSHIP_CONFIG_URL="${STARSHIPCONFIGURL:-""}"
INSTALL_ZSH_PLUGINS="${INSTALLZSHPLUGINS:-"true"}"
BIN_DIR="${BINDIR:-"/usr/local/bin"}"
PROXY_URL="${PROXYURL:-""}"

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

if [ -z "${_REMOTE_USER}" ]; then
  echo -e 'Feature script hope to be executed by a tool that implements the dev container specification.'
  _REMOTE_USER="$(whoami)"
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" >/etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
  ADJUSTED_ID="debian"
elif [ "${ID}" = "alpine" ]; then
  ADJUSTED_ID="alpine"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID}" = "mariner" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* || "${ID_LIKE}" = *"mariner"* ]]; then
  ADJUSTED_ID="rhel"
  VERSION_CODENAME="${ID}${VERSION_ID}"
else
  echo "Linux distro ${ID} not supported."
  exit 1
fi

# If `ADJUSTED_ID` is not `debian` or `alpine`, then exit
if [ "${ADJUSTED_ID}" != "debian" ] && [ "${ADJUSTED_ID}" != "alpine" ]; then
  echo "Unsupported Linux distribution: ${ADJUSTED_ID} (${ID})"
  exit 1
fi

# Determine architecture
architecture="$(uname -m)"
case ${architecture} in
x86_64) architecture="amd64" ;;
aarch64 | armv8* | arm64) architecture="arm64" ;;
armv7* | armhf) architecture="armhf" ;;
i?86) architecture="i386" ;;
*)
  echo "Unsupported architecture: ${architecture}"
  exit 1
  ;;
esac

echo "Detected platform: ${ADJUSTED_ID} (${ID}), architecture: ${architecture}"

if [ "${_REMOTE_USER}" != "root" ]; then
  user_home="/home/${_REMOTE_USER}"
else
  user_home="/root"
fi

echo "Detected user: ${_REMOTE_USER} (${user_home})"

current_shell=${DEFAULT_SHELL:-$(basename "$SHELL")}
current_shell_rc=""
if [ "$current_shell" = "bash" ]; then
  current_shell_rc="${user_home}/.bashrc"
elif [ "$current_shell" = "zsh" ]; then
  current_shell_rc="${user_home}/.zshrc"
fi

echo "Detected shell: ${current_shell} ($(which $current_shell)) (rc: ${current_shell_rc})"

command_exists() {
  type "$1" >/dev/null 2>&1
}

# Clean up
clean_up() {
  case $ADJUSTED_ID in
  debian)
    rm -rf /var/lib/apt/lists/*
    ;;
  alpine)
    rm -rf /var/cache/apk/*
    ;;
  esac
}

# Update package manager cache
pkg_mgr_update() {
  case $ADJUSTED_ID in
  debian)
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
      echo "Running apt-get update..."
      apt-get update -y
    fi
    ;;
  alpine)
    if [ "$(find /var/cache/apk/* | wc -l)" = "0" ]; then
      echo "Running apk update..."
      apk update
    fi
    ;;
  esac
}

_pkg_updated="false"
# Checks if packages are installed and installs them if not
check_packages() {
  if [ "$ADJUSTED_ID" = "debian" ]; then
    if ! dpkg -s "$@" >/dev/null 2>&1; then
      if [ "${_pkg_updated}" = "false" ]; then
        pkg_mgr_update
        _pkg_updated="true"
      fi
      apt-get -y install --no-install-recommends "$@"
    fi
  elif [ "$ADJUSTED_ID" = "alpine" ]; then
    if [ "${_pkg_updated}" = "false" ]; then
      pkg_mgr_update
      _pkg_updated="true"
    fi
    apk add --no-cache "$@"
  else
    echo "Unsupported Linux distribution: ${ADJUSTED_ID} (${ID})"
    exit 1
  fi
}

#
# -----------------------------------------------------
#
if [ "$ADJUSTED_ID" = "debian" ]; then
  # Ensure apt is in non-interactive to avoid prompts
  export DEBIAN_FRONTEND=noninteractive
fi

# Detect oh-my-zsh flag
use_omz="false"
# Check if oh-my-zsh is installed by looking for "source $ZSH/oh-my-zsh.sh" in the rc file
if [ "$current_shell" = "zsh" ] && [ -n "$current_shell_rc" ] && grep -q 'source $ZSH/oh-my-zsh.sh' "$current_shell_rc"; then
  use_omz="true"
fi

# fzf
# https://junegunn.github.io/fzf/installation/
install_fzf() {
  if command_exists fzf; then
    echo "fzf is already installed, skipping."
  else
    echo "Installing fzf..."
    check_packages git unzip ca-certificates
    git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf
    /tmp/fzf/install --bin --no-key-bindings --no-completion --no-update-rc
    cp /tmp/fzf/bin/fzf "$BIN_DIR/fzf"
    rm -rf /tmp/fzf

    # Set up shell integration
    if [ "$use_omz" = "true" ]; then
      echo "Detected oh-my-zsh installation, configuring fzf via oh-my-zsh plugin."
      # Enable fzf plugin in oh-my-zsh (only if not already present)
      if ! grep -q 'plugins=.*fzf' "$current_shell_rc"; then
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 fzf)/' "$current_shell_rc"
      fi
    elif [ "$current_shell" = "bash" ]; then
      echo 'eval "$(fzf --bash)"' >>"$current_shell_rc"
    elif [ "$current_shell" = "zsh" ]; then
      echo 'source <(fzf --zsh)' >>"$current_shell_rc"
    else
      echo "Unsupported shell for fzf integration: $current_shell"
    fi
  fi
}

# zoxide
# https://github.com/ajeetdsouza/zoxide/?tab=readme-ov-file#installation
install_zoxide() {
  if command_exists zoxide; then
    echo "zoxide is already installed, skipping."
  else
    echo "Installing zoxide..."
    check_packages curl ca-certificates unzip
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh -s -- --bin-dir="$BIN_DIR"

    # Set up shell integration
    if [ "$use_omz" = "true" ]; then
      echo "Detected oh-my-zsh installation, configuring zoxide via oh-my-zsh plugin."
      # Enable zoxide plugin in oh-my-zsh (only if not already present)
      if ! grep -q 'plugins=.*zoxide' "$current_shell_rc"; then
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 zoxide)/' "$current_shell_rc"
      fi
    elif [ "$current_shell" = "bash" ]; then
      echo 'eval "$(zoxide init bash)"' >>"$current_shell_rc"
    elif [ "$current_shell" = "zsh" ]; then
      echo 'eval "$(zoxide init zsh)"' >>"$current_shell_rc"
    else
      echo "Unsupported shell for zoxide integration: $current_shell"
    fi
  fi
}

# eza
# https://github.com/eza-community/eza/blob/main/INSTALL.md
install_eza() {
  if command_exists eza; then
    echo "eza is already installed, skipping."
  else
    echo "Installing eza..."
    if [ "$ADJUSTED_ID" = "debian" ]; then
      check_packages gnupg2 wget
      # Use official Debian/Ubuntu repository
      mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
      chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      apt-get update && apt-get install -y --no-install-recommends eza
    elif [ "$ADJUSTED_ID" = "alpine" ]; then
      apk add --no-cache eza
    else
      echo "Linux distro ${ID} not supported for eza installation."
      exit 1
    fi

    # Set up shell integration
    if [ "$use_omz" = "true" ]; then
      echo "Detected oh-my-zsh installation, configuring eza via oh-my-zsh plugin."
      # Enable eza plugin in oh-my-zsh (only if not already present)
      if ! grep -q 'plugins=.*eza' "$current_shell_rc"; then
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 eza)/' "$current_shell_rc"
      fi
    fi
  fi
}

# mise
# https://mise.jdx.dev/getting-started.html
install_mise() {
  if command_exists mise; then
    echo "mise is already installed, skipping."
  else
    echo "Installing mise..."
    check_packages curl
    export MISE_INSTALL_PATH="${BIN_DIR}/mise"
    curl -fsSL https://mise.run | sh

    # Set up shell integration
    if [ "$use_omz" = "true" ]; then
      echo "Detected oh-my-zsh installation, configuring mise via oh-my-zsh plugin."
      # Enable mise plugin in oh-my-zsh (only if not already present)
      if ! grep -q 'plugins=.*mise' "$current_shell_rc"; then
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 mise)/' "$current_shell_rc"
      fi
    elif [ "$current_shell" = "bash" ]; then
      echo "eval \"\$(${MISE_INSTALL_PATH} activate bash)\"" >>"$current_shell_rc"
    elif [ "$current_shell" = "zsh" ]; then
      echo "eval \"\$(${MISE_INSTALL_PATH} activate zsh)\"" >>"$current_shell_rc"
    else
      echo "Unsupported shell for mise integration: $current_shell"
    fi
  fi
}

# starship
# https://starship.rs/zh-CN/guide/
install_starship() {
  if command_exists starship; then
    echo "starship is already installed, skipping."
  else
    echo "Installing starship..."
    check_packages curl unzip
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y --bin-dir="$BIN_DIR"

    # Set up shell integration
    if [ "$use_omz" = "true" ]; then
      echo "Detected oh-my-zsh installation, configuring starship via oh-my-zsh plugin."
      # Enable starship plugin in oh-my-zsh (only if not already present)
      if ! grep -q 'plugins=.*starship' "$current_shell_rc"; then
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 starship)/' "$current_shell_rc"
      fi
    elif [ "$current_shell" = "bash" ]; then
      echo 'eval "$(starship init bash)"' >>"$current_shell_rc"
    elif [ "$current_shell" = "zsh" ]; then
      echo 'source <(starship init zsh)' >>"$current_shell_rc"
    else
      echo "Unsupported shell for starship integration: $current_shell"
    fi

    # Starship config
    local conf="${user_home}/.config/starship.toml"
    if [ ! -f "$conf" ]; then
      mkdir -p "${user_home}/.config"
      if [ -n "$STARSHIP_CONFIG_URL" ]; then
        echo "Downloading starship configuration from $STARSHIP_CONFIG_URL"
        curl -fsSL "$STARSHIP_CONFIG_URL" -o "$conf" || echo "Failed to download starship config, using default."
      else
        echo "Creating default starship configuration."
        cp -f "${FEATURE_DIR}/scripts/starship.toml" "$conf"
      fi
    fi
  fi
}

# oh-my-zsh plugins
load_zsh_plugins() {
  if [ ! "$use_omz" = "true" ]; then
    return
  fi

  check_packages git

  local custom_plugins_dir="${ZSH_CUSTOM:-${user_home}/.oh-my-zsh/custom}/plugins"
  # zsh-autosuggestions
  local autosuggestions_dir="${custom_plugins_dir}/zsh-autosuggestions"
  if [ ! -d "$autosuggestions_dir" ]; then
    echo "Installing zsh-autosuggestions plugin..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
  fi
  # zsh-syntax-highlighting
  local syntax_highlighting_dir="${custom_plugins_dir}/zsh-syntax-highlighting"
  if [ ! -d "$syntax_highlighting_dir" ]; then
    echo "Installing zsh-syntax-highlighting plugin..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$syntax_highlighting_dir"
  fi

  # Enable plugins in oh-my-zsh (only if not already present)
  if ! grep -q 'plugins=.*zsh-autosuggestions' "$current_shell_rc"; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/' "$current_shell_rc"
  fi
  if ! grep -q 'plugins=.*zsh-syntax-highlighting' "$current_shell_rc"; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' "$current_shell_rc"
  fi
}

clean_up
# Basic tools
check_packages curl git unzip ca-certificates
[ "$INSTALL_FZF" = "true" ] && install_fzf
[ "$INSTALL_ZOXIDE" = "true" ] && install_zoxide
[ "$INSTALL_EZA" = "true" ] && install_eza
[ "$INSTALL_STARSHIP" = "true" ] && install_starship
[ "$INSTALL_MISE" = "true" ] && install_mise
[ "$INSTALL_ZSH_PLUGINS" = "true" ] && load_zsh_plugins
clean_up
echo "Done!"
