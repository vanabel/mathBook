## mathBook

基于 `elegantbook` 的中文数学专著模板：分章写作、GB/T 7714 参考文献、中文拼音索引、MetaPost 插图、`minted` 代码高亮。示例排版参考 Jaffe--Taubes《涡旋与磁单极子》。

### 要点速览

| 你想… | 做法 |
|--------|------|
| 开始写作 | 改 `main.tex` 元数据 → 编辑 `chapters/*.tex` → `make watch` |
| 换入口文件 | `make MAIN=book.tex` 或在 `Makefile.local` 写 `MAIN := book.tex` |
| 加文献 | `references.bib` + `\cite{key}` → 见 [docs/bibliography.md](docs/bibliography.md) |
| 插入代码 | `\begin{minted}{python}`；Wolfram 用 `\begin{wolfram}` → 见 [docs/minted.md](docs/minted.md) |
| 作图 | `main.tex` 示例 `mpostinl` + `metapost/`；不用图可删相关 `\input` |
| 中文索引 | 需安装 `zhmakeindex` → 见 [docs/zhmakeindex.md](docs/zhmakeindex.md) |
| 编译出问题 | 见 [docs/build.md](docs/build.md) |

**引擎**：XeLaTeX + Biber + `latexmk`（`.latexmkrc`：`-shell-escape`、SyncTeX、中文索引）。

**三个外部工具**：`zhmakeindex`（索引）、`latexminted`（代码高亮，TeX Live 2024+ 通常已有）、MetaPost（仅作图时需要）。

---

### 快速开始

```bash
make              # 编译 main.pdf
make watch        # 保存即重编（写作推荐）
make minted-setup # 仅用 Wolfram 高亮时，执行一次
make help
```

多书同仓：`cp Makefile.local.example Makefile.local`，写入 `MAIN := yourbook.tex`。

编译时看 `make` 开头两行：`zhmakeindex:` 应指向系统路径；`TeX bin:` 应含 `latexminted`。

---

### 项目结构

```
main.tex              入口
mathbook.sty          导言区合集
elegantbook.cls       文档类
chapters/             章节
references.bib        文献
metapost/             MetaPost
pygments/             Wolfram 词法器（可选）
docs/                 详细文档
Makefile / .latexmkrc
```

---

### 写作 checklist

1. **元数据**：`main.tex` 书名、作者、日期。
2. **章节**：`chapters/*.tex`，`main.tex` 中 `\include{...}`。
3. **文献**：`references.bib`；分章参考文献见 `chapters/chap01.tex`。
4. **索引**：`\index{...}` 或 `\iemph[分类]{术语}`。

---

### 文档（docs/）

| 文档 | 内容 |
|------|------|
| [docs/build.md](docs/build.md) | 编译流程、Make 命令、PATH 踩坑、排错 |
| [docs/zhmakeindex.md](docs/zhmakeindex.md) | 中文索引安装（含 Apple Silicon / Windows） |
| [docs/minted.md](docs/minted.md) | 代码高亮、`latexminted`、Wolfram 词法器 |
| [docs/bibliography.md](docs/bibliography.md) | Biber、GB/T 7714、分章文献 |
| [docs/single-file.md](docs/single-file.md) | 合并为单文件投稿 |

---

### 与 mathPaper 的对应

| mathPaper | mathBook |
|-----------|----------|
| `amsart` | `elegantbook` |
| `mathpaper.sty` | `mathbook.sty` |
| BibTeX + AMSRefs | Biber + `gb7714-2015` |
| `pdflatex` | `xelatex` + `latexmk` |
| 单文件 | `chapters/*.tex` |

---

### 注意事项（一句话）

**勿** `export PATH="$(pwd):$PATH"` — 会误用 bundled `zhmakeindex`（ARM 段错误）并可能找不到 `latexminted`。细节见 [docs/build.md](docs/build.md)。
