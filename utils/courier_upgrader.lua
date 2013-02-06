local _G = getfenv(0)

local walkingCourier = "Pet_GroundFamiliar"
local flyingCourier = "Pet_FlyngCourier"

local function CourierFlies(courier)
  return courier:GetTypeName() == flyingCourier
end

local function CanUpgradeCourier(bot, courier)
  return bot:GetGold() >= 200 and not CourierFlies(courier)
end

local function UpgradeCourier(bot, courier)
  local upgAbil = courier:GetAbility(0)
  if upgAbil:CanActivate() then
    bot:OrderAbility(upgAbil)
  end
end

function CourierUpgrader()
  local functions = {}
  functions.CanUpgradeCourier = CanUpgradeCourier
  functions.UpgradeCourier = UpgradeCourier
  return functions
end
