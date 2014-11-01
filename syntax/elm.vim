if version < 600
  syn clear
elseif exists("b:current_syntax")
  finish
endif

syntax sync fromstart "mmhhhh.... is this really ok to do so?

" (Qualified) identifiers (no default highlighting)
syn match ConId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[A-Z][a-zA-Z0-9_']*\>"
syn match VarId "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=\<[a-z][a-zA-Z0-9_']*\>"

" Infix operators--most punctuation characters and any (qualified) identifier
" enclosed in `backquotes`. An operator starting with : is a constructor,
" others are variables (e.g. functions).
syn match elmVarSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[-!#$%&\*\+/<=>\?@\\^|~.][-!#$%&\*\+/<=>\?@\\^|~:.]*"
syn match elmConSym "\(\<[A-Z][a-zA-Z0-9_']*\.\)\=:[-!#$%&\*\+./<=>\?@\\^|~:]*"
syn match elmVarSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[a-z][a-zA-Z0-9_']*`"
syn match elmConSym "`\(\<[A-Z][a-zA-Z0-9_']*\.\)\=[A-Z][a-zA-Z0-9_']*`"

" Reserved symbols--cannot be overloaded.
syn match elmDelimiter  "(\|)\|\[\|\]\|,\|;\|_\|{\|}"

sy region elmInnerParen start="(" end=")" contained contains=elmInnerParen,elmConSym,elmType,elmVarSym
sy region elm_InfixOpFunctionName start="^(" end=")\s*[^:`]\(\W\&\S\&[^'`()[\]{}@]\)\+"re=s
    \ contained keepend contains=elmInnerParen,elm_HlInfixOp

sy match elm_hlFunctionName "[a-z_]\(\S\&[^,\(\)\[\]]\)*" contained 
sy match elm_FunctionName "^[a-z_]\(\S\&[^,\(\)\[\]]\)*" contained contains=elm_hlFunctionName
sy match elm_HighliteInfixFunctionName "`[a-z_][^`]*`" contained
sy match elm_InfixFunctionName "^\S[^=]*`[a-z_][^`]*`"me=e-1 contained contains=elm_HighliteInfixFunctionName,elmType,elmConSym,elmVarSym
sy match elm_HlInfixOp "\(\W\&\S\&[^`(){}'[\]]\)\+" contained
sy match elm_InfixOpFunctionName "^\(\w\|[[\]{}]\)\+\s*[^:]=*\(\W\&\S\&[^='`()[\]{}@]\)\+"
    \ contained contains=elm_HlInfixOp

sy match elm_OpFunctionName        "(\(\W\&[^(),]\)\+)" contained
sy region elm_Function start="^[a-z_([{]" end="=\(\s\|\n\|\w\|[([]\)" keepend extend
        \ contains=elm_OpFunctionName,elm_InfixOpFunctionName,elm_InfixFunctionName,elm_FunctionName,elmType,elmConSym,elmVarSym

sy match elm_DeclareFunction "^[a-z_(]\S*\(\s\|\n\)*:" contains=elm_FunctionName,elm_OpFunctionName

sy keyword elmStructure data class where instance default deriving
sy keyword elmTypedef type newtype

sy keyword elmInfix infix infixl infixr
sy keyword elmStatement  do case of let in
sy keyword elmConditional if then else

if exists("elm_highlight_types")
  " Primitive types from the standard prelude and libraries.
  sy match elmType "\<[A-Z]\(\S\&[^,.]\)*\>"
  sy match elmType "()"
  sy match elmSpecial "\<number'*\>"
  sy match elmSpecial "\<comparable'*\>"
  sy match elmSpecial "\<appendable'*\>"
endif

" Not real keywords, but close.
if exists("elm_highlight_boolean")
  " Boolean constants from the standard prelude.
  syn keyword elmBoolean True False
endif

sy keyword elmModuleStartLabel module contained
sy keyword elmExportModuleLabel module contained
sy keyword elmModuleWhereLabel where contained
sy match elmImport		"\<import\>\(.\|[^(]\)*\((.*)\)\?" contains=elmImportLabel,elmImportMod,elmModuleName,elmImportList
sy keyword elmImportLabel import contained
sy keyword elmImportMod		as qualified hiding contained
sy match   elmModuleName  excludenl "\([A-Z]\w*\.\?\)*" contained 
sy region elmImportListInner start="(" end=")" contained keepend extend contains=elm_OpFunctionName
sy region  elmImportList matchgroup=elmImportListParens start="("rs=s+1 end=")"re=e-1
        \ contained 
        \ keepend extend
        \ contains=elmType,elmLineComment,elmBlockComment,elm_hlFunctionName,elmImportListInner
sy region elmExportListInner start="(" end=")" contained keepend extend 
sy region elmExportListInner start="(" end=")" contained keepend extend contains=elm_OpFunctionName
sy match elmExportModule "\<module\>\(\s\|\t\|\n\)*.*" contained contains=elmExportModuleLabel,elmModuleName
sy region elmExportList matchgroup=elmExportListParens start="("rs=s+1 end=")"re=e-1
        \ contained
        \ keepend extend
        \ contains=elmBlockComment,elmLineComment,elmType,elm_hlFunctionName,elmExportListInner,elmExportModule


sy keyword elmFFIForeign foreign contained
sy keyword elmFFIImportExport import export contained
sy keyword elmFFICallConvention jsevent contained
sy region  elmFFIString		start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=elmSpecialChar
sy match elmFFI excludenl "\<foreign\>\(.\&[^\"]\)*\"\(.\)*\"\(\s\|\n\)*\(.\)*::"
  \ keepend
  \ contains=elmFFIForeign,elmFFIImportExport,elmFFICallConvention,elmFFIString,elm_OpFunctionName,elm_hlFunctionName

" elmModule regex MUST match all possible symbols between 'module' and 'where'
" else overlappings with other syntax elements will break correct elmModule 
" syntax highliting or evaluation of regex will stall vim.
"
" regex parts:
"   1: match keyword "module"
"   2: match modulename (optionaly comma separated)
"   3.1 and 3.2: parens of optional symbol list
"   4: final keyword "where"
"   5: any alphanumeric symbol
"   6: symbol list delimiter ","
"   7: any symbol non-alphanumeric symbol enclosed in parenthesis. e.g. (*)
"   8: optional line comment
"
"                                                                         |   optional Symbol List                            |
"                             |   1    |            |   2   |             |3.1| 5  6 :  7  :   8                          |3.2|            |   4   |
syn match elmModule excludenl "\<module\>\(\s\|\n\)*\(\<.*\>\)\(\s\|\n\)*\((\(\w\|,\|(\W*)\|--.*\n\|\.\|{\|}\|-\|\#\|'\|\s\|\n\)*)\)\?\(\s\|\n\)*\<where\>" 
    \ contains=elmModuleStartLabel,elmModuleWhereLabel,elmModuleName,elmExportList,elmModuleStart

"hi elmModule guibg=red

syn match  elmSpecialChar	contained "\\\([0-9]\+\|o[0-7]\+\|x[0-9a-fA-F]\+\|[\"\\'&\\abfnrtv]\|^[A-Z^_\[\\\]]\)"
syn match  elmSpecialChar	contained "\\\(NUL\|SOH\|STX\|ETX\|EOT\|ENQ\|ACK\|BEL\|BS\|HT\|LF\|VT\|FF\|CR\|SO\|SI\|DLE\|DC1\|DC2\|DC3\|DC4\|NAK\|SYN\|ETB\|CAN\|EM\|SUB\|ESC\|FS\|GS\|RS\|US\|SP\|DEL\)"
syn match  elmSpecialCharError	contained "\\&\|'''\+"
sy region  elmString		start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=elmSpecialChar,@Spell
sy match   elmCharacter		"[^a-zA-Z0-9_']'\([^\\]\|\\[^']\+\|\\'\)'"lc=1 contains=elmSpecialChar,elmSpecialCharError
sy match   elmCharacter		"^'\([^\\]\|\\[^']\+\|\\'\)'" contains=elmSpecialChar,elmSpecialCharError
sy match   elmNumber		"\<[0-9]\+\>\|\<0[xX][0-9a-fA-F]\+\>\|\<0[oO][0-7]\+\>"
sy match   elmFloat		"\<[0-9]\+\.[0-9]\+\([eE][-+]\=[0-9]\+\)\=\>"

" Comments
sy keyword elmCommentTodo    TODO FIXME XXX TBD contained
sy match   elmLineComment      "---*\([^-!#$%&\*\+./<=>\?@\\^|~].*\)\?$" contains=elmCommentTodo,@Spell
sy region  elmBlockComment     start="{-"  end="-}" contains=elmBlockComment,elmCommentTodo,@Spell
sy region  elmPragma	       start="{-#" end="#-}"

if version >= 508 || !exists("did_elm_syntax_inits")
  if version < 508
    let did_elm_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink elm_hlFunctionName    Function
  HiLink elm_HighliteInfixFunctionName Function
  HiLink elm_HlInfixOp       Function
  HiLink elm_OpFunctionName  Function
  HiLink elmTypedef          Typedef
  HiLink elmVarSym           elmOperator
  HiLink elmConSym           elmOperator
  if exists("elm_highlight_delimiters")
    " Some people find this highlighting distracting.
	HiLink elmDelimiter        Delimiter
  endif

  HiLink elmModuleStartLabel Structure
  HiLink elmExportModuleLabel Keyword
  HiLink elmModuleWhereLabel Structure
  HiLink elmModuleName       Normal

  HiLink elmImportLabel      Include
  HiLink elmImportMod        Include

  HiLink elmOperator         Operator

  HiLink elmInfix            Keyword
  HiLink elmStructure        Structure
  HiLink elmStatement        Statement
  HiLink elmConditional      Conditional

  HiLink elmSpecialCharError Error
  HiLink elmSpecialChar      SpecialChar
  HiLink elmString           String
  HiLink elmFFIString        String
  HiLink elmCharacter        Character
  HiLink elmNumber           Number
  HiLink elmFloat            Float

  HiLink elmLiterateComment		  elmComment
  HiLink elmBlockComment     elmComment
  HiLink elmLineComment      elmComment
  HiLink elmComment          Comment
  HiLink elmCommentTodo      Todo
  HiLink elmPragma           SpecialComment
  HiLink elmBoolean			  Boolean
  HiLink elmType             Type

  HiLink elmSpecial            Debug

  HiLink elmFFIForeign       Keyword
  HiLink elmFFIImportExport  Structure
  HiLink elmFFICallConvention Keyword

  delcommand HiLink
endif

let b:current_syntax = "elm"
