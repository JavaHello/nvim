set nocompatible " 关闭兼容模式
" filetype off " 关闭自动补全

" 侦测文件类型
filetype on
" 为特定文件类型载入相关缩进文件
filetype indent on
" 载入文件类型插件
filetype plugin on
filetype plugin indent on
set number " 打开行号设置
set relativenumber " 显示相对行号
set encoding=utf-8
set ruler " 光标信息
set hlsearch " 高亮显示搜索
" exec "nohlsearch"
set incsearch " 边搜索边高亮
set ignorecase " 忽悠大小写
set smartcase " 智能大小写

set cursorline " 突出显示当前行
set showcmd " 显示命令
" 增强模式中的命令行自动完成操作
set wildmenu " 可选菜单

" 可以在buffer的任何地方使用鼠标（类似office中在工作区双击鼠标定位）
set mouse=a
set selection=exclusive
set selectmode=mouse,key

" 在被分割的窗口间显示空白，便于阅读
set fillchars=vert:│
" set fillchars=vert:\
" ,stl:\ ,stlnc:\
" set ambiwidth=double

set ts=4 " tab 占4个字符宽度 
set softtabstop=4
set shiftwidth=4
set expandtab
" set autoindent " 复制上一行的缩进
" expandtab " tab为4个空格
" set autochdir

" 高亮显示匹配的括号
set showmatch

" 匹配括号高亮的时间（单位是十分之一秒）
set matchtime=5
" 光标移动到buffer的顶部和底部时保持3行距离
set scrolloff=3

autocmd Filetype dart setlocal ts=2 sw=2 expandtab
autocmd Filetype html setlocal ts=2 sw=2 expandtab
autocmd Filetype css setlocal ts=2 sw=2 expandtab
autocmd Filetype javascript setlocal ts=2 sw=2 expandtab
autocmd Filetype json setlocal ts=2 sw=2 expandtab

syntax enable " 语法高亮
syntax on

" set t_Co=256
" 开启24bit的颜色，开启这个颜色会更漂亮一些
set termguicolors
set background=dark
" set background=light
" colorscheme desert
" packadd! dracula
" colorscheme one
" 最后加载 gruvbox 主题
" autocmd vimenter * colorscheme gruvbox

" 取消备份
set nobackup
set noswapfile


" ============================================================================
" 快捷键配置
" ============================================================================
let mapleader=";" " 定义快捷键前缀,即<Leader>

" ==== 系统剪切板复制粘贴 ====
" v 模式下复制内容到系统剪切板
vmap <Leader>c "+yy
" n 模式下复制一行到系统剪切板
nmap <Leader>c "+yy
" n 模式下粘贴系统剪切板的内容
nmap <Leader>v "+p

" 取消搜索高亮显示
noremap <Leader><CR> :nohlsearch<CR>

" 分屏大写调整快捷键配置
noremap <up> :res -2<CR>
noremap <down> :res +2<CR>
noremap <left> :vertical resize +2<CR>
noremap <right> :vertical resize -2<CR>

" 标签页切换
" noremap te :tabe<CR>
" noremap th :-tabnext<CR>
" noremap tl :+tabnext<CR>

" 分割线
" set fillchars=vert:'│'

" 插件配置
call plug#begin('~/.vim/plugged')

" vim 状态栏
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" 左侧导航目录 使用coc.explorer
" Plug 'preservim/nerdtree'
" 侧边栏美化(需要下载字体,暂时不用)
" Plug 'ryanoasis/vim-devicons'

" 图标高亮插件
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

" vim 文件左侧 git 状态
" Plug 'airblade/vim-gitgutter'

" 文件搜索插件
" Plug 'kien/ctrlp.vim'
" 方法大纲搜索
" Plug 'tacahiroy/ctrlp-funky'

" 类似 ctrlp 功能
" Plug 'Shougo/denite.nvim', {'do': ':UpdateRemotePlugins' }

" 大纲
Plug 'majutsushi/tagbar'

" editorconfig 插件
Plug 'editorconfig/editorconfig-vim'

" 快速注释插件
Plug 'scrooloose/nerdcommenter'

" git 插件
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'


" go 语言相关插件
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Plug 'volgar1x/vim-gocode'

