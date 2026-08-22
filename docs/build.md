# 编译与排错

## 流水线

`make` / `make watch` 使用 `latexmk -pdf`，由 `.latexmkrc` 把 PDF 引擎设为 xelatex（直接写 `.pdf`，便于预览刷新）：

| 步骤 | 说明 |
|------|------|
| `xelatex -shell-escape` | 主引擎；写出 `.pdf`；触发 `imakeidx`、MetaPost、`minted` |
| `zhmakeindex` | 中文索引（见 [zhmakeindex.md](zhmakeindex.md)） |
| `biber` | 参考文献 |

`make watch` 等价于 `latexmk -pdf -pvc -view=pdf`。日志里多次 `xelatex` 属正常。`make terminology` 只重写 `chapters/terminology-glossary.tex`，不启动 LaTeX；该文件由 Markdown 生成，不要手改。术语对照表与拼音索引分开：前者给推荐译名，后者标页码。

手动：

```bash
latexmk -pdf -pvc -view=pdf main.tex
```

## 入口文件

默认 `main.tex`。覆盖方式：

```bash
make MAIN=book.tex
make MAIN=book.tex watch
```

或 `Makefile.local`：

```makefile
MAIN := book.tex
```

## Make 命令

| 命令 | 说明 |
|------|------|
| `make` / `make pdf` | 单次完整编译 |
| `make terminology` | 从 `TERMINOLOGY.md` 生成 `chapters/terminology-glossary.tex`（不跑 LaTeX） |
| `make watch` / `make live` | 保存即重编并刷新 PDF |
| `make stop` | 结束本项目相关的 `latexmk` / `xelatex` / `biber` 等进程（也会停掉本目录下的 `make watch`/`live`/`pdf`） |
| `make minted-setup` | Wolfram 词法器白名单（见 [minted.md](minted.md)） |
| `make clean` | 清理中间文件（含 `_minted/`） |
| `make distclean` | 另删 PDF |
| `make zip` | 打包发布 |
| `make help` | 命令摘要 |

`.latexmkrc` 另含：`synctex=1`（正反向跳转）、`$recorder`（增量依赖追踪）、`TEXMF_OUTPUT_DIRECTORY`（minted v3 / TeX Live 2025）。

macOS 上 `make watch` 默认用 Skim 刷新 PDF（若已安装）。`make stop` 按当前目录与入口文件 `MAIN` 限定范围，不会误杀其他 TeX 项目。

## PATH 与外部工具

编译开始时留意：

```
>> zhmakeindex: /usr/local/bin/zhmakeindex
>> TeX bin:     /usr/local/texlive/2025/bin/universal-darwin/
```

### 不要把项目目录放在 PATH 最前

```bash
# 错误示例 — 会导致：
export PATH="$(pwd):$PATH"
```

- 优先调用 bundled 的 x86_64 `zhmakeindex` → Apple Silicon 上可能 **SIGSEGV**
- 可能找不到 TeX Live 里的 `latexminted`

模板 `Makefile` / `.latexmkrc` 用 `command -v xelatex`（经 `abs_path` 解析，兼容 symlink 到 `xetex`）定位 TeX `bin`，并设置 `SELFAUTOLOC`，确保 `latexminted` 可被 minted v3 找到。`make` 会打印 `>> TeX bin:`，应类似 `/usr/local/texlive/2025/bin/universal-darwin`。

### Makefile.local 常用覆盖

```makefile
MAIN := riemann.tex
ZHMAKEINDEX := /usr/local/bin/zhmakeindex
```

## 常见现象

| 现象 | 可能原因 |
|------|----------|
| 只有 `.xdv` 无 `.pdf` | biber / 索引 / minted 报错；看 `main.log` |
| 索引无 A/B/C 分组 | 未用 `zhmakeindex -z pinyin`；见 [zhmakeindex.md](zhmakeindex.md) |
| `minted v3+ executable...` | 找不到 `latexminted`；见 [minted.md](minted.md) |
| `make watch` 很慢 | 多章 + 索引 + biber 时每轮 3–4 次 xelatex 正常 |
| MetaPost 图未更新 | 检查 `-shell-escape`；`mpostinl` 日志 |

## 清理

```bash
make clean      # 中间文件
make distclean  # 含 PDF
```
