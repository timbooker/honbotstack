local _G = getfenv(0)
local object = _G.object

object.core = {}
object.core.initialized = false
object.core.myTeam = 0
object.core.enemyTeam = 0

object.brain = {}
object.brain.initialized = false
object.brain.hero = nil
object.brain.skills = {}
object.teamBrain = nil

function object:onpickframe()
  if self:CanSelectHero(self.heroName) then
    self:SelectHero(self.heroName)
    self:Ready()
  end
end

function object:onthink(tGameVariables)
  if not self.core.initialized then
    self:CoreInitialize()
  end
  if not self.brain.initialized or self.brain.hero == nil then
    self:BrainInitialize(tGameVariables)
  end
  if self:IsDead() then
    return
  end
  if self.SkillBuild then
    self:SkillBuild()
  end
end

function object:CoreInitialize()
  self.core.myTeam = self:GetTeam()
  if self.core.myTeam == HoN.GetLegionTeam() then
    self.core.enemyTeam = HoN.GetHellbourneTeam()
  else
    self.core.enemyTeam = HoN.GetLegionTeam()
  end
  self.core.initialized = true
end

function object:BrainInitialize(tGameVariables)
  self.brain.hero = object:GetHeroUnit()
  self.teamBrain = HoN.GetTeamBotBrain()
  self.brain.initialized = true
end

function object:IsDead()
  return self.brain.hero:GetHealth() <= 0
end

function object:SkillBuild()
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

function object:SkillBuildWhatNext()
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
