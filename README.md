### Vim Local History


---
#### Introduction                                                

This plugin is a port of Sublime Text localhistory plugin.

Features:

* automatic backup directories generation, mirroring actual file path
* save backups with date or name (snapshots)
* load/delete backups with fzf
* diff with dated backups/snapshots
* optional autobackup on first load (configurable max size)
* optional autobackup on save, if no recent backups are found (configurable)



---
#### Requirements                                         

[fzf-vim](https://github.com/junegunn/fzf.vim) is required.

Tested in Linux only.



---
#### Installation                                         

Use [vim-plug](https://github.com/junegunn/vim-plug) or any other Vim plugin manager.

With vim-plug:

    Plug 'mg979/vim-localhistory'



---
#### Usage                                                       

You can set the base directory:

    let g:lh_basedir = '~/.vim/local_history'

When saving a backup, the file will mirror the original path inside the base dir:

    /some/path/file -> ~/.vim/local_history/some/path/file

Disable keymappings with:

    let g:local_history_disable_mappings = 1

Change the position in which files are opened (eg. |vs|, |sp|, |edit|, |botright| |vs|, etc):

    let g:lh_open_mode = 'bo vs'

Set to 0 if you prefer horizontal split for diff windows:

    let g:lh_vert_diff = 0



---
#### Autobackup                                             

To enable autobackup, you must first set these variables. It will only work
after Vim has beee restarted.

Activate autobackup on first access to a file, and max size (default 10240 bytes):

  `let g:lh_autobackup_first = 1`
  `let g:lh_autobackup_size  = 51200`

Activate autobackup after save, if no recent backup is found (frequency in minutes):

    `let g:lh_autobackup_frequency = 60`



---
#### Commands                                                  


|----------------------|------------------------|---------|
|Command               | Mapping                | Default |
|----------------------|------------------------|---------|
|:LHwrite              | `<Plug>LHWriteDated`   | ght     |
|:LHwrite <name>       | `<Plug>LHWriteSnapshot`| ghs     |
|:LHdiff               | `<Plug>LHDiff`         | ghd     |
|:LHdated              | `<Plug>LHLoadDated`    | ghT     |
|:LHsnapshot           | `<Plug>LHLoadSnapshot` | ghS     |
|:LHdelete             | `<Plug>LHDelete`       | ghD     |

    LHwrite         : write a backup with date
    LHwrite <name>  : write a named backup (snapshot)
    LHdated         : load a backup with a date
    LHsnapshot      : load a snapshot
    LHdiff          : select a backup and open a split diff window
    LHdelete        : delete backups for current dir (all types)

LHdated, LHsnapshot, LHdiff and LHdelete use fzf, and you can select multiple files.



---
#### Credits                                                   

Braam Moolenaar for Vim



---
#### License                                                   

MIT


