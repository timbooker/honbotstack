local _G = getfenv(0)
local herobot = _G.object

runfile 'bots/tournament_options.lua'
runfile 'bots/basic_metadata.lua'

runfile 'bots/chat.lua'

herobot.core = {}
herobot.core.initialized = false
herobot.core.myTeam = 0
herobot.core.enemyTeam = 0

herobot.brain = {}
herobot.brain.initialized = false
herobot.brain.hero = nil
herobot.brain.goldTreshold = 0
herobot.brain.skills = {}
herobot.brain.myLane = nil
herobot.teamBrain = nil

function herobot:onpickframe()
  if self:CanSelectHero(self.heroName) then
    self:SelectHero(self.heroName)
    self:Ready()
  end
end

local function ShouldBuy()
  return herobot.brain.hero:CanAccessStash() and
  herobot.brain.goldTreshold and
  herobot:GetGold() and
  herobot.brain.goldTreshold < herobot:GetGold()
end

function herobot:onthink(tGameVariables)
  if not self.metadata.initialized then
    self.metadata:Initialize()
  end
  if not self.core.initialized then
    self:CoreInitialize()
  end
  if not self.brain.initialized or self.brain.hero == nil then
    self:BrainInitialize(tGameVariables)
  end
  self.chat:ProcessChat()
  if self.SkillBuild then
    self:SkillBuild()
  end
  if ShouldBuy() then
    self:PerformShop()
  end
  if self:IsDead() then
    return
  end
  self:onthinkCustom(tGameVariables)
end

function herobot:onthinkCustom(tGameVariables)
end

function herobot:CoreInitialize()
  self.core.myTeam = self:GetTeam()
  if self.core.myTeam == HoN.GetLegionTeam() then
    self.core.enemyTeam = HoN.GetHellbourneTeam()
  else
    self.core.enemyTeam = HoN.GetLegionTeam()
  end
  self.core.initialized = true
end

function herobot:BrainInitialize(tGameVariables)
  self.brain.hero = herobot:GetHeroUnit()
  self.teamBrain = HoN.GetTeamBotBrain()
  self.brain.initialized = true
end

function herobot:IsDead()
  return self.brain.hero:GetHealth() <= 0
end

function herobot:SkillBuild()
  if self.brain.skills.abilQ == nil then
    self.brain.skills.abilQ = self.brain.hero:GetAbility(0)
    self.brain.skills.abilW = self.brain.hero:GetAbility(1)
    self.brain.skills.abilE = self.brain.hero:GetAbility(2)
    self.brain.skills.abilR = self.brain.hero:GetAbility(3)
    self.brain.skills.abilAttributeBoost  = self.brain.hero:GetAbility(4)
  end

  if self.brain.hero:GetAbilityPointsAvailable() <= 0 then
    return
  end

  local skill = self:SkillBuildWhatNext()
  skill:LevelUp()
end

function herobot:SkillBuildWhatNext()
  if self.brain.skills.abilQ:CanLevelUp() then
    return self.brain.skills.abilQ
  elseif self.brain.skills.abilW:CanLevelUp() then
    return self.brain.skills.abilW
  elseif self.brain.skills.abilE:CanLevelUp() then
    return self.brain.skills.abilE
  elseif self.brain.skills.abilR:CanLevelUp() then
    return self.brain.skills.abilR
  else
    return self.brain.skills.abilAttributeBoost
  end
end

function herobot:PerformShop()
end
