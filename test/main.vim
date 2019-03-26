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

inoremap <F5> <c-r>=Sbcom3_find()<cr>

fun! Sbcom3_isword()
  if (&filetype == "vim") " 特判vim格式,把#算进单词
    let g:sbcom3_isword = "[0-9a-zA-Z:_#]"
    let g:sbcom3_issplit = "[`~@$%^&*=+\\[{\\]}\\|;'\",<.>/ \t]"
  else
    let g:sbcom3_isword = "[0-9a-zA-Z:_]"
    let g:sbcom3_issplit = "[`~@#$%^&*=+\\[{\\]}\\|;'\",<.>/ \t]"
  endif
endfun

fun! Sbcom3_insert(word) " 将单词改成正则表达式
  let wordthis = a:word
  let wordlen = len(wordthis)
  let i = wordlen - 1
  while i >= 0
    let wordthis = wordthis[0:i] . "\.*" . wordthis[i + 1:len(wordthis) - 1] " 从第一个字母到最后一个字母全部增加正则表达式
    let i -= 1
  endwhile
  return wordthis
endfun

fun! Sbcom3_find() " 主函数
  call Sbcom3_isword()
  let theline = getline(line("."))
  let thehead = col(".") - 2
  let thetail = thehead
  while ((match(theline[thehead], g:sbcom3_isword) != -1)&&(thehead >= 1))
    let thehead -= 1
  endwhile
  while ((match(theline[thetail], g:sbcom3_isword) != -1)&&(1))
    let thetail += 1
  endwhile
  let thehead += 1
  let thetail -= 1
  let theword = theline[thehead:thetail]
  "==获取了单词==
    return []
""    let thislen = len(expand("<cword>")) " 光标单词的长度
""    let linetext = getline(0, 1000) " 获取全文
""    let linetemp = linetext 
""    let linetext = []
""    for i in linetemp 
""      let linetext += split(i, g:sbcom3_issplit) " 先去除非转义,非单词字符
""    endfor 
""    for j in ["!", "(", ")", "-", "?"] " 去除转义字符
""      let linetemp = linetext  
""      let linetext = []
""      for i in linetemp
""        let linetext += split(i, j)
""      endfor  
""    endfor 
""  "  清空全局变量
""    let g:sbcom3_wordnth = 0 " 匹配的单词中第几个单词,清空
""    let g:sbcom3_wordmatched = [] " 匹配的单词组成的list,清空
""    if (thislen != 0) " 获取的单词含字母
""      let wordthis = Sbcom3_insert(wordthis) " 变成正则表达式,不建议向前匹配
""    endif
""    call sort(linetext) " 按字典序排序
""    let self = 0
""    for i in linetext
""      if (match(i, wordthis) == 0) " 找到匹配且不是光标处单词本身
""        if (expand("<cword>") == i)
""          if (self == 0)
""            let self = 1
""            continue
""          endif
""        endif
""        if (len(g:sbcom3_wordmatched) != 0) " 是所有匹配单词中的第一个单词
""          if (i != g:sbcom3_wordmatched[len(g:sbcom3_wordmatched) - 1]) " 单词去重
""            call add(g:sbcom3_wordmatched, i) " 增加到wordmatched
""          endif
""        else " 不是所有匹配中的第一个单词
""          call add(g:sbcom3_wordmatched, i)
""        endif
""      endif
""    endfor
""  " 第一次匹配  
""    let g:sbcom3_wordnum = len(g:sbcom3_wordmatched) " 总匹配数
""    if (g:sbcom3_wordnum != 0) " 匹配不为空
""      call Sbcom3_delete(thislen) " 删除当前单词
""      return
""    else " 匹配为空
""      " echom "no matched"
""      call Sbcom3_fix(expand("<cword>"), thislen, linetext)
""      return
""    endif
endfun

""  fun! Sbcom3_delete(thislen) " 删除光标处的单词
""  " 跳转到单词头部
""    if ((col(".") != 1)&&(match(getline(line("."))[col(".") - 2], g:sbcom3_isword)) != -1) " 是否位于单词头部,特判行首的情况
""      execute("normal! b")
""    endif 
""  " 跳转到单词尾部
""    if (a:thislen != 1) " 判断单词长度是否为1
""      execute("normal! e") 
""    endif
""  " 判断单词是否处于行末
""    let oldcursor = col(".")
""    if (col(".") == len(getline(line("."))))
""      let thisend = 1 " 位于行末
""    else
""      let thisend = 0 " 不位于行末
""    endif
""  " 跳转回单词头部
""    if (a:thislen != 1) " 单词是否只有一个字母
""      execute("normal! b")
""    endif
""  " 删除单词
""    if (a:thislen == 1) " 单词只有一个字母
""      execute("normal! x")
""    else " 不需要往前跳转
""      execute("normal! de")
""    endif
""    if (thisend == 1) " 位于行末
""      execute("normal! a".g:sbcom3_wordmatched[g:sbcom3_wordnth])
""    else " 不位于行末
""      execute("normal! i".g:sbcom3_wordmatched[g:sbcom3_wordnth])
""    endif
""  " 解决函数缩进问题,待改进
""    if (oldcursor - a:thislen + len(g:sbcom3_wordmatched[g:sbcom3_wordnth]) > col("."))
""      if (match(g:sbcom3_wordmatched[g:sbcom3_wordnth], "end") == -1)
""        execute("normal! >>A")
""      endif
""    endif
""  endfun
""  
""  fun! Sbcom3_fix(originword, thislen, linetext)
""    " echom "correct:".a:originword
""    for i in a:linetext
""      let allin = 1 " 是否有匹配的flag
""      let j = 0
""      while j < len(a:originword)
""        if (match(i, a:originword[j]) == -1) " 比较所有字母是否存在于另一个单词中
""          let allin = 0 " 匹配失败
""          break
""        endif
""        let j += 1
""      endwhile
""      if ((allin == 1)&&(i != a:originword))
""        if (len(g:sbcom3_wordmatched) == 0) " 第一个匹配
""          let g:sbcom3_wordmatched = [i]
""          let g:sbcom3_wordnum = 1
""        else
""          if (i != g:sbcom3_wordmatched[len(g:sbcom3_wordmatched) - 1]) " 后面的匹配
""            let g:sbcom3_wordmatched += [i]
""            let g:sbcom3_wordnum += 1
""          endif
""        endif
""      endif
""    endfor
""    if (len(g:sbcom3_wordmatched)!= 0)
""      call Sbcom3_delete(a:thislen) " 再次调用删除,插入函数
""    endif
""  endfun
