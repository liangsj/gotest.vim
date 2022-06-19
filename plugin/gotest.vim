scriptencoding utf-8
" conf init
let g:GO_TEST_FILE_BUF_WIN_ID  = 0 
let s:errLineNu = {}
if !exists('g:VIM_GO_PATH')
let g:VIM_GO_PATH = $GOPATH
endif
if !exists("g:ATUO_LIST_FUNC")
    let g:ATUO_LIST_FUNC = 1
endif
if g:ATUO_LIST_FUNC == 1
call sign_define([
           \ {'name' : 'canTest',
           \  'text' : '>>',
           \ },
           \ {'name' : 'error',
           \  'text' : '!>',
           \ "texthl" : "Error"}
           \ ])

"autoCmd
augroup GOTEST
autocmd  BufReadPre,CursorMoved  *_test.go  :call s:redrawSign()
augroup END
endif
" command
command! Gtest :call s:runGoFuncTest() 
" get current line go test func name
function s:getGoTestFuncNameInLine() abort
    let fname = matchstr(getline("."),"Test.*(")
    let fname = substitute(fname,"(","","")
    return fname
endfunction

function s:checkGoTestEnv()abort
    if !executable("go")
        echoerr "executable : go bin not exist"
    endif
endfunction


func s:getGitProjectPath()abort
    let curPath = eval("%p")
endfunc
function! Callback_Handler(channel, msg)
   let texts = split(a:msg,'\n')
   execute(":wincmd p")
   let ls = s:getAllTestName()
   for text in  texts
        if  text =~ "FAIL" && text =~ "Test"
            for fn in keys(ls)
                if  text =~ fn
                    let s:errLineNu[ls[fn]] = fn
                    call s:signErrFunc(ls[fn])
                endif
            endfor
        endif
    endfor
endfunction

" run simple func Test
function s:runGoFuncTest() abort
    call s:checkGoTestEnv()
    if has_key(s:errLineNu , line("."))
        call remove(s:errLineNu,line("."))
    endif
    let fname = expand('%:t')
    let aFname = expand('%:p')
    let curDir = substitute(aFname,fname,"","")
    let curDir = substitute(curDir,"/data00","","")
    let funcName =  s:getGoTestFuncNameInLine()
    if funcName == ""
        call s:showErrMsgInTer( "this line do not have Unit TestFunc")
        return
    endif
    let testShell = join(['go','test','-v',curDir,'-run',printf('^%s$',funcName)])
    if has("nvim")
    let ret = system(testShell)
    call s:showResult(ret)
    call Callback_Handler("", ret)
    return
    endif
    call term_start(testShell,{"callback":"Callback_Handler"})
endfunction
func s:getAllTestName()abort
    let lineNu = line("$")
    let lineMap ={} 
    for n in range(0,lineNu)
        let l = getline(n)
        if  l=~"func.*Test" && l =~"testing.T" 
            let l = matchstr(l,"Test.*(")
            let l = substitute(l,"(","","")
            let lineMap[l] =  n
            
    endif
    endfor
    return lineMap
endfunc

func s:signAllTestFunc(tfs)abort
    for l in keys(a:tfs) 
            if has_key(s:errLineNu,a:tfs[l])
                continue
            endif
            call sign_place(1, "","canTest",
            \   bufname("%"),{"lnum":a:tfs[l]})
    endfor
endfunc

func s:signErrFunc(lineN) abort
    call sign_place(2,"","error",bufname("%"),{"lnum":a:lineN})
endfunc

func s:clearAllSign(tfs)abort
    for l in keys(a:tfs) 
    call sign_unplace('', {'buffer' : bufname("%"), 'id' : 1})
    endfor
endfunction

func s:showErrMsgInTer(errmsg)abort
    call term_start(printf("echo  err: %s",a:errmsg))
endfunc

func s:redrawSign() abort
    let testFuncs = s:getAllTestName()
    call s:clearAllSign(testFuncs)
    call s:signAllTestFunc(testFuncs)
endfunc

func s:clearSign() abort
    let testFuncs = s:getAllTestName()
    call s:clearAllSign(testFuncs)
endfunc

let s:gotest_buffer = 'GO_TEST_BUF'
function! s:showResult(results) abort
   let lineSum = 1
  if bufexists(s:gotest_buffer)
    let winid = bufwinid(s:gotest_buffer)
    if winid isnot# -1
      call win_gotoid(winid)
    else
      execute 'sbuffer' s:gotest_buffer
    endif
    let lineSum = line("$")
  else
    execute 'new' s:gotest_buffer
    set buftype=nofile
  endif
  "%delete _
  call setline(lineSum +1, split(a:results, '\n'))
endfunction
