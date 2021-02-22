" ==============================================================================
" @@@ general
" ==============================================================================
set nocompatible
set ttyfast

set hidden
set nobackup
set noswapfile

syntax on
set background=dark
set termguicolors

" set rulerformat=%40(%#BFaint#%=%t\ \ %l:%c%)
" set laststatus=0
set statusline=%<%F\ \ \ %=%l\ %c
set laststatus=2 " Always show status line.

set showcmd
set nonumber " Don't show line numbers
set noshowmode " Don't show mode. That's just silly.
set shortmess=atIWF " Don't show intro message.
let loaded_matchparen=1 " Don't highlight matching parens.
let c_no_bracket_error=1
let c_no_curly_error=1

filetype indent on
set autoindent
set nowrap
set nojoinspaces
set formatoptions=roqclj " No line wrap and remove comment when joining lines.
set eadirection=hor " The height of windows will not be changed when resizing, only width.
set backspace=indent,eol,start " Correct backspacing in insert mode.

set tabstop=4 " Show existing tab with 4 spaces width.
set expandtab " On pressing tab, insert 4 spaces.
set shiftwidth=4 " When indenting with '>', use 4 spaces width.
set cinkeys-=0# " Don't unintend C preprocessor directives.
set cinoptions=l1,:0,c0,C1 " Some indent rules mostly for switch statements.

set incsearch
set ignorecase
set smartcase
set suffixes=,,
set wildmenu
set wildignorecase
set wildignore=*.svg,*.png,*.mo,*.ogg,*.gz,*.out,*.o,*.dep
set wildcharm=<Tab> " So we can use "\<Tab>".

let g:netrw_list_hide  = '.*\.svg,.*\.png,.*\.jpg,.*\.mo,.*\.ogg,.*\.gz,.*\.out,.*\.o,.*\.dep'
let g:netrw_banner     = 0
let g:netrw_altv       = 1
let g:netrw_fastbrowse = 2
let g:netrw_keepdir    = 1

set guifont=Fira\ Mono\ for\ Powerline\ Medium\ 13px
set mouse+=a " Enable mouse in all modes.
set mouseshape=v:arrow
set guicursor+=a:BgNormal
set guicursor+=a:block
set guicursor+=a:blinkon0
set guioptions-=m " Remove menu bar.
set guioptions-=T " Remove toolbar.
set guioptions-=r " Remove right-hand scroll bar.
set guioptions-=L " Remove left-hand scroll bar.
set guioptions-=e " Don't use gui tabs.
set guioptions+=c " Don't use gui dialogs.
set guioptions+=! " External commands are executed in a terminal window.


" ==============================================================================
" @@@ functions and autocommands
" ==============================================================================
" This is a collection of custom function that will appear 
" in the List_custom_commands() buffer. 
" To add a function here define it like: func! s:custom_command.Foo()
let s:custom_command = {}

augroup autocommands
    au!

    au CmdlineEnter /,\? :set hlsearch
    au CmdlineLeave /,\? :set nohlsearch  " Unhighlight the search automatically.

    au QuickFixCmdPost [^l]* vert cwindow 100
    au QuickFixCmdPost l*    vert lwindow 100

    au FileType netrw setl bufhidden=delete
    au FileType netrw set nocursorline
augroup END

" @prompt       : string
" @prompt_color : string (a highlight group)
" @returns      : string
func! Prompt(str, hi_group)
    redraw
    execute('echohl ' . a:hi_group)
    call inputsave()
    let result = input(a:str, '')
    call inputrestore()
    redraw
    return result
endf

