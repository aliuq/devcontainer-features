#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) https://github.com/aliuq/devcontainer-features. All rights reserved.
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/aliuq/devcontainer-features/tree/main/src/common
# Maintainer: aliuq

set -e

# Parse feature options from environment variables
DEFAULT_SHELL="${DEFAULTSHELL:-}"
INSTALL_EZA="${INSTALLEZA:-"true"}"
INSTALL_FZF="${INSTALLFZF:-"true"}"
INSTALL_ZOXIDE="${INSTALLZOXIDE:-"true"}"
INSTALL_MISE="${INSTALLMISE:-"true"}"
MISE_PACKAGES="${MISEPACKAGES:-""}"
INSTALL_STARSHIP="${INSTALLSTARSHIP:-"false"}"
STARSHIP_URL="${STARSHIPURL:-""}"
INSTALL_HTTPIE="${INSTALLHTTPIE:-"false"}"
INSTALL_YAZI="${INSTALLYAZI:-"false"}"
YAZI_FLAVOR="${YAZIFLAVOR:-"dracula"}"
YAZI_FLAVOR_LIGHT="${YAZIFLAVORLIGHT:-"dracula"}"
ZSH_PLUGINS="${ZSHPLUGINS:-""}"
ZSH_CUSTOM_PLUGINS="${ZSHCUSTOMPLUGINS:-""}"
PROXY_URL="${PROXYURL:-""}"
BIN_DIR="${BIN_DIR:-"/usr/local/bin"}"

# Get the directory where this script is located
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
  echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" >/etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Load OS release information
. /etc/os-release

# Normalize distro ID for consistent package management
if [[ "${ID}" == "debian" || "${ID_LIKE}" == "debian" ]]; then
  ADJUSTED_ID="debian"
elif [[ "${ID}" == "alpine" ]]; then
  ADJUSTED_ID="alpine"
else
  echo "Linux distro ${ID} not supported."
  exit 1
fi

# Detect system architecture and normalize to common names
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

echo "Platform: ${ADJUSTED_ID} (${ID}), Arch: ${architecture}"

# Check if running in dev container context
if [[ -z "${_REMOTE_USER}" ]]; then
  echo 'Warning: Expected to run within dev container context'
fi

# Determine the target user and their home directory
if [[ "${_REMOTE_USER}" != "root" ]]; then
  if [[ -z "$(getent passwd "${_REMOTE_USER}")" ]]; then
    echo "Error: User \"${_REMOTE_USER}\" does not exist. Please install 'ghcr.io/devcontainers/features/common-utils' first."
    exit 1
  fi
  USERNAME="${_REMOTE_USER}"
  user_home="/home/${_REMOTE_USER}"
  group_name=$(id -gn "${_REMOTE_USER}")
else
  USERNAME="root"
  user_home="/root"
  group_name="root"
fi

echo "User: ${USERNAME}, Home: ${user_home}, Group: ${group_name}"

# Detect current shell and corresponding RC file
current_shell=${DEFAULT_SHELL:-$(basename "$SHELL")}
current_shell_rc=""
if [[ "$current_shell" == "bash" ]]; then
  current_shell_rc="${user_home}/.bashrc"
elif [[ "$current_shell" == "zsh" ]]; then
  current_shell_rc="${user_home}/.zshrc"
fi

shell_path=$(which "$current_shell" 2>/dev/null || echo "not found")
echo "Shell: ${current_shell} (${shell_path})"
[[ -n "$current_shell_rc" ]] && echo "Shell RC: ${current_shell_rc}" || echo "No shell RC file detected"

# Check if a command exists in PATH
command_exists() {
  type "$1" >/dev/null 2>&1
}

# Clean up package manager cache
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

# Update package manager cache if not already updated
pkg_mgr_update() {
  case $ADJUSTED_ID in
  debian)
    if [[ ! "$(ls -A /var/lib/apt/lists 2>/dev/null)" ]]; then
      echo "Updating apt cache..."
      apt-get update -y
    fi
    ;;
  alpine)
    if [[ ! "$(ls -A /var/cache/apk 2>/dev/null)" ]]; then
      echo "Updating apk cache..."
      apk update
    fi
    ;;
  esac
}

