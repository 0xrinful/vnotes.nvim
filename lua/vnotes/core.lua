local ui = require("vnotes.ui")
local state = require("vnotes.state")
local storage = require("vnotes.storage")

local M = {}

local reset_buffer = function()
	if state.buf then
		vim.api.nvim_buf_delete(state.buf, { force = true })
	end
	state.buf = nil
end

M.create_note = function()
	ui.create_note(function(name)
		state.note_name = storage.create_note(name)
		reset_buffer()
		M.toggle_note()
	end)
end

M.toggle_note = function()
	if not state.has_note() then
		M.select_note()
		return
	end

	if not ui.is_window_open() then
		local result = ui.open_floating_window()
		state.buf, state.win = result.buf, result.win
	else
		ui.hide_window()
	end
end

M.select_note = function()
	ui.select_note(function(name)
		state.note_name = name
		reset_buffer()
		if ui.is_window_open() then
			ui.hide_window()
		end
		M.toggle_note()
	end)
end

M.delete_note = function()
	ui.select_note(function(name)
		if name == state.note_name then
			if ui.is_window_open() then
				ui.hide_window()
			end
			reset_buffer()
			state.note_name = ""
		end

		storage.delete_note(name)
		vim.notify("Deleted note: " .. name, vim.log.levels.INFO)
	end)
end

return M
