local browse = require("browse")

browse.setup({
  -- search provider you want to use
  provider = "google", -- default
})

local bookmarks = {
  "https://docs.spring.io/spring-framework/docs/5.3.12/reference/html/",
  "https://github.com/",
  "https://stackoverflow.com/",
  "https://mvnrepository.com/",
  ["github"] = {
    ["name"] = "search github from neovim",
    ["code_search"] = "https://github.com/search?q=%s&type=code",
    ["repo_search"] = "https://github.com/search?q=%s&type=repositories",
    ["issues_search"] = "https://github.com/search?q=%s&type=issues",
    ["pulls_search"] = "https://github.com/search?q=%s&type=pullrequests",
  },
  ["maven"] = {
    ["name"] = "search maven from neovim",
    ["jar_search"] = "https://mvnrepository.com/search?q=%s",
  },
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
