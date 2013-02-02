local _G = getfenv(0)
local teambot = _G.object

runfile "bots/teams/berberi/teambot.lua"
runfile "bots/teams/lol/teambot.lua"

local function IsLegion()
  return teambot:GetTeam() == 1
end

local legionTeam = teambot.teams.team_berberi
local hellbourneTeam = teambot.teams.team_lol

teambot.team = {}

if IsLegion() then
  teambot.team = legionTeam
else
  teambot.team = hellbourneTeam
end

teambot.teamID = teambot:GetTeam()
teambot.myName = teambot.team.name

teambot.team:Initialize()
