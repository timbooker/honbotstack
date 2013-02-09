local _G = getfenv(0)
local teambot = _G.object

runfile 'bots/tournament_options.lua'
runfile 'bots/basic_metadata.lua'

function teambot:onthink(tGameVariables)
  if not self.metadata.initialized then
    self.metadata:Initialize()
  end
  self:onthinkCustom(tGameVariables)
end

function teambot.UseOriginal()
  runfile 'bots/teambot/teambotbrain.lua'
end
