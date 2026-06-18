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
    $ENV{PATH} = "$texbin:$ENV{PATH}" unless $ENV{PATH} =~ /\Q$texbin\E/;
    $ENV{SELFAUTOLOC} = $texbin
      unless defined $ENV{SELFAUTOLOC} && length $ENV{SELFAUTOLOC};
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
