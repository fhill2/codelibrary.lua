package.cpath = package.cpath .. ";/home/f1/dev/cl/lua/me-plug/codelibrary/luv/?.so"
vim = require("shared")
vim.loop = require("luv")
local uv = require("luv")
--local async = dofile("/home/f1/.local/share/nvim/site/pack/packer/start/plenary.nvim/lua/plenary/async/init.lua")
--local Path = dofile("/home/f1/.local/share/nvim/site/pack/packer/start/plenary.nvim/lua/plenary/path.lua")

local Path = require("plenary.path")
local json = loadfile("./json.lua")
local utils = require("futil/utils")
local inspect = require("inspect")
local dump = function(t)
  print(inspect(t))
end
--print(async, Path, utils, vim, inspect, inspect(vim.loop))

local path_to_this_file = os.getenv("PWD") .. "/" .. debug.getinfo(1).short_src
local root = path_to_this_file:match("^(.*)/.*$")
local repos = dofile(root .. "/repos.lua")
local home = os.getenv("HOME")
local nix_zsh = ("%s/.nix-profile/bin/zsh"):format(home)
local nix_git = ("%s/.nix-profile/bin/git"):format(home)
local nix_svn = ("%s/.nix-profile/bin/svn"):format(home)
local colors = dofile(root .. "/ansicolors.lua")

local function get_fs()
  local scan = require("plenary.scandir")
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
          table.insert(fs_orig, { sub_dir = sub_dir:match("/repos/(.*)$") })
        end,
      })
    end,
  })
  return fs_orig
end

