local _G = getfenv(0)
local teambot = _G.object

runfile 'bots/tournament_options.lua'
runfile 'bots/basic_metadata.lua'

teambot.courier = teambot.courier or nil

local function allUnits()
  return HoN.GetUnitsInRadius(Vector3.Create(), 99999, 0x0000020 + 0x0000001)
end

local function getCourier()
  for key, unit in pairs(allUnits()) do
    if unit:GetTypeName() == "Pet_GroundFamiliar" and unit:GetTeam() == teambot:GetTeam() then
      return unit
    end
  end
  return nil
end
function teambot:AssignCourier()
  local courier = getCourier()
  if courier then
    self.courier = courier
  else
    Echo("No courier :(")
  end
end

function teambot:onthink(tGameVariables)
  if not self.metadata.initialized then
    self.metadata:Initialize()
  end
  if not self.courier then
    self:AssignCourier()
  end
  self:onthinkCustom(tGameVariables)
end

function teambot.UseOriginal()
  runfile 'bots/teambot/teambotbrain.lua'
end
