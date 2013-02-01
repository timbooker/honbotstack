local _G = getfenv(0)
local object = _G.object

object.teams = object.teams or {}

object.teams.team_lol = {}
local team = object.teams.team_lol

team.name = 'Team LOL'

runfile 'bots/core_teambot.lua'
