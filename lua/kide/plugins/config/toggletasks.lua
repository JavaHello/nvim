require("toggletasks").setup({
  search_paths = {
    ".tasks",
    ".toggletasks",
    ".nvim/toggletasks",
    ".nvim/tasks",
  },
  defaults = {
    close_on_exit = true,
  },
})

require("telescope").load_extension("toggletasks")
