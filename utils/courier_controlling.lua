local _G = getfenv(0)

local M = {}

runfile "bots/utils/courier_controlling/selector.lua"
local selector = Utils_CourierControlling_Selector
runfile "bots/utils/courier_controlling/upgrader.lua"
local upgrader = Utils_CourierControlling_Upgrader
runfile "bots/utils/courier_controlling/protector.lua"
local protector = Utils_CourierControlling_Protector
runfile "bots/utils/courier_controlling/item_handler.lua"
local itemHandler = Utils_CourierControlling_ItemHandler

-- STATES
local IDLE = 0
local DELIVERING = 1
local RETURNING = 2

-- Initialization
local function IsInitialized(teambot)
  return teambot.data and teambot.data.courier and true
end

local function Initialize(teambot)
  teambot.data.courier = nil
  teambot.data.courierState = IDLE
  teambot.data.courierReserver = nil
end
-- Initialization ends

local function UpdateCourier(teambot)
  teambot.data.courier = selector.KeepCourier(teambot.data.courier, teambot:GetTeam())
end

local function Reserve(teambot, bot)
  teambot.data.courierReserver = bot:GetName()
end

local function Free(teambot)
  teambot.data.courierReserver = nil
  teambot.data.courierState = IDLE
end

local function CanThink(teambot, bot)
  if not teambot.data.courierReserver or
     teambot.data.courierReserver == bot:GetName() then
    return true
  end
  return false
end

local function IsAloneInWilderness(teambot, courier)
  return teambot.data.courierState == IDLE and
    not courier:CanAccessStash()
end

local function ReturnHome(teambot, bot, courier)
  bot:OrderAbility(courier:GetAbility(3))
  teambot.data.courierState = RETURNING
end

local function ReturnedHome(teambot, courier)
  return teambot.data.courierState == RETURNING and
    courier:CanAccessStash()
end

local function DeliveryDone(teambot, courier)
  local beha = courier:GetBehavior()
  return teambot.data.courierState == DELIVERING and
    beha and beha:IsIdle()
end

local function TakeABreak(teambot)
  teambot.data.courierState = IDLE
  Free(teambot)
end

local function HasEmptyInventory(unit)
  local inventory = unit:GetInventory()
  for i = 1, 6, 1 do
    local item = inventory[i]
    if item and item:IsValid() then
      return false
    end
  end
  return true
end

local function HasFullInventory(unit)
  local inventory = unit:GetInventory()
  return #inventory == 6
end

local function CanDeliverToAnother(teambot, bot, courier)
  local status = teambot.data.courierState
  return (status == IDLE or status == RETURNING) and
         not HasEmptyInventory(courier)
end

local function DeliverItems(teambot, bot, courier)
  local deliver = courier:GetAbility(2)
  if upgrader.CourierFlies(courier) then
    local speedBurst = courier:GetAbility(0)
    bot:OrderAbility(speedBurst)
  end
  teambot.data.courierState = DELIVERING
  Reserve(teambot, bot)
  bot:OrderAbility(deliver)
end

local function IdlingInPool(teambot, courier)
  return teambot.data.courierState == RETURNING and
    courier:CanAccessStash()
end

local function DeliveringToDeadGuy(teambot, bot)
  return bot:IsDead() and teambot.data.courierReserver == bot:GetName()
end

local function DeliveryTargetHasFullInventory(teambot, bot, courier)
  return teambot.data.courierState == DELIVERING and
    not HasEmptyInventory(courier) and
    HasFullInventory(bot:GetHeroUnit())
end

local function MoveCourier(teambot, bot, courier)
  if DeliveryTargetHasFullInventory(teambot, bot, courier) then
    Free(teambot)
    bot:Order(courier, "Stop")
  elseif CanDeliverToAnother(teambot, bot, courier) then
    DeliverItems(teambot, bot, courier)
  elseif IsAloneInWilderness(teambot, courier) then
    ReturnHome(teambot, bot, courier)
  elseif ReturnedHome(teambot, courier) then
    teambot.data.courierState = IDLE
    Free(teambot)
  elseif DeliveryDone(teambot, courier) then
    TakeABreak(teambot)
  elseif DeliveringToDeadGuy(teambot, bot) then
    Free(teambot)
    bot:Order(courier, "Stop")
  end
end

local function onthink(teambot, bot, canUpgrade)
  if not IsInitialized(teambot) then
    Initialize(teambot)
  end
  UpdateCourier(teambot)
  local courier = teambot.data.courier
  if not courier then
    return
  end
  if canUpgrade then
    upgrader.onthink(bot, courier)
  end
  protector.onthink(bot, courier)
  itemHandler.onthink(bot, courier)
  if not CanThink(teambot, bot) then
    return
  end
  MoveCourier(teambot, bot, courier)
end
M.onthink = onthink

Utils_CourierControlling = M
