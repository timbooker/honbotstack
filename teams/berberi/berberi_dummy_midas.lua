local _G = getfenv(0)
local herobot = _G.object

herobot.heroName = 'Hero_Midas'

runfile 'bots/core_herobot.lua'
runfile 'bots/drawings.lua'
runfile 'bots/utils.lua'

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
  self:Harass()
end

local function giveAll(bot, target)
  Echo("Giving all")
  local beha = bot.brain.hero:GetBehavior()
  if beha then
    Echo("Beha in use: "..beha:GetType())
    if beha:GetType() == "Attack" then
      Echo("not giving")
      return
    end
  end
  local skills = bot.brain.skills
  if skills.abilW:CanActivate() then
    bot:OrderAbilityPosition(skills.abilW, target:GetPosition())
    return
  elseif skills.abilQ:CanActivate() then
    bot:OrderAbilityPosition(skills.abilQ, target:GetPosition())
    return
  elseif skills.abilE:CanActivate() then
    bot:OrderAbilityPosition(skills.abilE, target:GetPosition())
    return
  end
  bot:OrderEntity(bot.brain.hero, "Attack", target)
end

function herobot:Harass()
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
    local invTps = self.brain.hero:FindItemInInventory(tpStone:GetName())
    local cinvTps = self.teamBrain.courier:FindItemInInventory(tpStone:GetName())
    if cinvTps then
      Echo(tostring(#cinvTps))
    end
    if invTps then
      Echo(tostring(#invTps))
    end
    if #invTps > 0 then
      local tp = invTps[1]
      Echo("courier can access: "..tostring(self.teamBrain.courier:CanAccess(tp)))
    end
    if #cinvTps > 0 then
      local tp = cinvTps[1]
      Echo("courier can access: "..tostring(self.teamBrain.courier:CanAccess(tp)))
    end
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
