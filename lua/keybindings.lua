vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

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
map('n', '<Leader>o', ':%bd|e#|bd#<CR>', opt)
map('n', '<Leader>w', ':bw<CR>', opt)
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

local pluginKeys = {}

-- lsp 回调函数快捷键设置
pluginKeys.maplsp = function(mapbuf)

    mapbuf('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opt)
    -- rename
    mapbuf('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opt)
    -- code action
    mapbuf('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opt)
    -- go xx
    mapbuf('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opt)
    mapbuf('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', opt)
    mapbuf('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opt)
    mapbuf('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opt)
    mapbuf('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opt)
    -- diagnostic
    mapbuf('n', 'go', '<cmd>lua vim.diagnostic.open_float()<CR>', opt)
    mapbuf('n', 'gp', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opt)
    mapbuf('n', 'gn', '<cmd>lua vim.diagnostic.goto_next()<CR>', opt)
    -- mapbuf('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opt)
    -- leader + =
    mapbuf('n', '<leader>=', '<cmd>lua vim.lsp.buf.formatting()<CR>', opt)
    -- mapbuf('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opt)
    -- mapbuf('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opt)
    -- mapbuf('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opt)
    -- mapbuf('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opt)
    -- mapbuf('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opt)
end

-- nvim-cmp 自动补全
pluginKeys.cmp = function(cmp)
    return {
        -- 上一个
        -- ['<C-k>'] = cmp.mapping.select_prev_item(),
        -- 下一个
        ['<Tab>'] = cmp.mapping.select_next_item(),
        -- 确认
        -- Accept currently selected item. If none selected, `select` first item.
        -- Set `select` to `false` to only confirm explicitly selected items.
        ['<CR>'] = cmp.mapping.confirm({
            select = true ,
        }),
    }
end

return pluginKeys
