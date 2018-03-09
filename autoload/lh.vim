"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#make_backup_dir()
    if !isdirectory(b:lh_dir)
        call mkdir(b:lh_dir, "p")
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#get_files()
    let s:file_syntax = &syntax
    let files = globpath(b:lh_dir, "*", 1)
    let files = split(files, '\n')
    return filter(files, '!isdirectory(v:val)')
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#backup_file(...)
    call lh#make_backup_dir()
    let fname = expand("%:t")

    if a:000 != []
        let bkname = "§ ".a:1
    else
        let bkname = "¦ ".strftime("%Y").".".strftime("%m")."."
        let bkname .= strftime("%d")." ".strftime("%H:%M")." ¦"
    endif

    let bkname = b:lh_dir."/".fname." ".bkname
    silent exe '!cp '.escape(expand("%:p"), ' ').' '.escape(bkname, ' ')
    redraw!
    echom "Created ".bkname
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#find_files(is_snap)
    let short_names = [] | let files = lh#get_files()

    if a:is_snap != 2
        let op = a:is_snap ? '=~' : '!~'
        call filter(files, 'v:val '.op.' " § "') | endif

    for file in files
        let file = substitute(file, b:lh_dir."/", "", "")
        call add(short_names, file)
    endfor

    return short_names
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#delete_backups(...)
    for file in a:000
        let path = lh#full_path(file)
        silent execute '!rm '.path 
        redraw!
        echom "Deleted ".path
    endfor
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#open_backup(file)
    exe "edit ".lh#full_path(a:file)
    let &syntax = s:file_syntax
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#full_path(file)
    return escape(b:lh_dir."/".a:file, ' ')
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#auto_backup()

endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#auto_first()

endfun

