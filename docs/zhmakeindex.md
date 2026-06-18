# 中文索引（zhmakeindex）

模板通过 `imakeidx` + `zhmakeindex` + `zh.ist` 实现中文拼音索引（`-z pinyin` 生成 A/B/C… 分组标题）。

## 模板如何调用

- `mathbook.sty` 中 `imakeidx` 默认程序为 `zhmakeindex`
- `Makefile` / `.latexmkrc` **优先使用系统 PATH 中的** `zhmakeindex`
- 项目内 bundled 的 x86_64 副本仅作无系统安装时的后备；**Apple Silicon 上可能 SIGSEGV**

编译时 `imakeidx`（`xelatex --shell-escape` 期间）与 `latexmk`（`$makeindex` 规则）都会调用 `zhmakeindex`，二者须指向同一可用二进制。

`make` 开头应显示：

```
>> zhmakeindex: /usr/local/bin/zhmakeindex
```

若显示 `./zhmakeindex` 或路径不对，在 `Makefile.local` 中指定：

```makefile
ZHMAKEINDEX := /usr/local/bin/zhmakeindex
# Windows 示例：
# ZHMAKEINDEX := C:/texlive/2025/bin/windows/zhmakeindex.exe
```

## 安装

`zhmakeindex` 是独立工具（[GitHub](https://github.com/leo-liu/zhmakeindex) / [CTAN](https://ctan.org/pkg/zhmakeindex)），**近年 TeX Live / MacTeX 默认不再附带**。

验证：

```bash
command -v zhmakeindex
zhmakeindex -help
```

### Apple Silicon（M 系列 Mac）

CTAN 预编译包多为 x86_64，在 ARM Mac 上可能段错误。推荐用 Go 编译原生 arm64：

```bash
# 1. 安装 Go：https://go.dev/dl/ （macOS ARM64）
git clone https://github.com/leo-liu/zhmakeindex.git
cd zhmakeindex
go mod tidy
go build -o zhmakeindex

# 2. 放入 PATH
sudo mv zhmakeindex /usr/local/bin/
# 或：mkdir -p ~/bin && mv zhmakeindex ~/bin/

zhmakeindex -help
```

若已有 `/usr/local/bin/zhmakeindex`，可直接使用，**可删除项目目录下的 `./zhmakeindex`**。

### Windows

1. 从 [CTAN](https://ctan.org/pkg/zhmakeindex) 解压，在 `bin/win32`（或 `windows`）下找到 `zhmakeindex.exe`；或从 GitHub 源码编译。
2. 放入 PATH 中的目录，例如：
   - `C:\texlive\2025\bin\windows\`
   - MiKTeX 的 `miktex\bin\x64\`
   - 自建 `C:\Users\<你>\bin\` 并加入系统环境变量
3. 新终端中运行 `zhmakeindex -help` 验证。
4. 未自动找到时，在 `Makefile.local` 写完整路径（见上）。

### 从源码编译（通用）

已安装 [Go](https://go.dev/dl/) 时：

```bash
git clone https://github.com/leo-liu/zhmakeindex.git
cd zhmakeindex
go mod tidy
go build -o zhmakeindex        # macOS/Linux
# go build -o zhmakeindex.exe  # Windows
```

Windows 也可在 CTAN 解压目录运行 `install.cmd`（需 `go` 在 PATH 中）。

## 正文用法

```tex
\index{Higgs模型!阿贝尔|hyperpage}
\iemph[可选分类]{术语}   % 下划线强调并自动入索引
```

示例见 `chapters/chap01.tex`。

## 常见问题

**索引无拼音分组（只有一条条平铺）**  
`latexmk` 可能调用了普通 `makeindex` 或错误的 `zhmakeindex`。检查 `make` 输出的 `zhmakeindex:` 路径；确认 `.latexmkrc` 中 `$makeindex` 含 `-z pinyin`。

**段错误（SIGSEGV）**  
勿将项目目录置顶到 `PATH`（会用到 bundled x86_64 二进制）。改用系统 arm64 版本或 `Makefile.local` 指定路径。
