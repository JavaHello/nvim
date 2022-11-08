local browse = require("browse")

browse.setup({
  -- search provider you want to use
  provider = "google", -- default
})

local bookmarks = {
  "https://docs.spring.io/spring-framework/docs/5.3.12/reference/html/",
  "https://github.com/",
  "https://stackoverflow.com/",
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
