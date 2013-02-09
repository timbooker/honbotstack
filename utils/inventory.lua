local _G = getfenv(0)
local print, tostring = _G.print, _G.tostring

local M = {}

local function PrintInventory(inventory)
  if not inventory then
    return
  end
  for i = 1, #inventory, 1  do
    local curItem = inventory[i]
    if curItem then
      print(tostring(i)..', '..curItem:GetName()..'\n')
    else
      print(tostring(i)..', nil\n')
    end
  end
end
M.PrintInventory = PrintInventory

local function HasItemsInInventory(unit)
  local inventory = unit:GetInventory()
  return #inventory > 0
end
M.HasItemsInInventory = HasItemsInInventory

local function HasItemsInStash(unit)
  local inventory = unit:GetInventory(true)
  for i = 7, 12, 1 do
    if inventory[i] then
      return true
    end
  end
  return false
end
M.HasItemsInStash = HasItemsInStash

Utils_Inventory = M
