" =============================================================================
" A plugin to make vim stand well with input methods (Mac only)
" Author:       Ying Bian <bianying@gmail.com>
" Last Change:  2017-03-30
" Version:      1.0.0
" Repository:   https://github.com/ybian/smartim
" License:      MIT
" =============================================================================

if exists('g:smartim_loaded') || &cp
  finish
endif
let g:smartim_loaded = 1

if !exists("g:smartim_default")
  let g:smartim_default = "com.apple.keylayout.US"
endif

if !exists("g:smartim_disable")
  let g:smartim_disable = 0
endif

if !exists("g:smartim_debug")
  let g:smartim_debug = 0
endif

let s:imselect_path = expand('<sfile>:p:h') . "/im-select "
let s:smartim_debug_output = $HOME . "/vim_smartim_debug_output"

function! Smartim_debug_print(msg)
  if g:smartim_debug == 0
    return
  endif

  let l:debug_msg = strftime("[%Y-%m-%d_%H:%M:%S]") . ' ' . a:msg
  silent call writefile([l:debug_msg], s:smartim_debug_output, "a")
endfunction

function! Smartim_start_debug()
  if g:smartim_debug == 0
    return
  endif

  let l:start_debug_msg = strftime("[%Y-%m-%d_%H:%M:%S]") . " - Debug Start"
  silent call writefile([l:start_debug_msg], s:smartim_debug_output)

  call Smartim_debug_print('g:smartim_loaded = ' . g:smartim_loaded)
  call Smartim_debug_print('g:smartim_default = ' . g:smartim_default)
  call Smartim_debug_print('g:smartim_disable = ' . g:smartim_disable)
  call Smartim_debug_print('g:smartim_debug = ' . g:smartim_debug)
  call Smartim_debug_print('s:imselect_path = ' . s:imselect_path)
endfunction

call Smartim_start_debug()

function! Smartim_SelectDefault()
  call Smartim_debug_print('>>> Smartim_SelectDefault')

  if g:smartim_disable == 1
    return
  endif

  silent let b:saved_im = system(s:imselect_path . g:smartim_default)

  call Smartim_debug_print('b:saved_im = ' . b:saved_im)
  call Smartim_debug_print('<<< Smartim_SelectDefault returned ' . v:shell_error)
endfunction

function! Smartim_SelectSaved()
  call Smartim_debug_print('>>> Smartim_SelectSaved')

  if g:smartim_disable == 1
    return
  endif

  if exists("b:saved_im")
    silent call system(s:imselect_path . b:saved_im)
    call Smartim_debug_print('b:saved_im = ' . b:saved_im)
    call Smartim_debug_print('<<< Smartim_SelectSaved returned ' . v:shell_error)
  else
    call Smartim_debug_print('<<< Smartim_SelectSaved returned')
  endif
endfunction

let s:action = 1
function! CheckedApply(func)
  if s:action
    call a:func()
  endif
endfunction

let s:timer = -1
function! SwitchIM(use_saved)
    call timer_pause(s:timer, 1)
    let l:info = timer_info(s:timer)
    if !empty(l:info)
      if l:info[0].repeat != 0 "seem useless
        let s:action = s:applying_saved == a:use_saved
      endif
      call timer_pause(s:timer, 0)
    else
      let s:action = 1
      if a:use_saved
        let s:applying_saved = 1
        let s:timer = timer_start(50, {-> CheckedApply(function('Smartim_SelectSaved'))})
      else
        let s:applying_saved = 0
        let s:timer = timer_start(50, {-> CheckedApply(function('Smartim_SelectDefault'))})
      endif
    endif
endfunction

augroup smartim
  autocmd!
  autocmd VimLeavePre * call SwitchIM(0)
  autocmd InsertLeave * call SwitchIM(0)
  autocmd InsertEnter * call SwitchIM(1)
augroup end

" vim:ts=2:sw=2:sts=2
