return {
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    build = [[:call delete(stdpath("data") .. "/auto-lsp-mappings.lua")]],
  },

  {
    "WieeRd/auto-lsp.nvim",
    build = [[:call delete(stdpath("data") .. "/auto-lsp-mappings.lua")]],
  },
}
