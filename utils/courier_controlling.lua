local _G = getfenv(0)

runfile "bots/utils/masks.lua"

local MASKS = Masks()

local IDLE = 0
local RESERVED = 1
local DELIVERING = 2
local RETURNING = 3

local WALKING_COURIER = "Pet_GroundFamiliar"
local FLYING_COURIER = "Pet_FlyngCourier"

local COURIER_SHIELD_RANGE = 1000

local function GetUnits(position, radius, sorted)
  return HoN.GetUnitsInRadius(position, radius, MASKS.ALIVE + MASKS.UNIT, sorted or false)
end

local function CourierFlies(courier)
  return courier:GetTypeName() == FLYING_COURIER
end

local function CanUpgradeCourier(teambot, bot)
  local courier = teambot.data.courier
  return bot:GetGold() >= 200 and not CourierFlies(courier)
end

local function UpgradeCourier(teambot, bot)
  local courier = teambot.data.courier
  local upgAbil = courier:GetAbility(0)
  if upgAbil:CanActivate() then
    bot:OrderAbility(upgAbil)
  end
end

local function GetCourier(teambot)
  local allUnits = GetUnits(Vector3.Create(), 99999)
  for key, unit in pairs(allUnits) do
    local typeName = unit:GetTypeName()
    if unit:GetTeam() == teambot:GetTeam() and
       (typeName == WALKING_COURIER or
        typeName == FLYING_COURIER) then
      return unit
    end
  end
  return nil
end

local function IsInitialized(teambot)
  return teambot.data and teambot.data.courier and true
end

local function Initialize(teambot)
  teambot.data = teambot.data or {}
  teambot.data.courier = teambot.data.courier or GetCourier(teambot)
  teambot.data.courierState = teambot.data.courierState or IDLE
end

local function HasCourier(teambot)
  return teambot.data.courier and teambot.data.courier:IsValid()
end

local function IsFreed(teambot)
  return teambot.data.courierState == IDLE
end

local function Reserve(teambot)
  if teambot.data.courierState == IDLE then
    teambot.data.courierState = RESERVED
    return true
  end
  return false
end

local function IsNearStash(teambot)
  if not IsInitialized(teambot) then return false end
  local courier = teambot.data.courier
  return courier and courier:CanAccessStash()
end

local function NextEmptyIndexInventory(inventory)
  for i = 1, 6, 1 do
    if not inventory[i] then
      return i
    end
  end
  return 0
end

local function MoveItemsToCourier(teambot, hero)
  local courier = teambot.data.courier
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
  if CourierFlies(courier) then
    local speedBurst = courier:GetAbility(0)
    bot:OrderAbility(speedBurst)
  end
end

local function ReturnToPool(bot, courier)
  local backToPool = courier:GetAbility(3)
  bot:OrderAbility(backToPool)
end

local function HasDelivered(teambot, bot, hero)
  local data = teambot.data
  local courier = data.courier
  local state = data.courierState
  Echo(tostring(state))

  local function deliver()
    DeliverItems(bot, courier)
    teambot.data.courierState = DELIVERING
  end

  local function toPool()
    ReturnToPool(bot, courier)
    teambot.data.courierState = RETURNING
  end

  local function protect(bot, courier)
    local shield = courier:GetAbility(1)
    bot:OrderAbility(shield)
  end

  local function enemiesNear(bot, courier)
    local units = GetUnits(courier:GetPosition(), COURIER_SHIELD_RANGE, true)
    local myTeam = bot:GetTeam()
    for key, unit in pairs(units) do
      if not (unit:GetTeam() == myTeam) and unit:GetCanAttack() then
        return true
      end
    end
    return false
  end

  local function canActiveProtect(courier)
    local shield = courier:GetAbility(1)
    return shield:CanActivate()
  end

  local function inventoryIsFull()
    local inventory = hero:GetInventory()
    return #inventory == 6
  end

  local function hasItems(courier)
    local inventory = courier:GetInventory()
    return #inventory > 0
  end

  if CourierFlies(courier) and enemiesNear(bot, courier) and canActiveProtect(courier) then
    protect(bot, courier)
  elseif state == DELIVERING then
    if bot:IsDead() then
      toPool()
    elseif not hasItems(courier) or inventoryIsFull() then
      toPool()
    end
  elseif state == RETURNING then
    if not bot:IsDead() and hasItems(courier) and not inventoryIsFull() then
      deliver()
    elseif IsNearStash(teambot) then
      teambot.data.courierState = IDLE
    end
  elseif hasItems(courier) and not bot:IsDead() then
    deliver()
  elseif not (state == RETURNING) and not IsNearStash(teambot) then
    -- Fixing crashes
    toPool()
  else
    teambot.data.courierState = IDLE
  end
end

local function FreeCourier(teambot)
  if IsNearStash(teambot) and not (teambot.data.courierState == IDLE) then
    teambot.data.courierState = IDLE
  end
end

function CourierControlling()
  local functions = {}
  functions.IsInitialized = IsInitialized
  functions.Initialize = Initialize
  functions.HasCourier = HasCourier
  functions.CourierFlies = CourierFlies
  functions.CanUpgradeCourier = CanUpgradeCourier
  functions.UpgradeCourier = UpgradeCourier
  functions.Reserve = Reserve
  functions.MoveItemsToCourier = MoveItemsToCourier
  functions.HasDelivered = HasDelivered
  functions.IsNearStash = IsNearStash
  functions.IsFreed = IsFreed
  functions.FreeCourier = FreeCourier
  return functions
end
