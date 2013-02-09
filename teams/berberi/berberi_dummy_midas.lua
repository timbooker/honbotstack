local _G = getfenv(0)
local herobot = _G.object

herobot.heroName = 'Hero_Midas'

runfile 'bots/core_herobot.lua'
runfile 'bots/utils/inventory.lua'
local InventoryFns = Utils_Inventory
runfile 'bots/utils/drawings.lua'
local DrawingsFns = Utils_Drawings
runfile 'bots/utils/chat.lua'
local ChatFns = Utils_Chat
runfile 'bots/utils/courier_controlling.lua'
local CourierControlling = Utils_CourierControlling
runfile 'bots/utils/metadata_manager.lua'
local MetadataManager = Utils_MetadataManager

local print, tostring, tremove = _G.print, _G.tostring, _G.table.remove

herobot.brain.goldTreshold = 0

herobot.data.canUpgradeCourier = true
herobot.data.creepWavePos = nil

local itemsToBuy = {
  'Item_MarkOfTheNovice',
  'Item_PretendersCrown',
  'Item_RunesOfTheBlight',
  'Item_ManaPotion',
  'Item_FlamingEye',
  'Item_Intelligence5',
  'Item_Marchers',
  'Item_Striders',
  'Item_BrainOfMaliken',
  'Item_Strength5',
  'Item_Astrolabe',
  'Item_NomesWisdom',
  'Item_SpellShards',
  'Item_SpellShards',
  'Item_SpellShards',
  'Item_PostHaste',
  'Item_Regen',
  'Item_Confluence',
  'Item_Protect',
  'Item_Lightbrand',
  'Item_Confluence',
  'Item_GrimoireOfPower'
}

local tpStone = HoN.GetItemDefinition("Item_HomecomingStone")
local function getNextItemToBuy()
  return HoN.GetItemDefinition(itemsToBuy[1]) or tpStone
end
local function updateTreshold(bot)
  local nextItem = getNextItemToBuy()
  bot.brain.goldTreshold = nextItem:GetCost()
end

function herobot:PerformShop()
  local hero = self.brain.hero
  if #itemsToBuy == 0 then return end
  local nextItem = getNextItemToBuy()
  local itemCost = nextItem:GetCost()
  if itemCost <= self:GetGold() then
    hero:PurchaseRemaining(nextItem)
    tremove(itemsToBuy, 1)
  end
  updateTreshold(self)
  Echo("My current treshold: "..tostring(self.brain.goldTreshold))
end

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

function herobot:onthinkCustom(tGameVariables)
  if not self.brain.myLane then
    self.brain.myLane = self.metadata:GetMiddleLane()
  end
  if self:ProcessingStash() then
    return
  end
  CourierControlling.onthink(self.teamBrain, self)
  --self:PrintStates()
  if self:IsDead() then
    return
  end
  self:WardSpots()
  self:MoveToCreeps()
  self:Harass()
end

local function giveAll(bot, target)
  local skills = bot.brain.skills
  local targetPosition = target:GetPosition()
  if skills.abilTaunt:CanActivate() then
    bot:OrderAbilityEntity(skills.abilTaunt, target)
    return
  end
  if skills.abilW:CanActivate() then
    bot:OrderAbilityPosition(skills.abilW, targetPosition)
    return
  end
  if skills.abilQ:CanActivate() then
    bot:OrderAbilityPosition(skills.abilQ, targetPosition)
    return
  end
  if skills.abilE:CanActivate() then
    bot:OrderAbilityPosition(skills.abilE, targetPosition)
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
    ChatFns.AllChat(self, "I gonna kill ya!")
    giveAll(self, target)
  end
end

function herobot:MoveToCreeps()
  local creepsInPosition = self:GetCreepPosOnMyLane()
  DrawingsFns.DrawX(creepsInPosition)
  if herobot.data.creepsInPosition ~= creepsInPosition then
    herobot.data.creepsInPosition = creepsInPosition
    self:OrderPosition(self.brain.hero, "Attack", creepsInPosition)
  end
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

local function MoveItemsFromStashToHero(hero)
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

function herobot:ProcessingStash()
  local hero = self.brain.hero
  if not InventoryFns.HasItemsInStash(hero) then return end
  if hero:CanAccessStash() then
    return MoveItemsFromStashToHero(hero)
  end
  return false
end

function herobot:WardSpots()
  local wardSpots = MetadataManager.GetMapData('/bots/metadatas/wardspots.botmetadata')
  for _, node in pairs(wardSpots:GetNodes()) do
    DrawingsFns.DrawX(node:GetPosition())
  end
end
