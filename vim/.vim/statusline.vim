"==============================================================================
" Status Line Settings (Depracated, use plugin vim-airline instead).
"==============================================================================

set statusline+=%{fugitive#statusline()}  " Require plugin 'fugitive'.
set statusline+=[%f]  " filename
set statusline+=%r    " read only flag
set statusline+=%m    " modified flag
set statusline+=%h    " help file flag
set statusline+=[%Y]  " filetype

" Display warnnings
set statusline+=%#warningmsg#
set statusline+=%{&paste?'[paste]':''}  " if &paste is set
set statusline+=%{&ff!='unix'?'['.&ff.']':''}  " if fileformat is not unix
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}  " if file encoding isnt utf-8
set statusline+=%*

" Display errors
set statusline+=%#error#
set statusline+=%{SyntasticStatuslineFlag()}  " Require plugin 'syntastic'.
set statusline+=%{StatuslineTabWarning()}  " if &et is wrong, or we have mixed-indenting
set statusline+=%{StatuslineTrailingSpaceWarning()}  " if has tailling space
set statusline+=%{StatuslineLongLineWarning()}  " if has long line.
set statusline+=%*  " Back to normal highlight

"left/right separator
set statusline+=%=

set statusline+=%{StatuslineCurrentHighlight()} "current highlight
set statusline+=[%c,      "cursor column
set statusline+=\ %l/%L,  "cursor line/total lines
set statusline+=\ %P]     "percent through file

" Recalculate the warnings when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

" Returns '[Trailing space at: x]' if trailing white space is detected
" Returns '' otherwise
function! StatuslineTrailingSpaceWarning()
  if !exists("b:statusline_trailing_space_warning")

    if !&modifiable
      let b:statusline_trailing_space_warning = ''
      return b:statusline_trailing_space_warning
    endif

    let line_number = search('\s\+$', 'nw')
    if line_number != 0
      let b:statusline_trailing_space_warning = '[Trailing space at: ' . line_number . ']'
    else
      let b:statusline_trailing_space_warning = ''
    endif
  endif
  return b:statusline_trailing_space_warning
endfunction

" Return the syntax highlight group under the cursor.
function! StatuslineCurrentHighlight()
  let name = synIDattr(synID(line('.'),col('.'),1),'name')
  if name == ''
    return ''
  else
    return '[' . name . ']'
  endif
endfunction

" Returns '[Expand tab wrong at: x]' if &et is set wrong
" Returns '[Mixed indenting at: x,y]' if spaces and tabs are used to indent
" Returns '' if everything is fine
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
      let b:statusline_tab_warning = '[Mixed indenting at: ' . tabs . ',' . spaces . ']'
    elseif spaces != 0 && !&et
      let b:statusline_tab_warning = '[Expand tab wrong at: ' . spaces . ']'
    elseif tabs != 0 && &et
      let b:statusline_tab_warning = '[Expand tab wrong at: ' . tabs . ']'
    endif
  endif
  return b:statusline_tab_warning
endfunction

" Warning if there are lines longer than &textwidth or 80 (if &textwidth is not
" set)
"
" Returns [Long line at: x] if line x is too long, '' if not long lines.
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

" Return the first long line number in this buffer
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
