-- how this script handles ignore paths:
-- symlinks.lua { "source", "dest", "recurse"/true/false, {"ignore_sub_dir_1", "ignore_sub_dir_2" }  }
-- cl_symlink.lua - reads symlinks.lua, converts to {"source", "dest", "recurse"/true/false", "ignore_sub_dir_1", "ignore_sub_dir_2" }

-- ln.lua - only accepts this format { "source", "dest", "recurse"/true/false, "ignore_sub_dir_1", "ignore_sub_dir_2" }
-- this is because I can't call with tables from CLI, but I can from another lua script

local scan = require("plenary.scandir")

local colors = require"lib.ansicolors"
local util = require"codelibrary.util"

local function create_symlink(sym)
  util.create_fp_dirs(sym.dest_parent)
  if not uv.fs_stat(sym.dest) then
    -- fs_symlink still creates a symlink if source doesnt exist

    if not uv.fs_stat(sym.source) then
      print(colors("%{bright red}[FAIL] " .. sym.source .. " source does not exist"))
      return
    end
    uv.fs_symlink(sym.source, sym.dest, {}, function(err, success)
      if err then
        print(colors("%{bright red}[FAIL] " .. err))
      end

      if success then
        print(colors("%{bright green}" .. sym.source .. " --> " .. sym.dest .. " [SUCCESSFULLY SYMLINKED]"))
      end
    end)
  else  
  print(colors("%{bright green}" .. sym.source .. " <--> " .. sym.dest .. " [ALREADY EXISTS]"))
  end
end

local function get_all_source_files(sym)
  -- generate absolute ignore paths
  local ignore_paths = {}
  if sym.recurse_ignore then
    for _, ignore_dir in ipairs(sym.recurse_ignore) do
      table.insert(ignore_paths, ("%s/%s"):format(sym.source, ignore_dir))
    end
  end

  local syms = {}
  scan.scan_dir(sym.source, {
    depth = 1,
    add_dirs = true,
    search_pattern = function(fp)
      if sym.recurse_ignore then
        for _, ignore_path in ipairs(ignore_paths) do
          if fp == ignore_path then
            return false
          end
        end
      end
      return true
    end,
    on_insert = function(fp)
      local sub_dir = fp:match("^.*/(.*)$")
      table.insert(syms, {
        source = fp,
        dest = sym.dest .. "/" .. sub_dir,
        recurse = false,
        dest_parent = sym.dest,
      })
    end,
  })
  return syms
end

local M = {}
-- SCRIPT START --
function M.ln(...)
  --local arg
  --if type(arg[1]) == "String" then
  arg = { ... }
  --else 
  --arg = arg
  --end
  --os.exit()

  if not arg[1] or not arg[2] then
    print("specify arg1: source arg2: dest minimum")
  end

  local sym = {
    source = arg[1],
    dest = arg[2],
  }
  sym.recurse = false
  if arg[3] then
    sym.recurse = true
    if arg[4] then
      local i = 4
      sym.recurse_ignore = {}
      repeat
        if arg[i] then
          table.insert(sym.recurse_ignore, arg[i])
        end
        i = i + 1
      until i - 1 == #arg
    end
  end

  if not sym.recurse then
    sym.dest_parent = sym.dest:match("^(.*)/")
  end

  if sym.recurse then
    local syms = get_all_source_files(sym)

    for _, sym in ipairs(syms) do
      create_symlink(sym)
    end
  else
    create_symlink(sym)
  end
end

-- use for CLI usage, this will only run if executed from CLI
if arg[1] then
  --ln()
end

return M