# Track if Alpine package cache has been updated
PKG_UPDATED="false"

# Install packages if not already present
check_packages() {
  if [[ "$ADJUSTED_ID" == "debian" ]]; then
    if ! dpkg -s "$@" >/dev/null 2>&1; then
      pkg_mgr_update
      apt-get -y install --no-install-recommends "$@"
    fi
  elif [[ "$ADJUSTED_ID" == "alpine" ]]; then
    if [[ "${PKG_UPDATED}" == "false" ]]; then
      pkg_mgr_update
      PKG_UPDATED="true"
    fi
    apk add --no-cache "$@"
  else
    echo "Unsupported Linux distribution: ${ADJUSTED_ID} (${ID})"
    exit 1
  fi
}

# Add or remove a plugin from the oh-my-zsh plugin list
# Usage: _add_omz_plugin <plugin_name> or _add_omz_plugin -<plugin_name> to remove
_add_omz_plugin() {
  local plugin_name="$1"
  # Remove leading/trailing whitespace
  plugin_name="$(echo "${plugin_name}" | xargs)"
  local is_delete="false"

  # Check if plugin name starts with '-', indicating removal operation
  if [[ "$plugin_name" == -* ]]; then
    is_delete="true"
    plugin_name="${plugin_name#-}"
  fi

  # Only proceed if oh-my-zsh is installed and shell RC file exists
  if [[ "$use_omz" == "true" && -n "$current_shell_rc" ]]; then
    # Handle plugin removal: check for exact match with word boundaries
    if [[ "$is_delete" == "true" ]]; then
      # Check if plugin exists in the list (with word boundaries to avoid partial matches)
      if grep -q "^plugins=(.*\b${plugin_name}\b.*)" "$current_shell_rc"; then
        # Remove the plugin from the plugins array
        # This handles: plugins=(plugin_name ...), plugins=(... plugin_name), and plugins=(... plugin_name ...)
        sed -i "/^plugins=(/s/\b${plugin_name}\b[[:space:]]*//g" "$current_shell_rc"
        # Clean up extra spaces: remove leading/trailing spaces and collapse multiple spaces
        sed -i '/^plugins=(/s/([[:space:]]\+/(/; s/[[:space:]]\+)/)/; s/[[:space:]]\{2,\}/ /g' "$current_shell_rc"
      fi
      return
    fi

    # Handle plugin addition: only add if not already present (check for word boundaries)
    if ! grep -q "^plugins=(.*\b${plugin_name}\b.*)" "$current_shell_rc"; then
      sed -i "s/^plugins=(\(.*\))/plugins=(\1 ${plugin_name})/" "$current_shell_rc"
    fi
  fi
}

# Add shell initialization command to RC file
_add_shell_config() {
  local shell_type="$1"
  local init_command="$2"
  local shell_rc="${3:-$current_shell_rc}"
  local check_omz="${4:-true}"

  # Skip if oh-my-zsh handles it via plugin
  if [[ "$use_omz" == "true" && "$check_omz" == "true" ]]; then
    return
  fi

  if [[ -n "$shell_rc" && "$shell_type" == "$current_shell" ]]; then
    if ! grep -qF "$init_command" "$shell_rc"; then
      echo "$init_command" >>"$shell_rc"
    fi
  fi
}

# Update binary ownership to match target user
_update_bin_user() {
  local bin_path="$1"
  if [[ -f "$bin_path" ]]; then
    local old_stat="$(stat -c '%u:%g' "$bin_path")"
    local expected_stat="$(id -u ${USERNAME}):$(id -g ${USERNAME})"
    if [[ "$old_stat" != "$expected_stat" ]]; then
      echo "Fixing ownership: $bin_path ($old_stat → $expected_stat)"
      chown ${USERNAME}:${group_name} "$bin_path"
    fi
  fi
}

#
# -----------------------------------------------------
# Main installation logic
# -----------------------------------------------------
#

