local _G = getfenv(0)
local print, tostring = _G.print, _G.tostring

function PrintInventory(inventory)
  if not inventory then
    return
  end
  for i = 1, 12, 1  do
    local curItem = inventory[i]
    if curItem then
      print(tostring(i)..', '..curItem:GetName()..'\n')
    else
      print(tostring(i)..', nil\n')
    end
  end
end

function InventoryIsEmpty(inventory)
  return #inventory == 0
end
