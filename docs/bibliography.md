# 参考文献（Biber + GB/T 7714）

## 基本用法

- 数据库：`references.bib`
- 正文：`\cite{key}`、`\parencite{key}` 等
- 编译链：XeLaTeX → Biber → XeLaTeX（`latexmk` 自动处理）

## 分章参考文献

在章节内使用 `refsection` 环境，章末 `\printbibliography`。示例见 `chapters/chap01.tex`：

```tex
\begin{refsection}
% 本章正文 ...
\printbibliography[heading=subbibliography, title={本章参考文献}]
\end{refsection}
```

## 样式与字段

`mathbook.sty` 使用 `biblatex` + `gb7714-2015`，并预设关闭部分字段：

```tex
\ExecuteBibliographyOptions{
  doi=false,
  url=false,
  isbn=false,
  eprint=false
}
```

可按需修改 `\ExecuteBibliographyOptions{...}` 或 `\DeclareFieldFormat{...}`。

## 与 mathPaper 的差异

| mathPaper | mathBook |
|-----------|----------|
| BibTeX + AMSRefs | Biber + `gb7714-2015` |
| 单次 `\bibliography` | 可分章 `refsection` |

从 mathPaper 迁移时，需将 `.bib` 条目改为 biblatex 兼容格式（多数标准条目可直接使用）。
