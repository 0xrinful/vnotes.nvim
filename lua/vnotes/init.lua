local core = require("vnotes.core")
local config = require("vnotes.config")
local user_cmd = vim.api.nvim_create_user_command

local M = {}

M.setup = function(opts)
	config.setup(opts or {})

	user_cmd("VnotesCreate", function()
		core.create_note()
	end, {})

	user_cmd("VnotesToggle", function()
		core.toggle_note()
	end, {})

	user_cmd("VnotesSelect", function()
		core.select_note()
	end, {})

	user_cmd("VnotesDelete", function()
		core.delete_note()
	end, {})
end

return M
