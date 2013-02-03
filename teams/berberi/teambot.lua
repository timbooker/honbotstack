local _G = getfenv(0)
local teambot = _G.object

teambot.name = 'Team Berberi'

runfile 'bots/core_teambot.lua'

local lol = false

local function allUnits()
  return HoN.GetUnitsInRadius(Vector3.Create(), 99999, 0)
end

function teambot:onthink(tGameVariables)
  --Echo(team.name..' is thinking')
  if not lol then
    Echo(tostring(teambot.Is1v1()))
    local units = allUnits()
    Echo("Units: "..#units)
    for key, unit in pairs(units) do
      Echo(unit:GetTypeName())
    end
    lol = true
  end
end
