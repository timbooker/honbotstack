local _G = getfenv(0)

local M = {}

local function table_find(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

local function HeroHasStackableItems(hero)
  local items = {}
  local inventory = hero:GetInventory(true)
  local stackableInHero = {}
  for i = 1, 6, 1 do
    local item = inventory[i]
    if item and item:GetCharges() > 0 then
      table.insert(stackableInHero, item:GetType())
    end
  end
  for i = 7, 12, 1 do
    local item = inventory[i]
    if item and table_find(stackableInHero, item:GetType()) then
      table.insert(items, i)
    end
  end
  return items
end

local function OtherItems(hero, oldItems)
  local items = {}
  local inventory = hero:GetInventory(true)
  local emptySlots = #(hero:GetInventory())
  local used = 0
  for i = 6, 7, 1 do
    if used >= emptySlots then
      return
    end
    local item = inventory[i]
    if item and not table_find(oldItems, i) then
      table.insert(items, i)
    end
  end
  return items
end

local function ItemIndexes(hero)
  local items = HeroHasStackableItems(hero)
  local otherItems = OtherItems(hero, items)
  for _, v in ipairs(otherItems) do
    table.insert(items, v)
  end
  return items
end

local function MoveItemsToCourier(courier, items)
  local inventory = courier:GetInventory()
  local itemsMoved = 0
  for slot = 1, 6, 1 do
    local slotItem = inventory[slot]
    if not slotItem then
      local item = items[1]
      if not item then
        return
      end
      courier:SwapItems(item, slot)
    end
  end
end

local function onthink(bot, courier)
  if not courier:CanAccessStash() then
    return
  end
  local hero = bot:GetHeroUnit()
  local items = ItemIndexes(hero)
  MoveItemsToCourier(courier, items)
end
M.onthink = onthink

Utils_CourierControlling_ItemHandler = M