" 主题
Plug 'dracula/vim', { 'as': 'dracula' }
" colorscheme one
Plug 'rakr/vim-one'
Plug 'morhetz/gruvbox'
Plug 'altercation/vim-colors-solarized'


" 可以在导航目录中看到 git 版本信息
" Plug 'Xuyuanp/nerdtree-git-plugin'

" 自动补全括号的插件，包括小括号，中括号，以及花括号
" Plug 'jiangmiao/auto-pairs'

" 可以使 nerdtree Tab 标签的名称更友好些
" Plug 'jistr/vim-nerdtree-tabs'

" html 神器
Plug 'mattn/emmet-vim'

" 补全插件
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" markdown 插件


" rust 插件
Plug 'rust-lang/rust.vim'

" dart 插件
Plug 'dart-lang/dart-vim-plugin'


" Vim 寄存器列表查看插件
Plug 'junegunn/vim-peekaboo'

" 配对符号替换插件
Plug 'tpope/vim-surround'

" 最近打开文件
Plug 'mhinz/vim-startify'

" 全局查找替换插件
Plug 'brooth/far.vim'

" 异步执行任务插件
Plug 'skywind3000/asynctasks.vim'
Plug 'skywind3000/asyncrun.vim'
Plug 'skywind3000/asyncrun.extra'

" jsx 插件
Plug 'chemzqm/vim-jsx-improve'

" 多光标插件
Plug 'mg979/vim-visual-multi'

" 类似 vim gitlens 插件
Plug 'APZelos/blamer.nvim'

" 类似 vscode ctrl+p
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" 浮动终端
Plug 'voldikss/vim-floaterm'

" debug 插件
Plug 'puremourning/vimspector'



" lsp
" Plug 'neovim/nvim-lspconfig'
" Plug 'williamboman/nvim-lsp-installer'

" debug
" Plug 'mfussenegger/nvim-dap'

" 数据库客户端
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'

call plug#end()
" 主题设置
colorscheme gruvbox
" colorscheme one
" colorscheme solarized
" 透明背景
" hi Normal ctermfg=252 ctermbg=none
highlight Normal guibg=NONE ctermbg=None



" 退出 terminal 模式
tnoremap <Esc> <C-\><C-N>

" "==============================================================================
" " nerdtree 文件列表插件配置
" "==============================================================================
" " 关闭打开NERDTree快捷键
" noremap <leader>t :NERDTreeToggle<CR>
" " 如果使用vim-plug的话，加上这一句可以避免光标在nerdtree
" " 中的时候进行插件升级而导致nerdtree崩溃
" let g:plug_window = 'noautocmd vertical topleft new'
" " 在nerdtree中删除文件之后，自动删除vim中相应的buffer
" let NERDTreeAutoDeleteBuffer = 1
" " 进入目录自动将workspace更改为此目录
" let g:NERDTreeChDirMode = 2
"
" " 显示隐藏文件
" let NERDTreeShowHidden=1
" " let g:NERTreeMapToggleHidden = '.'
"
" " let g:NERDTreeDirArrowExpandable = '▸'
" " let g:NERDTreeDirArrowCollapsible = '▾'
" let g:NERDTreeDirArrowExpandable = ''
" let g:NERDTreeDirArrowCollapsible = ''
" " 显示行号
" " let NERDTreeShowLineNumbers=1
" " 设置宽度
" let NERDTreeWinSize=31
" " 自动打开 nerdtree
" " autocmd StdinReadPre * let s:std_in=1
" " autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
"
" " 使用 vim 而不是 vim .
" " autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" " 打开任意文件启动 nerdtree 我不需要
" " autocmd vimenter * NERDTree
" " 打开 vim 文件及显示书签列表
" " let NERDTreeShowBookmarks=2
" " 忽略一下文件的显示
" let NERDTreeIgnore=['\.pyc','\~$','\.swp']
" " 显示在右边
" " let NERDTreeWinPos=1



" "==============================================================================
" "  nerdtree-git-plugin 插件
" "==============================================================================
" let g:NERDTreeGitStatusIndicatorMapCustom = {
"     \ "Modified"  : "✹",
"     \ "Staged"    : "✚",
"     \ "Untracked" : "✭",
"     \ "Renamed"   : "➜",
"     \ "Unmerged"  : "═",
"     \ "Deleted"   : "✖",
"     \ "Dirty"     : "✗",
"     \ "Clean"     : "✔︎",
"     \ 'Ignored'   : '☒',
"     \ "Unknown"   : "?"
"     \ }
"
" let g:NERDTreeGitStatusShowIgnored = 1
" let g:NERDTreeGitStatusUseNerdFonts = 1


