local _G = getfenv(0)

local courierShieldRange = 1000
local courierShieldUnitMasks = 0x0000020 + 0x0000001

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

local function IsFlying(courier)
  return courier:GetTypeName() == 'Pet_FlyngCourier'
end

local function DeliverItems(bot, courier)
  local deliver = courier:GetAbility(2)
  bot:OrderAbility(deliver)
  if IsFlying(courier) then
    local speedBurst = courier:GetAbility(0)
    bot:OrderAbility(speedBurst)
  end
end

local function ReturnToPool(bot, courier)
  local backToPool = courier:GetAbility(3)
  bot:OrderAbility(backToPool)
end

local function HasDelivered(bot, courier)
  bot.courierData = bot.courierData or {}
  local data = bot.courierData

  local function deliver()
    DeliverItems(bot, courier)
    data.delivering = true
    data.returning = false
  end

  local function toPool()
    ReturnToPool(bot, courier)
    data.delivering = false
    data.returning = true
  end

  local function protect(bot, courier)
    local shield = courier:GetAbility(1)
    bot:OrderAbility(shield)
  end

  local function enemiesNear(bot, courier)
    local units = HoN.GetUnitsInRadius(courier:GetPosition(), courierShieldRange, courierShieldUnitMasks, true)

    for key, unit in pairs(units) do
      if not (unit:GetTeam() == bot:GetTeam()) and unit:GetCanAttack() then
        return true
      end
    end
    return false
  end

  local function canActiveProtect(courier)
    local shield = courier:GetAbility(1)
    return shield:CanActivate()
  end

  if IsFlying(courier) and enemiesNear(bot, courier) and canActiveProtect(courier) then
    protect(bot, courier)
  elseif data.delivering then
    if bot:IsDead() then
      toPool()
    elseif not CourierHasItems(courier) then
      toPool()
    end
  elseif data.returning then
    if not bot:IsDead() and CourierHasItems(courier) then
      deliver()
    elseif IsNearStash(courier) then
      data.returning = false
    end
  elseif CourierHasItems(courier) and not bot:IsDead() then
    deliver()
  elseif not data.returning and not IsNearStash(courier) then
    -- Fixing crashes
    toPool()
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
