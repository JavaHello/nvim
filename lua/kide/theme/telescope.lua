local colors = require("kide.theme.gruvbox")
return {

	TelescopeBorder = {
		fg = colors.darker_black,
		bg = colors.darker_black,
	},

	TelescopePromptTitle = {
		fg = colors.black,
		bg = colors.red,
	},
	TelescopePromptPrefix = {
		fg = colors.red,
		bg = colors.darker_black,
	},
	TelescopePromptBorder = {
		fg = colors.darker_black,
		bg = colors.darker_black,
	},
	TelescopePromptNormal = {
		fg = colors.white,
		bg = colors.darker_black,
	},

	TelescopeResultsTitle = {
		fg = colors.black2,
		bg = colors.black2,
	},
	TelescopeResultsBorder = {
		fg = colors.black2,
		bg = colors.black2,
	},
	TelescopeResultsNormal = {
		fg = colors.white,
		bg = colors.black2,
	},

	TelescopeNormal = { bg = colors.darker_black },

	TelescopePreviewTitle = {
		fg = colors.black3,
		bg = colors.green,
	},
	TelescopePreviewBorder = {
		fg = colors.black3,
		bg = colors.black3,
	},
	TelescopePreviewNormal = {
		fg = colors.black3,
		bg = colors.black3,
	},

	TelescopeSelection = { bg = colors.black2, fg = colors.yellow },
}
