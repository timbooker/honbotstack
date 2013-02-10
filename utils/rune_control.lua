local _G = getfenv(0)

local M = {}

runfile "bots/utils/masks.lua"
local MASKS = Utils_Masks
runfile "bots/utils/drawings.lua"
local DrawingsFns = Utils_Drawings

local INTERVAL = 120000
local RUNE_TOP = Vector3.Create(5800, 9720)
local RUNE_BOTTOM = Vector3.Create(11300, 5200)

local function RuneTimer()
  return (math.floor( HoN.GetMatchTime() / INTERVAL ) + 1) * INTERVAL
end

local nextRune = RuneTimer()
local runeMayBeTop = false
local runeMayBeBot = false
local takingRune = false
local checkingRune = false
local walking = false

local function SkipCurrentRune(bot, hero)
  takingRune = false
  checkingRune = false
  runeMayBeTop = false
  runeMayBeBot = false
  nextRune = RuneTimer()
  bot:Order(hero, "Stop")
end
M.SkipCurrentRune = SkipCurrentRune

local function GetRuneInSpot(spot)
  local powerups = HoN.GetUnitsInRadius(spot, 500, MASKS.POWERUP + MASKS.ALIVE)
  for _, rune in pairs(powerups) do
    return rune
  end
  return nil
end

local function GetRune(bot, hero, rune)
  takingRune = true
  bot:OrderEntity(hero, "Touch", rune)
end

local function MakeSure(bot, hero, spot)
  local markRune = true
  if walking then
    if HoN.CanSeePosition(spot) then
      local rune = GetRuneInSpot(spot)
      if rune then
        GetRune(bot, hero, rune)
      else
        markRune = false
      end
      walking = false
    end
  else
    bot:OrderPosition(hero, "Move", spot)
    walking = true
  end
  return markRune
end

local function MakeSureTop(bot, hero)
  runeMayBeTop = MakeSure(bot, hero, RUNE_TOP)
end

local function MakeSureBot(bot, hero)
  runeMayBeBot = MakeSure(bot, hero, RUNE_BOTTOM)
end

local function GoCheckRune(bot, hero)
  if runeMayBeTop and not runeMayBeBot then
    MakeSureTop(bot, hero)
  elseif not runeMayBeTop and runeMayBeBot then
    MakeSureBot(bot, hero)
  elseif not runeMayBeTop and not runeMayBeBot then
    SkipCurrentRune(bot, hero)
  else
    MakeSureTop(bot, hero)
  end
end

local function CheckIfSpotsAreVisible()
  runeMayBeTop = true
  runeMayBeBot = true
  if HoN.CanSeePosition(RUNE_TOP) then
    local rune = GetRuneInSpot(RUNE_TOP)
    if rune then
      return rune
    else
      runeMayBeTop = false
    end
  elseif HoN.CanSeePosition(RUNE_BOTTOM) then
    local rune = GetRuneInSpot(RUNE_BOTTOM)
    if rune then
      return rune
    else
      runeMayBeBot = false
    end
  end
  checkingRune = true
  return nil
end

local function CanTake(bot, hero)
  local beha = hero:GetBehavior()
  return beha and beha:GetType() == "Touch"
end

local function IsRuneUp()
  DrawingsFns.DrawX(RUNE_TOP, "green")
  DrawingsFns.DrawX(RUNE_BOTTOM, "green")
  local currentMatchTime = HoN.GetMatchTime()
  return (currentMatchTime and currentMatchTime > nextRune) or
    GetRuneInSpot(RUNE_TOP) or GetRuneInSpot(RUNE_BOTTOM)
end
M.IsRuneUp = IsRuneUp

local function RuneAction(bot, hero)
  if takingRune then
    local canTake = CanTake(bot, hero)
    if not canTake then
      SkipCurrentRune(bot, hero)
      bot:Order(hero, "Stop")
    end
  elseif checkingRune then
    GoCheckRune(bot, hero)
  else
    local rune = CheckIfSpotsAreVisible()
    if rune then
      GetRune(bot, hero, rune)
    end
  end
end
M.RuneAction = RuneAction

Utils_RuneControl = M
