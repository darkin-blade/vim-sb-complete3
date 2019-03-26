fun! sbcom3#isword()
  if (&filetype == "vim") " 特判vim格式,把#算进单词
    let g:sbcom3_isword = "[0-9a-zA-Z:_#]"
    let g:sbcom3_issplit = "[`~@$%^&*=+\\[{\\]}\\|;'\",<.>/ \t]"
  else
    let g:sbcom3_isword = "[0-9a-zA-Z:_]"
    let g:sbcom3_issplit = "[`~@#$%^&*=+\\[{\\]}\\|;'\",<.>/ \t]"
  endif
endfun

fun! sbcom3#insert(word) " 将单词改成正则表达式
  let theword = a:word
  let thelen = len(theword)
  let i = thelen - 1
  while i >= 0
    let theword = theword[0:i] . "\.*" . theword[i + 1:len(theword) - 1] " 从第一个字母到最后一个字母全部增加正则表达式
    let i -= 1
  endwhile
  return theword
endfun

fun! sbcom3#exist(elem, lists)
  for i in a:lists
    if (a:elem == i)
      return 1
    endif
  endfor
  return 0
endfun

fun! sbcom3#find() " 主函数
  "==获取目前单词==
  call sbcom3#isword()
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
  let theregular = sbcom3#insert(theword)
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
    if (i == theword) " 相同单词
      let rightspell += 1
      continue
    endif
    if (sbcom3#exist(i, alltext))
      continue
    endif
    let alltext += [i]
  endfor
  "==单词匹配==
  let g:sbcom3_matched = [] " 匹配的单词组成的list,清空
  for i in alltext
    if (match(i, theregular) == 0) " 找到正则匹配
      if (theword == i) " 相同单词
        continue
      endif
      call add(g:sbcom3_matched, i)
    endif
  endfor
  if (rightspell >= 1) " 目前的单词是有效的
    call add(g:sbcom3_matched, theword)
  endif
  if (g:sbcom3_matched == [])
    call sbcom3#fix(theword, thelen, alltext, thetail)
  else
    call sbcom3#replace(thelen, thetail)
  endif
  return ""
endfun

fun! sbcom3#replace(thelen, thetail)
  call cursor([line("."), a:thetail + 2])
  call complete(col(".") - a:thelen, g:sbcom3_matched)
  echom a:thetail
  echom col(".") - 2
endfun



fun! sbcom3#fix(theword, thelen, alltext, thetail)
  for i in a:alltext
    let allin = 1 " 是否有匹配的flag
    let j = 0
    while j < len(a:theword)
      if (match(i, a:theword[j]) == -1) " 比较所有字母是否存在于另一个单词中
        let allin = 0 " 匹配失败
        break
      endif
      let j += 1
    endwhile
    if ((allin == 1)&&(i != a:theword))
      if (len(g:sbcom3_matched) == 0) " 第一个匹配
        let g:sbcom3_matched = [i]
        let g:sbcom3_wordnum = 1
      else
        if (i != g:sbcom3_matched[len(g:sbcom3_matched) - 1]) " 后面的匹配
          let g:sbcom3_matched += [i]
          let g:sbcom3_wordnum += 1
        endif
      endif
    endif
  endfor
  if (len(g:sbcom3_matched)!= 0)
    call sbcom3#replace(a:thelen, a:thetail) " 再次调用删除,插入函数
  endif
endfun

