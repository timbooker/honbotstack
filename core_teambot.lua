local _G = getfenv(0)
local teambot = _G.object

runfile 'bots/tournament_options.lua'

function teambot.UseOriginal()
  runfile 'bots/teambot/teambotbrain.lua'
end
