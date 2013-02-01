local _G = getfenv(0)
local object = _G.object

object.teams = object.teams or {}

object.teams.team_berberi = {}
local myTeam = object.teams.team_berberi

myTeam.name = 'Team Berberi'

runfile 'bots/core_teambot.lua'
