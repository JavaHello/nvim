-- vim.g.mapleader = ";"
-- vim.g.maplocalleader = ";"

local map = vim.api.nvim_set_keymap
local opt = {noremap = true, silent = true }

-- nvimTree
map('n', '<space>n', ':NvimTreeToggle<CR>', opt)
-- n 模式下复制内容到系统剪切板
map('n', '<Leader>c', '"+yy', opt)
-- v 模式下复制内容到系统剪切板
map('v', '<Leader>c', '"+yy', opt)
-- n 模式下粘贴系统剪切板的内容
map('n', '<Leader>v', '"+p', opt)
-- 取消搜索高亮显示
map('n', '<Leader><CR>', ':nohlsearch<CR>', opt)
-- %bd 删除所有缓冲区, e# 打开最后一个缓冲区, bd# 关闭[No Name]
-- map('n', '<Leader>o', ':%bd|e#|bd#<CR>', opt)
map('n', '<Leader>o', '<cmd>lua require("my_tools").close_other_bufline()<CR>', opt)
map('n', '<Leader>w', ':bdelete!<CR>', opt)
-- " 退出 terminal 模式
map('t', '<Esc>', '<C-\\><C-N>', opt)

-- Leaderf
vim.g.Lf_ShortcutF = '<C-P>'
map('n', '<C-F>', ':<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>', {})
map('v', '<C-F>', ':<C-U><C-R>=printf("Leaderf! rg -e %s ", leaderf#Rg#visual())<CR>', {})
map('n', '<space>r', ':Leaderf --nowrap task<CR>', {})

-- vim-floaterm
vim.g.floaterm_keymap_new = '<space>t'
map('n', '<F12>', ':FloatermToggle<CR>', opt)
map('t', '<F12>   <C-\\><C-n>', ':<C-\\><C-n>:FloatermToggle<CR>', opt)


-- vista
map('n', '<space>o', ':<C-u>Vista!!<CR>', opt)

-- trouble.nvim
-- see lsp map
-- map('n', '<space>x', '<cmd>Trouble<cr>', opt)

-- lspsaga
-- map('n', 'K', ':Lspsaga hover_doc<CR>', opt)
-- map('n', 'gr', ':Lspsaga lsp_finder<CR>', opt)

-- Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {})
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {})
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', {})

-- translate
map('n', '<Leader>t', ':TranslateW --engines=google<cr>', opt)
map('v', '<Leader>t', ':TranslateW --engines=google<cr>', opt)

-- vim-easy-align
vim.cmd([[
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
]])

-- nvim-dap
vim.cmd([[
nnoremap <silent> <F5> :lua require'dap'.continue()<CR>
nnoremap <silent> <F6> :lua require'dap'.step_over()<CR>
nnoremap <silent> <F7> :lua require'dap'.step_into()<CR>
nnoremap <silent> <F8> :lua require'dap'.step_out()<CR>
nnoremap <silent> <leader>b :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>
]])

-- nvim-dap-ui
vim.cmd([[
nnoremap <silent> <space>dr :lua require("dapui").float_element(vim.Nil, { enter = true}) <CR>
]])

-- bufferline.nvim
vim.cmd[[
nnoremap <silent><leader>1 <Cmd>BufferLineGoToBuffer 1<CR>
nnoremap <silent><leader>2 <Cmd>BufferLineGoToBuffer 2<CR>
nnoremap <silent><leader>3 <Cmd>BufferLineGoToBuffer 3<CR>
nnoremap <silent><leader>4 <Cmd>BufferLineGoToBuffer 4<CR>
nnoremap <silent><leader>5 <Cmd>BufferLineGoToBuffer 5<CR>
nnoremap <silent><leader>6 <Cmd>BufferLineGoToBuffer 6<CR>
nnoremap <silent><leader>7 <Cmd>BufferLineGoToBuffer 7<CR>
nnoremap <silent><leader>8 <Cmd>BufferLineGoToBuffer 8<CR>
nnoremap <silent><leader>9 <Cmd>BufferLineGoToBuffer 9<CR>
]]

