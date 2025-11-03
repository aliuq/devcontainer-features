
# Common Development Tools (common)

Install and configure common development tools including eza, fzf, zoxide, mise, Monaspace Nerd Font, starship, and zsh plugins

## Example Usage

```json
"features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| defaultShell | Set the default shell (bash or zsh) | string | zsh |
| installEza | Install eza (modern replacement for ls) | boolean | true |
| installFzf | Install fzf (fuzzy finder) | boolean | true |
| installZoxide | Install zoxide (smarter cd command) | boolean | true |
| installMise | Install mise (polyglot tool version manager) | boolean | true |
| installStarship | Install starship prompt | boolean | true |
| starshipConfigUrl | URL to a starship.toml configuration file to download and use | string | - |
| installZshPlugins | Install zsh-autosuggestions and zsh-syntax-highlighting | boolean | true |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/aliuq/devcontainer-features/blob/main/src/common/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
