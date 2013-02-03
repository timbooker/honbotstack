local _G = getfenv(0)
local herobot = _G.object

herobot.heroName = 'Hero_Midas'

runfile 'bots/core_herobot.lua'
runfile 'bots/drawings.lua'

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
  if not self.brain.myLane then
    self.brain.myLane = self.metadata:GetMiddleLane()
  end
  if nextChat < HoN.GetGameTime() then
    herobot.chat:AllChat("I gonna kill ya!")
    nextChat = nextChat + 100000
  end
  self:MoveToCreeps()
  self:PrintStates()
end

local inventoryDebugPrint = HoN.GetGameTime() + 1000
local tpStone = HoN.GetItemDefinition("Item_HomecomingStone")

function herobot:PerformShop()
  if inventoryDebugPrint < HoN.GetGameTime() then
    self.teamBrain.courier:PurchaseRemaining(tpStone)
    local invTps = self.brain.hero:FindItemInInventory(tpStone:GetName())
    if invTps then
      Echo(tostring(#invTps))
    end
    if #invTps > 0 then
      local tp = invTps[1]
      Echo("courier can access: "..tostring(self.teamBrain.courier:CanAccess(tp)))
      Echo("Slot: "..tostring(tp:GetSlot()))
      self.teamBrain.courier:SwapItems(1, tp:GetSlot())
    end
    local inventory = self.brain.hero:GetInventory(true)
    printInventory(inventory)
    local inventory = self.teamBrain.courier:GetInventory(true)
    printInventory(inventory)
    inventoryDebugPrint = inventoryDebugPrint + 5000
    --self.brain.goldTreshold = self.brain.goldTreshold + 100
    --Echo("My current treshold: "..tostring(self.brain.goldTreshold))
  end
end

function herobot:MoveToCreeps()
  local creepsInPosition = self:GetCreepPosOnMyLane()
  DrawXPosition(creepsInPosition)
  local myPos = self.brain.hero:GetPosition()
  local path = BotMetaData.FindPath(myPos, creepsInPosition)
  local nextPos = path[1]:GetPosition()
  if #path > 1 then
    local vecMeToFirst = nextPos - myPos
    local vecFirstToSecond = path[2]:GetPosition() - nextPos
    if Vector3.Dot(vecMeToFirst, vecFirstToSecond) < 0 then
      nextPos = path[2]:GetPosition()
    end
  end
  if Vector3.Distance2DSq(nextPos, myPos) < 200*200 then
    if path[3] then
      nextPos = path[3]:GetPosition()
    end
  end

  DrawXPosition(nextPos, "yellow")
  self:OrderPosition(self.brain.hero, "Move", nextPos)
end

function herobot:GetCreepPosOnMyLane()
  local lane = self.brain.myLane
  if not lane or #lane < 1 then
    Echo('No lane')
    return nil
  end
  return self.teamBrain:GetFrontOfCreepWavePosition(lane.laneName)
end

function herobot:PrintStates()
  local unit = self.brain.hero
  local behavior = unit:GetBehavior()
  if behavior then
    Echo(behavior:GetType())
  end
end
