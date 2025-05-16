local core = require("vnotes.core")
local config = require("vnotes.config")

local M = {}

M.setup = function(opts)
	config.setup(opts or {})

	vim.api.nvim_create_user_command("VNoteCreate", function()
		core.create_note()
	end, {})

	vim.api.nvim_create_user_command("VNoteOpen", function()
		core.open_note()
	end, {})

	vim.api.nvim_create_user_command("VNoteSelect", function()
		core.select_note()
	end, {})
end

return M
