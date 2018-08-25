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
    let s:dir = b:lh_dir
    let files = split(globpath(b:lh_dir, "*", 1), '\n')
    let hidden = split(globpath(b:lh_dir, ".*", 1), '\n')
    let files = extend(files, hidden)
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

    let bkname = b:lh_dir.lh#sep().fname." ".bkname
    silent exe '!cp '.fnameescape(resolve(expand("%:p"))).' '.fnameescape(bkname)
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
        let file = substitute(file, b:lh_dir.lh#sep(), "", "")
        call add(short_names, file)
    endfor

    return short_names
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#delete_backups(...)
    for file in a:000
        let path = fnameescape(s:dir.lh#sep().file)
        silent execute '!rm '.path
        redraw!
        echom "Deleted ".path
    endfor
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#open_backup(file)
    exe g:lh_open_mode. " " . fnameescape(s:dir.lh#sep().a:file)
    if exists('g:loaded_xtabline')
        call add(g:xtabline.Tabs[tabpagenr()-1].buffers.extra, bufnr("%"))
    endif
    let &syntax = s:file_syntax
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#diff(file)
    diffthis
    let vert = g:lh_vert_diff ? 'vert ' : ''
    exe vert."diffsplit ".lh#full_path(a:file)
    let &syntax = s:file_syntax
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#sep()
    return exists('+shellslash') && &shellslash ? '\' : '/'
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#full_path(file)
    return fnameescape(b:lh_dir.lh#sep().a:file)
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#auto_backup()
    if getfsize(resolve(expand("%:p"))) > g:lh_autobackup_size | return | endif
    let now = system('date +%s') | let recent = 0
    let files = lh#get_files() | let basename = expand("%:t")

    " exclude other files in the same dir that are not the current one
    call filter(files, 'v:val =~ "^".b:lh_dir.lh#sep().basename." "')

    " find the last time of modification for matching backup files
    for f in files
        let last_mod = system('stat -c %Y '.fnameescape(f))
        if last_mod > recent | let recent = last_mod | endif
    endfor

    " create new backup if the most recent is older than lh_autobackup_frequency
    if now - recent > g:lh_autobackup_frequency*60
        call lh#backup_file()
    endif
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

fun! lh#bufenter()
    let b:lh_dir = expand(fnamemodify(expand(g:lh_basedir), ":p:h").fnamemodify(resolve(expand("%")), ":p:h"))

    if g:lh_autobackup_first
        let file = resolve(expand("%:p"))
        if !filereadable(file) | return | endif
        if getfsize(file) > g:lh_autobackup_size | return | endif

        if !isdirectory(b:lh_dir) | call lh#make_backup_dir() | endif

        let fname = expand("%:t")
        let bkname = b:lh_dir.lh#sep().fname." § AUTOSAVE"
        if !filereadable(bkname)
            silent exe '!cp '.fnameescape(file).' '.fnameescape(bkname)
            redraw!
            echom "Created ".bkname
        endif
    endif
endfun

