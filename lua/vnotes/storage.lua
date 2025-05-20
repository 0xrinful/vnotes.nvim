local M = {}

local config = require("vnotes.config")
local state = require("vnotes.state")

local notes_dir = config.options.notes_dir

M.load_notes = function()
	if state.notes then
		return state.notes
	end

	local filenames = vim.fn.readdir(config.options.notes_dir)
	local notes = {}
	for _, name in ipairs(filenames) do
		if name:match("%.md$") then
			name = name:gsub("%.md$", "")
			notes[name] = true
		end
	end
	state.notes = notes
	return state.notes
end

M.load_note_content = function(name)
	local path = notes_dir .. "/" .. name .. ".md"
	local f = io.open(path, "r")
	if not f then
		return {}
	end

	local content = f:read("*a")
	f:close()

	local lines = vim.split(content, "\n", { plain = true })
	return lines
end

M.save_note = function(name, lines)
	vim.fn.mkdir(notes_dir, "p")

	local path = notes_dir .. "/" .. name .. ".md"
	local f = io.open(path, "w")
	if not f then
		vim.notify("Failed to save note: " .. name, vim.log.levels.ERROR)
		return
	end

	for _, line in ipairs(lines) do
		f:write(line .. "\n")
	end
	f:close()

	vim.notify("Note saved: " .. name, vim.log.levels.INFO)
end

M.create_note = function(name)
	local notes = M.load_notes()
	local path = notes_dir .. "/" .. name .. ".md"
	notes[name] = path
	return name
end

M.delete_note = function(name)
	local notes = M.load_notes()
	local path = notes_dir .. "/" .. name .. ".md"
	os.remove(path)
	notes[name] = nil
end

return M
