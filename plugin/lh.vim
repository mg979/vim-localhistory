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

com! LHLoadDated call fzf#run({'source': lh#find_files(0),
            \ 'sink': function('lh#open_backup'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Local History >>>  "'})

com! LHLoadSnapshot call fzf#run({'source': lh#find_files(1),
            \ 'sink': function('lh#open_backup'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Snapshots >>>  "'})

com! LHLoadAll call fzf#run({'source': lh#find_files(2),
            \ 'sink': function('lh#open_backup'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Snapshots >>>  "'})

com! LHDiff call fzf#run({'source': lh#find_files(2),
            \ 'sink': function('lh#diff'), 'down': '30%',
            \ 'options': '--reverse --prompt "Diff with backup >>>  "'})

com! LHDelete call fzf#run({'source': lh#find_files(2),
            \ 'sink': function('lh#delete_backups'), 'down': '30%',
            \ 'options': '--multi --reverse --prompt "Delete Backups >>>  "'})

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

if !exists('g:local_history_disable_mappings')
    if !hasmapto('<Plug>LHLoadAll')
        map <unique> gha <Plug>LHLoadAll
    endif
    if !hasmapto('<Plug>LHDiff')
        map <unique> ghd <Plug>LHDiff
    endif
    if !hasmapto('<Plug>LHLoadDated')
        map <unique> ght <Plug>LHLoadDated
    endif
    if !hasmapto('<Plug>LHLoadSnapshot')
        map <unique> ghs <Plug>LHLoadSnapshot
    endif
    if !hasmapto('<Plug>LHWriteDated')
        map <unique> ghT <Plug>LHWriteDated
    endif
    if !hasmapto('<Plug>LHWriteSnapshot')
        map <unique> ghS <Plug>LHWriteSnapshot
    endif
    if !hasmapto('<Plug>LHDelete')
        map <unique> ghD <Plug>LHDelete
    endif
endif

nnoremap <silent> <unique> <script> <Plug>LHLoadAll       :LHLoadAll<cr>
nnoremap <silent> <unique> <script> <Plug>LHWriteDated    :LHWrite<cr>
nnoremap <unique> <script>          <Plug>LHWriteSnapshot :LHWrite<Space>
nnoremap <silent> <unique> <script> <Plug>LHLoadDated     :LHLoadDated<cr>
nnoremap <silent> <unique> <script> <Plug>LHLoadSnapshot  :LHLoadSnapshot<cr>
nnoremap <silent> <unique> <script> <Plug>LHDelete        :LHDelete<cr>
nnoremap <silent> <unique> <script> <Plug>LHDiff          :LHDiff<cr>
