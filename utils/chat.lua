local _G = getfenv(0)

local ipairs, pairs, tinsert, tsort = _G.ipairs, _G.pairs, _G.table.insert, _G.table.sort

local function OutgoingMessages(messages)
  local currentTime = HoN.GetGameTime()
  local outgoingMessages = {}

  for key, message in pairs(messages) do
    if message[1] < currentTime then
      tinsert(outgoingMessages, message)
      messages[key] = nil
    end
  end
  return outgoingMessages
end

local function SortMessages(messages)
  if #messages > 1 then
    tsort(messages, function(a,b) return (a[1] < b[1]) end)
  end
end

local function SendMessages(bot, messages)
  for i, message in ipairs(messages) do
    local isAllChat = message[2]
    local content = message[3]
    if isAllChat then
      bot:Chat(content)
    else
      bot:TeamChat(content)
    end
  end
end

local function IsChatInitialized(bot)
  return not not bot.messages
end

local function InitializeChat(bot)
  bot.messages = bot.messages or {}
end

local function ProcessChat(bot)
  local messages = OutgoingMessages(bot.messages)
  SortMessages(messages)
  SendMessages(bot, messages)
end

local function Chat(bot, message, delay, isAll)
  delay = delay or 0
  if message == nil or message == "" then
    return
  end
  local currentTime = HoN.GetGameTime()
  tinsert(bot.messages, {(currentTime + delay), isAll, message})
end

local function AllChat(bot, message, delay)
  return Chat(bot, message, delay, true)
end

local function TeamChat(bot, message, delay)
  return Chat(bot, message, delay, false)
end

function ChatUtils()
  local functions = {}
  functions.IsChatInitialized = IsChatInitialized
  functions.InitializeChat = InitializeChat
  functions.ProcessChat = ProcessChat
  functions.AllChat = AllChat
  functions.TeamChat = TeamChat
  return functions
end
