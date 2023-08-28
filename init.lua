-- Plugins
-- lazy.nvim initialization.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- lazy.nvim package management
require("lazy").setup({
    -- colorscheme
    "sainnhe/gruvbox-material",
    "cocopon/iceberg.vim",
    "sainnhe/everforest",
    -- lsp
    {
        "williamboman/mason.nvim",
        build = "<Cmd>MasonUpdate<CR>" -- :MasonUpdate updates registry contents
    },
    "neovim/nvim-lspconfig",
    "williamboman/mason-lspconfig.nvim",
    "stevearc/dressing.nvim",
    "tami5/lspsaga.nvim",
    "onsails/lspkind-nvim",
    -- cmp
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/vim-vsnip",
    "hrsh7th/cmp-vsnip",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    -- others
    {
        "nvim-lua/telescope.nvim",
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    "nvim-treesitter/nvim-treesitter",
    "lambdalisue/fern.vim",
})

vim.cmd [[colorscheme gruvbox-material]]
--vim.cmd("colorscheme iceberg")

-- lsp configurataion
require("lspsaga").setup()
require("dressing").setup()
require("mason").setup()
local lspconfig = require("lspconfig")
require("mason-lspconfig").setup_handlers({ function(server)
    local opt = {
        capabilities = require("cmp_nvim_lsp").default_capabilities(
            vim.lsp.protocol.make_client_capabilities()
        )
    }
    lspconfig[server].setup(opt)
end })

lspconfig.lua_ls.setup({
    settings = {
        -- supress lua warnings
        Lua = {
            -- Get the language server to recognize the `vim` global
            diagnostics = { globals = { "vim" }, },
        },
    },
})


-- for lsp

--local function show_documentation()
--    local ft = vim.opt.filetype._value
--    if ft == "vim" or ft == "help" then
--        vim.cmd([[ execute "h " . expand("<cword>") ]])
--    else
--        require("lspsaga.hover").render_hover_doc()
--    end
--end

vim.api.nvim_create_autocmd({ "CursorHold" }, {
    pattern = { "*" },
    callback = function()
        require("lspsaga.diagnostic").show_cursor_diagnostics()
    end,
})

-- nvim-cmp
local cmp = require("cmp")
--local lspkind = require("lspkind")
cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            --require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
            -- require("snippy").expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        --{ name = "buffer" },
        --{ name = "path" },
        --{ name = "vsnip" },
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-l>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
    }),
    --    formatting = {
    --        fields = { 'abbr', 'kind', 'menu' },
    --        format = lspkind.cmp_format({
    --            mode = 'text',
    --        }),
    --    },
})

-- telescope
require("telescope").setup({
    defaults = {
        mappings = {
            n = {
                ["<Esc>"] = require("telescope.actions").close,
                ["<C-g>"] = require("telescope.actions").close,
            },
            i = {
                ["<Esc>"] = require("telescope.actions").close,
                ["<C-g>"] = require("telescope.actions").close,
            },
        },
    },
    pickers = {
        live_grep = {
            additional_args = function()
                return { "--hidden" }
            end
        },
    }
})

-- treesitter
require("nvim-treesitter.configs").setup({
    highlight = {
        enable = true
    }
})

-- key mapping
vim.g.mapleader = " "
vim.keymap.set({ "n" }, "<Esc><Esc>", ":nohl<CR>", {noremap =true, silent=true})
vim.keymap.set({ "n" }, "[d", vim.diagnostic.goto_prev)
vim.keymap.set({ "n" }, "]d", vim.diagnostic.goto_next)
vim.keymap.set({ "n" }, "<space>q", vim.diagnostic.setloclist)
--vim.keymap.set({ "n" }, "K", show_documentation)
vim.keymap.set({ "n" }, "K", '<Cmd>Lspsaga hover_doc<CR>')
vim.keymap.set({ "n" }, "<Leader>ca", require("lspsaga.codeaction").code_action)
vim.keymap.set({ "n" }, "<Leader>rn", require("lspsaga.rename").rename)
vim.keymap.set({ "n" }, "<Leader>q", "<Cmd>Telescope diagnostics<CR>")
vim.keymap.set({ "n" }, "<Leader>gn", require("lspsaga.diagnostic").navigate("next"))
vim.keymap.set({ "n" }, "<Leader>gp", require("lspsaga.diagnostic").navigate("prev"))
vim.keymap.set({ "n" }, "<space>f", function() vim.lsp.buf.format { async = true } end)
vim.keymap.set({ "n" }, "gi", "<Cmd>Telescope lsp_implementations<CR>")
vim.keymap.set({ "n" }, "gy", vim.lsp.buf.type_definition)
vim.keymap.set({ "n" }, "gd", vim.lsp.buf.definition)
vim.keymap.set({ "n" }, "gr", "<Cmd>Telescope lsp_references<CR>")
vim.keymap.set({ "n" }, "<space>wa", vim.lsp.buf.add_workspace_folder)
vim.keymap.set({ "n" }, "<space>wr", vim.lsp.buf.remove_workspace_folder)
vim.keymap.set({ "n" }, "<space>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end)
vim.keymap.set({ "n" }, "zf", "<Cmd>Telescope find_files hidden=true<CR>")
vim.keymap.set({ "n" }, "zg", "<Cmd>Telescope git_files<CR>")
vim.keymap.set({ "n" }, "zb", "<Cmd>Telescope buffers<CR>")
vim.keymap.set({ "n" }, "zs", "<Cmd>Telescope live_grep hidden=true<CR>")
vim.keymap.set({ "n" }, "zc", require("telescope.builtin").colorscheme, {})
vim.keymap.set({ "n" }, "<space>e", "<Cmd>Fern . -drawer<CR>", {})

-- option
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.wrap = true
vim.opt.clipboard = "unnamedplus"
vim.opt.whichwrap = "b,s,[,],<,>"
vim.opt.backspace = "indent,eol,start"
vim.opt.hidden = true
vim.opt.list = true
vim.opt.listchars = { tab = ">-" }
vim.cmd("let g:fern#default_hidden=1")
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 500
