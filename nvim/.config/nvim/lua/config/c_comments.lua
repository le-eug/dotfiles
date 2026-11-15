-- VS Code-style /* */ block comments for C/C++ buffers.
--   /*        -> /*| */
--   /* x *|/  -> typing / steps over the auto-inserted */
--   <CR> between /* and */ ->
--     /*
--      * |
--      */
-- Enter on later lines continues ` * ` via 'comments' + formatoptions 'r'/'o' (// comments don't continue).
local M = {}

local function line_parts()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return line:sub(1, col), line:sub(col + 1)
end

-- Is the end of `pre` (text before the cursor) inside a string, char literal, or comment?
local function in_string_or_comment(pre)
  local quote, i = nil, 1
  while i <= #pre do
    local c = pre:sub(i, i)
    if quote then
      if c == '\\' then
        i = i + 1
      elseif c == quote then
        quote = nil
      end
    elseif c == '"' or c == "'" then
      quote = c
    elseif pre:sub(i, i + 1) == '//' then
      return true
    elseif pre:sub(i, i + 1) == '/*' then
      local close = pre:find('*/', i + 2, true)
      if not close then
        return true
      end
      i = close + 1
    end
    i = i + 1
  end
  return quote ~= nil
end

function M.star()
  local pre = line_parts()
  local before = pre:sub(1, -2)
  if pre:sub(-1) == '/' and not in_string_or_comment(before) then
    -- Insert "* */" and leave the cursor right after the "*"
    return '* */<Left><Left><Left>'
  end
  return '*'
end

function M.slash()
  local pre, post = line_parts()
  local skip = post:match '^%s*%*/'
  if pre:sub(-1) == '*' and skip then
    -- Typed "*/" just before the auto-inserted " */": drop our "*" (and a space before it, since the
    -- closer brings its own), then step over the existing closer
    local bs = (pre:sub(-2, -2):match '%s' and skip:match '^%s') and '<BS><BS>' or '<BS>'
    return bs .. string.rep('<Right>', #skip)
  end
  return '/'
end

function M.cr()
  local pre, post = line_parts()
  local open = pre:find '/%*[^/]*$'
  if open and not pre:find('*/', open + 2, true) and post:match '^%s*%*/%s*$' then
    -- Remove trailing spaces and the " */", then let 'comments' build the block:
    -- <CR> gives " * ", <CR>/ turns the next " * " into " */", then go back up.
    -- A placeholder "x" stops Vim stripping the middle line's trailing space; it's deleted at the end.
    local trailing = #pre:match '%s*$'
    return string.rep('<BS>', trailing) .. string.rep('<Del>', #post) .. '<CR>x<CR>/<Up><End><BS>'
  end
  local ok, npairs = pcall(require, 'nvim-autopairs')
  if ok then
    return npairs.autopairs_cr()
  end
  return vim.api.nvim_replace_termcodes('<CR>', true, false, true)
end

function M.attach(buf)
  vim.bo[buf].comments = 's1:/*,mb:*,ex:*/'
  vim.opt_local.formatoptions:append { 'r', 'o' }
  local o = { buffer = buf, expr = true }
  vim.keymap.set('i', '*', M.star, o)
  vim.keymap.set('i', '/', M.slash, o)
  vim.keymap.set('i', '<CR>', function()
    local keys = M.cr()
    -- autopairs_cr() already returns termcodes; ours still need replacing
    return keys:find '<' and vim.api.nvim_replace_termcodes(keys, true, false, true) or keys
  end, vim.tbl_extend('force', o, { replace_keycodes = false }))
end

return M
