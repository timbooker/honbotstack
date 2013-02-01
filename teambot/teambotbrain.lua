local _G = getfenv(0)
local object = _G.object

runfile "bots/teams/berberi/teambot.lua"
runfile "bots/teams/lol/teambot.lua"

local function IsLegion()
  return object:GetTeam() == 1
end

local legionTeam = object.teams.team_berberi
local hellbourneTeam = object.teams.team_lol

object.team = {}

if IsLegion() then
  object.team = legionTeam
else
  object.team = hellbourneTeam
end

object.teamID = object:GetTeam()
object.myName = object.team.name
