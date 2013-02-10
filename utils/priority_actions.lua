local _G = getfenv(0)

local M = {}

local actions = {}

local latestAction = nil

local function onthink(bot)
  for _, action in ipairs(actions) do
    if action.CanActivate(bot) then
      if latestAction ~= action then
        if latestAction then
          latestAction.RunDown(bot)
        end
        latestAction = action
        Echo(bot:GetName() .. ": " .. action.name)
      end
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
