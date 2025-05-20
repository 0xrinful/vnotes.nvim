local M = {}

local state = require("vnotes.state")
local storage = require("vnotes.storage")
local config = require("vnotes.config")

local is_valid_buf = function(buf)
	return buf and vim.api.nvim_buf_is_valid(buf)
end

-- set buffer name and filetype options
local set_buf_options = function(buf)
	vim.api.nvim_buf_set_name(buf, config.options.notes_dir .. "/" .. state.note_name)
	vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
end

-- load note content from storage into buffer lines
local load_note_to_buf = function(buf)
	local lines = storage.load_note_content(state.note_name)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local set_win_options = function(win)
	vim.api.nvim_set_option_value("foldcolumn", "1", { win = win })
end

-- Open a floating window displaying the current note's content
M.open_floating_window = function()
	local opts = config.options

	-- calculate window size and position relative to the editor
	local width = math.floor(vim.o.columns * opts.width_ratio)
	width = math.max(width, config.options.min_width)
	local height = math.floor(vim.o.lines * opts.height_ratio)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- create a new buffer if the current one is invalid or nil, then load note content
	local buf = state.buf
	if not is_valid_buf(buf) then
		buf = vim.api.nvim_create_buf(false, true)
		set_buf_options(buf)
		load_note_to_buf(buf)
	end

	-- prepare the floating window config, including a title with the note name
	local note_name = state.note_name
	local title = { { " Note: " .. note_name .. " ", opts.title_hl } }

	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		border = opts.border,
		title = title,
		title_pos = opts.title_pos,
		style = opts.style,
	}

	-- open the floating window with the buffer and apply window options
	local win = vim.api.nvim_open_win(buf, true, win_config)
	set_win_options(win)

	-- clear any previous autocmds for this buffer and create a new one to save on buffer close
	vim.api.nvim_create_autocmd("BufWinLeave", {
		buffer = buf,
		group = vim.api.nvim_create_augroup("VNotesSave", { clear = true }),
		callback = function()
			local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
			storage.save_note(note_name, lines)
		end,
	})

	return { buf = buf, win = win }
end

M.create_note = function(callback)
	vim.ui.input({ prompt = "󱞩  Enter note name: " }, function(input)
		if input and input ~= "" then
			callback(input)
		else
			vim.notify("Note creation cancelled", vim.log.levels.INFO)
		end
	end)
end

M.select_note = function(callback)
	local index = storage.load_index()
	local notes = vim.tbl_keys(index)

	if vim.tbl_isempty(notes) then
		vim.notify("No notes found", vim.log.levels.INFO)
		return
	end

	vim.ui.select(notes, {
		prompt = "󱞩  Select a note:",
		format_item = function(item)
			return "  " .. item
		end,
	}, function(choice)
		if choice then
			callback(choice)
		else
			vim.notify("Note selection cancelled", vim.log.levels.INFO)
		end
	end)
end

M.hide_window = function()
	vim.api.nvim_win_hide(state.win)
end

M.is_window_open = function()
	return state.win and vim.api.nvim_win_is_valid(state.win)
end

return M
