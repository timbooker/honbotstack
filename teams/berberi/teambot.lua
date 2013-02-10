local _G = getfenv(0)
local teambot = _G.object

teambot.name = 'Team Berberi'

runfile 'bots/core_teambot.lua'

teambot.data.heroes = teambot.data.heroes or {}

function teambot:AddHero(bot)
  table.insert(self.data.heroes, bot)
end

function teambot:AmIRuneCollector(bot)
  return self.data and self.data.heroes and self.data.heroes[1] == bot
end

function teambot:onthinkCustom(tGameVariables)
  --Echo(team.name..' is thinking')
end
