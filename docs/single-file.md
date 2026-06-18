# 单文件投稿（减少外部依赖）

投稿或协作时，可将多文件结构合并为单个 `.tex`，减少对方需要同步的附件。

## 合并导言区

1. 打开 `mathbook.sty`，复制全部内容到 `main.tex` 导言区（`\begin{document}` 之前）。
2. 删除粘贴内容中的三行：
   - `\NeedsTeXFormat{LaTeX2e}`
   - `\ProvidesPackage{mathbook}[...]`
   - `\endinput`（若有）
3. 删除 `\usepackage{mathbook}`。

若对方无 `elegantbook.cls`，需一并提供或改用其他文档类。

## 合并章节

将 `chapters/*.tex` 的内容按顺序粘贴到 `main.tex` 正文中，删除对应的 `\include{chapters/...}` 行。

保留或删除：

- `\input{metapost/...}` — 仅在使用 MetaPost 插图时需要
- `\addbibresource{references.bib}` — 可改为内嵌 `thebibliography` 或仍附 `.bib`

## 仍可剥离的依赖

| 功能 | 单文件后是否仍需 |
|------|------------------|
| `zhmakeindex` | 使用索引则需要 |
| `latexminted` | 使用 `minted` / `wolfram` 则需要 |
| `biber` + `.bib` | 使用 biblatex 则需要 |
| MetaPost | 使用 `mpostinl` 则需要 |

不使用某功能时，可从导言区移除对应包与配置以简化。
