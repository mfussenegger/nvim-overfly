# Overfly

Provides keymaps to quickly fly around your source code

- `]q -> cnext`
- `[q -> cprevious`
- `]Q -> cfirst`
- `[Q -> clast`
- `]l -> lnext`
- `[l -> previous`
- `]L -> lfirst`
- `[L -> llast`
- `]w -> next diagnostic` (by worst severity, e.g. skips warnings if there are any errors)
- `[w -> prev diagnostic`
- `]v -> next document highlight` (highlighted by `vim.lsp.buf.document_highlight()`)
- `[v -> prev document highlight` (highlighted by `vim.lsp.buf.document_highlight()`)
- `]M -> next methods` prompts for selection; requires [nvim-qwahl][qwahl]
- `[M -> prev methods` prompts for selection; requires [nvim-qwahl][qwahl]

For each category there is also a `<leader>]<key>` variant that will enter a
"move-mode". In this mode you can continue navigating with just `]` or `[`.
Turning something like `]q ]q ]q ]q ]q` into `<leader]q ] ] ] ]`

An exception for that is `]M`, which instead has a `<leader>]m` which jumps
between methods without prompt.

## Installation

```bash
git clone \
    https://github.com/mfussenegger/nvim-overfly.git \
    ~/.config/nvim/pack/plugins/start/nvim-overfly
```

No setup required.

## Configuration

Fork it and edit the code in `plugin/overfly.lua`

## Contributions

Thanks, but no

## Bugs

Keep them

## Support

You are on your own


[qwahl]: https://github.com/mfussenegger/nvim-qwahl
