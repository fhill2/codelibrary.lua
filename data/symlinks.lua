local home = os.getenv("HOME")
local dev = home .. "/dev"
local cl = home .. "/cl"
-- these have to be absolute paths
return {
  dir = {
    {cl .. "/lua",},
    {cl .. "/nix"},
    {cl .. "/python"},
  },
  sym = {
    -- all ~/dev/cl
    { dev .. "/cl/format", cl .. "/format" },
    { dev .. "/cl/lua/me-plug", cl .. "/lua/me-plug" },
    { dev .. "/cl/lua/scratch", cl .. "/lua/scratch" },
    { dev .. "/cl/lua/tuts", cl .. "/lua/tuts" },
    { dev .. "/cl/old", cl .. "/old" },
    { dev .. "/cl/shell", cl .. "/shell", "recurse", { "AANotusingAnymore" } },
    { dev .. "/cl/python/me", cl .. "/python/me" },
    { dev .. "/cl/snippets", cl .. "/snippets" },

    -- other ~/dev
    { dev .. "/dot/me", cl .. "/dot" },
    { dev .. "/NOTES FREDDIE.txt", cl .. "/NOTES FREDDIE.txt" },

    -- other
    { home .. "/.local/share/nvim/site/pack/packer", home .. "/cl/lua/nv-plugs" },

    -- made f1 user config root config
    { home .. "/.config/nvim", "/root/.config/nvim" },
    { home .. "/.local/share/nvim", "/root/.local/share/nvim" },
  },
}

-- path to all systemd units for read only viewing
