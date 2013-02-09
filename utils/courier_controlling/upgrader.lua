local _G = getfenv(0)

local M = {}

local FLYING_COURIER = "Pet_FlyngCourier"

local function CourierFlies(courier)
  return courier:GetTypeName() == FLYING_COURIER
end
M.CourierFlies = CourierFlies

local function UpgradeCourier(courier, bot)
  local upgAbil = courier:GetAbility(0)
  if not CourierFlies(courier) and upgAbil:CanActivate() then
    bot:OrderAbility(upgAbil)
  end
end

local function CanUpgrade(bot)
  return bot and bot.data and bot.data.canUpgradeCourier and true
end

local function onthink(bot, courier)
  if not CanUpgrade(bot) then
    return
  end
  UpgradeCourier(courier, bot)
end
M.onthink = onthink

Utils_CourierControlling_Upgrader = M
