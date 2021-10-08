local symlinks = require"codelibrary.data.symlinks"
local repos = require"codelibrary.data.repos"
local dl_location = home .. "/" .. repos.config.dl
local dest = home .. "/" .. repos.config.dest


local util = require"codelibrary.util"
local ln = require"codelibrary.ln".ln


-- SCRIPT START --

-- delete ~/cl first
local cl_path = home .. "/cl"
if uv.fs_stat(cl_path) then
  util.remove_dir(cl_path)
end
uv.fs_mkdir(cl_path, mode, nil)
print("rm " .. cl_path)
print("mkdir " .. cl_path)

-- create non symlinked folders first
for _, dir in ipairs(symlinks.dir) do
  util.create_fp_dirs(dir)
end
-- create download.lua symlinks -->  ~/cl
for _, sym in ipairs(repos.repos) do
  local dest
  if not sym[2] then
    print(colors("%{bright red}group is missing destination: " .. group))
    os.exit()
  else
    dest = sym[2]
  end


end

-- create ~/dev/cl syms
for _, sym in ipairs(symlinks.sym) do
  if not sym[1] or not sym[2] then
    print("specify arg1: source arg2: dest minimum")
    os.exit()
  end

  if sym[5] then
    print("arg5 not allowed - use arg4 as table")
    os.exit()
  end

  local args = { sym[1], sym[2] }

  if sym[4] then
    table.insert(args, sym[3])
  end
  if sym[4] and type(sym[4]) == "table" then
    for _, v in ipairs(sym[4]) do
      table.insert(args, v)
    end
  elseif sym[4] and type(sym[4]) == "string" then
    table.insert(args, sym[4])
  end
  ln(unpack(args))
end
