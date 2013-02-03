local _G = getfenv(0)
local tournament = _G.object

function tournament.Is1v1()
  local mode = Cvar.GetCvar("tktl_tournament")
  return mode and mode:GetString() == "1v1" or false
end

function tournament.Is5v5()
  return not tournament.Is1v1()
end
