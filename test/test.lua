
package.cpath = package.cpath .. ';/home/f1/dev/cl/lua/me-plug/codelibrary/luv/?.so'
local uv = require"luv" 



--local stdin = uv.new_pipe()
local stdout = uv.new_pipe()
local stderr = uv.new_pipe()

--print("stdin", stdin)
print("stdout", stdout)
print("stderr", stderr)

local tasks_amount = 1
local completed_tasks = 0
local handle, pid = uv.spawn("git", {  
  --  -- /run/current-system/sw/bin/zsh"
  --args = {"-c", "'git", "clone", "https://github.com/fhill2/floating.nvim", "floater'"},
  args = {"clone", "https://github.com/fhill2/floating.nvim", "floater"},
  cwd = "/home/f1/dev/cl/lua/me-plug/codelibrary",
  stdio = {_, stdout, stderr}
}, function(code, signal) -- on exit
  print("exit code", code)
  print("exit signal", signal)
  completed_tasks = completed_tasks + 1
end)

print("process opened", handle, pid)

uv.read_start(stdout, function(err, data)
  assert(not err, err)
  if data then
    print("stdout chunk", stdout, data)
  else
    print("stdout end", stdout)
  end
end)

uv.read_start(stderr, function(err, data)
  assert(not err, err)
  if data then
    print("stderr chunk", stderr, data)
  else
    print("stderr end", stderr)
  end
end)


while tasks_amount ~= completed_tasks do
print(completed_tasks)
print(uv.is_active(handle))
print(uv.loop_alive())
end
uv.run()

-- uv.shutdown(stdin, function()
--   print("stdin shutdown", stdin)
--   uv.close(handle, function()
--     print("process closed", handle, pid)
--   end)
-- end)
