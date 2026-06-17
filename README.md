## mathBook：`elegantbook` 专著模板（中文 + 分章参考文献）

一个尽量“开箱即用”的数学专著写作模板，示例实例为 Jaffe--Taubes《涡旋与磁单极子》的排版配置。

- **主文件**：`main.tex`（可用 `make MAIN=...` 或 `Makefile.local` 换入口）
- **导言区包**：`mathbook.sty`（定理环境、`cleveref`、中文索引、biblatex 选项等）
- **MetaPost**：`main.tex` 中加载 `mpostinl`；`metapost/` 目录（`mpost-tex.tex` 图内中文、`mpost-def.tex` 作图宏）
- **文档类**：`elegantbook.cls`（项目内自带）
- **中文索引**：`zh.ist` + `zhmakeindex`（拼音排序）
- **示例文献库**：`references.bib`
- **章节目录**：`chapters/`
- **编译脚本**：`Makefile`

---

### 快速开始

**依赖**：XeLaTeX、Biber、`gb7714` 宏包、`imakeidx`、MetaPost（若使用 `mpostinl` 绘图；编译需 `-shell-escape`，已在 `.latexmkrc` 中配置）。

```bash
make help     # 查看所有编译目标
make          # 单次编译（默认 main.tex）
make watch    # 实时自动编译（推荐写作时使用）
make MAIN=book.tex          # 指定入口文件
cp Makefile.local.example Makefile.local   # 长期固定入口文件
```

`make watch`（或 `make live`）等价于 `latexmk -pvc -view=default`，会在后台监听文件保存；每次保存后只增量编译改动部分，并自动刷新 PDF 阅读器（macOS 上优先使用 Skim）。按 `Ctrl+C` 退出。

入口文件默认为 `main.tex`。多项目同仓时可在 `Makefile.local` 中写 `MAIN := riemann.tex`，或单次编译时 `make MAIN=riemann.tex watch`。

或手动：

```bash
export PATH="$(pwd):$PATH"
latexmk -pvc -view=default main.tex
```

**编译目标一览**

| 命令 | 说明 |
|------|------|
| `make` / `make pdf` | 单次完整编译 |
| `make watch` / `make live` | 持续预览：保存即增量编译并刷新 PDF |
| `make clean` | 清理中间文件 |
| `make distclean` | 清理中间文件及 PDF |
| `make zip` | 打包发布 |
| `make help` | 显示上述命令摘要 |

`.latexmkrc` 已预设 XeLaTeX、`shell-escape`（MetaPost）、`synctex=1`（正反向跳转）及依赖追踪（增量编译）。

**写作入口**：

1. 修改 `main.tex` 中的 “Book metadata” 块（书名、作者、日期等）。
2. 在 `chapters/` 下新增或编辑章节，并在 `main.tex` 中 `\include{...}`。
3. 需要作图时：在 `main.tex` 加载 `mpostinl`，并 `\input{metapost/mpost-tex.tex}`、`\input{metapost/mpost-def.tex}`（无图可删这三行）。
4. 文献写入 `references.bib`，正文用 `\cite{key}`；每章可用 `\begin{refsection}...\printbibliography...\end{refsection}` 生成分章参考文献。

---

### 与 mathPaper 的对应关系

| mathPaper | mathBook |
|-----------|----------|
| `amsart` | `elegantbook` |
| `mathpaper.sty` | `mathbook.sty` |
| BibTeX + AMSRefs | Biber + `gb7714-2015` |
| `pdflatex` / `latexmk -pdf` | `xelatex` / `latexmk`（`.latexmkrc`） |
| 单文件正文 | `chapters/*.tex` 分章 |
| — | `make watch`（`latexmk -pvc`）实时编译 |

---

### 中文索引（`zhmakeindex`）

模板通过 `imakeidx` 调用项目目录下的 `zhmakeindex`，配合 `zh.ist` 实现中文拼音索引。`Makefile` 已自动将当前目录加入 `PATH`；`.latexmkrc` 中 `$makeindex` 已配置为 `zhmakeindex -z pinyin`（若用默认 `makeindex`，索引会缺少拼音首字母分组标题）。

> **注意**：随项目附带的 `zhmakeindex` 为 macOS x86_64 可执行文件。Apple Silicon 机器通常可通过 Rosetta 运行；若无法运行，请自行编译或替换为可用的 `zhmakeindex` 二进制，并确保其在 `PATH` 中。

索引条目示例（正文中）：

```tex
\index{Higgs模型!阿贝尔|hyperpage}
\iemph[可选分类]{术语}  % 下划线强调并自动入索引
```

---

### 参考文献（Biber + GB/T 7714）

- **`.bib` 文件**：`references.bib`
- **引用命令**：`\cite{key}`
- **分章文献**：在章节内使用 `refsection` 环境（见 `chapters/chap01.tex`）

关闭 DOI/URL 等字段的选项已在 `mathbook.sty` 中预设；可按需修改 `\ExecuteBibliographyOptions{...}`。

---

### 单文件协作/投稿（减少依赖）

#### 1) 内联导言区：把 `mathbook.sty` 内容粘进 `main.tex`

- 删除 `\usepackage{mathbook}`
- 将 `mathbook.sty` 的内容粘贴到导言区（去掉 `\NeedsTeXFormat`、`\ProvidesPackage`、`\endinput` 三行）

#### 2) 合并章节

将 `chapters/*.tex` 的内容直接 `\input` 或粘贴进 `main.tex`，并删除 `\include` 行。

---

### 清理产物

```bash
make clean      # 清理中间文件
make distclean  # 连同 PDF 一并清理
```
