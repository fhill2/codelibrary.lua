local home = os.getenv("HOME")
local dev = home .. "/dev"
local cl = home .. "/cl"

return {
    -- all ~/dev/cl
    { dev .. "/cl/format", cl .. "/format" },
    { dev .. "/cl/lua/me-plug", cl .. "/lua/me-plug" },
    { dev .. "/cl/lua/scratch", cl .. "/lua/scratch" },
    { dev .. "/cl/lua/tuts", cl .. "/lua/tuts" },
    { dev .. "/cl/lua/old", cl .. "/lua/old" },
    { dev .. "/cl/sessions", cl .. "/nv-sessions" },
    { dev .. "/cl/shell", cl .. "/shell", "recurse", { "AANotusingAnymore" } },
    { dev .. "/cl/snippets", cl .. "/snippets" },

    -- other ~/dev
    { dev .. "/dot", cl .. "/dot" },
    { dev .. "/NOTES FREDDIE.txt", cl .. "/NOTES FREDDIE.txt" },

    -- other
    { home .. "/.local/share/nvim/site/pack/packer", home .. "/cl/lua/nv-plugs" },
}

-- path to all systemd units for read only viewing
