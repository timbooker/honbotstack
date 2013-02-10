local _G = getfenv(0)

local M = {}

runfile "bots/utils/masks.lua"
local MASKS = Utils_Masks

local warding = false

local ITEM = "Item_FlamingEye"
local GADGET = "Gadget_FlamingEye"

local function GetWardFromBag(unit)
  local inventory = unit:GetInventory()
  for _, item in ipairs(inventory) do
    if item:GetName() == ITEM then
      return item
    end
  end
  return nil
end

local function IsSpotWarded(spot)
  local gadgets = HoN.GetUnitsInRadius(spot, 200, MASKS.GADGET + MASKS.ALIVE)
  for k, gadget in pairs(gadgets) do
    if gadget:GetTypeName() == GADGET then
      return true
    end
  end
  return false
end

local function CanWardSpot(ward, spot)
  return ward and not IsSpotWarded(spot)
end

local function PlaceWard(bot, ward, spot)
  if CanWardInSpot(ward, spot) then
    return false
  end
  bot:OrderItemPosition(ward, spot)
  return true
end

local function IsCloseEnough(unit, spot)
  return Vector3.Distance(unit:GetPosition(), spot) < 600
end

local function MoveToWard(bot, unit, spot)
  bot:OrderPosition(unit, "Move", spot)
  warding = true
end

local function DoWarding(bot, unit, spot)
  local ward = GetWardFromBag(unit)
  if warding then
    if not CanWardSpot(ward, spot) then
      bot:Order(unit, "Stop")
      warding = false
    elseif IsCloseEnough(unit, spot) then
      bot:OrderItemPosition(ward, spot)
    end
    return
  end
  if CanWardSpot(ward, spot) then
    MoveToWard(bot, unit, spot)
  end
end
M.DoWarding = DoWarding

local function IsWardingPossible(unit, spot)
  local ward = GetWardFromBag(unit)
  return warding or CanWardSpot(ward, spot)
end
M.IsWardingPossible = IsWardingPossible

Utils_Warding = M