" @list         : list (list of lines to fuzzy search)
" @prompt       : string
" @prompt_color : string (a highlight group)
" @returns      : list of 2 [selection, vertically]
"     @selection  : string (selected line)
"     @vertically : bool   (true if user made selection with ctrl-v)
func! Lister(list, prompt, prompt_color) abort
    let l:laststatus_backup = &l:laststatus

    func! Lister_close(selection, do_vert, laststatus_backup)
        let l:buf = bufnr("%")
        let &l:laststatus=a:laststatus_backup
        wincmd p
        execute "bwipe" l:buf
        redraw
        echo "\r"
        return [a:selection, a:do_vert]
    endf

    botright 16new +setlocal\ buftype=nofile\ bufhidden=wipe\
        \ nobuflisted\ nonumber\ norelativenumber\ noswapfile\ nowrap\
        \ foldmethod=manual\ nofoldenable\ modifiable\ noreadonly

    setlocal cursorline | let &l:laststatus=0

    call setline(1, a:list)
    let l:needle  = ""
    let l:undoseq = []

    while 1
        redraw | execute('echohl ' . a:prompt_color) | echon a:prompt | echohl Normal | echon l:needle | echohl None

        try
            let ch = getchar()
        catch /^Vim:Interrupt$/  " Ctrl-c
            return Lister_close('', 0, l:laststatus_backup)
        endtry

        if ch ==# "\<bs>" " Backspace
            let l:needle = l:needle[:-2]
            let l:undo = empty(l:undoseq) ? 0 : remove(l:undoseq, -1)
            if l:undo
                silent norm u
            endif
            call cursor(1, 1)
        elseif ch ==# 0x17 " Ctrl-w (clear)
            call cursor(1, 1)
            call setline(1, a:list)
            let l:needle  = ""
            let l:undoseq = []
        elseif ch >=# 0x20 " Printable character
            let l:needle  .= nr2char(ch)
            let l:seq_old  = get(undotree(), 'seq_cur', 0)
            execute 'silent keepp g!:' . needle . ':norm "_dd'
            let l:seq_new = get(undotree(), 'seq_cur', 0)
            call cursor(1, 1)
            call add(l:undoseq, l:seq_new != l:seq_old)
        elseif ch ==# 0x09 " Tab
            let l:needle .= '.*'
            let l:seq_old  = get(undotree(), 'seq_cur', 0)
            execute 'silent keepp g!:' . needle . ':norm "_dd'
            let l:seq_new = get(undotree(), 'seq_cur', 0)
            call cursor(1, 1)
            call add(l:undoseq, l:seq_new != l:seq_old)
        elseif ch ==# 0x1B " Escape
            return Lister_close('', 0, l:laststatus_backup)
        elseif ch ==# 0x0D " Enter
            return Lister_close(getline('.'), 0, l:laststatus_backup)
        elseif ch ==# 0x16 " CTRL-v
            return Lister_close(getline('.'), 1, l:laststatus_backup)
        elseif ch ==# 0x0B " Ctrl-k
            norm k
        elseif ch ==# 0x0A " Ctrl-j
            norm j
        endif
    endwhile
endf

func! Go_to_next_search_result(direction)
    let cmd = (a:direction == 1) ? "\<C-g>" : "\<C-t>"
    return repeat(cmd, 1)
endf

func! Is_in_search_mode()
    return getcmdtype() =~# '[/\?]'
endf

func! Align(type, ...)
    let char    = nr2char(getchar())
    let lines   = a:0 ? range(line("'<"), line("'>")) : range(line("'["), line("']"))
    let max_col = 0

    for i in lines
        call cursor(i, 0)
        let col = stridx(getline(i), char)
        if col > max_col | let max_col = col | endif
    endfor

    for i in lines
        call cursor(i, 0)

        let col = stridx(getline(i), char)
        if col == -1 | continue | endif

        let n_to_insert = max_col - col
        if n_to_insert == 0 | continue | endif

        call cursor(i, col)
        execute "normal! " n_to_insert . "a \<esc>"
    endfor
endf

