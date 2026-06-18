# Ensure TeX Live/MiKTeX bin (latexminted for minted v3) is on PATH for shell-escape.
# kpsewhich xelatex returns a script name on macOS, not the bin directory; use
# command -v + abs_path (xelatex may resolve to .../xetex).
use Cwd 'abs_path';
BEGIN {
  my $texbin;
  for my $cmd (qw(xelatex xetex)) {
    my $path = `command -v $cmd 2>/dev/null`;
    chomp $path;
    next unless $path && -x $path;
    $path = abs_path($path);
    next unless $path =~ m{^(.*)/(xelatex|xetex)$};
    $texbin = $1;
    last;
  }
  if ($texbin) {
    $ENV{SELFAUTOLOC} = $texbin
      unless defined $ENV{SELFAUTOLOC} && length $ENV{SELFAUTOLOC};
  }
  # latexminted 0.6.x breaks on Python 3.14+; shim python3 → 3.8–3.13 (must precede TEX bin).
  my $pyshim = abs_path('scripts/shim');
  if (-d $pyshim && -x "$pyshim/python3") {
    my $py314 = system('python3 -c "import sys; sys.exit(0 if sys.version_info[:2]>=(3,14) else 1)" 2>/dev/null');
    if ($py314 == 0) {
      $ENV{PATH} = "$pyshim:$ENV{PATH}" unless $ENV{PATH} =~ /\Q$pyshim\E/;
    }
  }
  if ($texbin) {
    $ENV{PATH} = "$texbin:$ENV{PATH}" unless $ENV{PATH} =~ /\Q$texbin\E/;
  }
}

$pdf_mode = 5;            # xelatex → .xdv → xdvipdfmx → .pdf
$dvi_mode = 0;
$postscript_mode = 0;
$bibtex_use = 2;          # biber
$recorder = 1;            # .fdb_latexmk：追踪依赖，增量编译
$dependents_list = 1;
$show_time = 1;

$xelatex = 'xelatex -shell-escape -synctex=1 -interaction=nonstopmode %O %S';
$clean_ext = 'bbl bcf run.xml idx ilg ind synctex.gz minted* _minted*';

# Chinese index: prefer system zhmakeindex over bundled ./zhmakeindex (x86_64 may SIGSEGV on Apple Silicon).
sub mathbook_zhmakeindex {
  if ($ENV{ZHMAKEINDEX} && -x $ENV{ZHMAKEINDEX}) {
    return $ENV{ZHMAKEINDEX};
  }
  for my $c ('/usr/local/bin/zhmakeindex', '/opt/homebrew/bin/zhmakeindex') {
    return $c if -x $c;
  }
  return './zhmakeindex' if -x './zhmakeindex';
  return 'zhmakeindex';
}
$makeindex = mathbook_zhmakeindex() . ' -s zh.ist -z pinyin %O -o %D %S';

# make watch (-pvc)：保存后自动重编并刷新 PDF 阅读器
if ($^O eq 'darwin') {
  $pdf_previewer = (-d '/Applications/Skim.app')
    ? 'open -a Skim.app %S'
    : 'open %S';
}
