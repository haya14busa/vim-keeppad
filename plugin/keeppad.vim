"=============================================================================
" FILE: plugin/keeppad.vim
" AUTHOR: haya14busa
" DESCRIPTION: Keep left padding by always showing sign column. It works well
" with :set nonumber. See :h SignColumn for sign column.
" License: MIT license
"=============================================================================
scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_keeppad
endif
if exists('g:loaded_keeppad')
  finish
endif
let g:loaded_keeppad = 1
let s:save_cpo = &cpo
set cpo&vim

" function! s:id(name) abort
"   return eval(join(map(split(a:name, '\zs'), 'char2nr(v:val)'), '+'))
" endfunction
" echo s:id('keeppad')
" => 1148
let s:ID = get(g:, 'keeppad_id', 1148)

" There is a transparent char after 'text='
sign define keeppad text=ㅤ texthl=SignColumn

let g:keeppad_autopadding = get(g:, 'keeppad_autopadding', 1)
let g:keeppad_no_hl = get(g:, 'keeppad_no_hl', 1)
let g:keeppad_hook_number_option = get(g:, 'keeppad_hook_number_option', 1)

let s:ON = g:keeppad_autopadding

command! KeeppadOn  call s:on()
command! KeeppadOff call s:off()

if g:keeppad_autopadding
  augroup plugin-keeppad-dummysign
    autocmd!
    autocmd BufWinEnter * if !&number | call <SID>dummysign() | endif
    autocmd VimEnter * call <SID>clear_auto()
    if g:keeppad_hook_number_option
      autocmd OptionSet * call s:optionset()
    endif
  augroup END


function! s:optionset() abort
  if s:ON && expand('<amatch>') is# 'number'
    if v:option_new
      call s:dummysign_off()
    else
      call s:clear_enable_auto()
      call s:dummysign()
    endif
  endif
endfunction
endif

function! s:dummysign() abort
  execute printf('sign place %d line=%d name=keeppad buffer=%d', s:ID, 1, bufnr('%'))
endfunction

function! s:dummysign_off() abort
  execute printf('sign unplace %d buffer=%d', s:ID, bufnr('%'))
endfunction

function! s:clear_auto() abort
  if g:keeppad_no_hl
    call s:clear_hi()
    call s:clear_enable_auto()
  endif
endfunction

function! s:clear_enable_auto() abort
  augroup plugin-keeppad-clear-hi
    autocmd!
    autocmd ColorScheme * call <SID>clear_hi()
  augroup END
endfunction

function! s:clear_hi() abort
  highlight SignColumn ctermbg=None
endfunction

function! s:clear_hi_off() abort
  autocmd! plugin-keeppad-clear-hi
  if g:keeppad_no_hl
    let colors_name = get(g:, 'colors_name', '')
    if colors_name isnot# ''
      try
        execute 'colorscheme ' . colors_name
      endtry
    endif
  endif
endfunction

function! s:on() abort
  let s:ON = 1
  call s:clear_auto()
  call s:dummysign()
endfunction

function! s:off() abort
  let s:ON = 0
  call s:dummysign_off()
  call s:clear_hi_off()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