if [[ "$ADJUSTED_ID" == "debian" ]]; then
  # Ensure apt is in non-interactive mode to avoid prompts
  export DEBIAN_FRONTEND=noninteractive
fi

# Detect if oh-my-zsh is installed
use_omz="false"
if [[ "$current_shell" == "zsh" && -n "$current_shell_rc" ]] && grep -q 'source $ZSH/oh-my-zsh.sh' "$current_shell_rc"; then
  use_omz="true"
fi

# Install fzf (fuzzy finder)
# https://junegunn.github.io/fzf/installation/
install_fzf() {
  if command_exists fzf; then
    echo "✓ fzf already installed"
  else
    echo "Installing fzf..."

    git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf
    /tmp/fzf/install --bin --no-key-bindings --no-completion --no-update-rc
    cp /tmp/fzf/bin/fzf "$BIN_DIR/fzf"
    rm -rf /tmp/fzf
  fi

  # Set up shell integration
  _add_omz_plugin fzf
  _add_shell_config bash 'eval "$(fzf --bash)"'
  _add_shell_config zsh 'source <(fzf --zsh)'
}

# Install zoxide (smarter cd command)
# https://github.com/ajeetdsouza/zoxide/?tab=readme-ov-file#installation
install_zoxide() {
  if command_exists zoxide; then
    echo "✓ zoxide already installed"
  else
    echo "Installing zoxide..."

    # Download install script to local file
    local install_script="/tmp/zoxide-install.sh"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh -o "$install_script"

    # Apply proxy configuration if specified
    if [[ -n "$PROXY_URL" ]]; then
      # Remove trailing slash from PROXY_URL if present
      local proxy="${PROXY_URL%/}"
      echo "→ Using proxy: ${proxy}"
      sed -i "s|https://api.github.com|${proxy}/https://api.github.com|g" "$install_script"
    fi

    # Execute the modified script
    sh "$install_script" --bin-dir="$BIN_DIR"
    rm -f "$install_script"
  fi

  # Set up shell integration
  _add_omz_plugin zoxide
  _add_shell_config bash 'eval "$(zoxide init bash)"'
  _add_shell_config zsh 'eval "$(zoxide init zsh)"'
}

# Install eza (modern replacement for ls)
# https://github.com/eza-community/eza/blob/main/INSTALL.md
install_eza() {
  if command_exists eza; then
    echo "✓ eza already installed"
  else
    echo "Installing eza..."

    if [[ "$ADJUSTED_ID" == "debian" ]]; then
      check_packages gnupg2 wget
      # Use official Debian/Ubuntu repository
      mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | tee /etc/apt/sources.list.d/gierens.list
      chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      apt-get update && apt-get install -y --no-install-recommends eza
    elif [[ "$ADJUSTED_ID" == "alpine" ]]; then
      apk add --no-cache eza
    else
      echo "Linux distro ${ID} not supported for eza installation."
      exit 1
    fi
  fi

  # Set up shell integration
  _add_omz_plugin eza
}

# Install mise package
_mise_install_pkg() {
  # ref: https://mise.jdx.dev/configuration.html#global-config-config-mise-config-toml
  mise use -g -y -p "${MISE_SYSTEM_DIR:-"/etc/mise"}/config.toml" "$@"
}

