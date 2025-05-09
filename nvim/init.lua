function init_lazy_nvim()
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
	require("lazy").setup(PLUGINS, opts)
end

function define_keymaps()
	vim.api.nvim_set_keymap("n", "J", "10j", { noremap = true, silent = true })

	-- space+f to open telescope browser in normal mode
	vim.api.nvim_set_keymap("n", "<space>f", ":NvimTreeToggle<CR>", { noremap = true })

	-- space+l to open lazy plugin mgr in normal mode
	vim.api.nvim_set_keymap("n", "<space>l", ":Lazy home<CR>", { noremap = true })

	vim.api.nvim_set_keymap("n", "<space>t", ":FloatermToggle<CR>", { noremap = true })

	-- keymap for nvim-lspconfig
	-- Global mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
	vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

	-- Use LspAttach autocommand to only map the following keys
	-- after the language server attaches to the current buffer
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			-- Enable completion triggered by <c-x><c-o>
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

			-- Buffer local mappings.
			-- See `:help vim.lsp.*` for documentation on any of the below functions
			local opts = { buffer = ev.buf }
			vim.keymap.set("n", "<space>D", vim.lsp.buf.declaration, opts)
			vim.keymap.set("n", "<space>d", vim.lsp.buf.definition, opts)
			vim.keymap.set({ "n", "v" }, "<space>a", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
			vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
			vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
			vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
			vim.keymap.set("n", "<space>wl", function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, opts)
			vim.keymap.set("n", "<space>r", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

			vim.keymap.set("n", "<space>h", ":ClangdSwitchSourceHeader<CR>", { noremap = true })
		end,
	})

	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<space>F", builtin.find_files, {})
	vim.keymap.set("n", "<space>g", builtin.live_grep, {})
	vim.keymap.set("n", "<space>b", builtin.buffers, {})
	vim.keymap.set("n", "<space>u", builtin.lsp_references, {})
end

