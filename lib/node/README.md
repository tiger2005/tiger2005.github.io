# Node HTML Build

`build-html.mjs` 是当前项目的静态构建入口，负责把 `posts/`、`pages/`、`assets/` 汇总到输出目录（默认 `_site`）。其中博客文章会生成到 `_site/posts/<slug>/index.html`。

## Usage

```bash
npm run build
npm run build:force
npm run build:fast
npm run build:preview
npm run build:full
```

## CLI Options

- `-o, --out`：输出目录名（相对仓库根目录）
- `-f, --force`：忽略时间戳，强制刷新所有编译和复制任务
- `-j, --jobs`：Typst 并发编译进程数
- `-h, --help`：显示帮助

## Build Flow

1. 清空临时目录 `.typ-blog-cache/`。
2. 逐个编译 `posts/**/index.typ` 的 metadata 输出，生成 `_posts-metadata.json`。
3. 基于 tag/category 执行 slugify，并对冲突（不同值映射到同一 slug）直接报错。
4. 展开动态路由页面（`[tag]` / `[category]`），并校验每个路径 token 最多出现一次。
5. 编译 `posts/` 与 `pages/` 的 `index.typ` 到临时站点目录；其中文章固定输出到 `/posts/<slug>/`，按 `updated` / `unchanged` 标记。
6. 同步 `assets/`、`posts/`、`pages/` 下非 `.typ` 文件到临时目录，按时间戳标记 `updated` / `unchanged`。
7. 对比旧输出目录，计算不再保留的文件并标记 `deleted`。
8. 将临时目录整体移动到目标输出目录。

## Notes

- 动态路由模板路径中，`[tag]` 和 `[category]` 各自最多出现一次。
- 旧输出目录中的未保留文件会在发布阶段被移除。
- 构建结束后会清理 `.typ-blog-cache/`。
- 构建脚本已拆分为 `build/` 目录下多个模块（`cli`、`core`、`helpers`、`typst`、`pool`、`progress`）。
- 并发阶段使用项目内置进度条实现，不依赖第三方包。
