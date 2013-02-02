local _G = getfenv(0)
local herobot = _G.object

herobot.heroName = 'Hero_Midas'

runfile 'bots/core_herobot.lua'

function herobot:SkillBuildWhatNext()
  if self.brain.skills.abilE:GetLevel() < 1 then
    return self.brain.skills.abilE
  elseif self.brain.skills.abilW:GetLevel() < 1 then
    return self.brain.skills.abilW
  elseif self.brain.skills.abilQ:GetLevel() < 1 then
    return self.brain.skills.abilQ
  elseif self.brain.skills.abilR:CanLevelUp() then
    return self.brain.skills.abilR
  elseif self.brain.skills.abilW:CanLevelUp() then
    return self.brain.skills.abilW
  elseif self.brain.skills.abilQ:CanLevelUp() then
    return self.brain.skills.abilQ
  elseif self.brain.skills.abilE:CanLevelUp() then
    return self.brain.skills.abilE
  else
    return self.brain.skills.abilAttributeBoost
  end
end

local nextChat = HoN.GetGameTime() + 1000

function herobot:onthinkCustom(tGameVariables)
  if nextChat < HoN.GetGameTime() then
    herobot.chat:AllChat("I gonna kill ya!")
    nextChat = nextChat + 100000
  end
end
