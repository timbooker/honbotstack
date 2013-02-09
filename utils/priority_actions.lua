local _G = getfenv(0)

local M = {}

local actions = {}

local function onthink(bot)
  for _, action in ipairs(actions) do
    if action.CanActivate(bot) then
      action.Activate(bot)
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
