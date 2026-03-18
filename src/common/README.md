
# Common Development Tools (common)

Install and configure common development tools including eza, fzf, zoxide, mise, starship, yazi, and zsh plugins

## Example Usage

```json
"features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| defaultShell | Default shell to configure (bash or zsh) | string | zsh |
| installEza | Install eza (modern ls replacement) | boolean | true |
| installFzf | Install fzf (fuzzy finder) | boolean | true |
| installZoxide | Install zoxide (smart cd) | boolean | true |
| installMise | Install mise (tool version manager) | boolean | true |
| misePackages | Mise packages to install globally (comma-separated, e.g., 'node@lts,bun,pnpm') | string | - |
| installStarship | Install starship prompt | boolean | false |
| starshipUrl | Custom starship.toml URL | string | - |
| zshPlugins | Oh-my-zsh plugins (comma-separated, e.g., 'git,docker,kubectl') | string | - |
| zshCustomPlugins | Custom zsh plugins (comma-separated GitHub repos, e.g., 'user/repo1,user/repo2') | string | - |
| proxyUrl | Proxy server URL (e.g., https://proxy.example.com:8080) | string | - |
| installHttpie | Install HTTPie (HTTP client) | boolean | false |
| installYazi | Install Yazi (terminal file manager) | boolean | false |
| yaziFlavor | Yazi dark theme (e.g., dracula, user/repo, user/repo:theme-name) | string | dracula |
| yaziFlavorLight | Yazi light theme (e.g., dracula, user/repo, user/repo:theme-name) | string | dracula |
| pnpmCompletion | Enable pnpm shell completion (ref: https://pnpm.io/zh/completion) | boolean | false |

## QA

### How to get GitHub API Token?

GitHub Personal Access Token (PAT) can be created from [hhttps://github.com/settings/tokens/newe](https://github.com/settings/tokens/new?description=MISE_GITHUB_TOKEN), read the instructions in [mise documentation](https://mise.jdx.dev/troubleshooting.html#_403-forbidden-when-installing-a-tool) for details.

### Get GitHub API 403 Rate Limiting when devcontainer setuping?

Set `MISE_GITHUB_TOKEN` on your machine to a GitHub Personal Access Token to avoid rate limiting when installing mise-managed packages.

```json
// .devcontainer/devcontainer.json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {
      "MISE_GITHUB_TOKEN": "${localEnv:MISE_GITHUB_TOKEN}"
    }
  }
}
```

### Get GitHub API 403 Rate Limiting when mise installing packages on devcontainer?

Set `MISE_GITHUB_TOKEN` on your machine to a GitHub Personal Access Token to avoid rate limiting when installing mise-managed packages.

```json
// .devcontainer/devcontainer.json
{
  "containerEnv": {
    "MISE_GITHUB_TOKEN": "${localEnv:MISE_GITHUB_TOKEN}"
  }
}
```

### Get mise trust prompt when devcontainer setuping

Set `MISE_TRUSTED_CONFIG_PATHS` to the path of your devcontainer workspace to avoid trust prompt when setting up the devcontainer.

```json
// .devcontainer/devcontainer.json
{
  "containerEnv": {
    "MISE_TRUSTED_CONFIG_PATHS": "${containerWorkspaceFolder:-.}"
  }
}
```


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/aliuq/devcontainer-features/blob/main/src/common/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
