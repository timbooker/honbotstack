local _G = getfenv(0)
local herobot = _G.object

herobot.heroName = 'Hero_Midas'

runfile 'bots/core_herobot.lua'
runfile 'bots/drawings.lua'
runfile 'bots/utils.lua'

local print, tostring = _G.print, _G.tostring

function herobot:SkillBuildWhatNext()
  local skills = self.brain.skills
  if skills.abilE:GetLevel() < 1 then
    return skills.abilE
  elseif skills.abilW:GetLevel() < 1 then
    return skills.abilW
  elseif skills.abilQ:GetLevel() < 1 then
    return skills.abilQ
  elseif skills.abilR:CanLevelUp() then
    return skills.abilR
  elseif skills.abilW:CanLevelUp() then
    return skills.abilW
  elseif skills.abilQ:CanLevelUp() then
    return skills.abilQ
  elseif skills.abilE:CanLevelUp() then
    return skills.abilE
  else
    return skills.abilAttributeBoost
  end
end

local nextChat = HoN.GetGameTime() + 1000

local function courierFlies(courier)
  return courier:GetTypeName() == "Pet_FlyngCourier"
end

local function upgCourier(bot)
  local courier = bot.teamBrain.courier
  local upgAbil = courier:GetAbility(0)
  if upgAbil:CanActivate() then
    Echo(courier:GetTypeName())
    bot:OrderAbility(upgAbil)
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
  if not courierFlies(self.teamBrain.courier) then
    upgCourier(self)
  end
  if self:ProcessingStash() then
    return
  end
  self:DeliverItems()
  self:MoveToCreeps()
  self:PrintStates()
  self:Harass()
end

local function giveAll(bot, target)
  local skills = bot.brain.skills
  if skills.abilW:CanActivate() then
    bot:OrderAbilityPosition(skills.abilW, target:GetPosition())
    return
  end
  if skills.abilQ:CanActivate() then
    bot:OrderAbilityPosition(skills.abilQ, target:GetPosition())
    return
  end
  if skills.abilE:CanActivate() then
    bot:OrderAbilityPosition(skills.abilE, target:GetPosition())
    return
  end
  bot:OrderEntity(bot.brain.hero, "Attack", target)
end

function herobot:Harass()
  if self.brain.hero:GetLevel() < 4 then
    return
  end
  local enemies = self:GetLocalEnemies()
  local target = nil
  for uid, unit in pairs(enemies) do
    target = unit
  end
  if target then
    giveAll(self, target)
  end
end

local inventoryDebugPrint = HoN.GetGameTime() + 1000
local tpStone = HoN.GetItemDefinition("Item_HomecomingStone")

function herobot:PerformShop()
  if inventoryDebugPrint < HoN.GetGameTime() then
    self.teamBrain.courier:PurchaseRemaining(tpStone)
    self.teamBrain.courier:SwapItems(1,7)
    self.teamBrain.courier:SwapItems(7,1)
    local inventory = self.brain.hero:GetInventory(true)
    PrintInventory(inventory)
    local inventory = self.teamBrain.courier:GetInventory(true)
    PrintInventory(inventory)
    inventoryDebugPrint = inventoryDebugPrint + 5000
    --self.brain.goldTreshold = self.brain.goldTreshold + 100
    --Echo("My current treshold: "..tostring(self.brain.goldTreshold))
  end
end

local function lolCost(parent, current, link, original)
  --TODO: local nDistance = link:GetLength()
  local nDistance = Vector3.Distance(parent:GetPosition(), current:GetPosition())
  local nCostToParent = original - nDistance

  --BotEcho(format("nOriginalCost: %s  nDistance: %s  nSq: %s", nOriginalCost, nDistance, nDistance*nDistance))

  local sZoneProperty  = current:GetProperty("zone")
  local bTowerProperty = current:GetProperty("tower")
  local bBaseProperty  = current:GetProperty("base")

  local nMultiplier = 1.0
  local nEnemyTerritoryMul = 10
  local bEnemyZone = false
  if sZoneProperty and sZoneProperty == sEnemyZone then
    bEnemyZone = true
  end

  if bEnemyZone then
    nMultiplier = nMultiplier + nEnemyTerritoryMul
    if bBaseProperty then
      nMultiplier = nMultiplier + nBaseMul
    end

    if bTowerProperty then
      --check if the tower is there
      local tBuildings = HoN.GetUnitsInRadius(nodeCurrent:GetPosition(), 800, 0x0000020 + 0x0000002)

      for _, unitBuilding in pairs(tBuildings) do
        if unitBuilding:IsTower() then
          nMultiplier = nMultiplier + nTowerMul
          break
        end
      end
    end
  end

  return nCostToParent + nDistance * nMultiplier
