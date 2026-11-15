-- Match a C/C++ buffer's indent options to the nearest .clang-format (if any), so typed
-- indentation agrees with what clangd/clang-format (gq, <leader>f) produce.
-- No .clang-format found -> buffer keeps the global defaults from options.lua.
local M = {}

-- IndentWidth for each BasedOnStyle when the file doesn't set it (clang-format's built-in defaults)
local style_indent = {
  llvm = 2,
  google = 2,
  chromium = 2,
  mozilla = 2,
  gnu = 2,
  webkit = 4,
  microsoft = 4,
}

local function read_style(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end
  local s = {}
  for _, line in ipairs(lines) do
    -- Top-level "Key: value" only (indented lines belong to nested maps like BraceWrapping)
    local key, val = line:match '^(%w+):%s*([^#%s]+)'
    if key and s[key] == nil then
      s[key] = val
    end
  end
  return s
end

function M.apply(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local start = name ~= '' and vim.fs.dirname(name) or vim.uv.cwd()
  local found = vim.fs.find({ '.clang-format', '_clang-format' }, { upward = true, path = start })[1]
  if not found then
    return
  end
  local s = read_style(found)
  if not s then
    return
  end

  local based = (s.BasedOnStyle or 'llvm'):lower()
  local indent = tonumber(s.IndentWidth) or style_indent[based] or 2
  local tab = tonumber(s.TabWidth) or 8
  local use_tab = (s.UseTab or 'Never') ~= 'Never'

  local bo = vim.bo[buf]
  bo.expandtab = not use_tab
  bo.shiftwidth = indent
  bo.softtabstop = indent
  bo.tabstop = use_tab and tab or indent
end

return M
