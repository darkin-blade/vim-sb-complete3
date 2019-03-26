" 全部匹配的单词
let g:sbcom3_matched = []
" 算进单词的部分,不包括中文字符
let g:sbcom3_isword = ""
" 不算进单词的部分
let g:sbcom3_issplit = ""

inoremap <F5> <c-r>=sbcom3#find()<cr>

if (exists('g:sbcom3_active')&&(g:sbcom3_active != 0)) " 启动插件
  if (exists('g:sbcom3_trigger')) " 有自定义按键
    au BufEnter * execute("inoremap ".g:sbcom3_trigger." <c-r>=sbcom3#find()<cr>")
  else " 没有自定义按键
    au BufEnter * execute("inoremap <tab> <c-r>=sbcom3#find()<cr>")
  endif
  au BufEnter * call sbcom3#isword()
endif

" 关闭插件
command! SbCom3Off call Sbcom3Toggle(0)
" 开启插件
command! SbCom3On call Sbcom3Toggle(1)

fun! Sbcom3Toggle(para)
  if (a:para == 0) " 关闭插件
    if (exists('g:sbcom3_trigger')) " 有自定义按键
      execute("iunmap ".g:sbcom3_trigger)
    else " 没有自定义按键
      execute("iunmap <tab>")
    endif
  else
    if (exists('g:sbcom3_trigger'))
      execute("inoremap ".g:sbcom3_trigger." <c-r>=sbcom3#find()<cr>")
    else
      execute("inoremap <tab> <c-r>= sbcom3#find()<cr>")
    endif
  endif
endfun
