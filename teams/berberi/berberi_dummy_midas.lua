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
runfile "bots/utils/masks.lua"
local MASKS = Utils_Masks
runfile "bots/utils/priority_actions.lua"
local PriorityActions = Utils_PriorityActions

local print, tostring, tremove = _G.print, _G.tostring, _G.table.remove

herobot.brain.goldTreshold = 0

herobot.data.canUpgradeCourier = true
herobot.data.creepWavePos = nil
herobot.data.currentAction = nil

local actions = {}
actions.WARDING = 0

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
  if self:IsDead() then
    return
  end
  PriorityActions.onthink(self)
end

function herobot:MoveToCreeps()
  local creepsInPosition = self:GetCreepPosOnMyLane()
  DrawingsFns.DrawX(creepsInPosition)
  local hero = self.brain.hero
  local beha = hero:GetBehavior()
  if beha and beha:IsIdle() then
    self.data.creepsInPosition = nil
  end
  if self.data.creepsInPosition ~= creepsInPosition then
    self.data.creepsInPosition = creepsInPosition
    self:OrderPosition(hero, "Attack", creepsInPosition)
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

local function GetWardFromBag(hero)
  local inventory = hero:GetInventory()
  for _, item in ipairs(inventory) do
    if item:GetName() == "Item_FlamingEye" then
      return item
    end
  end
  return nil
end

local function WardInGround(spot)
  local gadgets = HoN.GetUnitsInRadius(spot, 200, MASKS.GADGET + MASKS.ALIVE)
  for k, gadget in pairs(gadgets) do
    if gadget:GetTypeName() == "Gadget_FlamingEye" then
      return true
    end
  end
  return false
end

function herobot:WardSpots()
  local ward = GetWardFromBag(self.brain.hero)
  if self.data.currentAction == actions.WARDING then
    if not ward then
      self:Order(self.brain.hero, "Stop")
      self.data.currentAction = nil
    end
    return
  end
  local wardSpots = MetadataManager.GetMapData('/bots/metadatas/wardspots.botmetadata')
  local wardSpot = wardSpots:FindByName("Legion ancients")
  local spot = wardSpot:GetPosition()
  DrawingsFns.DrawX(spot, "cyan")
  if not WardInGround(spot) and ward then
    self:OrderItemPosition(ward, spot)
    self.data.currentAction = actions.WARDING
    Echo("warding")
  end
end

local function giveAll(bot, target)
  ChatFns.AllChat(bot, "I gonna kill ya!")
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

function herobot:GetHarassTarget()
  local enemies = self:GetLocalEnemies()
  local target = nil
  for _, unit in pairs(enemies) do
    if unit then
      return unit
    end
  end
  return nil
end

local wardingAction = {}
wardingAction.name = "warding"
wardingAction.CanActivate = function(bot)
  local action = bot.data.currentAction
  return action == actions.WARDING or
    (action == nil and GetWardFromBag(bot.brain.hero))
end
wardingAction.Activate = function(bot)
  bot:WardSpots()
end
PriorityActions.AddAction(wardingAction)

local harassActionBuilder = function()
  local action = {}
  action.name = "harass"
  action.CanActivate = function(bot)
    local target = bot:GetHarassTarget()
    return bot.brain.hero:GetLevel() > 3 and target
  end
  action.Activate = function(bot)
    local target = bot:GetHarassTarget()
    giveAll(bot, target)
  end
  return action
end
PriorityActions.AddAction(harassActionBuilder())

local defaultAction = {}
defaultAction.name = "default"
defaultAction.CanActivate = function(bot)
  return true
end
defaultAction.Activate = function(bot)
  bot:MoveToCreeps()
end
PriorityActions.AddAction(defaultAction)
