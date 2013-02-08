local _G = getfenv(0)

function Masks()
  local masks = {}
  masks.UNIT = 0x0000001
  masks.BUILDING = 0x0000002
  masks.HERO = 0x0000004
  masks.POWERUP = 0x0000008
  masks.GADGET = 0x0000010
  masks.ALIVE = 0x0000020
  masks.CORPSE = 0x0000040
  return masks
end
