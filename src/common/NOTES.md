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
