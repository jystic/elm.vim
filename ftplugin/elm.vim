if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

function! ExecCompilerCmd(cmd)
  return system("which elm && " . a:cmd)
endfunction

function! ElmPrintTypes()
  let file = expand("%")
  let tmpname = "tmp.elm.vim.plugin"
  let buildDir = tmpname . ".build"
  let cacheDir = tmpname . ".cache"
  let compilercmd = "elm " . "-b " . buildDir . " -c " . cacheDir . " --print-types " . file
  let cleanUpCmd = "rm -rf " . buildDir . " " . cacheDir
  echo ExecCompilerCmd(compilercmd . " && " . cleanUpCmd)
endfunction

function! ElmMake(file)
  let compilercmd = "elm " . "--make " . a:file
  return ExecCompilerCmd(compilercmd)
endfunction

function! ElmMakeCurrentFile()
  echo ElmMake(expand("%"))
endfunction

function! ElmMakeMain()
  echo ElmMake("Main.elm")
endfunction

map <LocalLeader>t :call ElmPrintTypes()<ENTER>
map <LocalLeader>c :call ElmMakeCurrentFile()<ENTER>
map <LocalLeader>m :call ElmMakeMain()<ENTER>