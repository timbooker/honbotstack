local _G = getfenv(0)
local herobot = _G.object

herobot.heroName = 'Hero_Midas'

runfile 'bots/core_herobot.lua'

local print, tostring = _G.print, _G.tostring

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

local function printInventory(inventory)
  for i = 1, 12, 1  do
    local curItem = inventory[i]
    if curItem then
      print(tostring(i)..', '..curItem:GetName()..'\n')
    else
      print(tostring(i)..', nil\n')
    end
  end
end

function herobot:onthinkCustom(tGameVariables)
  if nextChat < HoN.GetGameTime() then
    herobot.chat:AllChat("I gonna kill ya!")
    nextChat = nextChat + 100000
  end
end

local inventoryDebugPrint = HoN.GetGameTime() + 1000
local tpStone = HoN.GetItemDefinition("Item_HomecomingStone")

function herobot:PerformShop()
  if inventoryDebugPrint < HoN.GetGameTime() then
    self.brain.hero:PurchaseRemaining(tpStone)
    local inventory = self.brain.hero:GetInventory(true)
    printInventory(inventory)
    inventoryDebugPrint = inventoryDebugPrint + 5000
    self.brain.goldTreshold = self.brain.goldTreshold + 100
    Echo("My current treshold: "..tostring(self.brain.goldTreshold))
  end
end
