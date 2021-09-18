--local p = require('lib/utils').prettyPrint
--
package.cpath = package.cpath .. ';/home/f1/dev/cl/lua/me-plug/codelibrary/luv/?.so'
local uv = require('luv')

local inspect = require"inspect"
local dump = function(t) print(inspect(t)) end


local tasks_amount = 1
local completed_tasks = 0

local child, pid
child, pid = uv.spawn("sleep", {
  args = {"2"}
}, function (code, signal)
  print("EXIT")
  dump({code=code,signal=signal})
  uv.close(child)
  completed_tasks = 1
end)


dump{child=child, pid=pid}

--uv.kill(pid, "SIGKILL")
--uv.process_kill(child, "SIGTERM")

-- repeat
--  -- print("\ntick.")
-- until tasks_amount == completed_tasks


-- repeat
--  -- print("\ntick.")
--  -- print(completed_tasks)
-- until uv.run('once') == 0

while uv.run('once') == 1 do print('uv.run ~= 1') end


print("done")
