" Require plugin 'scrooloose/syntastic'.

"statusline setup
set statusline+=[%f]  "filename
set statusline+=%r    "read only flag
set statusline+=%m    "modified flag
set statusline+=%h    "help file flag
set statusline+=[%Y]  "filetype

"set statusline+=%{fugitive#statusline()}

"display errors
set statusline+=%#error#
set statusline+=%{&ff!='unix'?'['.&ff.']':''} "if fileformat is not unix
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''} "if file encoding isnt utf-8
set statusline+=%*

"display warnning
set statusline+=%#warningmsg#
set statusline+=%{&paste?'[paste]':''} "if &paste is set
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%{StatuslineLongLineWarning()}
set statusline+=%{StatuslineTabWarning()} "if &et is wrong, or we have mixed-indenting
set statusline+=%{StatuslineTrailingSpaceWarning()} " if has tailling space
set statusline+=%*

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()} "current highlight
set statusline+=[%c,      "cursor column
set statusline+=\ %l/%L,  "cursor line/total lines
set statusline+=\ %P]     "percent through file

set laststatus=2 " Set statusline always display

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[Trailing space at line: x]' if trailing white space is detected
"return empty otherwise
function! StatuslineTrailingSpaceWarning()
  if !exists("b:statusline_trailing_space_warning")

    if !&modifiable
      let b:statusline_trailing_space_warning = ''
      return b:statusline_trailing_space_warning
    endif

    let line_number = search('\s\+$', 'nw')
    if line_number != 0
      let b:statusline_trailing_space_warning = '[Trailing space at line: ' . line_number . ']'
    else
      let b:statusline_trailing_space_warning = ''
    endif
  endif
  return b:statusline_trailing_space_warning
endfunction

"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
  let name = synIDattr(synID(line('.'),col('.'),1),'name')
  if name == ''
    return ''
  else
    return '[' . name . ']'
  endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[Expand tab wrong at line: tabs/spaces]' if &et is set wrong
"return '[Mixed indenting at line: tabs,spaces]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
  if !exists("b:statusline_tab_warning")
    let b:statusline_tab_warning = ''

    if !&modifiable
      return b:statusline_tab_warning
    endif

    let tabs = search('^\t', 'nw')

    "find spaces that arent used as alignment in the first indent column
    let spaces = search('^ \{' . &ts . ',}[^\t]', 'nw')

    if tabs != 0 && spaces != 0
      let b:statusline_tab_warning = '[Mixed indenting at line: ' . tabs . ',' . spaces . ']'
    elseif spaces != 0 && !&et
      let b:statusline_tab_warning = '[Expand tab wrong at line: ' . spaces . ']'
    elseif tabs != 0 && &et
      let b:statusline_tab_warning = '[Expand tab wrong at line: ' . tabs . ']'
    endif
  endif
  return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"Warning if there are lines longer than &textwidth or 80 (if no &textwidth is set)
"
"return '' if no long lines
"return [Long line at: x] if line x is too long
function! StatuslineLongLineWarning()
  if !exists("b:statusline_long_line_warning")
    let b:statusline_long_line_warning = ''

    if &ft != 'cpp' && &ft != 'python' && &ft != 'sh'
      return b:statusline_long_line_warning
    elseif !&modifiable
      return b:statusline_long_line_warning
    endif

    let long_line_number = s:FirstLongLineNumber()
    if long_line_number > 0
      let b:statusline_long_line_warning = '[Long line at: ' . long_line_number . ']'
    endif

    return b:statusline_long_line_warning
  endif
  return b:statusline_long_line_warning
endfunction

"return the first long line number in this buffer
function! s:FirstLongLineNumber()
  let threshold = (&tw ? &tw : 80)
  let tabs = repeat(" ", &ts)
  let lines = map(getline(1,'$'), 'substitute(v:val, "\\t", tabs, "g")')
  let line_number = 0
  for line in lines
    let line_number = line_number + 1
    if len(line) > threshold
      let line = Strip(line)
      if line[0] == '#' || line[0] == '/' || line[0] == '\"'
        continue
      endif
      return line_number
    endif
  endfor
  return 0
endfunction

function! Strip(string)
  return substitute(a:string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction
