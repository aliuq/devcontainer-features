# Development Guide

## Steps

### 一、复制 feature

复制 `src/common` 到 `.devcontainer/common`

```bash
cp -r src/common .devcontainer/common
```

### 二、修改 .devcontainer/devcontainer.json

将 `ghcr.io/aliuq/devcontainer-features/common:0` 替换为 `./common`

```diff
{
  "features": {
+   "./common": {}
-   "ghcr.io/aliuq/devcontainer-features/common:0": {}
  }
}
```

### 三、重新生成容器

在 VSCode 中按下 `F1`，输入 `Dev Containers: Rebuild Container` 并回车，等待容器重新生成完成即可。
