"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Write backup
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:sep = has('win32') ? '\' : '/'

fun! lh#backup_file(name) abort
    " Write backup for current file.
    call s:make_backup_dir()

    if a:name != ''
        " named snapshot
        let stamp = "§ ".a:name
    else
        " use timestamp
        if has('win32')
            let stamp = printf("¦ %s_%s_%s %s", strftime("%Y"), strftime("%m"),
                        \                       strftime("%d"), strftime("%H_%M"))
        else
            let stamp = printf("¦ %s.%s.%s %s", strftime("%Y"), strftime("%m"),
                        \                       strftime("%d"), strftime("%H:%M"))
        endif
    endif

    let bkname = printf("%s%s%s %s", b:lh_dir, s:sep, expand("%:t"), stamp)
    call s:do_backup(bkname)
endfun


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Open/delete backups with fzf
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


fun! lh#fzf(cmd, prompt) abort
    " Run the fzf selection dialogue.
    if !exists('g:loaded_fzf')
        silent! delcommand LHLoad
        silent! delcommand LHLoadSnapshot
        silent! delcommand LHLoadTimestamp
        silent! delcommand LHDelete
        silent! delcommand LHDiff
        return s:msg('without fzf installed, only :LHBrowse is allowed.')
    endif

    let s:fzf_dir = s:bkdir()

    let opts = {}
    let opts.source  = a:cmd == 'timestamped' ? lh#find_files('timestamped')
                \    : a:cmd == 'snapshots'   ? lh#find_files('snapshots')
                \                             : lh#find_files('all')

    let opts.dir     = s:fzf_dir
    let opts.down    = '30%'
    let opts.options = [ '--prompt', a:prompt . ' >>> ' ]

    if executable('cat')
        let opts.options += ['--preview', 'cat {}']
    endif

    if a:cmd != 'diff'
        let opts['sink*'] = a:cmd == 'delete' ? function('lh#delete_backup')
                    \                         : function('lh#open_backup')
        let opts.options += ['--multi']
    else
        let opts.sink = function('lh#diff')
    endif

    if empty(opts.source)
        if a:cmd == 'timestamped'
            return s:msg('No timestamped backups for this file.')
        elseif a:cmd == 'snapshots'
            return s:msg('No snapshots for this file.')
        else
            return s:msg('No backups for this file.')
        endif
    endif

    call fzf#run(fzf#wrap(opts, 0))
endfun


fun! lh#find_files(type) abort
    " Generate a list of files for fzf.
    if !s:valid_file() | return [] | endif

    let files = s:get_files()

    if a:type == 'snapshots'
        call filter(files, 'v:val =~ " § "')

    elseif a:type == 'timestamped'
        call filter(files, 'v:val !~ " § "')
    endif

    return map(files, 'fnamemodify(v:val, ":t")')
endfun


fun! lh#open_backup(files) abort
    " Open the selected files.
    for file in a:files
        exe g:lh_open_mode s:bkpath(file)
        let &ft = s:filetype
    endfor
    unlet s:fzf_dir
endfun


fun! lh#delete_backup(files) abort
    " Delete the selected files.
    let deleted_files = []
    for file in a:files
        let path = s:fzf_dir . '/' . file
        if !delete(path)
            call add(deleted_files, "Deleted " . path)
        else
            call add(deleted_files, "Error deleting " . path)
        endif
    endfor
    botright 10new +setlocal\ bt=nofile\ bh=wipe\ noswf\ nobl
    0put =deleted_files
    $put ='  Press ENTER to dismiss'
    nnoremap <buffer><silent> <CR> :bw!<CR>
    syn keyword LHDeleted1 Deleted
    syn match LHDeleted2 '^Error deleting'
    syn match LHDeleted3 'Press ENTER to dismiss'
    hi def link LHDeleted1 Function
    hi def link LHDeleted2 Error
    hi def link LHDeleted3 WarningMsg
    unlet s:fzf_dir
endfun


fun! lh#diff(file) abort
    " Run a diff with the selected file.
    exe ( tabpagenr() - 1 ) . 'tabedit' @%
    diffthis
    let type = g:lh_vert_diff ? 'vertical' : ''
    exe type "diffsplit" s:bkpath(a:file)
    let &ft = s:filetype
    unlet s:fzf_dir
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Open backup directory in file browser
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


