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

**依赖**：XeLaTeX、Biber、`gb7714` 宏包、`imakeidx`、**`zhmakeindex`**（中文索引，见下节安装说明）、MetaPost（若使用 `mpostinl` 绘图；编译需 `-shell-escape`，已在 `.latexmkrc` 中配置）。

```bash
make help     # 查看所有编译目标
make          # 单次编译（默认 main.tex）
make watch    # 实时自动编译（推荐写作时使用）
make MAIN=book.tex          # 指定入口文件
cp Makefile.local.example Makefile.local   # 长期固定入口文件
```

`make watch`（或 `make live`）等价于 `latexmk -xelatex -pvc -view=pdf`：XeLaTeX 先写出中间文件 `.xdv`，再由 `xdvipdfmx` 生成最终 `.pdf`；日志里 `xelatex` 规则较多属正常，完整一轮末尾应有 `xdvipdfmx` 与 `update_view`。若只有 `.xdv` 而无 `.pdf`，说明编译未跑完（常见原因：索引/biber 报错、中途退出）。

入口文件默认为 `main.tex`。多项目同仓时可在 `Makefile.local` 中写 `MAIN := riemann.tex`，或单次编译时 `make MAIN=riemann.tex watch`。

或手动：

```bash
latexmk -xelatex -pvc -view=pdf main.tex
```

勿将项目目录置于 `PATH` 最前（`export PATH="$(pwd):$PATH"` 会优先调用 bundled 的 x86_64 `zhmakeindex`，在 Apple Silicon 上可能段错误）。

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

模板通过 `imakeidx` + `zhmakeindex` 配合 `zh.ist` 实现中文拼音索引（`-z pinyin` 生成 A/B/C… 分组标题）。`Makefile` 与 `.latexmkrc` **优先使用系统 PATH 中的** `zhmakeindex`（如 `/usr/local/bin/zhmakeindex`）；项目内 bundled 的 x86_64 副本仅作无系统安装时的后备，**在 Apple Silicon 上可能 SIGSEGV，建议删除或勿置于 PATH 最前**。

编译时 `imakeidx`（`xelatex --shell-escape` 期间）与 `latexmk`（`$makeindex` 规则）都会调用 `zhmakeindex`，二者须指向同一可用二进制。若 `make watch` 索引缺拼音分组，检查 `make` 开头打印的 `zhmakeindex:` 路径；可在 `Makefile.local` 中设置：

```makefile
ZHMAKEINDEX := /usr/local/bin/zhmakeindex   # macOS/Linux 示例
# ZHMAKEINDEX := C:/texlive/bin/windows/zhmakeindex.exe   # Windows 示例
```

#### 安装 zhmakeindex

`zhmakeindex` 是独立命令行工具（[GitHub](https://github.com/leo-liu/zhmakeindex) / [CTAN](https://ctan.org/pkg/zhmakeindex)），**近年 TeX Live / MacTeX 默认不再附带**，需自行安装。安装后请确认：

```bash
command -v zhmakeindex    # 能找到可执行文件
zhmakeindex -help         # 能正常输出中文帮助
```

**Apple Silicon（M 系列 Mac）**

bundled 或 CTAN 附带的 macOS 二进制多为 x86_64，在 ARM Mac 上可能段错误。推荐用 Go 从源码编译原生 arm64 版本：

```bash
# 1. 安装 Go：https://go.dev/dl/ （选 macOS ARM64 安装包）
# 2. 编译
git clone https://github.com/leo-liu/zhmakeindex.git
cd zhmakeindex
go mod tidy
go build -o zhmakeindex

# 3. 安装到 PATH（二选一）
sudo mv zhmakeindex /usr/local/bin/
# 或：mkdir -p ~/bin && mv zhmakeindex ~/bin/  （确保 ~/bin 在 PATH 中）

# 4. 验证
zhmakeindex -help
```

若你已有可用的 `/usr/local/bin/zhmakeindex`（例如此前手动安装），可直接使用，**删除项目目录下的 `./zhmakeindex` 即可**。

**Windows**

1. 从 [CTAN 下载 zhmakeindex](https://ctan.org/pkg/zhmakeindex) 解压，在 `bin` 子目录中找到 `win32`（或 `windows`）下的 `zhmakeindex.exe`；或从 [GitHub 仓库](https://github.com/leo-liu/zhmakeindex) 获取源码自行编译。
2. 将 `zhmakeindex.exe` 放到已在 `PATH` 中的目录，例如：
   - TeX Live：`C:\texlive\2025\bin\windows\`
   - MiKTeX：MiKTeX 安装目录下的 `miktex\bin\x64\`
   - 或自建 `C:\Users\<你>\bin\` 并加入系统环境变量 PATH
3. 打开新的命令提示符 / PowerShell，运行 `zhmakeindex -help` 验证。
4. 在本项目中用 `make` 编译时，若未自动找到，可在 `Makefile.local` 写完整路径（见上）。

**从源码编译（Apple Silicon / Windows / Linux 通用）**

已安装 [Go](https://go.dev/dl/) 时，在仓库根目录执行：

```bash
git clone https://github.com/leo-liu/zhmakeindex.git
cd zhmakeindex
go mod tidy
go build -o zhmakeindex        # macOS/Linux
# go build -o zhmakeindex.exe  # Windows
```

将生成的可执行文件放入 PATH 即可。Windows 用户也可在解压后的 CTAN 目录中运行 `install.cmd`（需已安装 Go 且 `go` 在 PATH 中）。

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
