local _G = getfenv(0)

local M = {}

local actions = {}

local latestAction = nil

local function onthink(bot)
  for _, action in ipairs(actions) do
    if action.CanActivate(bot) then
      action.Activate(bot)
      if latestAction ~= action.name then
        latestAction = action.name
        Echo(latestAction)
      end
      return
    end
  end
end
M.onthink = onthink

local function AddAction(action)
  table.insert(actions, action)
end
M.AddAction = AddAction

Utils_PriorityActions = M
