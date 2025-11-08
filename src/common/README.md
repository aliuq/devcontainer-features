
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
| installStarship | Install starship prompt | boolean | false |
| starshipConfigUrl | URL to a starship.toml configuration file to download and use | string | - |
| installZshPlugins | Install zsh-autosuggestions and zsh-syntax-highlighting | boolean | true |
| proxyUrl | URL of the proxy server to use for downloading resources (e.g., https://proxy.example.com:8080/), ends with a slash '/' | string | - |
| misePackages | Comma-separated list of mise packages to install globally (e.g., 'node@lts bun yarn@1 pnpm') | string | - |

## 功能特性

这个 feature 会自动安装和配置以下工具：

- **eza**: 现代化的 `ls` 命令替代品，具有更好的输出格式和颜色支持
- **fzf**: 强大的命令行模糊查找工具
- **zoxide**: 智能的 `cd` 命令，可以记住常用目录
- **mise**: 多语言工具版本管理器（替代 asdf）
- **starship**: 快速、可定制的跨平台 shell 提示符
- **zsh plugins** (仅在使用 Oh-My-Zsh 时): 
  - `zsh-autosuggestions`: 根据历史记录自动提示命令
  - `zsh-syntax-highlighting`: 命令语法高亮

### 平台支持矩阵

| 工具 | Debian/Ubuntu | Alpine Linux |
|-----|--------------|--------------|
| eza | ✅ 官方仓库 | ✅ 官方仓库 |
| fzf | ✅ 源码编译 | ✅ 官方仓库 |
| zoxide | ✅ 安装脚本 | ✅ 安装脚本 |
| mise | ✅ 安装脚本 | ✅ 安装脚本 |
| starship | ✅ 安装脚本 | ✅ 安装脚本 |
| zsh plugins | ✅ Git 克隆 | ✅ Git 克隆 |

## 使用方法

在你的 `devcontainer.json` 中添加：

```json
{
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "installOhMyZsh": true
    },
    "ghcr.io/aliuq/devcontainer-features/common:0": {}
  }
}
```

**推荐配置**: 这个 feature 建议与 `ghcr.io/devcontainers/features/common-utils` 一起使用来设置 zsh 和 Oh-My-Zsh，这样可以获得更好的 shell 集成体验。如果检测到 Oh-My-Zsh，工具将通过 Oh-My-Zsh 插件系统进行集成。

### 支持的 Shell

- **bash**: 支持基本的工具集成
- **zsh**: 完整支持，包括 Oh-My-Zsh 插件集成（如果已安装）

## 配置选项

所有工具默认都会安装，你可以通过选项来禁用某些工具或自定义配置：

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {
      "defaultShell": "zsh",
      "installEza": true,
      "installFzf": true,
      "installZoxide": true,
      "installMise": true,
      "installStarship": true,
      "starshipConfigUrl": "",
      "installZshPlugins": true
    }
  }
}
```

### 选项说明

| 选项 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `defaultShell` | string | `"zsh"` | 设置默认 shell（bash 或 zsh） |
| `installEza` | boolean | `true` | 安装 eza (ls 替代品) |
| `installFzf` | boolean | `true` | 安装 fzf (模糊查找) |
| `installZoxide` | boolean | `true` | 安装 zoxide (智能 cd) |
| `installMise` | boolean | `true` | 安装 mise (工具版本管理) |
| `installStarship` | boolean | `false` | 安装 starship 提示符 |
| `starshipConfigUrl` | string | `""` | 自定义 starship 配置文件的 URL（留空使用默认配置） |
| `installZshPlugins` | boolean | `true` | 安装 zsh 插件（仅在 Oh-My-Zsh 存在时生效） |

## Shell 集成

### Oh-My-Zsh 集成

如果检测到 Oh-My-Zsh（通过在 `.zshrc` 中查找 `source $ZSH/oh-my-zsh.sh`），工具将自动通过 Oh-My-Zsh 插件系统进行集成，会自动启用以下插件：

- `fzf` - 模糊查找集成
- `zoxide` - 智能目录跳转
- `eza` - ls 命令别名
- `mise` - 工具版本管理
- `starship` - Shell 提示符
- `zsh-autosuggestions` - 命令自动建议
- `zsh-syntax-highlighting` - 语法高亮

### Bash/Zsh 直接集成

如果没有 Oh-My-Zsh，工具将直接在 `.bashrc` 或 `.zshrc` 中添加初始化代码：

- fzf 的快捷键绑定和自动补全
- zoxide 初始化 (使用 `z` 命令跳转目录)
- mise 自动激活
- starship 提示符初始化

### eza 别名（仅 Oh-My-Zsh）

当使用 Oh-My-Zsh 的 eza 插件时，会自动配置以下别名：

```bash
ls   -> eza
ll   -> eza -l
la   -> eza -la
lt   -> eza --tree
```

## 工具使用示例

### eza
```bash
ls              # 列出文件
ll              # 详细列表
la              # 显示所有文件包括隐藏文件
lt              # 树形显示
```

### zoxide
```bash
z projects      # 快速跳转到包含 "projects" 的常用目录
zi              # 交互式选择目录（需要 fzf）
```

### fzf
```bash
Ctrl+R          # 搜索命令历史
Ctrl+T          # 搜索文件
Alt+C           # 搜索并跳转到目录
```

### mise
```bash
mise install node@20    # 安装 Node.js 20
mise use node@20        # 使用 Node.js 20
mise list              # 列出已安装的工具
```

## 安装方式

根据不同的 Linux 发行版，此 feature 会自动选择最合适的安装方法：

### Debian / Ubuntu
- **eza**: 从官方 deb 仓库安装（添加 gierens.de 仓库）
- **fzf**: 从源码编译安装（克隆 GitHub 仓库并构建）
- **zoxide**: 使用官方安装脚本
- **mise**: 使用官方安装脚本
- **starship**: 使用官方安装脚本

### Alpine Linux
- **eza**: 从 Alpine 官方仓库安装（apk）
- **fzf**: 从源码编译安装（克隆 GitHub 仓库并构建）
- **zoxide**: 使用官方安装脚本
- **mise**: 使用官方安装脚本
- **starship**: 使用官方安装脚本

## 注意事项

- 建议在 `common-utils` 之后安装此 feature，以获得更好的 Oh-My-Zsh 集成体验
- 所有工具默认安装到 `/usr/local/bin`，确保全局可用
- 首次运行可能需要几分钟来下载和安装所有工具
- starship 配置文件会保存到 `~/.config/starship.toml`，如果文件已存在则不会覆盖
- zsh 插件仅在检测到 Oh-My-Zsh 时才会安装和启用

## 系统要求

### 支持的操作系统
- **Debian / Ubuntu** (及其衍生版本如 Linux Mint, Pop!_OS)
- **Alpine Linux**

### 支持的架构
- x86_64 (amd64)
- aarch64 (arm64)
- armv7 (部分工具支持)

### 其他要求
- 需要互联网连接来下载工具
- 建议至少 500MB 可用磁盘空间

## 自定义 Starship 配置

你可以使用 `starshipConfigUrl` 选项来指定自定义的 starship 配置文件：

```json
{
  "features": {
    "ghcr.io/aliuq/devcontainer-features/common:0": {
      "starshipConfigUrl": "https://raw.githubusercontent.com/your-repo/starship.toml"
    }
  }
}
```

如果不指定，将使用 feature 自带的默认配置。如果 `~/.config/starship.toml` 已存在，则不会覆盖。

## 故障排除

### 工具未正确初始化

如果工具安装后无法使用，请检查：

1. **重新加载 shell 配置**:
   ```bash
   source ~/.zshrc  # 或 source ~/.bashrc
   ```

2. **检查 PATH**:
   ```bash
   echo $PATH | grep /usr/local/bin
   ```

3. **验证工具是否安装**:
   ```bash
   which eza fzf zoxide mise starship
   ```

### Oh-My-Zsh 插件未启用

如果 Oh-My-Zsh 插件未启用，检查 `.zshrc` 中的 `plugins` 数组：

```bash
grep "^plugins=" ~/.zshrc
```

应该包含相应的插件名称。

## License

MIT

---

*Generated by AI* 


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/aliuq/devcontainer-features/blob/main/src/common/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
