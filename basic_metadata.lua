local _G = getfenv(0)
local bot = _G.object

bot.metadata = bot.metadata or {}
local metadata = bot.metadata

BotMetaData.RegisterLayer('/bots/test.botmetadata')
BotMetaData.SetActiveLayer('/bots/test.botmetadata')

metadata.lanes = {}
local lanes = metadata.lanes
lanes.top = {}
lanes.middle = {}
lanes.bottom = {}

function metadata:GetTopLane()
  return self.lanes.top
end

function metadata:GetMiddleLane()
  return self.lanes.middle
end

function metadata:GetBottomLane()
  return self.lanes.bottom
end

metadata.initialized = false

local function createLaneCostFunction(laneName)
  local function laneCostFunction(parent, current, link, cost)
    local lane = current:GetProperty('lane')
    if lane and lane == laneName then
      return cost
    end
    return cost + 9999
  end
  return laneCostFunction
end

function metadata:Initialize()
  local startVector = Vector3.Create()
  local endVector = Vector3.Create(16000, 16000)

  lanes.top = BotMetaData.FindPath(startVector, endVector, createLaneCostFunction('top'))
  lanes.top.laneName = 'top'

  lanes.middle = BotMetaData.FindPath(startVector, endVector, createLaneCostFunction('middle'))
  lanes.middle.laneName = 'middle'

  lanes.bottom = BotMetaData.FindPath(startVector, endVector, createLaneCostFunction('bottom'))
  lanes.bottom.laneName = 'bottom'

  metadata.initialized = true
end
