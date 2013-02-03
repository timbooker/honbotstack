local _G = getfenv(0)
local teambot = _G.object

local legionTeamCvar = Cvar.GetCvar("teambotmanager_legion")
local legionTeam = nil
local hellbourneTeamCvar = Cvar.GetCvar("teambotmanager_hellbourne")
local hellbourneTeam = nil

if legionTeamCvar then
  legionTeam = legionTeamCvar:GetString()
end
if hellbourneTeamCvar then
  hellbourneTeam = hellbourneTeamCvar:GetString()
end

local function IsLegion()
  return teambot:GetTeam() == 1
end

local function RunTeam(teamName)
  if teamName and teamName ~= "" then
    runfile ("bots/teams/"..teamName.."/teambot.lua")
  else
    runfile "bots/teambot/teambotbrain.lua"
  end
end

if IsLegion() then
  RunTeam(legionTeam)
else
  RunTeam(hellbourneTeam)
end
