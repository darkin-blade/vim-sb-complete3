fun! sbcom3#main#insert(word) " 将单词改成正则表达式
  let wordthis = a:word
  let wordlen = len(wordthis)
  let i = wordlen - 1
  while i >= 0
    let wordthis = wordthis[0:i] . "\.*" . wordthis[i + 1:len(wordthis) - 1] " 从第一个字母到最后一个字母全部增加正则表达式
    let i -= 1
  endwhile
  return wordthis
endfun

fun! sbcom3#main#find() " 主函数
  let wordthis = expand("<cword>") " 获取当前单词
  let thislen = len(expand("<cword>")) " 光标单词的长度
  if (match(getline(line("."))[col(".") - 1], g:sbcom3_isword) == -1) " 获取的字符不含字母或数字
    echom "invalid word"
    echom getline(line("."))[col(".") - 1]
    execute("normal! l")
    return
  endif
" 切换单词
  for i in g:sbcom3_wordmatched " g:sbcom3_wordnum不能为0
    if (i == wordthis) " 单词已经匹配过
      let g:sbcom3_wordnth += 1
      let g:sbcom3_wordnth = g:sbcom3_wordnth%g:sbcom3_wordnum " 循环
      call sbcom3#main#delete(thislen) " 删除当前单词并插入新的单词
      return 
    endif
  endfor
" 没有找到原来的匹配
  let linetext = getline(0, 1000) " 获取全文
  let linetemp = linetext 
  let linetext = []
  for i in linetemp 
    let linetext += split(i, g:sbcom3_issplit) " 先去除非转义,非单词字符
  endfor 
  for j in ["!", "(", ")", "-", "?"] " 去除转义字符
    let linetemp = linetext  
    let linetext = []
    for i in linetemp
      let linetext += split(i, j)
    endfor  
  endfor 
"  清空全局变量
  let g:sbcom3_wordnth = 0 " 匹配的单词中第几个单词,清空
  let g:sbcom3_wordmatched = [] " 匹配的单词组成的list,清空
  if (thislen != 0) " 获取的单词含字母
    let wordthis = sbcom3#main#insert(wordthis) " 变成正则表达式,不建议向前匹配
  endif
  call sort(linetext) " 按字典序排序
  let self = 0
  for i in linetext
    if (match(i, wordthis) == 0) " 找到匹配且不是光标处单词本身
      if (expand("<cword>") == i)
        if (self == 0)
          let self = 1
          continue
        endif
      endif
      if (len(g:sbcom3_wordmatched) != 0) " 是所有匹配单词中的第一个单词
        if (i != g:sbcom3_wordmatched[len(g:sbcom3_wordmatched) - 1]) " 单词去重
          call add(g:sbcom3_wordmatched, i) " 增加到wordmatched
        endif
      else " 不是所有匹配中的第一个单词
        call add(g:sbcom3_wordmatched, i)
      endif
    endif
  endfor
" 第一次匹配  
  let g:sbcom3_wordnum = len(g:sbcom3_wordmatched) " 总匹配数
  if (g:sbcom3_wordnum != 0) " 匹配不为空
    call sbcom3#main#delete(thislen) " 删除当前单词
    return
  else " 匹配为空
    " echom "no matched"
    call sbcom3#main#fix(expand("<cword>"), thislen, linetext)
    return
  endif
endfun

fun! sbcom3#main#delete(thislen) " 删除光标处的单词
" 跳转到单词头部
  if ((col(".") != 1)&&(match(getline(line("."))[col(".") - 2], g:sbcom3_isword)) != -1) " 是否位于单词头部,特判行首的情况
    execute("normal! b")
  endif 
" 跳转到单词尾部
  if (a:thislen != 1) " 判断单词长度是否为1
    execute("normal! e") 
  endif
" 判断单词是否处于行末
  let oldcursor = col(".")
  if (col(".") == len(getline(line("."))))
    let thisend = 1 " 位于行末
  else
    let thisend = 0 " 不位于行末
  endif
" 跳转回单词头部
  if (a:thislen != 1) " 单词是否只有一个字母
    execute("normal! b")
  endif
" 删除单词
  if (a:thislen == 1) " 单词只有一个字母
    execute("normal! x")
  else " 不需要往前跳转
    execute("normal! de")
  endif
  if (thisend == 1) " 位于行末
    execute("normal! a".g:sbcom3_wordmatched[g:sbcom3_wordnth])
  else " 不位于行末
    execute("normal! i".g:sbcom3_wordmatched[g:sbcom3_wordnth])
  endif
" 解决函数缩进问题,待改进
  if (oldcursor - a:thislen + len(g:sbcom3_wordmatched[g:sbcom3_wordnth]) > col("."))
    if (match(g:sbcom3_wordmatched[g:sbcom3_wordnth], "end") == -1)
      execute("normal! >>A")
    endif
  endif
endfun

fun! sbcom3#main#fix(originword, thislen, linetext)
  " echom "correct:".a:originword
  for i in a:linetext
    let allin = 1 " 是否有匹配的flag
    let j = 0
    while j < len(a:originword)
      if (match(i, a:originword[j]) == -1) " 比较所有字母是否存在于另一个单词中
        let allin = 0 " 匹配失败
        break
      endif
      let j += 1
    endwhile
    if ((allin == 1)&&(i != a:originword))
      if (len(g:sbcom3_wordmatched) == 0) " 第一个匹配
        let g:sbcom3_wordmatched = [i]
        let g:sbcom3_wordnum = 1
      else
        if (i != g:sbcom3_wordmatched[len(g:sbcom3_wordmatched) - 1]) " 后面的匹配
          let g:sbcom3_wordmatched += [i]
          let g:sbcom3_wordnum += 1
        endif
      endif
    endif
  endfor
  if (len(g:sbcom3_wordmatched)!= 0)
    call sbcom3#main#delete(a:thislen) " 再次调用删除,插入函数
  endif
endfun
