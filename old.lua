-- local repo = "https://github.com/fhill2/floating.nvim"

-- print(repo:match("https://github.com"))
-- print(repo:match("github.com/(.*)$"))

--  if type(repo) == "string" then
--  if repo:match("https://github.com") then repo = repo:match"github.com/(.*)$" end
-- elseif type(repo) == "table" then
--   if repo[1]:match("https://github.com") then 
--     repo = repo[1]:match"github.com/(.*)$" 
--     type = "github"
--   end
-- end


--       if type(repo) == "string" then
--                table.insert(repo_orig, { ("%s/%s"):format(group, repo:match("/(.*)$")), repo, group, "github" })
--       elseif type(repo) == "table" then
       
--         if repo[2] then
--           table.insert(repo_orig, { ("%s/%s"):format(group, repo[2]), sub_dir, group, "github", repo[2] })
--         else
--           table.insert(repo_orig, {
--             ("%s/%s"):format(group, repo[1]:match("/(.*)$")),
--             repo[1],
--             group,
--             "github",
--           }) 




  -- local args
  -- if repo.alt_name then
  --   local alt_dirname = repo.alt_name
  --   args = {
  --     "-c",
  --     ([[%s/.nix-profile/bin/git clone %s %s]]):format(home, repo.url, repo.alt_dirname),
  --   }
  -- else
  --   args = { "-c", ([[%s/.nix-profile/bin/git clone %s]]):format(home, repo.url) }
  -- end