"==============================================================================
"  vim-nerdtree-syntax-highlight 插件
"==============================================================================
" 自定义颜色
" you can add these colors to your .vimrc to help customizing
" let s:brown = "905532"
" let s:aqua =  "3AFFDB"
" let s:blue = "689FB6"
" let s:darkBlue = "44788E"
" let s:purple = "834F79"
" let s:lightPurple = "834F79"
" let s:red = "AE403F"
" let s:beige = "F5C06F"
" let s:yellow = "F09F17"
" let s:orange = "D4843E"
" let s:darkOrange = "F16529"
" let s:pink = "CB6F6F"
" let s:salmon = "EE6E73"
" let s:green = "8FAA54"
" let s:lightGreen = "31B53E"
" let s:white = "FFFFFF"
" let s:rspec_red = 'FE405F'
" let s:git_orange = 'F54D27'
"
" let g:NERDTreeExtensionHighlightColor = {} " this line is needed to avoid error
" let g:NERDTreeExtensionHighlightColor['css'] = s:blue " sets the color of css files to blue
"
" let g:NERDTreeExactMatchHighlightColor = {} " this line is needed to avoid error
" let g:NERDTreeExactMatchHighlightColor['.gitignore'] = s:git_orange " sets the color for .gitignore files
"
" let g:NERDTreePatternMatchHighlightColor = {} " this line is needed to avoid error
" let g:NERDTreePatternMatchHighlightColor['.*_spec\.rb$'] = s:rspec_red " sets the color for files ending with _spec.rb
"
" let g:WebDevIconsDefaultFolderSymbolColor = s:beige " sets the color for folders that did not match any rule
" let g:WebDevIconsDefaultFileSymbolColor = s:blue " sets the color for files that did not match any rule


"==============================================================================
" ctrlp.vim 文件搜索插件配置
"==============================================================================
" 快捷键配置
" let g:ctrlp_map = '<c-p>'
" let g:ctrlp_cmd = 'CtrlP'
" 设置工作目录读取方式
" let g:ctrlp_working_path_mode = 'ra'
" 忽略搜索文件
"let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
" let g:ctrlp_custom_ignore = {
"   \ 'dir':  '\v[\/](\.git|\.hg|\.svn|target|node_modules)$',
"   \ 'file': '\v\.(exe|so|dll|class)$',
"   \ 'link': 'some_bad_symbolic_links',
"   \ }


"==============================================================================
" ctrlp-funky 插件配置
"==============================================================================
" map <F6> :CtrlPFunky<cr>
" let g:ctrlp_extensions = ['funky']
" let g:ctrlp_funky_syntax_highlight = 1



"==============================================================================
" tagbar 插件配置
"==============================================================================
" map <F5> :TagbarToggle<cr>
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }


"==============================================================================
" vim-airline 配置
"==============================================================================
" 启用显示缓冲区
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
" let g:airline#extensions#tabline#left_alt_sep = '｜'
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_powerline_fonts = 1


"==============================================================================
" nerdocmmenter 注释插件配置
"==============================================================================
let g:NERDSpaceDelims = 1 " 默认情况下，在注释分割符后添加空格
let g:NERDCompactSexyComs = 1 " 使用紧凑语法进行美化的多行s注释
let g:NERDDefaultAlign = 'left' " 让对齐向注释分割符向左而不是跟随代码缩进
let g:NERDAltDelims_java = 1 " 默认情况，将语言设置为使用其备用分割符
let g:NERDCustomDelimiters = { 'c': { 'left': '/**', 'right': '*/'}} " 添加自定义格式
let g:NERDCommentEmptyLines = 1 " 允许注释和反转空行(在注释区域时很有用)
let g:NERDTrimTrailingWhitespace = 1 " 在取消s注释时启用尾部空格的修剪
let g:NERDToggleCheckAllLines = 1 " 启用检查是否以注释

"==============================================================================
" vim-go 插件
"==============================================================================
let g:go_fmt_command = "goimports" " 格式化将默认的 gofmt 替换
let g:go_autodetect_gopath = 1
let g:go_list_type = "quickfix"

