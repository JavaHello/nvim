local wilder = require("wilder")
wilder.setup({
  modes = { ":", "/", "?" },
  next_key = "<Tab>",
  previous_key = "<S-Tab>",
  accept_key = "<Down>",
  reject_key = "<Up>",
})
local popupmenu_renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
  highlighter = wilder.basic_highlighter(),
  highlights = {
    bg = "NormalFloat",
    border = "NormalFloat", -- highlight to use for the border
  },
  pumblend = 20,
  -- 'single', 'double', 'rounded' or 'solid'
  -- can also be a list of 8 characters, see :h wilder#popupmenu_border_theme() for more details
  border = "rounded",
  left = { " ", wilder.popupmenu_devicons() },
  right = { " ", wilder.popupmenu_scrollbar() },
}))

local wildmenu_renderer = wilder.wildmenu_renderer({
  highlighter = wilder.basic_highlighter(),
  highlights = {
    bg = "NormalFloat",
    border = "NormalFloat", -- highlight to use for the border
  },
  separator = " · ",
  left = { " ", wilder.wildmenu_spinner(), " " },
  right = { " ", wilder.wildmenu_index() },
})
wilder.set_option(
  "renderer",
  wilder.renderer_mux({
    [":"] = popupmenu_renderer,
    ["/"] = wildmenu_renderer,
  })
)
