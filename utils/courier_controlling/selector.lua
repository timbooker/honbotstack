local _G = getfenv(0)

local M = {}

runfile "bots/utils/masks.lua"
local MASKS = Masks()

local WALKING_COURIER = "Pet_GroundFamiliar"
local FLYING_COURIER = "Pet_FlyngCourier"

local function GetCourier(teamId)
  local allUnits = HoN.GetUnitsInRadius(Vector3.Create(), 99999, MASKS.ALIVE + MASKS.UNIT)
  for key, unit in pairs(allUnits) do
    local typeName = unit:GetTypeName()
    if unit:GetTeam() == teamId and
       (typeName == WALKING_COURIER or
        typeName == FLYING_COURIER) and
        unit:IsValid() then
      return unit
    end
  end
  return nil
end
M.GetCourier = GetCourier

local function KeepCourier(courier, teamId)
  if courier and courier:IsValid() then
    return courier
  end
  return GetCourier(teamId)
end
M.KeepCourier = KeepCourier

Utils_CourierControlling_Selector = M
