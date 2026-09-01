-- Snacks-picker UI for ThePrimeagen/git-worktree.nvim.
-- That plugin only ships a telescope extension for browsing/creating
-- worktrees; this config uses Snacks as its picker, so we drive the
-- plugin's core API (switch_worktree/create_worktree/delete_worktree)
-- from a couple of small custom Snacks sources instead.

local M = {}

-- Snacks runs finders in a fast-event context where vim.fn/vim.api calls
-- are disallowed, so this uses io.popen (plain Lua) instead of
-- vim.fn.systemlist, and takes cwd as a param captured on the main loop.
---@param cwd string
---@return { path: string, sha: string, branch: string, current: boolean }[]
local function list_worktrees(cwd)
  local proc = io.popen("git worktree list 2>/dev/null")
  local items = {}
  if not proc then
    return items
  end
  for line in proc:lines() do
    local path, sha, branch = line:match("^(%S+)%s+(%S+)%s+%[?([^%]]*)%]?%s*$")
    if path and sha ~= "(bare)" then
      items[#items + 1] = {
        path = path,
        sha = sha,
        branch = branch ~= "" and branch or "(detached)",
        current = path == cwd,
      }
    end
  end
  proc:close()
  return items
end

function M.switch()
  local cwd = vim.fn.getcwd()
  Snacks.picker.pick({
    source = "git_worktrees",
    finder = function()
      return function(cb)
        for _, wt in ipairs(list_worktrees(cwd)) do
          cb({
            text = wt.branch .. " " .. wt.path,
            path = wt.path,
            branch = wt.branch,
            current = wt.current,
          })
        end
      end
    end,
    format = function(item)
      local a = Snacks.picker.util.align
      return {
        { a(item.branch, 30, { truncate = true }), item.current and "SnacksPickerGitBranchCurrent" or "SnacksPickerGitBranch" },
        { " " },
        { item.path, "SnacksPickerFile" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        require("git-worktree").switch_worktree(item.path)
      end
    end,
    win = {
      input = {
        keys = {
          ["<c-d>"] = { "git_worktree_delete", mode = { "n", "i" } },
        },
      },
    },
    actions = {
      git_worktree_delete = function(picker, item)
        if not item then
          return
        end
        local ok = vim.fn.confirm("Delete worktree " .. item.path .. "?", "&Yes\n&No") == 1
        if ok then
          require("git-worktree").delete_worktree(item.path)
          picker:find()
        end
      end,
    },
  })
end

function M.create()
  Snacks.picker.git_branches({
    confirm = function(picker, item)
      picker:close()
      if not item then
        return
      end
      local branch = item.branch
      local default_path = branch:gsub("[/\\]", "-")
      local path = vim.fn.input("Worktree path: ", default_path)
      if path ~= "" then
        require("git-worktree").create_worktree(path, branch)
      end
    end,
  })
end

return M
