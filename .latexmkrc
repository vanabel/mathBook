$pdf_mode = 5;            # xelatex
$bibtex_use = 2;          # biber
$recorder = 1;            # .fdb_latexmk：追踪依赖，增量编译
$dependents_list = 1;
$show_time = 1;

$xelatex = 'xelatex -shell-escape -synctex=1 -interaction=nonstopmode %O %S';
$clean_ext = 'bbl bcf run.xml idx ilg ind synctex.gz';

# Chinese index: latexmk defaults to makeindex (no pinyin group headers).
# Must match mathbook.sty: zhmakeindex -s zh.ist -z pinyin
$makeindex = './zhmakeindex -s zh.ist -z pinyin %O -o %D %S';

# make watch (-pvc)：保存后自动重编并刷新 PDF 阅读器
if ($^O eq 'darwin') {
  $pdf_previewer = (-d '/Applications/Skim.app')
    ? 'open -a Skim.app %S'
    : 'open %S';
}
