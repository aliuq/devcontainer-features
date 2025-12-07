# DevContainer Features

[![Version](https://img.shields.io/badge/dynamic/json?url=https://raw.githubusercontent.com/aliuq/devcontainer-features/refs/heads/main/src/common/devcontainer-feature.json&query=$.version&label=version)](https://github.com/aliuq/devcontainer-features)
[![Static Badge](https://img.shields.io/badge/github-aliuq/devcontainer--images-blue?logo=github&color=blue)](https://github.com/aliuq/devcontainer-images)

一个用于 DevContainer 的常用开发工具集合，旨在提升开发体验和效率

## 功能特性

### Common Development Tools

提供一整套现代化的开发工具，可按需安装和配置：

| 工具 | 描述 | 默认安装 |
|------|------|----------|
| [**eza**](https://github.com/eza-community/eza) | 现代化的 `ls` 命令替代品，支持树状视图和 Git 集成 | ✅ |
| [**fzf**](https://github.com/junegunn/fzf) | 强大的命令行模糊查找工具 | ✅ |
| [**zoxide**](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转工具，自动记忆常用目录 | ✅ |
| [**mise**](https://github.com/jdx/mise) | 多语言工具版本管理器，可替代 nvm、pyenv 等 | ✅ |
| [**starship**](https://github.com/starship/starship) | 快速可定制的跨平台终端提示符 | ⬜ |
| [**httpie**](https://github.com/httpie/cli) | 现代化的命令行 HTTP 客户端 | ⬜ |
| [**yazi**](https://github.com/sxyazi/yazi) | 极速终端文件管理器 | ⬜ |
| **zsh plugins** | Oh-My-Zsh 插件（自动补全、语法高亮等） | ✅ |

## 快速开始

在你的 `.devcontainer/devcontainer.json` 中添加：

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {}
  }
}
```

### 常用配置示例

#### 最小配置（使用默认值）

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {}
  }
}
```

#### 完整配置示例

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {
      "defaultShell": "zsh",
      "installEza": true,
      "installFzf": true,
      "installZoxide": true,
      "installMise": true,
      "misePackages": "node@lts,bun,pnpm,yarn@1",
      "installStarship": true,
      "starshipUrl": "https://example.com/starship.toml",
      "installHttpie": true,
      "installYazi": true,
      "yaziFlavor": "catppuccin-mocha",
      "yaziFlavorLight": "catppuccin-latte",
      "zshPlugins": "docker,kubectl",
      "zshCustomPlugins": "",
      "pnpmCompletion": true,
      "proxyUrl": ""
    }
  },
  "containerEnv": {
    "MISE_TRUSTED_CONFIG_PATHS": "${containerWorkspaceFolder}"
  }
}
```

## 配置选项

| 选项 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `defaultShell` | string | `zsh` | 默认 shell（bash 或 zsh） |
| `installEza` | boolean | `true` | 安装 eza |
| `installFzf` | boolean | `true` | 安装 fzf |
| `installZoxide` | boolean | `true` | 安装 zoxide |
| `installMise` | boolean | `true` | 安装 mise |
| `misePackages` | string | `""` | mise 全局安装的包（逗号分隔） |
| `installStarship` | boolean | `false` | 安装 starship |
| `starshipUrl` | string | `""` | 自定义 starship.toml 配置文件 URL |
| `installHttpie` | boolean | `false` | 安装 HTTPie |
| `installYazi` | boolean | `false` | 安装 Yazi |
| `yaziFlavor` | string | `dracula` | Yazi 深色主题 |
| `yaziFlavorLight` | string | `dracula` | Yazi 浅色主题 |
| `zshPlugins` | string | `""` | Oh-my-zsh 插件（逗号分隔） |
| `zshCustomPlugins` | string | `""` | 自定义 zsh 插件（GitHub 仓库，逗号分隔） |
| `pnpmCompletion` | boolean | `false` | 启用 pnpm shell 自动补全 |
| `proxyUrl` | string | `""` | 代理服务器 URL |

完整的配置选项和使用说明请查看 [Common Feature 详细文档](./src/common/README.md)。

## 文档

- [Common Feature 详细文档](./src/common/README.md) - 功能特性、使用示例和常见问题
- [开发指南](./DEVELOPMENT.md) - 本地开发和测试指南

## 相关链接

- [DevContainer Features 规范](https://containers.dev/implementors/features/)
- [DevContainer 文档](https://containers.dev/)
- [GitHub Container Registry](https://ghcr.io)
