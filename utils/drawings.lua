local _G = getfenv(0)

local defaultColor = "red"

function DrawLine(startPosition, endPosition, color)
  if not startPosition or not endPosition then return end
  HoN.DrawDebugLine(startPosition, endPosition, false, color or defaultColor)
end

function DrawXPosition(position, color, size)
  if not position then return end

  size = size or 50
  local tl = Vector3.Create(0.5, -0.5) * size
  local bl = Vector3.Create(0.5, 0.5) * size

  DrawLine(position - tl, position + tl, color)
  DrawLine(position - bl, position + bl, color)
end
