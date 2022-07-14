require("toggletasks").setup({
  search_paths = {
    ".tasks",
    ".toggletasks",
    ".nvim/toggletasks",
    ".nvim/tasks",
  },
})

require("telescope").load_extension("toggletasks")
