return {
-- dl_location = "home/f1/repos"
-- each module is symlinked to  = "home/f1/cl/modulepath" <-- module path defined as [2] in each table
  config = {
    destination = "/repos",
    symlink_destination = "/cl",
  },
  repos = {
    shell = { {
      "https://github.com/jarun/nnn",
      "https://github.com/kovidgoyal/kitty",
      { "https://github.com/kovidgoyal/kitty/tree/master/kittens", "kitty_kittens" },
    }, "shell/repos" },

    dotfiles_nix = {
      {
        { "https://github.com/mjlbach/nix-dotfiles", "mjlbach" },
        { "https://github.com/sherubthakur/dotfiles", "sherubthakur" },
        { "https://github.com/teto/home", "teto" },
        { "https://github.com/notusknot/dotfiles-nix", "notusknot" },
        { "https://github.com/breuerfelix/nixos", "breuerfelix" },
        { "https://github.com/MoleTrooper/dotfiles", "moletrooper" },
        { "https://github.com/elianiva/dotfiles", "elianiva" },
      },
      "dot/nix",
    },

    dotfiles_lua = {
      {
        { "https://github.com/gf3/dotfiles", "gf3" },
        { "https://github.com/jameswalmsley/dotfiles", "jameswalmsley" },
        { "https://github.com/LunarVim/LunarVim", "lunarvim" },
        { "https://github.com/NvChad/NvChad", "nvchad" },
      },
      "dot/lua",
    },

    dotfiles_shell = { { "https://github.com/junegunn/dotfiles", "junegunn" }, "dot/shell" },

    lua_telescope_extensions = {
      {
        "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
        "https://github.com/nvim-telescope/telescope-github.nvim",
        "https://github.com/nvim-telescope/telescope-project.nvim",
        "https://github.com/nvim-telescope/telescope-fzf-writer.nvim",
        "https://github.com/nvim-telescope/telescope-dap.nvim",
        "https://github.com/nvim-telescope/telescope-arecibo.nvim",
        "https://github.com/nvim-telescope/telescope-bibtex.nvim",
        "https://github.com/nvim-telescope/telescope-media-files.nvim",
        "https://github.com/nvim-telescope/telescope-node-modules.nvim",
        "https://github.com/nvim-telescope/telescope-ghq.nvim",
        "https://github.com/nvim-telescope/telescope-cheat.nvim",
        "https://github.com/nvim-telescope/telescope-snippets.nvim",
        "https://github.com/nvim-telescope/telescope-symbols.nvim",
        "https://github.com/nvim-telescope/telescope-packer.nvim",
        "https://github.com/nvim-telescope/telescope-vimspector.nvim",
        -- from wiki extensions page
        "https://github.com/nvim-telescope/telescope-frecency.nvim",
        "https://github.com/nvim-telescope/telescope-z.nvim",
        "https://github.com/GustavoKatel/telescope-asynctasks.nvim",
        "https://github.com/bi0ha2ard/telescope-ros.nvim",
        "https://github.com/fhill2/telescope-ultisnips.nvim",
        "https://github.com/luc-tielen/telescope_hoogle",
        "https://github.com/brandoncc/telescope-harpoon.nvim",
        "https://github.com/TC72/telescope-tele-tabby.nvim",
        "https://github.com/gbrlsnchs/telescope-lsp-handlers.nvim",
        "https://github.com/fannheyward/telescope-coc.nvim",
        "https://github.com/dhruvmanila/telescope-bookmarks.nvim",
      },
      "lua/repos/telescope/extensions",
    },

    lua_telescope = { {
      "https://github.com/nvim-telescope/telescope.nvim",
    }, "lua/repos/telescope" },

    lua_awesome = { {
      "https://github.com/streetturtle/awesome-wm-widgets",
      "https://github.com/awesomeWM/awesome",
    }, "lua/repos/awesome" },
    nix = { {
      { "https://github.com/NixOS/nixpkgs", "nixpkgs" },
    }, "nix/repos" },
    python = {
      {
        { "https://github.com/ghill2/pytower_proj", "pytower" },
        { "https://github.com/polygon-io/client-python", "polygon-client-library" },
        { "https://github.com/polygon-io/client-examples", "polygon-examples" },
      },
      "python/repos",
    },
  },
}
