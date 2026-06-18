# 代码高亮（minted v3+）

`mathbook.sty` 已加载 `minted`。示例章节：`chapters/chap03-code.tex`。

## 基本要求

- **引擎**：XeLaTeX + `-shell-escape`（`.latexmkrc` / `Makefile` 已配置）
- **可执行文件**：`latexminted`（minted v3 不再直接调用 `pygmentize`）
- TeX Live 2024+ 通常已自带 `latexminted`；`make` 会打印 `>> TeX bin:`，应含其所在目录

验证：

```bash
command -v latexminted
latexminted --help
```

未找到时：

```bash
pip install latexminted pygments   # Python 3.10–3.12 较稳；3.14+ 可能与部分版本不兼容
```

## 普通语言

```tex
\begin{minted}{python}
print("hello")
\end{minted}
```

## Wolfram / Mathematica

Pygments 自带的 `mathematica` 词法器把**所有**标识符都标为 `Name`，`Integrate`、`Sin` 等与用户函数外观相同。

本模板提供 `pygments/wolfram_lexer.py`：按 Wolfram 惯例，**大写开头**的符号标为内置函数（绿色）。

```tex
\begin{wolfram}
Integrate[Sin[x]^2, {x, 0, Pi}]
\end{wolfram}

\wl{D[Sin[x]^2, x]}    % 行内；含方括号时已用 | 分隔符封装
```

### 一次性配置

minted v3 对自定义词法器需 SHA-256 白名单（写入 `TEXMFHOME`）：

```bash
make minted-setup
make pdf
```

等价于写入 `$(kpsewhich -var-value TEXMFHOME)/.latexminted_config`。可参考 `.latexminted.config.example` 手动配置。

修改 `pygments/wolfram_lexer.py` 后须重新 `make minted-setup`。

## 常见错误

### `minted v3+ executable is not installed or is not added to PATH`

**不是正文语法问题**，而是 XeLaTeX 子进程找不到 `latexminted`。

排查：

1. `command -v latexminted`
2. `make pdf` 时查看 `>> TeX bin:` 是否含 TeX Live `bin` 目录
3. **勿**将项目目录置顶到 `PATH`（`export PATH="$(pwd):$PATH"`），否则可能跳过 TeX Live 里的 `latexminted`

macOS 常见路径：`/Library/TeX/texbin/latexminted`

### Python 3.14 与 `ArgParser ... color`

TeX Live 2025 自带的 `latexminted` 0.6.x 在 **Python 3.14** 上会崩溃（`argparse` 向子解析器传入 `color=`）。表现与「找不到 latexminted」相同。

本模板在检测到 Python ≥ 3.14 时，自动将 `scripts/shim/python3` 置于 `PATH` 最前，使 `latexminted` 的 `#!/usr/bin/env python3` 改用 3.8–3.13。长期方案：`tlmgr update minted`（minted 3.8+ / latexminted 0.7.1+），或 `pip install latexminted` 并使用兼容的 Python。

验证 shim：

```bash
PATH="$(pwd)/scripts/shim:$PATH" python3 --version   # 应 < 3.14
latexminted --version
```

### Windows 补充

- TeX Live：确认 `C:\texlive\2025\bin\windows\latexminted.exe` 在 PATH 中
- MiKTeX：可能需 `pip install latexminted`；编译须 `-shell-escape`（模板已启用）
- 使用单独 `-output-directory` 时，可设环境变量 `TEXMF_OUTPUT_DIRECTORY`（MiKTeX 常见）

## 缓存与清理

高亮结果缓存在 `_minted/`（已在 `.gitignore`）。`make clean` 会删除。

手动编译：

```bash
latexmk -xelatex -shell-escape main.tex
```
