-- ─────────────────────────────────────────────────────────────────
--  DevForge Neovim Extra Plugins (LazyVim extras)
-- ─────────────────────────────────────────────────────────────────

return {
  -- ── Colorscheme ─────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato",
      transparent_background = true,
      term_colors = true,
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = false,
        oil = true,
        telescope = { enabled = true },
        which_key = true,
        treesitter = true,
        mason = true,
        noice = true,
        notify = true,
        lsp_trouble = true,
        aerial = true,
        neogit = true,
      },
    },
  },

  -- ── Oil.nvim — file manager ──────────────────────────────────────
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = { show_hidden = true },
      float = { padding = 4 },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },

  -- ── Harpoon ──────────────────────────────────────────────────────
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>a", function() require("harpoon"):list():add() end, desc = "Harpoon add" },
      { "<C-e>",     function() local h = require("harpoon") h.ui:toggle_quick_menu(h:list()) end },
      { "<C-h>",     function() require("harpoon"):list():select(1) end },
      { "<C-j>",     function() require("harpoon"):list():select(2) end },
      { "<C-k>",     function() require("harpoon"):list():select(3) end },
      { "<C-l>",     function() require("harpoon"):list():select(4) end },
    },
  },

  -- ── Trouble ───────────────────────────────────────────────────────
  {
    "folke/trouble.nvim",
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>",                        desc = "Diagnostics" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",  desc = "Workspace" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",   desc = "Document" },
    },
  },

  -- ── Noice ─────────────────────────────────────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = { override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      }},
      routes = {
        { filter = { event = "msg_show", any = {{ find = "%d+L, %d+B" }, { find = "; after #%d+" }, { find = "; before #%d+" }} }, view = "mini" },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
  },

  -- ── Aerial — code outline ─────────────────────────────────────────
  {
    "stevearc/aerial.nvim",
    opts = { layout = { max_width = { 40, 0.2 }, width = nil, min_width = 20 } },
    keys = { { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Outline" } },
  },

  -- ── Multiple cursors ──────────────────────────────────────────────
  { "mg979/vim-visual-multi", branch = "master" },

  -- ── Surround ──────────────────────────────────────────────────────
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- ── Copilot ───────────────────────────────────────────────────────
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = true, auto_trigger = true, keymap = { accept = "<Tab>" } },
      panel = { enabled = false },
    },
  },

  -- ── Avante — AI assistant ─────────────────────────────────────────
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
      provider = "claude",
      claude = { model = "claude-sonnet-4-20250514", max_tokens = 8192 },
      behaviour = { auto_suggestions = false },
    },
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },

  -- ── Neogit ────────────────────────────────────────────────────────
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    config = true,
    keys = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" } },
  },

  -- ── Crates (Rust) ─────────────────────────────────────────────────
  {
    "saecki/crates.nvim",
    event = "BufRead Cargo.toml",
    opts = {},
  },

  -- ── Rust tools ────────────────────────────────────────────────────
  { "simrat39/rust-tools.nvim" },

  -- ── Telescope extensions ──────────────────────────────────────────
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { "nvim-telescope/telescope-file-browser.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions = require("telescope.actions")
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = { ["<C-t>"] = actions.select_tab, ["<esc>"] = actions.close },
        },
      })
    end,
  },

  -- ── Flash — fast cursor navigation ────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- ── Which-key extensions ──────────────────────────────────────────
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>g", group = "git" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader>o", group = "outline" },
      },
    },
  },
}