-- sub_dir, user_repo, group, type
local function get_repos()
  local all_repos_in_file = {}
  for group, v in pairs(repos) do
    for _, vv in ipairs(v) do
      local repo = {
        -- url final URL that goes to git clone command
        -- user_name DONE
        -- alt_name DONE
        group = group, -- DONE
        -- download_type - gitlab or github DONE
        -- sub_dir - auto generated from user_name and alt_name DONE
        -- partial -- download a folder within a git repo true/false DONE
        -- partial_path NOT DONE
        args = { "-c" }, -- generated from url alt_name and partial
      }

      local url_orig
      if type(vv) == "string" then
        url_orig = vv
      elseif type(repo) == "table" then
        url_orig = vv[1]
        if vv[2] then
          repo.alt_name = vv[2]
        end
      end

      local is_github_url = url_orig:match("https://github.com")
      --local is_gitlab_url = url_orig:match("https://gitlab.com')
      local is_partial = url_orig:match("/tree/")

      if is_github_url then
        repo.download_type = "github"
      end

      if is_github_url and not is_partial then
        repo.user_name = url_orig:match("github.com/(.*)$")
        repo.url = url_orig
      elseif is_github_url and is_partial then
        if url_orig:match("/tree/master/") == nil then
          print("partial URLs must be tree/master")
          os.exit()
        end

        repo.partial = true

        repo.user_name = url_orig:match("github.com/(.*)/tree")
        repo.partial_path = url_orig:match("/tree/master/(.*)$")

        repo.sub_dir = ("%s/%s"):format(group, repo.alt_name or url_orig:match("^.*/(.*)$"))
        repo.url = url_orig:gsub("/tree/master/", "/trunk/")

        --table.insert(repo.args, nix_svn)
        --table.insert(repo.args, "checkout")
        local svn_arg = ("%s checkout %s"):format(nix_svn, repo.url)
        if repo.alt_name then
          svn_arg = svn_arg .. " " .. repo.alt_name
        end
        table.insert(repo.args, svn_arg)
      elseif is_github_url == nil then
        repo.user_name = url_orig
        repo.url = ("https://github.com/%s"):format(repo.user_name)
      end

      if not is_partial then
        repo.partial = false
        repo.sub_dir = ("%s/%s"):format(group, repo.alt_name or repo.user_name:match("/(.*)$"))
        --table.insert(repo.args, nix_git)
        --table.insert(repo.args, "clone")
        local git_arg = ("%s clone %s"):format(nix_git, repo.url)
        if repo.alt_name then
          git_arg = git_arg .. " " .. repo.alt_name
        end
        table.insert(repo.args, git_arg)
      end

      -- table.insert(repo.args, repo.url)
      -- if repo.alt_name then
      --   table.insert(repo.args, repo.alt_name)
      -- end

      table.insert(all_repos_in_file, repo)
    end
  end

  return all_repos_in_file
  --os.exit()
end

local function compare(fs_orig, repo_orig)
  local fs_orig = vim.deepcopy(fs_orig)
  local repo_orig = vim.deepcopy(repo_orig)

  local exists_in_both = {}

  for i, file_repo in ipairs(repo_orig) do
    for j, fs_repo in ipairs(fs_orig) do
      --print(file_repo[1], fs_repo[1], type(file_repo[1]), type(fs_repo[1]))
      if file_repo.sub_dir == fs_repo.sub_dir then
        table.insert(exists_in_both, table.remove(repo_orig, i))
        table.remove(fs_orig, j)
      end
    end
  end

  local not_in_file = fs_orig
  local not_in_fs = repo_orig

  -- print it
  for _, repo in ipairs(exists_in_both) do
    print(colors("%{bright green}" .. "file:" .. repo.sub_dir .. " <-----> fs:" .. repo.sub_dir))
  end

  for _, repo in ipairs(not_in_fs) do
    print(colors("%{bright red}" .. "file:" .. repo.sub_dir .. " -----> fs:" .. repo.sub_dir .. " [Downloading]"))
  end

  for _, repo in ipairs(not_in_file) do
    print(colors("%{bright yellow}" .. "file:" .. repo.sub_dir .. " <----- fs:" .. repo.sub_dir .. " [Doing Nothing]"))
  end

  return exists_in_both, not_in_file, not_in_fs
end

local fs_orig = get_fs()
local repo_orig = get_repos()
local exists_in_both, not_in_file, not_in_fs = compare(fs_orig, repo_orig)
--os.exit()

local function download_prepare()
  local mode = uv.fs_stat(root).mode
  -- make sure all roots from file exist on fs before downloading
  local roots_to_check = {}

  for _, repo in ipairs(not_in_fs) do
    local fp = root .. "/repos/" .. repo.sub_dir
    if uv.fs_stat(fp) == nil then
      print('doesnt exist')
      print(fp)
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
    local error_messages = {}
    handle, pid = uv.spawn(opts.cmd, {
      cwd = opts.cwd,
      --args = { "-c", [[echo "hello world"]] },
      args = opts.args,
      env = opts.env,
      stdio = { _, stdout, stderr },
    }, function(code, signal)
      -- git clone
      -- exit code 0: cloned successfully
      -- exit code 128 - cant find path to public repo

      if code == 0 then
        print(colors("%{bright green}github: " .. opts.repo.user_name .. " -----> fs: " .. opts.repo.sub_dir .. " [Downloaded Successfully]"))
      else
        for _, errmsg in ipairs(error_messages) do
          if errmsg:match("terminal prompts disabled") then
            errmsg = "github repo not found"
          end
          print(colors("%{bright red}github: " .. opts.repo.user_name .. " Error: Code: " .. code .. ": " .. errmsg))
        end
      end
      completed_tasks = completed_tasks + 1
      uv.close(handle)
    end)

    uv.read_start(stdout, function(err, data)
      assert(not err, err)
      if data then
        print("stdout chunk", stdout, data)
      end
    end)

    uv.read_start(stderr, function(err, data)
      assert(not err, err)
      if data then
        table.insert(error_messages, data)
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
  local opts = {
    repo = repo,
    cmd = nix_zsh,
    args = repo.args,
    env = {
      "GIT_TERMINAL_PROMPT=0",
    },
    cwd = root .. "/repos/" .. repo.sub_dir,
  }

  table.insert(tasks, download_single_repo(opts))
end

for _, fn in ipairs(tasks) do
  fn()
end
--while task_amount ~= completed_tasks do print('uv.run ~= 1') end
repeat
until uv.run() == false

--print("done")
--print(completed_tasks)
