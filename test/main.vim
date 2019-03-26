" 全部匹配的单词
let g:sbcom3_matched = []
" 算进单词的部分,不包括中文字符
let g:sbcom3_isword = ""
" 不算进单词的部分
let g:sbcom3_issplit = ""

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
  let theword = a:word
  let thelen = len(theword)
  let i = thelen - 1
  while i >= 0
    let theword = theword[0:i] . "\.*" . theword[i + 1:len(theword) - 1] " 从第一个字母到最后一个字母全部增加正则表达式
    let i -= 1
  endwhile
  return theword
endfun

fun! Sbcom3_exist(elem, lists)
  for i in a:lists
    if (a:elem == i)
      return 1
    endif
  endfor
  return 0
endfun

fun! Sbcom3_find() " 主函数
  "==获取目前单词==
  call Sbcom3_isword()
  let theline = getline(line("."))
  let thehead = col(".") - 2
  let thetail = thehead
  while ((match(theline[thehead], g:sbcom3_isword) != -1)&&(thehead >= 0))
    let thehead -= 1
  endwhile
  while ((match(theline[thetail], g:sbcom3_isword) != -1)&&(1))
    let thetail += 1
  endwhile
  let thehead += 1
  let thetail -= 1
  let theword = theline[thehead:thetail]
  let thelen = len(theword)
  if (thelen == 0)
    echom "invalid --sbcom3"
    return []
  endif
  let theregular = Sbcom3_insert(theword)
  "==获取全部单词==
  let lineup = line(".")
  let linedown = line(".") + 1
  let alltext = []
  while ((lineup >= 1)||(linedown <= len(getline(0, 1000)))) " 按就近添加行
    if (lineup >= 1)
      let alltext += getline(lineup, lineup)
    endif
    if (linedown <= len(getline(0, 1000)))
      let alltext += getline(linedown, linedown)
    endif
    let lineup -= 1
    let linedown += 1
  endwhile
  let alltext_temp = alltext 
  let alltext = []
  for i in alltext_temp 
    let alltext += split(i, g:sbcom3_issplit) " 先去除非转义,非单词字符
  endfor 
  for j in ["!", "(", ")", "-", "?"] " 去除转义字符
    let alltext_temp = alltext  
    let alltext = []
    for i in alltext_temp
      let alltext += split(i, j)
    endfor  
  endfor 
  "==单词去重==
  let alltext_temp = alltext
  let alltext = []
  let rightspell = -1 " 如果为1,说明是正确的单词
  for i in alltext_temp
    if (i == theword)
      let rightspell += 1
    endif
    if (Sbcom3_exist(i, alltext))
      continue
    endif
    let alltext += [i]
  endfor
  "==单词匹配==
  let g:sbcom3_matched = [] " 匹配的单词组成的list,清空
  for i in alltext
    if (match(i, theregular) != -1) " 找到正则匹配
      if ((theword == i)&&(rightspell < 1)) " 无效拼写
        continue
      endif
      call add(g:sbcom3_matched, i)
    endif
  endfor
  call complete(col("."), g:sbcom3_matched)
  return ""
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
""      execute("normal! a".g:sbcom3_matched[g:sbcom3_wordnth])
""    else " 不位于行末
""      execute("normal! i".g:sbcom3_matched[g:sbcom3_wordnth])
""    endif
""  " 解决函数缩进问题,待改进
""    if (oldcursor - a:thislen + len(g:sbcom3_matched[g:sbcom3_wordnth]) > col("."))
""      if (match(g:sbcom3_matched[g:sbcom3_wordnth], "end") == -1)
""        execute("normal! >>A")
""      endif
""    endif
""  endfun
""  
""  fun! Sbcom3_fix(originword, thislen, alltext)
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
""        if (len(g:sbcom3_matched) == 0) " 第一个匹配
""          let g:sbcom3_matched = [i]
""          let g:sbcom3_wordnum = 1
""        else
""          if (i != g:sbcom3_matched[len(g:sbcom3_matched) - 1]) " 后面的匹配
""            let g:sbcom3_matched += [i]
""            let g:sbcom3_wordnum += 1
""          endif
""        endif
""      endif
""    endfor
""    if (len(g:sbcom3_matched)!= 0)
""      call Sbcom3_delete(a:thislen) " 再次调用删除,插入函数
""    endif
""  endfun
