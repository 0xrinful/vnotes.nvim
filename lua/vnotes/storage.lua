local M = {}

local config = require("vnotes.config")
local state = require("vnotes.state")

local notes_dir = config.options.notes_dir
local index_file = notes_dir .. "/index.json"

M.load_index = function()
	if state.cached_index then
		return state.cached_index
	end

	local f = io.open(index_file, "r")
	if not f then
		state.cached_index = {}
		return state.cached_index
	end

	local content = f:read("*a")
	f:close()

	state.cached_index = vim.fn.json_decode(content) or {}
	return state.cached_index
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

M.save_index = function(index)
	vim.fn.mkdir(notes_dir, "p")
	local f = io.open(index_file, "w")
	f:write(vim.fn.json_encode(index))
	f:close()

	state.cached_index = index
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
	local index = M.load_index()
	local path = notes_dir .. "/" .. name .. ".md"
	index[name] = path
	M.save_index(index)
	return name
end

M.delete_note = function(name)
	local index = M.load_index()
	local path = notes_dir .. "/" .. name .. ".md"
	os.remove(path)
	index[name] = nil
	M.save_index(index)
end

return M
