## `vim-sb-complete2`

the most lightweight(SHA BI) completion plug of vim

### Information

1. 1th

![](demo/demo1.gif)

- the functions is the same as [vim-sb-complete](https://github.com/NiaBie/vim-sb-complete): you need to input the charactors in right order, and the plug will complete the entire word
- if there are more than 1 words matched, your can switch them

2. 2nd

![](demo/demo2.gif)

- ~~this script won't add space to the end of line(compare to the previous version)~~
- it can complete words inside words, so you don't need to move the cursor to the end of the word to complete the word

3. 3rd

![](demo/demo3.gif)

- if it can't find the proper words to complete(if you want to correct your wrong spelling quickly or just because you want to input wrong spelling deliberately), it will correct your spelling

### Installation

- manual
    - put the `autoload/sbcom2_main.vim` to `~/.vim/autoload/`
    - put the `autoload/sbcom2.vim` to `~/.vim/autoload/`
    - put the `plugin/sbcom2_main.vim` to `~/.vim/plugin/`

- `vim-plug`
    - add `Plug 'niabie/vim-sb-complete2'` to your `~/.vimrc`
		- execute `:PlugInstall` in vim

### Usage

1. add this to `~/.vimrc`, to start-up the plug

```vim
let g:sbcom2_active = 1
```

2. manual turning off or on
    - turn off `:SbCom2Off`
    - turn on `:SbCom2On`

3. The default trigger is `<tab>`. If you want to change the trigger, for example, replace `<tab>` with `<space>`, add this to your `~/.vimrc`

```vim
let g:sbcom2_trigger = "<space>"
```

another example, using a sequence `jkl` to replace `<tab>`

```vim
let g:sbcom2_trigger = "jkl"
```

Don't use this command in commandline directly

### Uninstallation

- manual
    - delete `autoload/sbcom2_main.vim`
    - delete `autoload/sbcom2.vim`
    - delete `plugin/sbcom2_main.vim`

- `vim-plug`
    -  ~~`Plug 'niabie/vim-sb-complete2'`~~
		- execute `:PlugClean` in vim

### TODO

- there are some bugs when the words are next to the charactors such CJK
- can't after `.` in cgn
