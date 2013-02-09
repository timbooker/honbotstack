local _G = getfenv(0)

local M = {}

runfile "bots/utils/masks.lua"
local MASKS = Utils_Masks

local COURIER_SHIELD_RANGE = 1000
local FLYING_COURIER = "Pet_FlyngCourier"

local function CourierFlies(courier)
  return courier:GetTypeName() == FLYING_COURIER
end

local function EnemiesNear(bot, courier)
  local units = HoN.GetUnitsInRadius(courier:GetPosition(),
    COURIER_SHIELD_RANGE, MASKS.ALIVE + MASKS.UNIT, true)
  local myTeam = bot:GetTeam()
  for key, unit in pairs(units) do
    if not (unit:GetTeam() == myTeam) and unit:GetCanAttack() then
      return true
    end
  end
  return false
end

local function onthink(bot, courier)
  local shield = courier:GetAbility(1)
  if CourierFlies(courier) and
     EnemiesNear(bot, courier) and
     shield:CanActivate() then
    bot:OrderAbility(shield)
  end
end
M.onthink = onthink

Utils_CourierControlling_Protector = M
