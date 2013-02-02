local _G = getfenv(0)
local teambot = _G.object

teambot.teams = teambot.teams or {}

teambot.teams.team_lol = {}
local team = teambot.teams.team_lol

team.name = 'Team LOL'

runfile 'bots/core_teambot.lua'

function team:Initialize()
  teambot:UseOriginal()
end