let g:go_version_warning = 1
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_methods = 1
let g:go_highlight_generate_tags = 1

let g:godef_split=2




"==============================================================================
"  coc.nvim 插件
"==============================================================================

" 插件列表
let g:coc_global_extensions = [
    \'coc-vimlsp',
    \'coc-snippets',
    \'coc-prettier',
    \'coc-pairs',
    \'coc-marketplace',
    \'coc-lists',
    \'coc-highlight',
    \'coc-git',
    \'coc-explorer',
    \'coc-emmet',
    \'coc-yaml',
    \'coc-vetur',
    \'coc-tsserver',
    \'coc-rust-analyzer',
    \'coc-python',
    \'coc-json',
    \'coc-java',
    \'coc-java-debug',
    \'coc-xml',
    \'coc-html',
    \'coc-flutter',
    \'coc-tasks',
    \'coc-floaterm',
    \'coc-translator',
    \'coc-toml',
    \'coc-markdownlint',
    \'coc-gitignore',
    \'coc-word',
    \'coc-sh',
    \'coc-imselect',
    \'coc-clangd',
    \'coc-css']
" 插件列表备注
" coc-imselect 输入法中英显示 Mac 下专用

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
" set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=400

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
" nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" coc.nvim debug 日志
" let g:node_client_debug=1

" CocList files
" nnoremap <silent> <C-p> :<C-u>CocList files<CR>
" nnoremap <silent> <C-p>@ :<C-u>CocList outline<CR>


"==============================================================================
"  coc-translator 配置
"==============================================================================
nmap <Leader>t <Plug>(coc-translator-p)
vmap <Leader>t <Plug>(coc-translator-pv)

"==============================================================================
"  coc-floaterm 配置
"==============================================================================
nnoremap <silent> <space>ft  :<C-u>CocList floaterm<cr>

