if exists('g:fvim_loaded')
    set guifont=Cascadia\ Code:h16
    " Ctrl-ScrollWheel for zooming in/out
    nnoremap <silent> <C-ScrollWheelUp> :set guifont=+<CR>
    nnoremap <silent> <C-ScrollWheelDown> :set guifont=-<CR>
    nnoremap <A-CR> :FVimToggleFullScreen<CR>
endif

if exists('g:fvim_loaded')
    FVimCursorSmoothMove v:true
    FVimCursorSmoothBlink v:true
endif