end
function herobot:MoveToCreeps()
  if self:EnemyCreepsNear() then return end
  local creepsInPosition = self:GetCreepPosOnMyLane()
  DrawXPosition(creepsInPosition)
  local myPos = self.brain.hero:GetPosition()
  local path = {}
  --if self:GetTeam() == 2 then
  --  path = BotMetaData.FindPath(creepsInPosition, myPos, lolCost)
  --else
    path = BotMetaData.FindPath(myPos, creepsInPosition, lolCost)
  --end
  local nextIndex = 1
  local nextI = 2
  local nnextI = 3
  if #path > 1 then
    local vecMeToFirst = path[nextIndex]:GetPosition() - myPos
    local vecFirstToSecond = path[nextI]:GetPosition() - path[nextIndex]:GetPosition()
    if self:GetTeam() == 2 then
      vecMeToFirst = myPos - path[nextIndex]:GetPosition()
      vecFirstToSecond = path[nextIndex]:GetPosition() - path[nextI]:GetPosition()
    end
    if Vector3.Dot(vecMeToFirst, vecFirstToSecond) < 0 then
      nextIndex = nextI
    end
  end
  if Vector3.Distance2DSq(path[nextIndex]:GetPosition(), myPos) < 300*300 then
    if nextIndex == nextI then nextI = nnextI end
    if path[nextI] then
      nextIndex = nextI
    end
  end

  local nextPos = path[nextIndex]:GetPosition()

  DrawXPosition(nextPos, "yellow")
  --local beha = self.brain.hero:GetBehavior()
  --if beha and beha:GetType() == "Attack" then
  --  Echo("DONT MOVE")
  --  return
  --end
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

function herobot:EnemyCreepsNear()
  local creeps = self:GetLocalUnitsSorted().EnemyUnits
  for key, unit in pairs(creeps) do
    local unitType = unit:GetTypeName()
    if unit:IsHero() or unitType == "Creep_HellbourneMelee" or unitType == "Creep_HellbourneRanged" or unitType == "Creep_HellbourneSiege" then
      return true
    end
  end
  return false
end

local function hasInStash(items)
  for i = 7, 12, 1 do
    if items[i] then
      return true
    end
  end
  return false
end

local function emptySlotInBackpack(items)
  for i = 1, 6, 1 do
    if not items[i] then
      return i
    end
  end
  return 0
end

local function itemInStash(items)
  for i = 7, 12, 1 do
    if items[i] then
      return i
    end
  end
  return 0
end

local function worthyItemsInStash(items)
  -- TODO: create worthy matcher
  return 0, 0
end

local function moveItemsFromStash(hero, items)
  local slotIndex = emptySlotInBackpack(items)
  if slotIndex > 0 then
    hero:SwapItems(slotIndex, itemInStash(items))
    return true
  end
  local packIndex, stashIndex = worthyItemsInStash(items)
  if packIndex > 0 and stashIndex > 0 then
    hero:SwapItems(packIndex, stashIndex)
    return true
  else
    return false
  end
end

function herobot:ProcessingStash()
  local hero = self.brain.hero
  if not hero:CanAccessStash() then
    return false
  end
  local inventory = hero:GetInventory(true)
  local items_slot = {}
  for i = 1, 12, 1 do
    local item = inventory[i]
    if item then
      items_slot[i] = item
    end
  end
  return hasInStash(items_slot) and moveItemsFromStash(hero, items_slot)
end

function herobot:DeliverItems()
  local courier = self.teamBrain.courier
  local inv = courier:GetInventory()
  local deliver = courier:GetAbility(2)
  local backToPool = courier:GetAbility(3)
  local beha = courier:GetBehavior()
  if beha then
    Echo("courier beha"..beha:GetType())
    Echo("idling? "..tostring(beha:IsIdle()))
    Echo("traveling ? "..tostring(beha:IsTraveling()))
    if beha:IsTraveling() or not beha:IsIdle() then
      return
    end
  end
  if not InventoryIsEmpty(inv) then
    Echo("deliver")
    self:OrderAbility(deliver)
  else
    Echo("go back")
    self:OrderAbility(backToPool)
  end
end
