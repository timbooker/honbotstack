local _G = getfenv(0)
local teambot = _G.object

teambot.name = 'Team Berberi'

runfile 'bots/core_teambot.lua'

teambot.data.heroes = teambot.data.heroes or {}
teambot.data.runeCollector = nil
teambot.data.support = nil

function teambot:AddHero(bot)
  self.data.heroes[bot] = bot
  if not self.data.runeCollector then
    self.data.runeCollector = bot
  elseif not self.data.support then
    self.data.support = bot
  end
end

function teambot:GetFirst()
  for _, bot in pairs(self.data.heroes) do
    return bot
  end
  return nil
end

function teambot:AmIRuneCollector(bot)
  return (self.data.runeCollector or self:GetFirst()) == bot
end

function teambot:AmISupport(bot)
  return (self.data.support or self:GetFirst()) == bot
end

function teambot:onthinkCustom(tGameVariables)
  --Echo(team.name..' is thinking')
end
