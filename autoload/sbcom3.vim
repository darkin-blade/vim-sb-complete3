function sbcom3#toggle(para)
  if (a:para == 0) " 关闭插件
    if (exists('g:sbcom3_trigger')) " 有自定义按键
      execute("iunmap ".g:sbcom3_trigger)
    else " 没有自定义按键
      execute("iunmap <tab>")
    endif
  else
    if (exists('g:sbcom3_trigger'))
      execute("inoremap ".g:sbcom3_trigger." <esc>:call sbcom3#main#find()<cr>a")
    else
      execute("inoremap <tab> <esc>:call sbcom3#main#find()<cr>a")
    endif
  endif
endfunction

function sbcom3#isword()
  if (&filetype == "vim") " 特判vim格式,把#算进单词
    let g:sbcom3_isword = "[0-9a-zA-Z:_#]"
    let g:sbcom3_issplit = "[`~@$%^&*=+\\[{\\]}\\|;'\",<.>/ \t]"
  else
    let g:sbcom3_isword = "[0-9a-zA-Z:_]"
    let g:sbcom3_issplit = "[`~@#$%^&*=+\\[{\\]}\\|;'\",<.>/ \t]"
  endif
endfunction
