scriptencoding utf-8
" conf init
let g:GO_TEST_FILE_BUF_WIN_ID  = 0 
if !exists('g:VIM_GO_PATH')
let g:VIM_GO_PATH = $GOPATH
endif
if !exists("g:ATUO_LIST_FUNC")
    let g:ATUO_LIST_FUNC = 1
endif
func GOTestInit()abort
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
"autocmd  BufWrite *_test.go :call s:checkGoTestEnv()
augroup GOTEST
autocmd  BufReadPre,CursorMoved  *_test.go  :call s:redrawSign()
augroup END
endif
endfunc
" command
command! GOTEST :call s:runGoFuncTest() 
command! GOTESTCLEAR :call s:clearSign() 
nnoremap gt :GOTEST<CR>
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
let g:FAIL_FUNCS =  {}
function! Callback_Handler(channel, msg)
   let texts = split(a:msg,'\n')
   execute(":wincmd p")
   let ls = s:getAllTestName()
   for text in  texts
         echomsg text
        if  text =~ "FAIL"
            for fn in keys(ls)
                if  text == fn
                    g:FAIL_FUNCS[fn] = 1
                    call s:signErrFunc(ls[fn])
                endif
            endfor
        endif
    endfor
endfunction

" run simple func Test
function s:runGoFuncTest() abort
    call s:checkGoTestEnv()
    let fname = expand('%:t')
    let aFname = expand('%:p')
    let curDir = substitute(aFname,fname,"","")
    let funcName =  s:getGoTestFuncNameInLine()
    let g:GO_TEST_FILE_BUF_WIN_ID = bufwinnr(bufname())
    if funcName == ""
        call s:showErrMsgInTer( "this line do not have Unit TestFunc")
        return
    endif
    let testShell = join(['go','test','-v',curDir,'-run',printf('^%s$',funcName)])
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
            if !has_key(g:FAIL_FUNCS,l) 
              let lineMap[l] =  n
            endif
            
    endif
    endfor
    return lineMap
endfunc

func s:signAllTestFunc(tfs)abort
    for l in keys(a:tfs) 
            call sign_place(1, "","canTest",
            \   bufname("%"),{"lnum":a:tfs[l]})
    endfor
endfunc

func s:signErrFunc(lineNu) abort
    echoerr "lsj"
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

call GOTestInit()