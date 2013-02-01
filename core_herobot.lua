local _G = getfenv(0)
local object = _G.object

function object:onpickframe()
  if self:CanSelectHero(self.heroName) == true then
    self:SelectHero(self.heroName)
    self:Ready()
  end
end
