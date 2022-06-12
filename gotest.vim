scriptencoding utf-8
" get current line go test func name
let g:VIM_GO_PATH = $GOPATH
call sign_define([
           \ {'name' : 'canTest',
           \  'text' : '>>',
           \ "linehl" : "Search"},
           \ {'name' : 'error',
           \  'text' : '!>',
           \ "texthl" : "Error"}
           \ ])
function s:getGoTestFuncNameInLine() abort
    let fname = matchstr(getline("."),"Test.*(")
    let fname = substitute(fname,"(","","")
    return fname
endfunction
call s:getGoTestFuncNameInLine()

func s:initGoTestEnv()abort
    if g:VIM_GO_PATH == ""
        g:VIM_GO_PATH = $GOPATH
    endif
    if g:VIM_GO_PATH == ""
        echoerr "$GOPATH / VIM_GO_PATH  not set"
    endif
endfunction

function s:checkGoTestEnv()abort
    if !executable("go")
        echoerr "executable : go bin not exist"
    endif
endfunction


func s:getGitProjectPath()abort
    let curPath = eval("%p")
endfunc

" run simple func Test
function s:runGoFuncTest() abort
    call s:checkGoTestEnv()
    let fname = expand('%:t')
    let aFname = expand('%:p')
    let curDir = substitute(aFname,fname,"","")
    let funcName =  s:getGoTestFuncNameInLine()
    if funcName == ""
        call s:showErrMsgInTer( "this line do not have Unit TestFunc")
        return
    endif
    let testShell = join(['go','test','-v',curDir,'-run',printf('^%s$',funcName)])
    call term_start(testShell)
endfunction

func s:getAllTestName()abort
    let lineNu = line("$")
    let lineMap ={} 
    for n in range(0,lineNu  )
        let l = getline(n)
        if  l=~"func.*Test" && l =~"testing.T"

            let l = matchstr(l,"Test.*(")
            let l = substitute(l,"(","","")
            let lineMap[n] =  l
    endif
    endfor
    echo lineMap
    return lineMap
endfunc

func s:signAllTestFunc(testFuns)abort
    for l in keys(a:testFuns) 
            call sign_place(l, "","canTest",
            \   bufname("%"),{"lnum":l})
    endfor
endfunc

func s:signErrFunc(lineNu) abort
            call sign_place(1, "","error",
            \   bufname("%"),{"lnum":lineNu})
endfunc

func s:clearAllSign(testFuncs)abort
    for l in keys(a:testFuncs) 
    call sign_unplace('', {'buffer' : bufname("%"), 'id' : l})
    endfor
endfunction

func s:showErrMsgInTer(errmsg)abort
    call term_start(printf("echo  err: %s",a:errmsg))
endfunc
let fs = s:getAllTestName()
"call s:clearAllSign(fs)
call s:signAllTestFunc(fs)