# Install mise (polyglot tool version manager)
# https://mise.jdx.dev/getting-started.html
install_mise() {
  if command_exists mise; then
    echo "✓ mise already installed"
  else
    echo "Installing mise..."

    export MISE_INSTALL_PATH="${BIN_DIR}/mise"
    curl -fsSL https://mise.run | sh
  fi

  # Set up shell integration
  _add_omz_plugin mise

  # Configure mise activation for bash and zsh
  # ref: https://mise.jdx.dev/dev-tools/shims.html#how-to-add-mise-shims-to-path

  # 1. bash
  if [[ -f "${user_home}/.bashrc" ]] && ! grep -qF 'eval "$(mise activate bash)"' "${user_home}/.bashrc"; then
    echo 'eval "$(mise activate bash)"' >>"${user_home}/.bashrc"
  fi
  if [[ -f "${user_home}/.bash_profile" ]]; then
    if ! grep -qF 'eval "$(mise activate bash --shims)"' "${user_home}/.bash_profile"; then
      echo 'eval "$(mise activate bash --shims)"' >>"${user_home}/.bash_profile"
    fi
  elif [[ -f "${user_home}/.profile" ]]; then
    if ! grep -qF 'eval "$(mise activate bash --shims)"' "${user_home}/.profile"; then
      echo 'eval "$(mise activate bash --shims)"' >>"${user_home}/.profile"
    fi
  fi

  # 2. zsh
  if [[ "$use_omz" != "true" && -f "${user_home}/.zshrc" ]] && ! grep -qF 'eval "$(mise activate zsh)"' "${user_home}/.zshrc"; then
    echo 'eval "$(mise activate zsh)"' >>"${user_home}/.zshrc"
  fi
  if [[ -f "${user_home}/.zprofile" ]]; then
    if ! grep -qF 'eval "$(mise activate zsh --shims)"' "${user_home}/.zprofile"; then
      echo 'eval "$(mise activate zsh --shims)"' >>"${user_home}/.zprofile"
    fi
  fi

  local mise_pkg_installed=""

  # Install usage CLI (required for mise)
  # https://usage.jdx.dev
  if mise which usage >/dev/null 2>&1; then
    echo "✓ mise 'usage' package already installed"
  else
    echo "→ Installing mise package: usage"
    _mise_install_pkg usage
    mise_pkg_installed="true"
  fi

  # Install additional mise packages if specified
  if [[ -n "${MISE_PACKAGES}" ]]; then
    # Normalize format: support space or comma-separated lists
    MISE_PACKAGES="$(echo "${MISE_PACKAGES}" | tr ',' ' ' | xargs)"
    echo "→ Installing mise packages: ${MISE_PACKAGES}"
    _mise_install_pkg ${MISE_PACKAGES}
    mise_pkg_installed="true"
  fi

  # Clean mise cache to reduce image size
  if [[ "$mise_pkg_installed" == "true" ]]; then
    echo "→ Cleaning mise cache"
    mise cache clear
  fi

  # Ensure non-root user can access mise data directory
  if [[ "${USERNAME}" != "root" ]]; then
    sudo chown -R ${USERNAME}:${group_name} "${MISE_DATA_DIR:-"/usr/local/share/mise"}"
  fi

  # Set up shell completions for mise
  # ref: https://mise.jdx.dev/installing-mise.html#autocompletion
  if [[ "$use_omz" != "true" ]]; then
    if [[ $current_shell == "zsh" ]]; then
      mkdir -p /usr/local/share/zsh/site-functions
      mise completion zsh >/usr/local/share/zsh/site-functions/_mise
    elif [[ $current_shell == "bash" ]]; then
      mkdir -p ${user_home}/.local/share/bash-completion/completions
      mise completion bash --include-bash-completion-lib >${user_home}/.local/share/bash-completion/completions/mise
    fi
  fi
}

# Install starship prompt
# https://starship.rs/guide/
install_starship() {
  if command_exists starship; then
    echo "✓ starship already installed"
  else
    echo "Installing starship..."

    curl -fsSL https://starship.rs/install.sh | sh -s -- -y --bin-dir="$BIN_DIR"
  fi

  # Set up shell integration
  _add_omz_plugin starship
  _add_shell_config bash 'eval "$(starship init bash)"'
  _add_shell_config zsh 'eval "$(starship init zsh)"'

  # Set up starship configuration
  local conf="${user_home}/.config/starship.toml"
  if [[ ! -f "$conf" ]]; then
    mkdir -p "${user_home}/.config"
    if [[ -n "$STARSHIP_URL" ]]; then
      echo "→ Downloading config: $STARSHIP_URL"
      if ! curl -fsSL "$STARSHIP_URL" -o "$conf"; then
        echo "Warning: Download failed, using default config"
        cp -f "${FEATURE_DIR}/scripts/starship.toml" "$conf"
      fi
    else
      echo "→ Using default config"
      cp -f "${FEATURE_DIR}/scripts/starship.toml" "$conf"
    fi
  fi
}

