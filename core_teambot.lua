local _G = getfenv(0)
local teambot = _G.object

teambot.myName = (teambot.myName or 'unknown')

function teambot:UseOriginal()
  runfile 'bots/teambot/teambotbrain.lua'
end
