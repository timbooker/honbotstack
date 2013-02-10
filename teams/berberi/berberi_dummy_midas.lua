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
runfile "bots/utils/warding.lua"
local Warding = Utils_Warding
runfile "bots/utils/rune_control.lua"
local RuneControl = Utils_RuneControl

local print, tostring, tremove = _G.print, _G.tostring, _G.table.remove

herobot.brain.goldTreshold = 0

herobot.data.canUpgradeCourier = true
herobot.data.creepWavePos = nil
herobot.data.currentAction = nil

local assignedToTeam = false

local itemsToBuy = {
  'Item_MarkOfTheNovice',
  'Item_PretendersCrown',
  'Item_RunesOfTheBlight',
  'Item_ManaPotion',
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
local ward = HoN.GetItemDefinition("Item_FlamingEye")
local function getNextItemToBuy()
  return HoN.GetItemDefinition(itemsToBuy[1]) or tpStone
end
local function updateTreshold(bot)
  local nextItem = getNextItemToBuy()
  bot.brain.goldTreshold = nextItem:GetCost()
end

function herobot:PerformShop()
  local hero = self.brain.hero
  local wardFound = false
  for _, item in ipairs(hero:GetInventory(true)) do
    if item:GetTypeName() == "Item_FlamingEye" then
      wardFound = true
    end
  end
  if self.teamBrain:AmISupport(self) and not wardFound then
    hero:PurchaseRemaining(ward)
  end
  if #itemsToBuy == 0 then return end
  local nextItem = getNextItemToBuy()
  local itemCost = nextItem:GetCost()
  if itemCost <= self:GetGold() then
    hero:PurchaseRemaining(nextItem)
    tremove(itemsToBuy, 1)
  end
  updateTreshold(self)
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
  if not assignedToTeam then
    self.teamBrain:AddHero(self)
    assignedToTeam = true
  end
  if not self.brain.myLane then
    self.brain.myLane = self.metadata:GetMiddleLane()
  end
  if self:ProcessingStash() then
    return
  end
  CourierControlling.onthink(self.teamBrain, self, self.teamBrain:AmISupport(self))
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
    self:OrderPosition(hero, "Move", creepsInPosition)
  end
end

function herobot:GetCreepPosOnMyLane()
  local lane = self.brain.myLane
  if not lane or #lane < 1 then
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


local function table_find(table, value)
  for _, v in ipairs(table) do
    if v.item_type == value then
      return true
    end
  end
  return false
end
local function HeroHasStackableItems(hero)
  local items = {}
  local inventory = hero:GetInventory(true)
  local stackableInHero = {}
  for i = 1, 6, 1 do
    local item = inventory[i]
    if item and item:GetCharges() > 0 then
      local lol = {}
      lol.item_type = item:GetType()
      lol.index = i
      table.insert(stackableInHero, lol)
    end
  end
  for i = 7, 12, 1 do
    local item = inventory[i]
    if item and table_find(stackableInHero, item:GetType()) then
      local lol = {}
      lol.slot1 = i
      lol.slot2 = stackableInHero.index
      table.insert(items, lol)
    end
  end
  return items
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
  local stackable = HeroHasStackableItems(hero)
  for _, slots in ipairs(stackable) do
    hero:SwapItems(slots.slot1, slots.slot2)
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

function herobot:ProcessingStash()
  local hero = self.brain.hero
  if not InventoryFns.HasItemsInStash(hero) then return end
  if hero:CanAccessStash() then
    return MoveItemsFromStashToHero(hero)
  end
  return false
end

function herobot:GetWardingSpot()
  local wardSpots = MetadataManager.GetMapData('/bots/metadatas/wardspots.botmetadata')
  local wardSpot = wardSpots:FindByName("Legion ancients")
  local spot = wardSpot:GetPosition()
  DrawingsFns.DrawX(spot, "cyan")
  return spot
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

local runeAction = {}
runeAction.name = "checking rune"
runeAction.CanActivate = function(bot)
  return bot.teamBrain:AmIRuneCollector(bot) and RuneControl.IsRuneUp()
end
runeAction.Activate = function(bot)
  RuneControl.RuneAction(bot, bot.brain.hero)
end
runeAction.RunDown = function(bot)
  RuneControl.SkipCurrentRune(bot, bot.brain.hero)
end

local wardingAction = {}
wardingAction.name = "warding"
wardingAction.CanActivate = function(bot)
  return Warding.IsWardingPossible(bot.brain.hero, bot:GetWardingSpot())
end
wardingAction.Activate = function(bot)
  Warding.DoWarding(bot, bot.brain.hero, bot:GetWardingSpot())
end
wardingAction.RunDown = function(bot)
  bot:Order(bot.brain.hero, "Stop")
end

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
  action.RunDown = function(bot)
  end
  return action
end

local defaultAction = {}
defaultAction.name = "default"
defaultAction.CanActivate = function(bot)
  return true
end
defaultAction.Activate = function(bot)
  bot:MoveToCreeps()
end
defaultAction.RunDown = function(bot)
  bot:Order(bot.brain.hero, "Stop")
end

local laningAction ={}
laningAction.name = "laning"
laningAction.CanActivate = function(bot)
  local units = bot:GetLocalUnitsSorted()
  local enemies = units.Enemies
  for _, unit in pairs(enemies) do
    return true
  end
  return false
end
laningAction.Activate = function(bot)
  -- TODO: refactor this
  local hero = bot.brain.hero
  local heroPosition = hero:GetPosition()
  local beha = hero:GetBehavior()
  if beha and (beha:GetType() == "Attack" or beha:GetType() == "Ability") then
    return
  end
  local target = nil
  local units = bot:GetLocalUnitsSorted()
  local enemies = units.Enemies
  for _, unit in pairs(enemies) do
    if not target or Vector3.Distance(heroPosition, target:GetPosition()) > Vector3.Distance(heroPosition, unit:GetPosition()) then
      target = unit
    end
  end
  bot:OrderEntity(bot.brain.hero, "Attack", target)
end
laningAction.RunDown = function(bot)
  bot:Order(bot.brain.hero, "Stop")
end

local movingToTree = false
local eatingTree = false
local eatingTreeCD = nil
local healingAction = {}
local target = nil
local rune = nil
healingAction.name = "healing"
healingAction.CanActivate = function(bot)
  if eatingTree then
    return true
  elseif eatingTreeCD and eatingTreeCD > HoN.GetMatchTime() then
    return false
  end
  local hero = bot.brain.hero
  if hero:GetHealth() < (hero:GetMaxHealth() - 115) then
    local inv = hero:GetInventory()
    for _, item in ipairs(inv) do
      if item:GetTypeName() == "Item_RunesOfTheBlight" then
        return true
      end
    end
  end
  return false
end
healingAction.Activate = function(bot)
  local hero = bot.brain.hero
  local heroPosition = hero:GetPosition()
  if target and target:IsValid() and movingToTree then
    local distance = Vector3.Distance(heroPosition, target:GetPosition())
    if distance < 150 then
      bot:OrderItemEntity(rune, target)
      eatingTree = true
      movingToTree = false
    else
    end
    return
  elseif eatingTree then
    local beha = hero:GetBehavior()
    eatingTreeCD = HoN.GetMatchTime() + 16000
    eatingTree = false
    return
  end
  local inv = hero:GetInventory()
  for _, item in ipairs(inv) do
    if item:GetTypeName() == "Item_RunesOfTheBlight" then
      rune = item
      break
    end
  end
  if rune then
    local trees = HoN.GetTreesInRadius(heroPosition, 900)
    for _, tree in pairs(trees) do
      if not target or Vector3.Distance(heroPosition, target:GetPosition()) > Vector3.Distance(heroPosition, tree:GetPosition()) then
        target = tree
      end
    end
    if target then
      bot:OrderPosition(hero, "Move", target:GetPosition())
      movingToTree = true
    end
  end
end
healingAction.RunDown = function(bot)
  target = nil
  rune = nil
  bot:Order(bot.brain.hero, "Stop")
end

local manaActionPotion = nil
local manaActionRing = nil
local manaAction = {}
manaAction.name = "moar mana"
manaAction.CanActivate = function(bot)
  local hero = bot.brain.hero
  local inv = hero:GetInventory()
  for _, item in ipairs(inv) do
    if item:GetTypeName() == "Item_ManaPotion" then
      manaActionPotion = item
    elseif item:GetTypeName() == "Item_Replenish" then
      manaActionRing = item
    end
  end
  return (manaActionPotion or manaActionRing and manaActionRing:CanActivate()) and hero:GetMana() < (hero:GetMaxMana() - 100)
end
manaAction.Activate = function(bot)
  if manaActionRing and manaActionRing:CanActivate() then
    bot:OrderItem(manaActionRing)
    manaActionRing = nil
  elseif manaActionPotion then
    bot:OrderItemEntity(manaActionPotion, bot.brain.hero)
    manaActionPotion = nil
  end
end
manaAction.RunDown = function(bot)
end

PriorityActions.AddAction(manaAction)
PriorityActions.AddAction(healingAction)
PriorityActions.AddAction(harassActionBuilder())
PriorityActions.AddAction(wardingAction)
PriorityActions.AddAction(runeAction)
PriorityActions.AddAction(laningAction)
PriorityActions.AddAction(defaultAction)
