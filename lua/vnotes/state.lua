local M = {
	note_name = "",
	notes = nil,
	buf = nil,
	win = nil,
}

M.has_note = function()
	return M.note_name ~= ""
end

return M
