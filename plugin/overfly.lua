local move_maps = {
  {']q', ':cnext<CR>'},
  {'[q', ':cprevious<CR>'},
  {']Q', ':cfirst<CR>'},
  {'[Q', ':clast<CR>'},
  {']l', ':lnext<CR>'},
  {'[l', ':lprevious<CR>'},
  {']L', ':lfirst<CR>'},
  {'[L', ':llast<CR>'},
  {']w', function() require("overfly").next_diagnostic() end},
  {'[w', function() require("overfly").prev_diagnostic() end},
  {']v', function() require("overfly").next_highlight() end},
  {'[v', function() require("overfly").prev_highlight() end},
  {']M', function() require("overfly").select_methods { mode = "next" } end},
  {'[M', function() require("overfly").select_methods { mode = "prev" } end},
}

local keymap = vim.keymap
for _, move_map in pairs(move_maps) do
  keymap.set('n', move_map[1], move_map[2])
end


keymap.set('n', '<leader>]v', function()
  require("overfly").move({
    next = require("overfly").next_highlight,
    prev = require("overfly").prev_highlight
  })
end)
keymap.set("n", "<leader>]q", function()
  require("overfly").move({
    next = function() vim.cmd("cnext") end,
    prev = function() vim.cmd("cprev") end,
  })
end)
keymap.set("n", "<leader>]l", function()
  require("overfly").move({
    next = function() vim.cmd("lnext") end,
    prev = function() vim.cmd("lprev") end,
  })
end)
keymap.set("n", "<leader>]w", function()
  local overfly = require("overfly")
  overfly.move({
    next = overfly.next_diagnostic(),
    prev = overfly.prev_diagnostic()
  })
end)
keymap.set("n", "<leader>]m", function()
  local overfly = require("overfly")
  overfly.move({
    next = function() overfly.select_methods_sync { mode = "next", pick_first = true } end,
    prev = function() overfly.select_methods_sync { mode = "prev", pick_first = true } end,
  })
end)
keymap.set("n", "<leader>]c", function()
  require("overfly").move({
    next = function() vim.cmd.normal("]c") end,
    prev = function() vim.cmd.normal("[c") end,
  })
end)