local pluginKeys = {}

-- lsp 回调函数快捷键设置
pluginKeys.maplsp = function(mapbuf)

    vim.api.nvim_buf_set_option(mapbuf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    mapbuf('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opt)
    -- rename
    mapbuf('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opt)
    -- mapbuf('n', '<leader>rn', '<cmd>lua require("lspsaga.rename").rename()<CR>', opt)
    -- code action
    mapbuf('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opt)
    -- mapbuf('n', '<leader>ca', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opt)
    -- go xx
    -- mapbuf('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opt)
    mapbuf('n', 'gd', '<cmd>Trouble lsp_definitions<CR>', opt)
    mapbuf('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opt)
    -- mapbuf('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opt)
    -- mapbuf('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opt)
    mapbuf('n', 'gD', '<cmd>Trouble lsp_type_definitions<CR>', opt)
    -- mapbuf('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opt)
    mapbuf('n', 'gi', '<cmd>Trouble lsp_implementations<CR>', opt)
    mapbuf('n', '<leader>gi', '<cmd>Telescope lsp_implementations<CR>', opt)
    -- mapbuf('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opt)
    mapbuf('n', 'gr', '<cmd>Trouble lsp_references<CR>', opt)
    mapbuf('n', '<leader>gr', '<cmd>Telescope lsp_references<CR>', opt)
    -- mapbuf('n', 'gr', '<cmd>lua require"lspsaga.provider".lsp_finder()<CR>', opt)
    -- mapbuf('n', '<space>s', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opt)
    -- mapbuf('n', '<space>s', '<cmd>lua require"telescope.builtin".lsp_workspace_symbols({ query = vim.fn.input("Query> ") })<CR>', opt)
    mapbuf('n', '<leader>sw', '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>', opt)
    mapbuf('n', '<leader>sd', '<cmd>Telescope lsp_document_symbols<CR>', opt)
    -- diagnostic
    mapbuf('n', 'go', '<cmd>lua vim.diagnostic.open_float()<CR>', opt)
    mapbuf('n', '[g', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opt)
    mapbuf('n', ']g', '<cmd>lua vim.diagnostic.goto_next()<CR>', opt)
    -- mapbuf('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opt)
    -- leader + =
    mapbuf('n', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', opt)
    -- mapbuf('v', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', opt)
    -- mapbuf('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opt)
    -- mapbuf('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opt)
    -- mapbuf('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opt)
    -- mapbuf('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opt)
    -- mapbuf('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opt)
    mapbuf('n', '<leader>xx', '<cmd>Trouble<CR>', opt)
    mapbuf('n', '<leader>xw', '<cmd>Trouble workspace_diagnostics<CR>', opt)
    mapbuf('n', '<leader>xd', '<cmd>Trouble document_diagnostics<CR>', opt)
    mapbuf('n', '<leader>xq', '<cmd>Trouble quickfix<CR>', opt)
end

-- nvim-cmp 自动补全
pluginKeys.cmp = function(cmp)

local luasnip = require('luasnip');
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end
return {
  -- 上一个
  -- ['<C-k>'] = cmp.mapping.select_prev_item(),
  -- 下一个
  -- ['<Tab>'] = cmp.mapping.select_next_item(),
  -- ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  -- ['<Esc>'] = cmp.mapping.close(),
  -- 确认
  -- Accept currently selected item. If none selected, `select` first item.
  -- Set `select` to `false` to only confirm explicitly selected items.
  -- ["<C-d>"] = cmp.mapping.scroll_docs(-4),
  -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-Space>"] = cmp.mapping.complete(),
  ["<C-e>"] = cmp.mapping.close(),
  ["<CR>"] = cmp.mapping.confirm {
    behavior = cmp.ConfirmBehavior.Replace,
    select = true,
  },

  ["<Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    elseif has_words_before() then
      cmp.complete()
    else
      fallback()
    end
  end, { "i", "s" }),

  ["<S-Tab>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end, { "i", "s" }),
}
end

return pluginKeys
