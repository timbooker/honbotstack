local _G = getfenv(0)
local herobot = _G.object

local ipairs, pairs, tinsert, tsort = _G.ipairs, _G.pairs, _G.table.insert, _G.table.sort

herobot.chat = herobot.chat or {}
herobot.chat.messages = herobot.chat.messages or {}

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

function herobot.chat:ProcessChat()
  local messages = OutgoingMessages(self.messages)
  SortMessages(messages)
  SendMessages(herobot, messages)
end

local function Chat(chat, message, delay, isAll)
  delay = delay or 0
  if message == nil or message == "" then
    return
  end
  local currentTime = HoN.GetGameTime()
  tinsert(chat.messages, {(currentTime + delay), isAll, message})
end

function herobot.chat:AllChat(message, delay)
  return Chat(self, message, delay, true)
end

function herobot.chat:TeamChat(message, delay)
  return Chat(self, message, delay, false)
end