func! Toggle_comment(type, ...)
    if !exists("s:comment_map") | let s:comment_map = { "c": '\/\/', "cpp": '\/\/', "rust": '\/\/', "lua": '--', "python": '#', "javascript": '\/\/', "sh": '#', "desktop": '#', "conf": '#', "profile": '#', "bashrc": '#', "bash_profile": '#', "vim": '"', } | endif
    if !has_key(s:comment_map, &filetype) | echo "No comment leader found for filetype" | return | endif

    let leader = s:comment_map[&filetype]
    let lines  = a:0 ? range(line("'<"), line("'>")) : range(line("'["), line("']"))

    for i in lines
        call cursor(i, 0)
        let line = getline(i)

        if line =~ '^\s*$' | continue | endif
        if line =~ '^\s*' . leader | execute 'silent s/\v\s*\zs' . leader . '\s*\ze//' | else | execute 'silent s/\v^(\s*)/\1' . leader . ' /' | endif
    endfor
endf

func! s:custom_command.Open_vimrc()
    :e $MYVIMRC
endf

func! s:custom_command.Diff_against_n_minutes_ago()
    let n = Prompt('How many minutes ago >>> ', 'Bold')
    if n != '' | execute('earlier ' . n . 'm | %y | later ' . n . 'm | diffthis | vnew | setlocal buftype=nofile | setlocal bufhidden=hide | setlocal nobuflisted | put | 1d | diffthis') | endif
endf

func! s:custom_command.Strip_trailing_whitespace()
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endf

func! s:custom_command.Change_language()
    let n = Prompt('Which language >>> ', 'Bold')
    execute('set syntax=' . n)
endf

func! List_files()
    let files = globpath('.', '**/*', 0, 1)
    " let files = systemlist("find . -not -path '*/\.*' ! -name '*.o' ! -name '*.dep'")
    let [file, do_vert] = Lister(files, 'Files >>> ' , 'Bold')
    if     file == '' | return
    elseif do_vert    | execute "vs \| edit" file
    else              | execute 'edit' file
    endif
endf

func! List_buffers()
    let buffers = map(split(execute('ls'), '\n'), 'strcharpart(v:val, 0)')
    let [buf, do_vert] = Lister(buffers, 'Buffers >>> ', 'Bold')
    if     buf == '' | return
    elseif do_vert   | execute "vs \| buffer" split(buf)[0]
    else             | execute 'buffer' split(buf)[0]
    endif
endf

func! List_custom_commands()
    let [f, _] = Lister(keys(s:custom_command), 'Custom Functions >>> ', 'Bold')
    if f != '' | execute('call s:custom_command.' . f . '()') | endif
endf