# Install essential zsh plugins
install_zsh_plugins() {
  if [[ "$use_omz" != "true" ]]; then
    echo "⊘ oh-my-zsh not detected, skipping plugins"
    return
  fi

  # Custom plugin
  local custom_plugins_dir="${ZSH_CUSTOM:-${user_home}/.oh-my-zsh/custom}/plugins"
  local custom_plugins="zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting"
  if [[ -n "${ZSH_CUSTOM_PLUGINS}" ]]; then
    custom_plugins="${custom_plugins} ${ZSH_CUSTOM_PLUGINS}"
  fi
  local custom_plugins_list="$(echo "${custom_plugins}" | tr ',' ' ' | xargs)"
  for plugin_repo in ${custom_plugins_list}; do
    # Remove leading/trailing whitespace
    plugin_repo="$(echo "${plugin_repo}" | xargs)"

    # Skip empty values
    [[ -z "$plugin_repo" ]] && continue

    # Add GitHub URL prefix if not starting with http(s)://
    if [[ "$plugin_repo" != http*://* ]]; then
      plugin_repo="https://github.com/${plugin_repo}"
    fi
    local plugin_name="${plugin_repo##*/}"
    local plugin_dir="${custom_plugins_dir}/${plugin_name}"

    if [[ ! -d "$plugin_dir" ]]; then
      echo "→ Installing zsh plugin: ${plugin_name}"
      git clone --depth=1 "${plugin_repo}" "${plugin_dir}"
      _add_omz_plugin "${plugin_name}"
    else
      echo "✓ zsh plugin '${plugin_name}' already installed"
    fi
  done

  # Internal plugins
  if [[ -n "${ZSH_PLUGINS}" ]]; then
    local internal_plugins_list="$(echo "${ZSH_PLUGINS}" | tr ',' ' ' | xargs)"
    echo "→ Enabling omz plugins: ${internal_plugins_list}"
    for plugin in ${internal_plugins_list}; do
      [[ -z "$plugin" ]] && continue
      _add_omz_plugin "${plugin}"
    done
  fi
}

# Install HTTPie (user-friendly HTTP client)
# https://httpie.io/docs/cli/installation
install_httpie() {
  if command_exists http; then
    echo "✓ httpie already installed"
  else
    echo "Installing httpie..."

    if [[ "$ADJUSTED_ID" == "debian" ]]; then
      check_packages gnupg2
      # Use official Debian/Ubuntu repository
      curl -SsL https://packages.httpie.io/deb/KEY.gpg | gpg --dearmor -o /usr/share/keyrings/httpie.gpg
      echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | tee /etc/apt/sources.list.d/httpie.list >/dev/null
      apt-get update && apt-get install -y --no-install-recommends httpie
    elif [[ "$ADJUSTED_ID" == "alpine" ]]; then
      apk add --no-cache httpie
    else
      echo "Linux distro ${ID} not supported for httpie installation."
      exit 1
    fi
  fi

  # Set up shell integration
  _add_omz_plugin httpie
}

# Add a yazi flavor package if not already installed
_add_yazi_flavor() {
  local repo="$1"         # yazi-rs/flavors:dracula or dracula or user/repo
  local type="${2:-dark}" # dark or light, defaults to dark if not specified
  local yazi_dir="${3:-$HOME/.config/yazi}"
  local name=""
  local theme_file="${yazi_dir}/theme.toml"

  # Remove leading/trailing whitespace
  repo="$(echo "${repo}" | xargs)"

  if [[ -z "$repo" ]]; then
    echo "No flavor repository specified."
    return
  fi

  # If repo doesn't contain a slash, it's a short form (just flavor name)
  # Expand it to yazi-rs/flavors:name
  if [[ "$repo" != *"/"* ]]; then
    # dracula
    repo="yazi-rs/flavors:${repo}"
    name="${repo##*:}"
  elif [[ "$repo" == *":"* ]]; then
    # yazi-rs/flavors:dracula
    name="${repo##*:}"
  else
    # user/repo
    name="${repo##*/}"
  fi

  echo "→ Configuring yazi ${type} flavor: ${name}"

  # Install flavor package if not already installed
  if ! ya pkg list 2>/dev/null | grep -q "${repo}"; then
    echo "  Installing flavor: ${repo}"
    ya pkg add "${repo}"
  else
    echo "  ✓ Flavor already installed"
  fi

  mkdir -p "$yazi_dir"
  touch "$theme_file"
  # Update flavor configuration in theme.toml using dasel@2.8.1
  dasel put -f "$theme_file" -r toml -t string --indent 0 -v "${name}" "flavor.${type}"

  echo "  ✓ Configured ${type} flavor: ${name}"
}

# Install yazi (terminal file manager)
# https://yazi-rs.github.io
install_yazi() {
  if command_exists yazi; then
    echo "✓ yazi already installed"
    return
  fi

  if ! command_exists mise; then
    echo "⊘ yazi requires mise, please enable 'installMise' option"
    return
  fi

  echo "Installing yazi..."
  check_packages file
  # Install yazi via mise
  _mise_install_pkg yazi@latest
}

# Configure yazi flavors
configure_yazi_flavors() {
  # Skip flavor installation if not specified
  if [[ -z "${YAZI_FLAVOR}" && -z "${YAZI_FLAVOR_LIGHT}" ]]; then
    return
  fi

  if ! command_exists yazi; then
    echo "Warning: yazi not installed, skipping flavor configuration"
    return
  fi

  # Temporarily activate mise to access yazi and dasel
  eval "$(mise activate --shims)"

  local old_home="$HOME"

  # Set HOME to target user for package installation
  if [[ "${USERNAME}" != "root" ]]; then
    export HOME="${user_home}"
  fi

  # Install dasel for TOML manipulation (only once)
  _mise_install_pkg dasel@2.8.1

  # Install flavors (dark and light)
  [[ -n "${YAZI_FLAVOR}" ]] && _add_yazi_flavor "${YAZI_FLAVOR}"
  [[ -n "${YAZI_FLAVOR_LIGHT}" ]] && _add_yazi_flavor "${YAZI_FLAVOR_LIGHT}" "light"

  # Uninstall dasel to reduce image size
  mise uninstall -y dasel@2.8.1 2>/dev/null || true
  # Clean up mise cache once at the end
  mise cache clear
  # Clean ya pkg cache
  if [[ -d "${user_home}/.local/state/yazi/packages" ]]; then
    rm -rf "${user_home}/.local/state/yazi/packages"/*
  fi

  # Restore HOME
  if [[ "${USERNAME}" != "root" ]]; then
    export HOME="${old_home}"
  fi
}

#
# -----------------------------------------------------
# Execute installations based on feature options
# -----------------------------------------------------
#

# Install essential packages first
check_packages curl git unzip ca-certificates

# Install tools in dependency order
[[ "$INSTALL_FZF" == "true" ]] && install_fzf
[[ "$INSTALL_ZOXIDE" == "true" ]] && install_zoxide
[[ "$INSTALL_EZA" == "true" ]] && install_eza
[[ "$INSTALL_STARSHIP" == "true" ]] && install_starship
[[ "$INSTALL_HTTPIE" == "true" ]] && install_httpie
# Install mise before yazi since yazi depends on mise
[[ "$INSTALL_MISE" == "true" ]] && install_mise
[[ "$INSTALL_YAZI" == "true" ]] && install_yazi
# Configure yazi flavors after yazi installation
[[ "$INSTALL_YAZI" == "true" ]] && configure_yazi_flavors
# Install zsh plugins at the end
install_zsh_plugins

# Fix ownership of user home directory
if [[ "${USERNAME}" != "root" ]]; then
  sudo chown -R ${USERNAME}:${group_name} "$user_home"
fi

# Clean up package manager cache to reduce image size
clean_up

echo "Done"
