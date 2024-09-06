return {
  {
    "neovim/nvim-lspconfig",
    build = [[:let g:auto_lsp_update = 1]],
  },

  {
    "WieeRd/auto-lsp.nvim",
    build = [[:let g:auto_lsp_update = 1]],
  },
}
