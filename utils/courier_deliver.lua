local _G = getfenv(0)

local function IsNearStash(courier)
  return courier and courier:CanAccessStash()
end

local function CourierHasItems(courier)
  local inventory = courier:GetInventory()
  return #inventory > 0
end

local function NextEmptyIndexInventory(inventory)
  for i = 1, 6, 1 do
    if not inventory[i] then
      return i
    end
  end
  return 0
end

local function MoveItemsToCourier(hero, courier)
  local hero_inventory = hero:GetInventory(true)
  local courier_inventory = courier:GetInventory()
  for i = 7, 12, 1 do
    local toSlot = NextEmptyIndexInventory(courier_inventory)
    if toSlot == 0 then
      break
    end

    local item = hero_inventory[i]
    if item then
      courier:SwapItems(i, toSlot)
    end
  end
end

local function DeliverItems(bot, courier)
  local deliver = courier:GetAbility(2)
  bot:OrderAbility(deliver)
end

local function ReturnToPool(bot, courier)
  local backToPool = courier:GetAbility(3)
  bot:OrderAbility(backToPool)
end

local function HasDelivered(bot, courier)
  bot.courierData = bot.courierData or {}
  local data = bot.courierData
  if data.delivering then
    if not CourierHasItems(courier) then
      ReturnToPool(bot, courier)
      data.delivering = false
      data.returning = true
    end
  elseif data.returning then
    if IsNearStash(courier) then
      data.returning = false
    end
  elseif CourierHasItems(courier) then
    DeliverItems(bot, courier)
    data.delivering = true
  elseif not data.returning and not IsNearStash(courier) then
    -- Fixing crashes
    ReturnToPool(bot, courier)
    data.returning = true
  else
    data.delivering = false
    data.returning = false
  end
end

function CourierDeliver()
  local functions = {}
  functions.IsNearStash = IsNearStash
  functions.MoveItemsToCourier = MoveItemsToCourier
  functions.HasDelivered = HasDelivered
  return functions
end
