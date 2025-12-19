
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

## 功能特性

Common feature 支持按需安装以下工具

- [`mise`](https://github.com/jdx/mise): 开发工具、环境变量、任务运行器
  - 多语言工具版本管理器，可替代 asdf、nvm、pyenv、rbenv 等工具
  - 支持在不同项目目录中切换环境变量集合，可替代 direnv
  - 内置任务运行器，可替代 make 或 npm scripts

  ```bash
  # 全局安装多个工具的最新版本
  mise use node@lts yarn@1 pnpm@latest bun@latest -g
  ```

  > 💡 最实用的开发工具之一，但可能触发 GitHub API 速率限制，详见[常见问题](#常见问题)

  可以通过 `misePackages` 选项全局安装常用的开发工具包，例如：

  ```json
  "misePackages": "node@lts,bun,pnpm,yarn@1,uv@latest"
  ```

- [`eza`](https://github.com/eza-community/eza): 现代化的 `ls` 命令替代品，提供更美观的输出格式和颜色支持

  ```bash
  # 显示当前目录的树状结构（最多 2 层），忽略 node_modules、spec 和 .git 目录
  eza --tree -a --level 2 --ignore-glob "node_modules|spec|.git"
  ```

  > 💡 已自动配置别名，使用 `ls`、`ll`、`la` 等命令时会自动调用 eza

- [`fzf`](https://github.com/junegunn/fzf): 强大的命令行模糊查找工具

  ```bash
  # 在命令历史中进行模糊搜索（带边框、反向布局）
  history | fzf --height 40% --layout=reverse --border
  ```

  > 💡 快捷键：`Ctrl+R` 搜索历史命令，`Ctrl+T` 模糊查找文件，`Alt+C` 切换目录

- [`zoxide`](https://github.com/ajeetdsouza/zoxide): 智能目录跳转工具，自动记住常用目录

  ```bash
  z ..    # 返回上一级目录
  z -     # 进入上次访问的目录
  zi      # 交互式选择目录
  zi app  # 交互式选择包含 app 的目录
  ```

  > 💡 使用 `z` 命令可快速跳转到最近访问的目录，支持模糊匹配

- [`starship`](https://github.com/starship/starship): 轻量、快速、可定制的跨平台终端提示符

  ```bash
  # 启用自动补全功能（可选，配置 starship 后很少需要）
  echo 'eval "$(starship completions zsh)"' >> ~/.zshrc
  ```

  > 💡 支持多终端、跨平台，可通过 `starshipUrl` 选项自定义配置文件

- `zsh plugins` (需要安装 [Oh-My-Zsh](https://github.com/ohmyzsh/ohmyzsh)):
  - `zsh-autosuggestions`: 基于历史记录的命令自动建议
  - `zsh-syntax-highlighting`: 实时命令语法高亮
  
  默认安装以上两个增强插件，也可通过 `zshPlugins` 或 `zshCustomPlugins` 选项添加更多插件

  ```bash
  # 查看已启用的插件
  omz plugin list --enabled
  # 启用更多插件（如 docker、kubectl）
  omz plugin enable docker kubectl
  ```

- [`httpie`](https://github.com/httpie/cli): 现代化的命令行 HTTP 客户端，简化 API 测试和交互

  ```bash
  # 发送 GET 请求
  http GET https://api.github.com/repos/aliuq/devcontainer-features
  # 发送 POST 表单请求
  http -f POST pie.dev/post hello=World
  ```

  > 💡 查看[更多示例](https://httpie.io/docs/cli/examples)

- [`yazi`](https://github.com/sxyazi/yazi): 基于异步 I/O 的极速终端文件管理器（Rust 编写）

  ```bash
  # 启动 yazi 文件管理器
  yazi
  ```

  > 💡 默认使用 [dracula](https://github.com/yazi-rs/flavors/tree/main/dracula.yazi) 主题，可通过 `yaziFlavor`（深色）和 `yaziFlavorLight`（浅色）选项自定义主题

- [`pnpm` shell completion](https://pnpm.io/zh/completion): pnpm 命令自动补全

  > 💡 在 monorepo 项目中使用自动补全可大幅提升开发效率

## 常见问题

### 1. 如何解决 GitHub API 403 限流问题？

**问题**：安装 mise 或其他工具时遇到 GitHub API 请求速率限制

**解决方案**：

1. 访问 [GitHub Personal Access Token](https://github.com/settings/tokens/new?description=MISE_GITHUB_TOKEN) 创建访问令牌
2. 无需勾选任何权限范围（public access 即可）
3. 在 devcontainer 配置中添加环境变量：

```json
"ghcr.io/aliuq/devcontainer-features/common:0": {
  "MISE_GITHUB_TOKEN": "<your_github_token>"
}
```

**参考文档**：[mise GitHub API Rate Limiting](https://mise.jdx.dev/getting-started.html#github-api-rate-limiting)

### 2. 如何信任工作区目录以使用 mise？

**问题**：mise 需要明确信任项目目录才能自动加载 `.mise.toml` 配置文件

**解决方案**：

在 `.devcontainer/devcontainer.json` 中添加环境变量配置：

```json
"containerEnv": {
  "MISE_TRUSTED_CONFIG_PATHS": "${containerWorkspaceFolder}"
}
```

这会将当前工作区目录添加到 mise 的可信路径列表中


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/aliuq/devcontainer-features/blob/main/src/common/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
