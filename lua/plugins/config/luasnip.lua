local ls = require("luasnip")
local types = require("luasnip.util.types")

ls.config.setup({
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = {{"●", "GruvboxOrange"}}
			}
		},
		[types.insertNode] = {
			active = {
				virt_text = {{"●", "GruvboxBlue"}}
			}
		}
	},
})
require("luasnip.loaders.from_vscode").load()
