# DevContainer Features

一个用于 DevContainer 的常用开发工具集合。

## 📦 功能特性

### Common Development Tools

安装和配置常用开发工具，包括：

- **eza** - 现代化的 `ls` 命令替代品
- **fzf** - 命令行模糊查找工具
- **zoxide** - 智能 `cd` 命令，记住常用目录
- **mise** - 多语言工具版本管理器
- **starship** - 快速可定制的 shell 提示符
- **zsh plugins** - 命令自动提示和语法高亮

## 🚀 快速开始

在你的 `.devcontainer/devcontainer.json` 中添加：

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {}
  }
}
```

## ⚙️ 配置选项

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {
      "defaultShell": "zsh",
      "installEza": true,
      "installFzf": true,
      "installZoxide": true,
      "installMise": true,
      "installStarship": false,
      "starshipConfigUrl": "",
      "installZshPlugins": true,
      "proxyUrl": "",
      "misePackages": "node@lts pnpm"
    }
  }
}
```

## 📖 文档

详细文档请查看：[src/common/README.md](./src/common/README.md)

## 🧪 测试

```bash
# 运行测试
./start.sh --help
```
