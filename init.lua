package.cpath = package.cpath .. ';/home/f1/dev/cl/lua/me-plug/codelibrary/luv/?.so'
vim = require"shared"
vim.loop = require"luv"
local uv = require"luv"
--local async = dofile("/home/f1/.local/share/nvim/site/pack/packer/start/plenary.nvim/lua/plenary/async/init.lua")


--local Path = dofile("/home/f1/.local/share/nvim/site/pack/packer/start/plenary.nvim/lua/plenary/path.lua")

local Path = require'plenary.path'
--local async = require "plenary.async"
--local await_schedule = async.util.scheduler
--local channel = require("plenary.async.control").channel
--local sync = require''
local json = loadfile'./json.lua'
local utils = require'futil/utils'
local inspect = require"inspect"
local dump = function(t) print(inspect(t)) end
--print(async, Path, utils, vim, inspect, inspect(vim.loop))

local path_to_this_file = os.getenv("PWD") .. '/'.. debug.getinfo(1).short_src
local root = path_to_this_file:match"^(.*)/.*$"
local repos = dofile(root .. "/repos.lua")
local home = os.getenv("HOME") 
local colors = dofile(root .. "/ansicolors.lua")

local function get_fs()
local scan = require"plenary.scandir"
local fs_orig = {}
-- root level scan
scan.scan_dir(root .. "/repos", {
only_dirs = true, 
depth = 1,
on_insert = function(dir)
--local sub_root = dir:match"^(.*)/.*$"

scan.scan_dir(dir, {
  only_dirs = true, 
  depth = 1,
  on_insert = function(sub_dir)
table.insert(fs_orig, { sub_dir:match"/repos/(.*)$"})
  end
})
end
})
return fs_orig
end


local function get_repos()
local repo_orig = {}
for group, v in pairs(repos) do
for _, repo in ipairs(v) do
if type(repo) == "string" then
table.insert(repo_orig, { ("%s/%s"):format(group, repo:match"/(.*)$"), repo, group, "github" })
elseif type(repo) == "table" then

if repo[2] then
table.insert(repo_orig, { ("%s/%s"):format(group, repo[2]), repo[1], group, "github", repo[2]})
else
table.insert(repo_orig, { ("%s/%s"):format(group, repo[1]:match"/(.*)$"), repo[1], group, "github"})
end
end
end
end
return repo_orig
end

local function compare(fs_orig, repo_orig)
local fs_orig = vim.deepcopy(fs_orig)
local repo_orig = vim.deepcopy(repo_orig)
dump(fs_orig)
dump(repo_orig)

local exists_in_both = {}

for i, file_repo in ipairs(repo_orig) do
for j, fs_repo in ipairs(fs_orig) do
  --print(file_repo[1], fs_repo[1], type(file_repo[1]), type(fs_repo[1]))
  if file_repo[1] == fs_repo[1] then
    table.insert(exists_in_both, table.remove(repo_orig, i)) 
    table.remove(fs_orig, j)
  end
  end
end

local not_in_file = fs_orig
local not_in_fs = repo_orig


-- print it
for _, repo in ipairs(exists_in_both) do
print(colors('%{bright green}' .. 'file:' .. repo[1] .. " <-----> fs:" .. repo[1]))
end

for _, repo in ipairs(not_in_fs) do
print(colors('%{bright red}' .. 'file:' .. repo[1] .. " -----> fs:" .. repo[1] .. "... Downloading"))
end

for _, repo in ipairs(not_in_file) do
print(colors('%{bright yellow}' .. 'file:' .. repo[1] .. " <----- fs:" .. repo[1] .. "... Doing Nothing"))
end

--print(colors('%{bright red underline}hello'))


return exists_in_both, not_in_file, not_in_fs
end

local fs_orig = get_fs()
local repo_orig = get_repos()
local exists_in_both, not_in_file, not_in_fs = compare(fs_orig, repo_orig)


local function download_prepare()
local mode = uv.fs_stat(root).mode
-- make sure all roots from file exist on fs before downloading
local roots_to_check = {}

-- for k, _ in pairs(repos) do
-- table.insert(roots_to_check, k)
-- end

for _, repo in ipairs(not_in_fs) do
local sub_dir = repo[3]
local fp = root .. "/repos/" .. sub_dir
if uv.fs_stat(fp) == nil then
uv.fs_mkdir(fp, mode)
end
end


end


local task_amount = #not_in_fs
local completed_tasks = 0
local tasks = {}


local function download_single_repo(opts)
return function()
local stdout = uv.new_pipe()
local stderr = uv.new_pipe()

local handle
handle, pid = uv.spawn(opts.cmd, {
  cwd = opts.cwd,
  --args = { "-c", [[echo "hello world"]] },
  args = opts.args,
  env = opts.env,
  stdio = {_, stdout, stderr}
}, function(code, signal) -- on exit
print('----- START EXIT ----')
 dump(opts)
 print("EXITING: " .. opts.cmd .. " " .. inspect(opts.args) .. " -- " .. opts.cwd)
  print("exit code", code)
  print("exit signal", signal)
  completed_tasks = completed_tasks + 1
  uv.close(handle)
  print('----- END EXIT -----')
end)

uv.read_start(stdout, function(err, data)
  assert(not err, err)
  if data then
    print("stdout chunk", stdout, data)
  else
    --print("stdout end", stdout)
  end
end)

uv.read_start(stderr, function(err, data)
  assert(not err, err)
  if data then
    print("stderr chunk", stderr, data)
  else
    --print("stderr end", stderr)
  end

end)

print(handle)
return handle
end

end


--- download not_in_fs
download_prepare()


dump(not_in_fs)
for _, repo in ipairs(not_in_fs) do
--local dirpath = root .. "/repos" .. not_in_file[1]
local user_repo = repo[2]
local sub_dir = repo[3]

local github = ("https://github.com/%s"):format(user_repo)
local args
if repo[5] then
local alt_dirname = repo[5]
args = {"-c", ([[%s/.nix-profile/bin/git clone %s %s]]):format(home, github, alt_dirname)}
else
args = {"-c",  ([[%s/.nix-profile/bin/git clone %s]]):format(home, github)}

end

local opts = {
cmd = home .. "/.nix-profile/bin/zsh",
args = args,
env = {
"GIT_TERMINAL_PROMPT=0"
},
cwd = root .. "/repos/" .. sub_dir
}

table.insert(tasks, download_single_repo(opts))
end

for _, fn in ipairs(tasks) do fn() end
--while task_amount ~= completed_tasks do print('uv.run ~= 1') end
repeat
until uv.run() == false

print("done")
print(completed_tasks)
