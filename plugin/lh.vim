""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vim-localhistory
" Copyright (C) 2018 Gianmaria Bajo <mg1979.git@gmail.com>
" License: MIT License
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Init
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:lh_basedir              = get(g:, 'lh_basedir', '~/.vim/local_history')
let g:lh_open_mode            = get(g:, 'lh_open_mode', 'edit')
let g:lh_vert_diff            = get(g:, 'lh_vert_diff', 1)
let g:lh_autobackup_frequency = get(g:, 'lh_autobackup_frequency', 0)
let g:lh_autobackup_first     = get(g:, 'lh_autobackup_first', 0)
let g:lh_autobackup_size      = get(g:, 'lh_autobackup_size', 10240)


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

com! -nargs=? LHWrite call lh#backup_file(<f-args>)

com! LHLoadDated redraw! | call fzf#vim#files('', {'source': lh#find_files(0),
            \ 'sink': function('lh#open_backup'), 'down': '30%',
            \ 'options': '--multi --reverse --no-preview --prompt "Local History >>>  "'})

com! LHLoadSnapshot redraw! | call fzf#vim#files('', {'source': lh#find_files(1),
            \ 'sink': function('lh#open_backup'), 'down': '30%',
            \ 'options': '--multi --reverse --no-preview --prompt "Snapshots >>>  "'})

com! LHLoadAll redraw! | call fzf#vim#files('', {'source': lh#find_files(2),
            \ 'sink': function('lh#open_backup'), 'down': '30%',
            \ 'options': '--multi --reverse --no-preview --prompt "Snapshots >>>  "'})

com! LHDiff redraw! | call fzf#vim#files('', {'source': lh#find_files(2),
            \ 'sink': function('lh#diff'), 'down': '30%',
            \ 'options': '--reverse --no-preview --prompt "Diff with backup >>>  "'})

com! LHDelete redraw! | call fzf#vim#files('', {'source': lh#find_files(2),
            \ 'sink': function('lh#delete_backups'), 'down': '30%',
            \ 'options': '--multi --reverse --no-preview --prompt "Delete Backups >>>  "'})

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

fun! s:mapkeys(keys, plug)
    let plug = '<Plug>(LH-'.a:plug.')'
    if maparg(a:keys, 'n') == '' && !hasmapto(plug)
        silent! execute 'nmap <unique>' a:keys plug
    endif
endfun

if !exists('g:local_history_disable_mappings')
    call s:mapkeys('gha', 'LoadAll')
    call s:mapkeys('ghd', 'Diff')
    call s:mapkeys('ght', 'LoadDated')
    call s:mapkeys('ghs', 'LoadSnapshot')
    call s:mapkeys('ghT', 'WriteDated')
    call s:mapkeys('ghS', 'WriteSnapshot')
    call s:mapkeys('ghD', 'Delete')
endif

nnoremap <silent> <Plug>(LH-LoadAll)       :LHLoadAll<cr>
nnoremap <silent> <Plug>(LH-WriteDated)    :LHWrite<cr>
nnoremap          <Plug>(LH-WriteSnapshot) :LHWrite<Space>
nnoremap <silent> <Plug>(LH-LoadDated)     :LHLoadDated<cr>
nnoremap <silent> <Plug>(LH-LoadSnapshot)  :LHLoadSnapshot<cr>
nnoremap <silent> <Plug>(LH-Delete)        :LHDelete<cr>
nnoremap <silent> <Plug>(LH-Diff)          :LHDiff<cr>