fun! lh#browse() abort
    " Open backup directory in file browser.
    if !isdirectory(s:bkdir())
        return s:msg('No backups for this file.')
    endif
    let cmd = get(g:, 'lh_browse_cmd', 'Explore')
    if !exists(':'.cmd)
        return s:msg('File browser is needed, read documentation.')
    endif
    exe cmd s:bkdir()
endfun




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" From autocommands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


fun! lh#bufenter() abort
    " Perform operations on BufEnter autocommand.
    if !s:valid_file() | return | endif
    let b:lh_dir = s:bkdir()

    if g:lh_autobackup_first
        let file = resolve(expand("%:p"))
        if !filereadable(file) | return | endif
        if getfsize(file) > g:lh_autobackup_size | return | endif

        call s:make_backup_dir()
        let bkname = expand("%:t") . " § AUTOSAVE"
        if !filereadable(b:lh_dir . s:sep . bkname)
            call lh#backup_file('AUTOSAVE')
        endif
    endif
endfun


fun! lh#auto_backup() abort
    " Perform an automatic backup if option is set.
    if !s:valid_file() || !executable('stat') | return | endif
    if getfsize(resolve(expand("%:p"))) > g:lh_autobackup_size | return | endif

    let now      = system('date +%s')
    let recent   = 0
    let files    = s:get_files()
    let basename = expand("%:t")

    " exclude other files in the same dir that are not the current one
    let file_pattern = '^' . s:bkpath(basename) . ' ¦\|§'
    call filter(files, 'v:val =~ file_pattern')

    " find the last time of modification for matching backup files
    for f in files
        let last_mod = system('stat -c %Y '.fnameescape(f))
        if last_mod > recent
            let recent = last_mod
        endif
    endfor

    " create new backup if the most recent is older than lh_autobackup_frequency
    if now - recent > g:lh_autobackup_frequency*60
        call lh#backup_file('')
    endif
endfun



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helpers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


fun! s:bkpath(file) abort
    " Escaped file path of the backup.
    if exists('s:fzf_dir')    | return fnameescape(s:fzf_dir . '/' . a:file)
    elseif exists('b:lh_dir') | return fnameescape(b:lh_dir . '/' . a:file)
    else                      | return s:msg('invalid file', 1)
    endif
endfun


fun! s:bkdir() abort
    " The path for the backup directory for the current file.
    if has('win32')
        let base = fnamemodify(expand(g:lh_basedir), ":p:h")
        let file = fnamemodify(resolve(expand("%")), ":p:h")
        let path = base . '/' . substitute(file, ':', '', '')
        return expand(path)
    else
        return expand(
                    \ fnamemodify(expand(g:lh_basedir), ":p:h") .
                    \ fnamemodify(resolve(expand("%")), ":p:h"))
    endif
endfun


fun! s:make_backup_dir()
    " Ensure the backup directory exists.
    if !isdirectory(expand(g:lh_basedir))
        call mkdir(expand(g:lh_basedir), "p")
    endif
    let b:lh_dir = s:bkdir()
    if !isdirectory(b:lh_dir)
        call mkdir(b:lh_dir, "p")
    endif
endfun


fun! s:get_files() abort
    " Return a list of valid files in the backup directory.
    let s:filetype = &filetype
    let b:lh_dir = s:bkdir()
    let files = split(globpath(b:lh_dir, "*", 1), '\n')
    let hidden = split(globpath(b:lh_dir, ".*", 1), '\n')
    return filter(extend(files, hidden), '!isdirectory(v:val)')
endfun


fun! s:valid_file() abort
    " If a file is eligible for backup or not.
    return buflisted(bufnr('')) && &buftype == '' && expand('%:p') !~ '\V\^'.expand(g:lh_basedir)
endfun


fun! s:do_backup(bkname) abort
    " Perform the actual backup operation on the file.
    if !filereadable(resolve(expand("%:p")))
        return s:msg("source file doesn't exist", 1)
    endif
    let cmd = has('win32') ? 'copy' : 'cp'
    silent exe '!'.cmd shellescape(resolve(expand("%:p"))) shellescape(a:bkname)
    redraw!
    echom "Created" a:bkname
endfun


fun! s:msg(txt, ...)
    " Print a message, optionally as an error.
    if a:0
        echoerr '[local-history]' a:txt
    else
        echo '[local-history]' a:txt
    endif
endfun


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim: et sw=4 ts=4 sts=4 fdm=indent fdn=1
