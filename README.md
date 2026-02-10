# DevContainer Features

[![Version](https://shields.xod.cc/badge/dynamic/json?url=https://raw.githubusercontent.com/aliuq/devcontainer-features/refs/heads/main/src/common/devcontainer-feature.json&query=$.version&label=version)](https://github.com/aliuq/devcontainer-features)
[![CI](https://shields.xod.cc/github/actions/workflow/status/aliuq/devcontainer-features/test.yaml?label=CI%20Test)](./.github/workflows/test.yaml)
[![images](https://shields.xod.cc/badge/devcontainer--images-blue?logo=github)](https://github.com/aliuq/devcontainer-images)

A lightweight collection of useful CLI tools and shell integrations for DevContainers. Designed to improve the developer experience in containerized environments.

## Included tools (defaults)

- [**eza**](https://github.com/eza-community/eza) — modern `ls` replacement with Git support (default)
- [**fzf**](https://github.com/junegunn/fzf) — command-line fuzzy finder (default)
- [**zoxide**](https://github.com/ajeetdsouza/zoxide) — smart directory jumper (default)
- [**mise**](https://github.com/jdx/mise) — multi-language tool manager (default)
- [**starship**](https://github.com/starship/starship) — customizable prompt (optional)
- [**httpie**](https://github.com/httpie/cli) — user-friendly HTTP client (optional)
- [**yazi**](https://github.com/sxyazi/yazi) — terminal file manager (optional)
- [**zsh plugins**](https://github.com/ohmyzsh/ohmyzsh) — common Oh‑My‑Zsh plugins (default)
- [**pnpm completion**](https://github.com/g-plane/pnpm-shell-completion) — shell completion for pnpm (optional)

## Quick start

Add the feature to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {}
  }
}
```

For full configuration options, see [`src/common/README.md`](src/common/README.md).

## Configuration highlights

- `defaultShell` (string, default: `zsh`) — choose `bash` or `zsh`
- `installEza`, `installFzf`, `installZoxide`, `installMise` (boolean) — enable core tools
- `misePackages` (string) — comma-separated packages for `mise`
- `installStarship`, `installHttpie`, `installYazi` (boolean) — enable optional tools
- `zshPlugins`, `zshCustomPlugins` (string) — comma-separated plugins

## References

- [Devcontainer Features](https://github.com/devcontainers/features)
- [Devcontainer Images](https://github.com/devcontainers/images)
- [Devcontainer Documentation](https://containers.dev/)
- [Devcontainer Cli](https://github.com/devcontainers/cli)
- [Mise Documentation](https://mise.jdx.dev/getting-started.html)