function setup_plugins()
	require("nvim-treesitter.configs").setup({
		-- A list of parser names, or "all" (the five listed parsers should always be installed)
		ensure_installed = { "c", "lua", "vim", "vimdoc" },

		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = false,

		-- Automatically install missing parsers when entering buffer
		-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
		auto_install = true,

		-- List of parsers to ignore installing (or "all")
		ignore_install = { "javascript" },

		---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
		-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

		highlight = {
			enable = true,

			-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
			-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
			-- Using this option may slow down your editor, and you may see some duplicate highlights.
			-- Instead of true it can also be a list of languages
			additional_vim_regex_highlighting = false,
		},

		autotag = {
			enable = true,
		},
	})

	require("auto-dark-mode").setup({
		set_dark_mode = function()
			vim.opt.background = "dark"
			vim.cmd("colorscheme catppuccin-mocha")
		end,

		set_light_mode = function()
			vim.opt.background = "light"
			vim.cmd("colorscheme catppuccin-latte")
		end,
	})

	require("no-neck-pain").setup({
		width = 120,
		fallbackOnBufferDelete = true,
		autocmds = {
			enableOnVimEnter = true,
			reloadOnColorSchemeChange = true,
		},
	})

	require("nvim-tree").setup({
		disable_netrw = false,
		hijack_netrw = true,
		respect_buf_cwd = true,
		sync_root_with_cwd = true,
		filters = { dotfiles = false, custom = { "^.git$" } },
		view = {
			relativenumber = true,
			float = {
				enable = true,
				open_win_config = function()
					local screen_w = vim.opt.columns:get()
					local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
					local window_w = screen_w * 0.5
					local window_h = screen_h * 0.5
					local window_w_int = math.floor(window_w)
					local window_h_int = math.floor(window_h)
					local center_x = (screen_w - window_w) / 2
					local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
					return {
						border = "rounded",
						relative = "editor",
						row = center_y,
						col = center_x,
						width = window_w_int,
						height = window_h_int,
					}
				end,
			},
			width = function()
				return math.floor(vim.opt.columns:get() * 0.5)
			end,
		},
	})

	local telescope = require("telescope")
	telescope.setup({
		defaults = {
			file_ignore_patterns = { "node_modules" },
		},

		extensions = {
			["ui-select"] = {
				require("telescope.themes").get_dropdown({}),

				-- pseudo code / specification for writing custom displays, like the one
				-- for "codeactions"
				-- specific_opts = {
				--   [kind] = {
				--     make_indexed = function(items) -> indexed_items, width,
				--     make_displayer = function(widths) -> displayer
				--     make_display = function(displayer) -> function(e)
				--     make_ordinal = function(e) -> string
				--   },
				--   -- for example to disable the custom builtin "codeactions" display
				--      do the following
				--   codeactions = false,
				-- }
			},
		},
	})
	telescope.load_extension("ui-select")

	require("nvim-web-devicons").setup()

	local lsps = {
		lua_ls = {
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					completion = {
						callSnippet = "Replace",
					},
					-- You can toggle below to ignore Lua_LS's noisy missing-fields warnings
					-- diagnostics = { disable = { 'missing-fields' } },
				},
			},
		},

		dartls = {
			cmd = { "dart", "language-server", "--protocol=lsp" },
		},

		vtsls = {
			settings = {
				typescript = {
					updateImportsOnFileMove = "prompt",
					preferences = {
						preferTypeOnlyAutoImports = true,
						useAliasesForRenames = false,
						renameShorthandProperties = false,
					},
				},
			},
		},

		clangd = {
			cmd = { "clangd", "--background-index", "--clang-tidy" },
		},
	}

	require("mason").setup()
	require("mason-lspconfig").setup()
	require("mason-lspconfig").setup_handlers({
		function(server_name)
			local server = lsps[server_name] or {}
			require("lspconfig")[server_name].setup(server)
		end,
	})

	require("lualine").setup({
		options = {
			theme = "auto",
			icons_enabled = true,
			component_separators = "",
			section_separators = { left = "", right = "" },
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			globalstatus = true,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			},
		},
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "branch", "diff" },
			lualine_c = {},
			lualine_x = {},
			lualine_y = { "os.date('%a %b %d %H:%M')" },
			lualine_z = {},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {},
			lualine_x = { "location" },
			lualine_y = {},
			lualine_z = {},
		},
		tabline = {},
		winbar = {
			lualine_a = {},
			lualine_b = {
				{
					"filename",
					path = 1,
				},
			},
			lualine_c = {},
			lualine_x = { "searchcount", "encoding", "diagnostics" },
			lualine_y = { "filetype" },
			lualine_z = {},
		},
		inactive_winbar = {},
		extensions = {},
	})

	local util = require("formatter.util")
	require("formatter").setup({
		filetype = {
			javascript = {
				require("formatter.filetypes.javascript").biome,
			},
			javascriptreact = {
				require("formatter.filetypes.javascriptreact").biome,
			},
			typescript = {
				require("formatter.filetypes.typescript").biome,
			},
			typescriptreact = {
				require("formatter.filetypes.typescriptreact").biome,
			},
			json = {
				require("formatter.filetypes.json").biome,
			},
			css = {
				require("formatter.filetypes.css").prettier,
			},
			rust = {
				require("formatter.filetypes.rust").rustfmt,
			},
			astro = {
				function()
					return {
						exe = "prettier",
						args = {
							"--stdin-filepath",
							util.escape_path(util.get_current_buffer_file_path()),
							"--parser",
							"astro",
						},
						stdin = true,
						try_node_modules = true,
					}
				end,
			},
			lua = { require("formatter.filetypes.lua").stylua },
			c = { require("formatter.filetypes.c").clangformat },
			cpp = { require("formatter.filetypes.cpp").clangformat },
			dart = { require("formatter.filetypes.dart").dartformat },
			python = { require("formatter.filetypes.python").black },
			go = { require("formatter.filetypes.go").goimports },
			sql = {
				function()
					return {
						exe = "sqlfmt",
						args = {
							"-",
						},
						stdin = true,
					}
				end,
			},
			nix = { require("formatter.filetypes.nix").nixpkgs_fmt },
		},
	})

	local cmp = require("cmp")
	cmp.setup({
		window = {
			completion = {
				winhighlight = "Normal:CmpNormal,FloatBorder:CmpNormal,Search:None",
				side_padding = 0,
				border = "rounded",
				scrollbar = "║",
			},
		},

		formatting = {
			fields = { "kind", "abbr", "menu" },
			format = function(entry, vim_item)
				local kind = require("lspkind").cmp_format({
					mode = "symbol_text",
					maxwidth = 50,
					symbol_map = {
						Text = "󰦨",
						Variable = "󰫧",
						Keyword = "",
						Field = "",
					},
				})(entry, vim_item)
				local strings = vim.split(kind.kind, "%s", { trimempty = true })
				kind.kind = " " .. (strings[1] or "") .. " "
				kind.menu = "    [" .. (strings[2] or "") .. "]"

				return kind
			end,
		},

		snippet = {
			expand = function(args)
				require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
			end,
		},

		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Up>"] = cmp.mapping.select_prev_item(),
			["<Down>"] = cmp.mapping.select_next_item(),
		}),

		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "buffer" },
			{ name = "nvim_lsp_signature_help" },
		}),
	})

	require("gitsigns").setup({
		signs = {
			add = { text = "┃" },
			change = { text = "┃" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "┆" },
		},
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]h", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end)

			map("n", "[h", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[h", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end)

			map("n", "<space>hr", gitsigns.reset_hunk)
			map("n", "<space>hp", gitsigns.preview_hunk)
		end,
	})
end

function config_vim()
	local default_tabwidth = 2
	local override_tabwidth = {
		cpp = 4,
		go = 4,
	}

	vim.opt.tabstop = default_tabwidth
	vim.opt.shiftwidth = default_tabwidth
	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.laststatus = 3
	vim.opt.pumheight = 10
	vim.opt.scrolloff = 10
	vim.opt.listchars = {}
	vim.opt.termguicolors = true

	vim.o.guifont = "CommitMono Nerd Font:h14"

	vim.g.neovide_floating_shadow = false
	vim.g.neovide_position_animation_length = 0
	vim.g.neovide_cursor_animation_length = 0.00
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_cursor_animate_in_insert_mode = false
	vim.g.neovide_cursor_animate_command_line = false
	vim.g.neovide_scroll_animation_far_lines = 0
	vim.g.neovide_scroll_animation_length = 0.00

	vim.filetype.add({
		extension = {
			typ = "typst",
		},

		filename = {
			["Dockerfile"] = "dockerfile",
			["docker-compose.yml"] = "yaml.docker-compose",
			["docker-compose.yaml"] = "yaml.docker-compose",
			["compose.yml"] = "yaml.docker-compose",
			["compose.yaml"] = "yaml.docker-compose",
		},

		pattern = {
			["Dockerfile.*"] = "dockerfile",
			["docker%-compose%b..yml"] = "yaml.docker-compose",
			["compose%b..yml"] = "yaml.docker-compose",
		},
	})

	local augroup = vim.api.nvim_create_augroup
	local autocmd = vim.api.nvim_create_autocmd

	augroup("__formatter__", { clear = true })
	autocmd("BufWritePost", {
		group = "__formatter__",
		command = ":FormatWrite",
	})

	augroup("__indentation__", { clear = true })
	autocmd("FileType", {
		group = "__indentation__",
		callback = function(opts)
			local filetype = vim.bo[opts.buf].filetype
			if override_tabwidth[filetype] ~= nil then
				vim.opt.tabstop = override_tabwidth[filetype]
				vim.opt.shiftwidth = override_tabwidth[filetype]
			end
		end,
	})

	vim.diagnostic.config({
		virtual_text = false,
		update_in_insert = true,
	})
	local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
	for type, icon in pairs(signs) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end
end

PLUGINS = {
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "shortcuts/no-neck-pain.nvim" },
	{ "nvim-tree/nvim-web-devicons" },
	{ "nvim-tree/nvim-tree.lua" },
	{ "nvim-lualine/lualine.nvim" },
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "onsails/lspkind.nvim" },
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "hrsh7th/nvim-cmp" },
	{ "hrsh7th/cmp-nvim-lsp-signature-help" },
	{ "mhartington/formatter.nvim" },
	{
		"L3MON4D3/LuaSnip",
		-- install jsregexp (optional!).
		build = "make install_jsregexp",
	},
	{ "voldikss/vim-floaterm" },
	{ "f-person/auto-dark-mode.nvim" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ "nvim-telescope/telescope-ui-select.nvim" },
	{
		{
			"kdheepak/lazygit.nvim",
			cmd = {
				"LazyGit",
				"LazyGitConfig",
				"LazyGitCurrentFile",
				"LazyGitFilter",
				"LazyGitFilterCurrentFile",
			},
			-- optional for floating window border decoration
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			-- setting the keybinding for LazyGit with 'keys' is recommended in
			-- order to load the plugin when the command is run for the first time
			keys = {
				{ "<space>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
			},
		},
	},
	{ "lewis6991/gitsigns.nvim" },
	{ "nvim-treesitter/nvim-treesitter" },
	{
		"chomosuke/typst-preview.nvim",
		lazy = false, -- or ft = 'typst'
		version = "0.2.0",
		build = function()
			require("typst-preview").update()
		end,
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{ "windwp/nvim-ts-autotag" },
	{
		"numToStr/Comment.nvim",
		opts = {
			-- add any options here
		},
	},
}

init_lazy_nvim()
setup_plugins()
define_keymaps()
config_vim()

vim.cmd("source ~/dotfiles/nvim/macmap.vim")
