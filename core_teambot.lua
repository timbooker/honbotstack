local _G = getfenv(0)
local teambot = _G.object

runfile 'bots/tournament_options.lua'
runfile 'bots/basic_metadata.lua'

runfile 'bots/utils/courier_controlling.lua'
local CourierControllingFns = CourierControlling()

function teambot:onthink(tGameVariables)
  if not self.metadata.initialized then
    self.metadata:Initialize()
  end
  if not CourierControllingFns.IsInitialized(self) then
    CourierControllingFns.Initialize(self)
  end
  CourierControllingFns.FreeCourier(self)
  self:onthinkCustom(tGameVariables)
end

function teambot.UseOriginal()
  runfile 'bots/teambot/teambotbrain.lua'
end
