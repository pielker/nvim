-- Lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
  {"ellisonleao/gruvbox.nvim", priority = 1000, config = function() vim.cmd("colorscheme gruvbox") end},
  {"neovim/nvim-lspconfig"},
  {"williamboman/mason.nvim", config = true},
  {"williamboman/mason-lspconfig.nvim", config = true},
  {"hrsh7th/nvim-cmp", dependencies = {"hrsh7th/cmp-nvim-lsp"}},
  {"hrsh7th/cmp-cmdline"},
  {"nvim-lualine/lualine.nvim", dependencies = {"nvim-tree/nvim-web-devicons"}, config = true},
  {"lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}},
  {"folke/trouble.nvim", opts = {}},
  {"nvim-java/nvim-java"},
  {"iamcco/markdown-preview.nvim", 
    cmd = {"MarkdownPreviewToggle", 
          "MarkdownPreview", 
          "MarkdownPreviewStop"}, 
    build = "cd app && yarn install", 
    init = function() vim.g.mkdp_filetypes = {"markdown"} end,
    ft = {"markdown"}}
  })

-- General
vim.o.background = "dark"
vim.o.number = true
vim.o.linebreak = true
vim.o.signcolumn = 'yes'
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.expandtab = true
vim.o.breakindent = true
vim.o.autoread = true
vim.api.nvim_set_option("clipboard", "unnamed")

-- Mappings
vim.keymap.set('n', '<C-h>', 'gT', { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', 'gt', { noremap = true, silent = true })


-- Treesitter
require("nvim-treesitter.configs").setup({highlight = { enable = true }})

-- Java
require("java").setup()

-- Vertical lines indent
require("ibl").setup({indent = {char = "│"}})

-- LSP
--local lspconfig = require("lspconfig")
--local lsp_defaults = lspconfig.util.default_config
--lsp_defaults.capabilities = vim.tbl_deep_extend('force', lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP Keybindings",
  callback = function(event)
    local opts = {buffer = event.buf}
    local keymap = vim.keymap.set
    keymap("n", "K", vim.lsp.buf.hover, opts)
    keymap("n", "gd", vim.lsp.buf.definition, opts)
    keymap("n", "gD", vim.lsp.buf.declaration, opts)
    keymap("n", "gi", vim.lsp.buf.implementation, opts)
    keymap("n", "gr", vim.lsp.buf.references, opts)
    keymap("n", "<F2>", vim.lsp.buf.rename, opts)
    keymap({"n", "x"}, "<F3>", function() vim.lsp.buf.format({async = true}) end, opts)
    keymap("n", "<F4>", vim.lsp.buf.code_action, opts)
    keymap("n", "<space>e", function() vim.diagnostic.open_float(0, {scope="line"}) end, opts)
  end,
})

-- Autocompletion (cmp)
local cmp = require("cmp")
cmp.setup({
  sources = {{ name = "nvim_lsp" }},
  snippet = {expand = function(args) vim.snippet.expand(args.body) end},
  mapping = cmp.mapping.preset.insert({})
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({{ name = 'path' }}, {{ name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } }})
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {{ name = 'buffer' }}
})

-- LSP servers
local servers = {"clangd", 
                "bashls", 
                "cssls", 
                "html", 
                "pyright", 
                "jdtls", 
                "ts_ls"}
for _, server in ipairs(servers) do
  --lspconfig[server].setup({})
  vim.lsp.enable(server)
end
