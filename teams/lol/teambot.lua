local _G = getfenv(0)
local teambot = _G.object

teambot.name = 'Team LOL'

runfile 'bots/core_teambot.lua'

teambot.UseOriginal()
