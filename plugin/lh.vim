""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-localhistory
" Copyright (C) 2018 Gianmaria Bajo <mg1979.git@gmail.com>
" License: MIT License
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists('g:loaded_localhistory')
    finish
endif
let g:loaded_localhistory = 1

" Preserve external compatibility options, then enable full vim compatibility
let s:save_cpo = &cpo
set cpo&vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Init
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if has('win32')
    let g:lh_basedir = get(g:, 'lh_basedir', '~/local_history')
else
    let g:lh_basedir = get(g:, 'lh_basedir', '~/.local_history')
endif

let g:lh_open_mode            = get(g:, 'lh_open_mode', 'edit')
let g:lh_vert_diff            = get(g:, 'lh_vert_diff', 1)
let g:lh_autobackup_frequency = get(g:, 'lh_autobackup_frequency', 0)
let g:lh_autobackup_first     = get(g:, 'lh_autobackup_first', 0)
let g:lh_autobackup_size      = get(g:, 'lh_autobackup_size', 10240)


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -nargs=? LHWrite  call lh#backup_file(<q-args>)

command! LHLoad            call lh#fzf('all', 'Local History')
command! LHLoadTimestamp   call lh#fzf('timestamped', 'Timestamped')
command! LHLoadSnapshot    call lh#fzf('snapshots', 'Snapshots')
command! LHDiff            call lh#fzf('diff', 'Diff with backup')
command! LHDelete          call lh#fzf('delete', 'Delete Backups')
command! LHBrowse          call lh#browse()

augroup plugin-lh
    autocmd!
    autocmd BufEnter * call lh#bufenter()

    if g:lh_autobackup_frequency
        autocmd BufWritePost * call lh#auto_backup()
    endif
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! s:mapkeys(keys, cmd, ...)
    let k = g:lh_mappings_prefix . a:keys
    let s = a:0 ? '<silent>' : ''
    if maparg(k, 'n') == '' && !hasmapto(a:cmd)
        execute 'nnoremap' s k a:cmd
    endif
endfun

if exists('g:lh_mappings_prefix') && !empty(g:lh_mappings_prefix)
    call s:mapkeys('l',       ':LHLoad<cr>')
    call s:mapkeys('d',       ':LHDiff<cr>')
    call s:mapkeys('t',       ':LHLoadTimestamp<cr>')
    call s:mapkeys('s',       ':LHLoadSnapshot<cr>')
    call s:mapkeys('w',       ':LHWrite<cr>', 1)
    call s:mapkeys('<space>', ':LHWrite<Space>')
    call s:mapkeys('x',       ':LHDelete<cr>')
    call s:mapkeys('b',       ':LHBrowse<cr>')
    call s:mapkeys('?',       ':nmap ' . g:lh_mappings_prefix . '<cr>')
endif

" Restore previous external compatibility options
let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=4 ts=4 sts=4