func! Do_global_search(needle)
    let n = escape(a:needle, '/\')
    execute('vimgrep /\C\V' . n . '/j ** | copen | match QuickFixSearch /\V' . n . '/')
endf

func! Global_search()
    let text = Prompt('Global search >>> ', 'Bold')
    if text == '' | return | endif
    call Do_global_search(text)
endf

func! s:custom_command.Global_search_and_replace()
    let old = escape(Prompt('Old >>> ', 'Bold'), '/\')
    let new = escape(Prompt('New >>> ', 'Bold'), '/\')
    call Do_global_search(old)
    execute('cfdo %s/' . old . '/' . new . '/gI | w')
endf

" ==============================================================================
" @@@ keybindings
" ==============================================================================
cabbrev h vert h
cabbrev term vert term ++close
iabbrev printf printf("%i\n",);<Left><Left>

let mapleader=','

imap jk <Esc><Esc>
imap JK <Esc><Esc>
imap Jk <Esc><Esc>
tmap <Esc> <C-\><C-n>

map <silent> <Leader>s :write<CR>
map <silent> <Leader>q :close<CR>

nnoremap L w
vnoremap L w
nnoremap H b
vnoremap H b
noremap  J 4j
noremap  K 4k
noremap  M J

noremap <space> $
noremap <S-space> $
noremap - ^

noremap f /
noremap F ?

nnoremap Y  y$
noremap  gp "+p
noremap  gy "+y

nnoremap <expr> <CR> &buftype ==# 'quickfix' ? "\<CR>" : ':normal o<CR>'

nnoremap <Leader>v <C-w>v

nnoremap r @
vnoremap r :normal! @q<CR>
vnoremap . :normal! .<CR>

vnoremap <expr> i mode() =~ '\cv' ? 'i' : 'I'
vnoremap <expr> a mode() =~ '\cv' ? 'a' : 'A'

nnoremap <silent> <Leader>a :execute 'Vexplore' getcwd()<CR>
vnoremap <silent> <Leader>, y:call Do_global_search(@@)<CR>
nnoremap <silent> <Leader>, :call Global_search()<CR>
nnoremap <silent> <Leader>f :call List_files()<CR>
nnoremap <silent> <Leader>b :call List_buffers()<CR>
nnoremap <silent> <Leader>c :call List_custom_commands()<CR>
nnoremap <silent> <Leader>t :vert term ++close<CR>

nnoremap <silent> ga :set opfunc=Align<CR>g@
vnoremap <silent> ga :<C-U>call Align(visualmode(), 1)<CR>

nnoremap <silent> gc  :set opfunc=Toggle_comment<CR>g@
vnoremap <silent> gc  :<C-U>call Toggle_comment(visualmode(), 1)<CR>
nnoremap <silent> gcc :normal gcl<CR>

nnoremap <silent> e :cnext<CR>
nnoremap <silent> E :cprevious<CR>

nnoremap j  gj
nnoremap k  gk
nnoremap gj j
nnoremap gk k

cnoremap <expr> <S-Tab> Is_in_search_mode() ? Go_to_next_search_result(0) : "\<S-Tab>"
cnoremap <expr> <Tab>   Is_in_search_mode() ? Go_to_next_search_result(1) : "\<Tab>"
cnoremap <expr> <C-k>   Is_in_search_mode() ? Go_to_next_search_result(0) : "\<Up>"
cnoremap <expr> <C-j>   Is_in_search_mode() ? Go_to_next_search_result(1) : "\<Down>"
cnoremap <C-h> <Left>
cnoremap <C-l> <Right>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

tmap <C-h> <C-w>h
tmap <C-j> <C-w>j
tmap <C-k> <C-w>k
tmap <C-l> <C-w>l

noremap <A-h> <C-w>4<
noremap <A-j> <C-w>4-
noremap <A-k> <C-w>4+
noremap <A-l> <C-w>4>

augroup keybindings
    au!
    au filetype netrw map <buffer> I %
    au filetype netrw map <buffer> o <CR>
augroup END

" ==============================================================================
" @@@ color / palette
" ==============================================================================
let s:bg        = "221A0F"
let s:bg_faint  = "2B2114"
let s:fg        = "B48E56"
let s:fg_faint  = "837668"
let s:red       = "BD5157"
let s:blue      = "6589AA"
let s:cyan      = "558F7F"
let s:brown     = "A45D43"
let s:green     = "7E9038"
let s:green2    = "63A465"
let s:orange    = "D2651D"
let s:yellow    = "C19133"
let s:magenta   = "AA73A1"

" ==============================================================================
" @@@ color / utils and settings
" ==============================================================================
let g:terminal_ansi_colors = [
    \ '#' . s:bg,
    \ '#' . s:red,
    \ '#' . s:green,
    \ '#' . s:yellow,
    \ '#' . s:blue,
    \ '#' . s:magenta,
    \ '#' . s:cyan,
    \ '#' . s:fg,
    \ '#' . s:bg_faint,
    \ '#' . s:red,
    \ '#' . s:green2,
    \ '#' . s:yellow,
    \ '#' . s:blue,
    \ '#' . s:magenta,
    \ '#' . s:cyan,
    \ '#' . s:fg_faint
\]

let s:col_to_term_col = {
    \ s:bg        : "0",
    \ s:bg_faint  : "0",
    \ s:fg        : "7*",
    \ s:fg_faint  : "8",
    \ s:red       : "1",
    \ s:blue      : "4",
    \ s:cyan      : "6",
    \ s:brown     : "3",
    \ s:green     : "2",
    \ s:green2    : "2*",
    \ s:orange    : "3*",
    \ s:yellow    : "3*",
    \ s:magenta   : "5*",
\}

fun s:hi (group, fg, bg, attr)
    if a:fg != ""
        execute "hi " . a:group . " guifg=#" . a:fg
        execute "hi " . a:group . " ctermfg=" . s:col_to_term_col[a:fg]
    endif

    if a:bg != ""
        execute "hi " . a:group . " guibg=#" . a:bg
        execute "hi " . a:group . " ctermbg=" . s:col_to_term_col[a:bg]
    endif

    if a:attr != ""
        execute "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
    endif
endf

" ==============================================================================
" @@@ color / standard language groups
" ==============================================================================
call s:hi("Comment", s:cyan, "", "none")
call s:hi("Todo", s:cyan, s:bg, "none")
call s:hi("Error", s:bg, s:red, "none")
call s:hi("Ignore", s:bg, s:bg, "none")
call s:hi("Underlined", s:fg, "", "underline")
call s:hi("Type", s:brown, "", "none")
call s:hi("String", s:green, "", "none")
call s:hi("SpecialChar", s:green, "", "none")

call s:hi("Special", s:fg, "", "none")
call s:hi("Typedef", s:fg, "", "none")
call s:hi("PreCondit", s:fg, "", "none")
call s:hi("PreProc", s:fg, "", "none")
call s:hi("Include", s:fg, "", "none")
call s:hi("Define", s:fg, "", "none")
call s:hi("Macro", s:fg, "", "none")
call s:hi("Constant", s:fg, "", "none")
call s:hi("Character", s:fg, "", "none")
call s:hi("Number", s:fg, "", "none")
call s:hi("Boolean", s:fg, "", "none")
call s:hi("Float", s:fg, "", "none")
call s:hi("Identifier", s:fg, "", "none")
call s:hi("Function", s:fg, "", "none")
call s:hi("Statement", s:fg, "", "none")
call s:hi("Conditional", s:fg, "", "none")
call s:hi("Repeat", s:fg, "", "none")
call s:hi("Label", s:fg, "", "none")
call s:hi("Operator", s:fg, "", "none")
call s:hi("Keyword", s:fg, "", "none")
call s:hi("Exception", s:fg, "", "none")
call s:hi("StorageClass", s:fg, "", "none")
call s:hi("Structure", s:fg, "", "none")
call s:hi("Tag", s:fg, "", "none")
call s:hi("Delimiter", s:fg, "", "none")
call s:hi("SpecialComment" , s:fg, "", "none")
call s:hi("Debug", s:fg, "", "none")

" ==============================================================================
" @@@ color / default groups
" ==============================================================================
call s:hi("Normal", s:fg, s:bg, "")
call s:hi("NormalAlt", s:fg, s:bg_faint, "")
call s:hi("Search", s:bg, s:cyan, "bold") " Remaining search results
call s:hi("IncSearch", s:bg, s:yellow, "bold") " Current search result

" We add the 'nocombine' to StatusLineNC in order to make it different from
" StatusLine so that vim doesn't draw a bunch of ^^^ on the active buffer.
call s:hi("StatusLine", s:fg, s:bg_faint, "bold")
call s:hi("StatusLineNC", s:fg, s:bg_faint, "bold,nocombine")
call s:hi("StatusLineTerm", s:fg, s:bg_faint, "bold")
call s:hi("StatusLineTermNC", s:fg, s:bg_faint, "bold")
call s:hi("WildMenu", s:bg, s:yellow, "bold")

call s:hi("Terminal", s:fg, s:bg, "")
call s:hi("EndOfBuffer", s:bg, s:bg, "")
call s:hi("ErrorMsg", s:red, s:bg, "")
call s:hi("TooLong", s:red, "", "")
call s:hi("MoreMsg", s:green, "", "")
call s:hi("Question", s:blue, "", "")
call s:hi("WarningMsg", s:red, "", "")
call s:hi("Conceal", s:bg, s:bg, "")
call s:hi("QuickFixLine", s:bg, s:fg, "NONE")
call s:hi("Directory", s:brown, "", "")
call s:hi("Folded", s:fg_faint, s:bg_faint, "")
call s:hi("FoldColumn", s:cyan, s:bg_faint, "")
call s:hi("MatchParen", s:bg, s:fg_faint,  "")
call s:hi("SpecialKey", s:fg_faint, "", "")
call s:hi("Visual", s:bg, s:fg, "")
call s:hi("VisualNOS", s:bg, s:fg, "none")
call s:hi("Title", s:fg, "", "")
call s:hi("NonText", s:fg_faint, "", "")
call s:hi("LineNr", s:fg_faint, s:bg_faint, "")
call s:hi("SignColumn", s:fg_faint, s:bg_faint, "")
call s:hi("VertSplit", s:bg_faint, s:bg_faint, "")
call s:hi("ColorColumn", "", s:bg_faint, "")
call s:hi("CursorColumn","", s:bg_faint, "")
call s:hi("CursorLine", "", s:bg_faint, "none")
call s:hi("CursorLineNr", s:fg_faint, s:bg_faint, "")
call s:hi("TabLine", s:fg, s:bg_faint, "bold")
call s:hi("TabLineSel", s:yellow, s:bg_faint, "")
call s:hi("TabLineFill", s:bg_faint, "", "")
call s:hi("PMenu", s:fg, s:bg_faint, "")
call s:hi("PMenuSel", s:bg_faint, s:fg, "")
call s:hi("PMenuSbar", s:fg, s:bg_faint, "")
call s:hi("PMenuThumb", s:bg, s:yellow, "")

call s:hi("DiffText", s:bg, s:blue, "")
call s:hi("DiffAdd", s:bg, s:green, "")
call s:hi("DiffChange", s:bg, s:yellow, "")
call s:hi("DiffDelete", s:bg, s:red, "")

" ==============================================================================
" @@@ color / custom groups
" ==============================================================================
call s:hi("QuickFixSearch", s:bg, s:cyan, "NONE")

call s:hi("Faint", s:fg_faint, "", "")
call s:hi("Red", s:red, "", "")
call s:hi("Blue", s:blue, "", "")
call s:hi("Cyan", s:cyan, "", "")
call s:hi("Brown", s:brown, "", "")
call s:hi("Green", s:green, "", "")
call s:hi("Orange", s:orange, "", "")
call s:hi("Yellow", s:yellow, "", "")
call s:hi("Magenta", s:magenta, "", "")

call s:hi("Bold", s:fg, s:bg, "bold")
call s:hi("BFaint", s:fg_faint, "", "bold")
call s:hi("BRed", s:red, "", "bold")
call s:hi("BBlue", s:blue, "", "bold")
call s:hi("BCyan", s:cyan, "", "bold")
call s:hi("BBrown", s:brown, "", "bold")
call s:hi("BGreen", s:green, "", "bold")
call s:hi("BOrange", s:orange, "", "bold")
call s:hi("BYellow", s:yellow, "", "bold")
call s:hi("BMagenta", s:magenta, "", "bold")

call s:hi("BgNormal", s:bg, s:fg, "")
call s:hi("BgRed", s:bg, s:red, "")
call s:hi("BgBlue", s:bg, s:blue, "")
call s:hi("BgCyan", s:bg, s:cyan, "")
call s:hi("BgBrown", s:bg, s:brown, "")
call s:hi("BgGreen", s:bg, s:green, "")
call s:hi("BgYellow", s:bg, s:yellow, "")
call s:hi("BgMagenta", s:bg, s:magenta, "")
