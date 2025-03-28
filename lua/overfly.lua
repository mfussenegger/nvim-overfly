local api = vim.api
local M = {}


local function move_to_highlight(is_closer)
  local lsp = vim.lsp
  local util = vim.lsp.util

  local win = api.nvim_get_current_win()
  local lnum, col = unpack(api.nvim_win_get_cursor(win))
  lnum = lnum - 1
  local cursor = {
    start = { line = lnum, character = col }
  }
  ---@diagnostic disable-next-line: deprecated
  local get_clients = lsp.get_clients or lsp.get_active_clients
  local method = "textDocument/documentHighlight"
  local bufnr = api.nvim_get_current_buf()
  local clients = get_clients({ bufnr = 0, method = method })
  if not next(clients) then
    return
  end
  local remaining = #clients
  local closest = nil
  ---@param result lsp.DocumentHighlight[]|nil
  local function on_result(_, result)
    for _, hl in ipairs(result or {}) do
      local range = hl.range
      local cursor_inside_range = (
        range.start.line <= lnum
        and range.start.character < col
        and range["end"].line >= lnum
        and range["end"].character > col
      )
      if not cursor_inside_range
        and is_closer(cursor, range)
        and (closest == nil or is_closer(range, closest)) then
        closest = range
      end
    end
    remaining = remaining - 1
  end
  for _, client in ipairs(clients) do
    local params = util.make_position_params(win, client.offset_encoding)
    if vim.fn.has("nvim-0.11") == 1 then
      client:request(method, params, on_result, bufnr)
    else
      ---@diagnostic disable-next-line: param-type-mismatch
      client.request(method, params, on_result, bufnr)
    end
  end
  vim.wait(1000, function()
    return remaining == 0
  end)
  if closest then
    api.nvim_win_set_cursor(win, { closest.start.line + 1, closest.start.character })
  end
end

local function is_before(x, y)
  if x.start.line < y.start.line then
    return true
  elseif x.start.line == y.start.line then
    return x.start.character < y.start.character
  else
    return false
  end
end

function M.next_highlight()
  return move_to_highlight(is_before)
end


function M.prev_highlight()
  return move_to_highlight(function(x, y) return is_before(y, x) end)
end


local function diagnostic_severity()
  local num_warnings = 0
  for _, d in ipairs(vim.diagnostic.get(0)) do
    if d.severity == vim.diagnostic.severity.ERROR then
      return vim.diagnostic.severity.ERROR
    elseif d.severity == vim.diagnostic.severity.WARN then
      num_warnings = num_warnings + 1
    end
  end
  if num_warnings > 0 then
    return vim.diagnostic.severity.WARN
  else
    return nil
  end
end


function M.next_diagnostic()
  ---@diagnostic disable-next-line: deprecated
  local jump = vim.diagnostic.jump or vim.diagnostic.goto_next
  jump({
    severity = diagnostic_severity(),
    float = { border = 'single' },
    count = 1,
  })
end


function M.prev_diagnostic()
  ---@diagnostic disable-next-line: deprecated
  local jump = vim.diagnostic.jump or vim.diagnostic.goto_prev
  jump({
    severity = diagnostic_severity(),
    float = { border = 'single' },
    count = -1,
  })
end


---@param opts? lsp_tags.opts
function M.select_methods(opts)
  local default_opts = {
    kind = {"Constructor", "Method", "Function"}
  }
  opts = vim.tbl_extend("force", default_opts, opts or {})
  require('qwahl').lsp_tags(opts)
end


---@param opts? lsp_tags.opts
function M.select_methods_sync(opts)
  local done = false
  opts = opts or {}
  opts.on_done = function()
    done = true
  end
  M.select_methods(opts)
  vim.wait(1000, function() return done == true end)
end


---@param opts {next: function, prev:function}
function M.move(opts)
  print("Move mode: Use ] or [ to move, any other char to abort: ")
  while true do
    vim.cmd.normal("zz")
    vim.cmd.redraw()
    local ok, keynum = pcall(vim.fn.getchar)
    if not ok then
      break
    end
    assert(type(keynum) == "number")
    local key = string.char(keynum)
    local fn
    if key == "]" then
      fn = opts.next
    elseif key == "[" then
      fn = opts.prev
    else
      break
    end
    local jump_ok, err = pcall(fn)
    if not jump_ok then
      vim.notify(err, vim.log.levels.WARN)
    end
  end
  print("Move mode exited")
end


return M
