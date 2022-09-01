-- vim.g.mapleader = ";"
-- vim.g.maplocalleader = ";"

local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }
local keymap = vim.keymap.set

local M = {}

M.setup = function()
  -- Esc
  -- map('i', 'jk', '<C-\\><C-N>', opt)
  -- nvimTree
  map("n", "<leader>e", ":NvimTreeToggle<CR>", opt)
  -- n 模式下复制内容到系统剪切板
  map("n", "<Leader>c", '"+yy', opt)
  -- v 模式下复制内容到系统剪切板
  map("v", "<Leader>c", '"+yy', opt)
  -- n 模式下粘贴系统剪切板的内容
  map("n", "<Leader>v", '"+p', opt)
  -- 取消搜索高亮显示
  map("n", "<Leader><CR>", ":nohlsearch<CR>", opt)
  -- %bd 删除所有缓冲区, e# 打开最后一个缓冲区, bd# 关闭[No Name]
  -- map('n', '<Leader>o', ':%bd|e#|bd#<CR>', opt)
  -- map('n', '<Leader>o', '<cmd>lua require("kide.core.utils").close_other_bufline()<CR>', opt)
  vim.api.nvim_create_user_command("BufferCloseOther", function()
    require("kide.core.utils").close_other_bufline()
  end, {})
  map("n", "<Leader>s", ":w<CR>", opt)
  map("n", "<Leader>w", ":bd<CR>", opt)
  map("n", "<Leader>W", ":%bd<CR>", opt)
  map("n", "<Leader>q", ":q<CR>", opt)
  -- buffer
  map("n", "<leader>n", ":BufferLineCycleNext <CR>", opt)
  map("n", "<leader>p", ":BufferLineCyclePrev <CR>", opt)
  -- window
  map("n", "<A-[>", ":vertical resize +5 <CR>", opt)
  map("n", "<A-]>", ":vertical resize -5  <CR>", opt)

  -- " 退出 terminal 模式
  map("t", "<Esc>", "<C-\\><C-N>", opt)
  map("t", "jk", "<C-\\><C-N>", opt)

  -- Leaderf
  -- vim.g.Lf_ShortcutF = '<C-P>'
  -- map('n', '<C-F>', ':<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>', {})
  -- map('v', '<C-F>', ':<C-U><C-R>=printf("Leaderf! rg -e %s ", leaderf#Rg#visual())<CR>', {})
  -- map('n', '<space>r', ':Leaderf --nowrap task<CR>', {})

  -- vim-floaterm
  -- vim.g.floaterm_keymap_new = '<leader>ft'
  -- map('n', '<F12>', ':FloatermToggle<CR>', opt)
  -- map('t', '<F12>   <C-\\><C-n>', ':<C-\\><C-n>:FloatermToggle<CR>', opt)
  map("n", "<F12>", ":ToggleTerm<CR>", opt)

  -- symbols-outline.nvim
  map("n", "<space>o", ":<C-u>SymbolsOutline<CR>", opt)

  -- trouble.nvim
  -- see lsp map
  -- map('n', '<space>x', '<cmd>Trouble<cr>', opt)

  -- lspsaga
  -- map('n', 'K', ':Lspsaga hover_doc<CR>', opt)
  -- map('n', 'gr', ':Lspsaga lsp_finder<CR>', opt)

  -- Telescope
  map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opt)
  keymap("v", "<leader>ff", function()
    local tb = require("telescope.builtin")
    local text = require("kide.core.utils").get_visual_selection()
    tb.find_files({ default_text = text })
  end, opt)
  map("n", "<C-p>", "<cmd>Telescope find_files<cr>", opt)
  map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opt)
  keymap("v", "<leader>fg", function()
    local tb = require("telescope.builtin")
    local text = require("kide.core.utils").get_visual_selection()
    tb.live_grep({ default_text = text })
  end, opt)
  map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opt)
  map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opt)

  -- translate
  map("n", "<leader>tz", ":Translate ZH -source=EN -parse_after=window -output=floating<cr>", opt)
  map("v", "<leader>tz", ":Translate ZH -source=EN -parse_after=window -output=floating<cr>", opt)
  map("n", "<leader>te", ":Translate EN -source=ZH -parse_after=window -output=floating<cr>", opt)
  map("v", "<leader>te", ":Translate EN -source=ZH -parse_after=window -output=floating<cr>", opt)

  -- camel_case
  require("kide.core.utils").camel_case_init()

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
nnoremap <silent> <leader>db :lua require'dap'.toggle_breakpoint()<CR>
nnoremap <silent> <leader>dB :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
nnoremap <silent> <leader>dp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
nnoremap <silent> <leader>dr :lua require'dap'.repl.open()<CR>
nnoremap <silent> <leader>dl :lua require'dap'.run_last()<CR>
]])

  -- nvim-dap-ui
  vim.cmd([[
nnoremap <silent> <space>dr :lua require("dapui").float_element(vim.Nil, { enter = true}) <CR>
]])

  -- bufferline.nvim
  vim.cmd([[
nnoremap <silent><leader>1 <Cmd>BufferLineGoToBuffer 1<CR>
nnoremap <silent><leader>2 <Cmd>BufferLineGoToBuffer 2<CR>
nnoremap <silent><leader>3 <Cmd>BufferLineGoToBuffer 3<CR>
nnoremap <silent><leader>4 <Cmd>BufferLineGoToBuffer 4<CR>
nnoremap <silent><leader>5 <Cmd>BufferLineGoToBuffer 5<CR>
nnoremap <silent><leader>6 <Cmd>BufferLineGoToBuffer 6<CR>
nnoremap <silent><leader>7 <Cmd>BufferLineGoToBuffer 7<CR>
nnoremap <silent><leader>8 <Cmd>BufferLineGoToBuffer 8<CR>
nnoremap <silent><leader>9 <Cmd>BufferLineGoToBuffer 9<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
]])

  -- nvim-spectre
  map("n", "<leader>S", "<cmd>lua require('spectre').open()<CR>", opt)
  -- search current word
  map("n", "<leader>fr", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", opt)
  map("v", "<leader>fr", "<cmd>lua require('spectre').open_visual()<CR>", opt)
  --  search in current file
  -- map("n", "<leader>fp", "viw:lua require('spectre').open_file_search()<cr>", opt)
  -- run command :Spectre

  -- ToggleTask
  map("n", "<leader>ts", "<cmd>Telescope toggletasks spawn<cr>", opt)
end
-- lsp 回调函数快捷键设置
M.maplsp = function(client, buffer)
  vim.api.nvim_buf_set_option(buffer, "omnifunc", "v:lua.vim.lsp.omnifunc")
  vim.api.nvim_buf_set_option(buffer, "formatexpr", "v:lua.vim.lsp.formatexpr()")

  vim.api.nvim_buf_set_keymap(buffer, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
  -- rename
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opt)
  -- mapbuf('n', '<leader>rn', '<cmd>lua require("lspsaga.rename").rename()<CR>', opt)
  -- code action
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opt)
  -- mapbuf('n', '<leader>ca', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opt)
  -- go xx
  -- mapbuf('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>Trouble lsp_definitions<CR>', opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opt)
  -- mapbuf('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opt)
  -- mapbuf('n', 'gD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>Trouble lsp_type_definitions<CR>", opt)
  -- mapbuf('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>Trouble lsp_implementations<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gi", "<cmd>Telescope lsp_implementations<CR>", opt)
  -- mapbuf('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>Trouble lsp_references<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "gr", "<cmd>Telescope lsp_references<CR>", opt)
  -- mapbuf('n', 'gr', '<cmd>lua require"lspsaga.provider".lsp_finder()<CR>', opt)
  -- mapbuf('n', '<space>s', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opt)
  -- mapbuf('n', '<space>s', '<cmd>lua require"telescope.builtin".lsp_workspace_symbols({ query = vim.fn.input("Query> ") })<CR>', opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", opt)
  keymap("v", "<leader>fs", function()
    local tb = require("telescope.builtin")
    local text = require("kide.core.utils").get_visual_selection()
    tb.lsp_workspace_symbols({ default_text = text, query = text })
  end, opt)

  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>fo", "<cmd>Telescope lsp_document_symbols<CR>", opt)
  -- diagnostic
  vim.api.nvim_buf_set_keymap(buffer, "n", "go", "<cmd>lua vim.diagnostic.open_float()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "[g", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opt)
  vim.api.nvim_buf_set_keymap(buffer, "n", "]g", "<cmd>lua vim.diagnostic.goto_next()<CR>", opt)
  -- mapbuf('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opt)
  -- leader + =
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>=', '<cmd>lua vim.lsp.buf.format()<CR>', opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'v', '<leader>=', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opt)

  keymap("n", "<leader>=", function()
    local bfn = vim.api.nvim_get_current_buf()
    vim.lsp.buf.format({
      bufnr = bfn,
      filter = function(c)
        return require("kide.lsp.utils").filter_format_lsp_client(c, bfn)
      end,
    })
  end, opt)
  vim.api.nvim_buf_set_keymap(
    buffer,
    "v",
    "<leader>=",
    '<cmd>lua require("kide.lsp.utils").format_range_operator()<CR>',
    opt
  )
  -- mapbuf('v', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', opt)
  -- mapbuf('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opt)
  -- mapbuf('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opt)
  -- mapbuf('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opt)
  -- mapbuf('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opt)
  -- mapbuf('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opt)

  vim.api.nvim_buf_set_keymap(buffer, "n", "<leader>xw", "<cmd>Telescope diagnostics<CR>", opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<CR>", opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>xx", "<cmd>Trouble<CR>", opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<CR>", opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>xd", "<cmd>Trouble document_diagnostics<CR>", opt)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>xq", "<cmd>Trouble quickfix<CR>", opt)
end

-- nvim-cmp 自动补全
M.cmp = function(cmp)
  local luasnip = require("luasnip")
  local neogen = require("neogen")
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
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      -- select = true,
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif neogen.jumpable() then
        neogen.jump_next()
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
      elseif neogen.jumpable(true) then
        neogen.jump_prev()
      else
        fallback()
      end
    end, { "i", "s" }),
  }
end

M.rest_nvim = function()
  -- rest-nvim
  vim.cmd([[
command! -buffer Http  :lua require'rest-nvim'.run()
command! -buffer HttpCurl  :lua require'rest-nvim'.run(true)
command! -buffer HttpLast  :lua require'rest-nvim'.last()
]])
end

M.hop_mapkey = function()
  -- hop.nvim
  -- place this in one of your configuration file(s)
  map(
    "n",
    "f",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>",
    opt
  )
  map(
    "v",
    "f",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>",
    opt
  )
  map(
    "n",
    "F",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>",
    opt
  )
  map(
    "v",
    "F",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>",
    opt
  )
  map(
    "o",
    "f",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, inclusive_jump = true })<cr>",
    opt
  )
  map(
    "o",
    "F",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, inclusive_jump = true })<cr>",
    opt
  )
  -- map('', 't', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>", opt)
  -- map('', 'T', "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>", opt)
  -- map('n', '<leader>e', "<cmd> lua require'hop'.hint_words({ hint_position = require'hop.hint'.HintPosition.END })<cr>", opt)
  -- map('v', '<leader>e', "<cmd> lua require'hop'.hint_words({ hint_position = require'hop.hint'.HintPosition.END })<cr>", opt)
  -- map('o', '<leader>e', "<cmd> lua require'hop'.hint_words({ hint_position = require'hop.hint'.HintPosition.END, inclusive_jump = true })<cr>", opt)
end

return M
