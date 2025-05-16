local M = {}

M.options = {
  width_ratio = 0.40,
  min_width = 75,
  height_ratio = 0.80,
  title_hl = "TelescopeResultsTitle",
  title_pos = "center",
  border = "rounded",
  style = "minimal",
  notes_dir = vim.fn.stdpath("data") .. "/notes",
}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
