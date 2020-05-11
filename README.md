### Vim Local History


#### Introduction

This plugin creates automatic and/or manual backups for your files, in
predefined paths. Backups are browsed with fzf or built-in `:Explore`.

Features:

* automatic backup directories generation, mirroring actual file path
* save backups with timestamp or name (snapshots)
* load/delete backups with fzf
* perform diffs
* optional autobackup on first load (configurable max size)
* optional autobackup on save, if no recent backups are found (configurable)



#### Requirements

[fzf](https://github.com/junegunn/fzf) is required for many commands.




#### Installation

Use [vim-plug](https://github.com/junegunn/vim-plug) or any other Vim plugin manager.

With vim-plug:

    Plug 'mg979/vim-localhistory'



#### Usage

Default base directory is `~/.local_history` (Unix) or `~\local_history` (Windows):

    let g:lh_basedir = '~/.local_history'

When saving a backup, the file will mirror the original path inside the base dir:

    /path/to/file -> ~/.local_history/path/to/file

To enable mappings, specify a prefix, for example:

    let g:lh_mappings_prefix = 'gh'

Change the position in which files are opened (eg. `vs`, `sp`, `edit`, `botright` `vs`, etc):

    let g:lh_open_mode = 'bo vs'

Set to 0 if you prefer horizontal split for diff windows:

    let g:lh_vert_diff = 0



#### Autobackup

To enable autobackup, you must first set these variables. It will only work
after Vim has been restarted. Max size affects both types of autobackup.

Activate autobackup on first access to a file, and max size (default 10240 bytes):

    let g:lh_autobackup_first = 1
    let g:lh_autobackup_size  = 51200

Activate autobackup after save, if no recent backup is found (frequency in minutes):

    let g:lh_autobackup_frequency = 60




#### Commands


|Command               |  Map                  |                                              |
|----------------------|-----------------------|----------------------------------------------|
|:LHLoad               |  ghl                  | load either timestamped backup or snapshot   |
|:LHLoadTimestamp      |  ght                  | load a backup with timestamp                 |
|:LHLoadSnapshot       |  ghs                  | load a snapshot                              |
|:LHWrite              |  ghw                  | write a backup with timestamp                |
|:LHWrite <name>       |  gh <kbd>Space</kbd>  | write a named backup (snapshot)              |
|:LHDiff               |  ghd                  | select a backup and open a split diff window |
|:LHDelete             |  ghx                  | delete backups for current dir (all types)   |
|:LHBrowse             |  ghb                  | browse the current backup directory          |

The displayed mappings are only enabled if a prefix has been defined (here `gh`
is used, as example). Commands use *fzf*, and you can select multiple files.




#### Credits

Bram Moolenaar for Vim




#### License


MIT