"==============================================================================
"  coc.explorer 配置
"==============================================================================
let g:coc_explorer_global_presets = {
\   '.vim': {
\     'root-uri': '~/.vim',
\   },
\   'cocConfig': {
\      'root-uri': '~/.config/coc',
\   },
\   'tab': {
\     'position': 'tab',
\     'quit-on-open': v:true,
\   },
\   'tab:$': {
\     'position': 'tab:$',
\     'quit-on-open': v:true,
\   },
\   'floating': {
\     'position': 'floating',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingTop': {
\     'position': 'floating',
\     'floating-position': 'center-top',
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingLeftside': {
\     'position': 'floating',
\     'floating-position': 'left-center',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'floatingRightside': {
\     'position': 'floating',
\     'floating-position': 'right-center',
\     'floating-width': 50,
\     'open-action-strategy': 'sourceWindow',
\   },
\   'simplify': {
\     'file-child-template': '[selection | clip | 1] [indent][icon | 1] [filename omitCenter 1]'
\   },
\   'buffer': {
\     'sources': [{'name': 'buffer', 'expand': v:true}]
\   },
\ }

" Use preset argument to open it
nnoremap <space>ed :CocCommand explorer --preset .vim<CR>
nnoremap <space>ee :CocCommand explorer <CR>
nnoremap <space>ef :CocCommand explorer --preset floating<CR>
nnoremap <space>ec :CocCommand explorer --preset cocConfig<CR>
nnoremap <space>eb :CocCommand explorer --preset buffer<CR>

" List all presets
nnoremap <space>el :CocList explPresets

"==============================================================================
"  coc-java-debug 配置
"==============================================================================
nmap <F1> :CocCommand java.debug.vimspector.start<CR>

" function! JavaStartDebugCallback(err, port)
"   execute "cexpr! 'Java debug started on port: " . a:port . "'"
"   call vimspector#LaunchWithSettings({ "configuration": "Java Attach", "AdapterPort": a:port })
" endfunction
" 
" function JavaStartDebug()
"   call CocActionAsync('runCommand', 'vscode.java.startDebugSession', function('JavaStartDebugCallback'))
" endfunction
" 
" nmap <F5> :call JavaStartDebug()<CR>



"==============================================================================
"  asynctasks异步执行任务插件 配置
"==============================================================================
let g:asyncrun_open = 20
let g:asyncrun_mode = 'term'
let g:asynctasks_term_pos = 'floaterm'
" 此配置无效(无效变量)
let g:asyncrun_term_pos = 'floaterm'

" Search workspace tasks.
nnoremap <silent> <space>t  :<C-u>CocList tasks<cr>



"==============================================================================
"  blamer 配置
"==============================================================================
" default 0
let g:blamer_enabled = 1
let g:blamer_delay = 400
let g:blamer_show_in_visual_modes = 0
let g:blamer_show_in_insert_modes = 0
" let g:blamer_prefix = ' > '
let g:blamer_date_format = '%Y-%m-%d %H:%M:%S'


"==============================================================================
"  LeaderF 配置
"==============================================================================
let g:Lf_WindowPosition = 'popup'
let g:Lf_ShortcutF = '<C-P>'

"==============================================================================
"  LeaderF 自定义 配置
"==============================================================================
" nnoremap <silent> <C-T> :<C-u><CR>

" let g:Lf_WildIgnore = {
"             \ 'dir': ['.svn','.git','.hg','.wine','.deepinwine','.oh-my-zsh', 'target'],
"             \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]', '*.class']
"             \}

" LeaderF rg
" search word under cursor, the pattern is treated as regex, and enter normal mode directly
noremap <C-F> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>

" search word under cursor, the pattern is treated as regex,
" append the result to previous search results.
" noremap <C-G> :<C-U><C-R>=printf("Leaderf! rg --append -e %s ", expand("<cword>"))<CR>

" search word under cursor literally only in current buffer
" noremap <C-B> :<C-U><C-R>=printf("Leaderf! rg -F --current-buffer -e %s ", expand("<cword>"))<CR>

" search word under cursor literally in all listed buffers
" noremap <C-D> :<C-U><C-R>=printf("Leaderf! rg -F --all-buffers -e %s ", expand("<cword>"))<CR>

" search visually selected text literally, don't quit LeaderF after accepting an entry
" xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -F --stayOpen -e %s ", leaderf#Rg#visual())<CR>
xnoremap gf :<C-U><C-R>=printf("Leaderf! rg -e %s ", leaderf#Rg#visual())<CR>

" recall last search. If the result window is closed, reopen it.
noremap go :<C-U>Leaderf! rg --recall<CR>

" search word under cursor in *.h and *.cpp files.
" noremap <Leader>a :<C-U><C-R>=printf("Leaderf! rg -e %s -g *.h -g *.cpp", expand("<cword>"))<CR>
" the same as above
" noremap <Leader>a :<C-U><C-R>=printf("Leaderf! rg -e %s -g *.{h,cpp}", expand("<cword>"))<CR>

" search word under cursor in cpp and java files.
" noremap <Leader>b :<C-U><C-R>=printf("Leaderf! rg -e %s -t cpp -t java", expand("<cword>"))<CR>

" search word under cursor in cpp files, exclude the *.hpp files
" noremap <Leader>c :<C-U><C-R>=printf("Leaderf! rg -e %s -t cpp -g !*.hpp", expand("<cword>"))<CR>


"==============================================================================
"  voldikss/vim-floaterm 配置
"==============================================================================
let g:floaterm_keymap_new = '<Leader>ft'
nnoremap   <silent>   <F12>   :FloatermToggle<CR>
tnoremap   <silent>   <F12>   <C-\><C-n>:FloatermToggle<CR>

" Set floaterm window's background to black
" hi Floaterm guibg=black
"
" Set floating window border line color to cyan, and background to orange
" hi FloatermBorder guibg=orange guifg=cyan
"
" Set floaterm window background to gray once the cursor moves out from it
" hi FloatermNC guibg=gray
autocmd User FloatermOpen        " triggered after opening a new/existed floaterm

let g:floaterm_position='bottomright'
let g:floaterm_autoclose=1
let g:floaterm_wintype='float'
let g:floaterm_width=0.6
let g:floaterm_height=0.4
let g:floaterm_rootmarkers=['.project', '.git', '.hg', '.svn', '.root', '.gitignore']

"==============================================================================
"  puremourning/vimspector 配置
"==============================================================================
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'



"==============================================================================
"  自定义配置
"==============================================================================

" %bd 删除所有缓冲区, e# 打开最后一个缓冲区, bd# 关闭[No Name]
noremap <Leader>o :%bd\|e#\|bd#<CR>
