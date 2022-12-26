function! s:toggle_extra_chars(bang) abort
  if !empty(a:bang)
    unlet! w:toggle_extra_chars
  endif

  if exists('w:toggle_extra_chars')
    let l:number = get(w:toggle_extra_chars, 'number', 0)
    let l:relativenumber = get(w:toggle_extra_chars, 'relativenumber', 0)
    let l:list = get(w:toggle_extra_chars, 'list', 0)
    let l:breakindent = get(w:toggle_extra_chars, 'breakindent', 0)
    let l:showbreak = get(w:toggle_extra_chars, 'showbreak', 'NONE')
    let l:cursorline = get(w:toggle_extra_chars, 'cursorline', 0)
    let l:colorcolumn = get(w:toggle_extra_chars, 'colorcolumn', '')
    let l:laststatus = get(w:toggle_extra_chars, 'laststatus', 1)
    let l:ruler = get(w:toggle_extra_chars, 'ruler', 0)
    let l:showcmd = get(w:toggle_extra_chars, 'showcmd', 0)
    let l:showmode = get(w:toggle_extra_chars, 'showmode', 0)
    let l:showtabline = get(w:toggle_extra_chars, 'showtabline', 1)

    unlet w:toggle_extra_chars

    let &l:number = l:number
    let &l:relativenumber = l:relativenumber
    let &l:list = l:list
    let &l:breakindent = l:breakindent
    let &l:showbreak = l:showbreak
    let &l:cursorline = l:cursorline
    let &l:colorcolumn = l:colorcolumn
    let &l:laststatus = l:laststatus
    let &l:ruler = l:ruler
    let &l:showcmd = l:showcmd
    let &l:showmode = l:showmode
    let &l:showtabline = l:showtabline
  else
    let w:toggle_extra_chars = {}
    let w:toggle_extra_chars['number'] = &number
    let w:toggle_extra_chars['relativenumber'] = &relativenumber
    let w:toggle_extra_chars['list'] = &list
    let w:toggle_extra_chars['breakindent'] = &breakindent
    let w:toggle_extra_chars['showbreak'] = &showbreak
    let w:toggle_extra_chars['cursorline'] = &cursorline
    let w:toggle_extra_chars['colorcolumn'] = &colorcolumn
    let w:toggle_extra_chars['laststatus'] = &laststatus
    let w:toggle_extra_chars['ruler'] = &ruler
    let w:toggle_extra_chars['showcmd'] = &showcmd
    let w:toggle_extra_chars['showmode'] = &showmode
    let w:toggle_extra_chars['showtabline'] = &showtabline

    setlocal nonumber
    setlocal norelativenumber
    setlocal nolist
    setlocal nobreakindent
    setlocal showbreak=NONE
    setlocal nocursorline
    setlocal colorcolumn=
    setlocal laststatus=0
    setlocal noruler
    setlocal noshowcmd
    setlocal showtabline=0
  endif
endfunction

" An extremely naive command similar to "Goyo.vim", but only hide extra
" characters.
command! -bang -bar ToggleExtraChars call s:toggle_extra_chars(<q-bang>)
