local path_to_this_file = os.getenv("PWD") .. "/" .. debug.getinfo(1).short_src
local root = path_to_this_file:match("^(.*)/.*$")
package.cpath = package.cpath .. ";" .. root .. "/luv/?.so"
vim = require("shared")
vim.loop = require("luv")
local luv = require("luv")


local function remove_dir(cwd)
  local handle = luv.fs_scandir(cwd)
  if type(handle) == 'string' then
   -- return api.nvim_err_writeln(handle)
     return print(handle) 
 end

  while true do
    local name, t = luv.fs_scandir_next(handle)
    if not name then break end

    local new_cwd = utils.path_join({cwd, name})
    if t == 'directory' then
      local success = remove_dir(new_cwd)
      if not success then return false end
    else
      local success = luv.fs_unlink(new_cwd)
      if not success then return false end
     -- clear_buffer(new_cwd)
    end
  end

  return luv.fs_rmdir(cwd)
end

remove_dir("/tmp/floating.nvim")
