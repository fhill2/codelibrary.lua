local path_to_this_file = os.getenv("PWD") .. "/" .. debug.getinfo(1).short_src
local root = path_to_this_file:match("^(.*)/.*$")
package.cpath = package.cpath .. ";" .. root .. "/luv/?.so"
vim = require("shared")
vim.loop = require("luv")
local uv = require("luv")
local home = uv.os_homedir()
local mode = uv.fs_stat(home).mode

---
local utils = require("futil/utils")
local symlinks = dofile(root .. "/symlinks.lua")
local scan = require("plenary.scandir")
local inspect = require("inspect")
local dump = function(t)
  print(inspect(t))
end
local colors = dofile(root .. "/ansicolors.lua")

-- check if all folders in a filepath exist. if not, create them
-- only works for folders in current user folder
local create_fp_dirs = function(fp)
  local uv = vim.loop

  if fp:find(home) then
    _, _, fp = fp:find(home .. "/(.*)")
  end

  local dirs_to_create = {}

  local fp = vim.split(fp, "/")
  local file_or_dir = fp[#fp]:find("%.")
  if file_or_dir then
    table.remove(fp, #fp)
  end
  local depth = #fp
  local current_relpath = fp[1]
  for i = 1, depth do
    table.insert(dirs_to_create, string.format("%s/%s", home, current_relpath))
    current_relpath = current_relpath .. "/" .. (fp[i + 1] or "")
  end

  for i, folderpath in ipairs(dirs_to_create) do
    local r = uv.fs_stat(folderpath, nil)
    if r == nil then
      local r = uv.fs_mkdir(folderpath, mode, nil)
      if r == nil then
        assert(false, "couldnt write to file " .. folderpath)
      end
    end
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

local function create_symlink(sym)
  create_fp_dirs(sym.dest_parent)
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
        print(colors("%{bright green}" .. sym.source .. " --> " .. sym.dest .. " [SUCCESS]"))
      end
    end)
  end
end


-- remove dir




local function path_join(paths)
  return table.concat(paths, "/")
end

local function remove_dir(cwd)
  local handle = uv.fs_scandir(cwd)
  if type(handle) == 'string' then
   -- return api.nvim_err_writeln(handle)
     return print(handle) 
 end

  while true do
    local name, t = uv.fs_scandir_next(handle)
    if not name then break end

    local new_cwd = path_join({cwd, name})
    if t == 'directory' then
      local success = remove_dir(new_cwd)
      if not success then return false end
    else
      local success = uv.fs_unlink(new_cwd)
      if not success then return false end
     -- clear_buffer(new_cwd)
    end
  end

  return uv.fs_rmdir(cwd)
end

-- end remove dir

-- SCRIPT START --

-- delete ~/cl first
local root = home .. "/cl"
  if uv.fs_stat(root) then remove_dir(root) end
  uv.fs_mkdir(root, mode, nil)
  print("rm " .. root)
  print("mkdir " .. root)


-- create syms
for _, sym_orig in ipairs(symlinks) do
  local sym = {
    source = sym_orig[1],
    dest = sym_orig[2],
  }
  sym.recurse = false
  if sym_orig[3] then
    sym.recurse = true
    if sym_orig[4] then
      sym.recurse_ignore = sym_orig[4]
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
