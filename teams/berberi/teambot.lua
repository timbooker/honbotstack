local _G = getfenv(0)
local teambot = _G.object

teambot.teams = teambot.teams or {}

teambot.teams.team_berberi = {}
local team = teambot.teams.team_berberi

team.name = 'Team Berberi'

runfile 'bots/core_teambot.lua'

function team:Initialize()
end
