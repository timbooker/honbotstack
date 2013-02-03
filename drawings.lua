local _G = getfenv(0)

function DrawXPosition(position, color, size)
  if not position then
    return
  end

  color = color or "red"
  size = size or 100
  local tl = Vector3.Create(0.5, -0.5) * size
  local bl = Vector3.Create(0.5, 0.5) * size

  HoN.DrawDebugLine(position - 0.5 * tl, position + 0.5 * tl, false, color)
  HoN.DrawDebugLine(position - 0.5 * bl, position + 0.5 * bl, false, color)
end
