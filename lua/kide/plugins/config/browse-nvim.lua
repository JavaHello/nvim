local browse = require("browse")

browse.setup({
  -- search provider you want to use
  provider = "google", -- default
})

local bookmarks = {
  "https://github.com/hoob3rt/lualine.nvim",
  "https://github.com/neovim/neovim",
  "https://neovim.discourse.group/",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/rockerBOO/awesome-neovim",
}

local function command(name, rhs, opts)
  opts = opts or {}
  vim.api.nvim_create_user_command(name, rhs, opts)
end

command("BrowseInputSearch", function()
  browse.input_search()
end, {})

command("Browse", function()
  browse.browse({ bookmarks = bookmarks })
end, {})

command("BrowseBookmarks", function()
  browse.open_bookmarks({ bookmarks = bookmarks })
end, {})

command("BrowseDevdocsSearch", function()
  browse.devdocs.search()
end, {})

command("BrowseDevdocsFiletypeSearch", function()
  browse.devdocs.search_with_filetype()
end, {})

command("BrowseMdnSearch", function()
  browse.mdn.search()
end, {})
