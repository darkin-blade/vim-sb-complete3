" 全部匹配的单词
let g:sbcom3_wordmatched = []
" 算进单词的部分,不包括中文字符
let g:sbcom3_isword = ""
" 不算进单词的部分
let g:sbcom3_issplit = ""
" 下一个切换的单词
let g:sbcom3_wordnth = 0
" 总共匹配数
let g:sbcom3_wordnum = 0

if (exists('g:sbcom3_active')&&(g:sbcom3_active != 0)) " 启动插件
  if (exists('g:sbcom3_trigger')) " 有自定义按键
    au BufEnter * execute(":inoremap ".g:sbcom3_trigger." <esc>:call sbcom3#main#find()<cr>a")
  else " 没有自定义按键
    au BufEnter * execute(":inoremap <tab> <esc>:call sbcom3#main#find()<cr>a")
  endif
  au BufEnter * call sbcom3#isword()
endif

" 关闭插件
command! SbCom2Off call sbcom3#toggle(0)
" 开启插件
command! SbCom2On call sbcom3#toggle(1)
