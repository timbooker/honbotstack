local _G = getfenv(0)

local defaultColor = "red"

local function DrawLineOrArrow(startPosition, endPosition, color, arrow)
  if not startPosition or not endPosition then return end
  HoN.DrawDebugLine(startPosition, endPosition, arrow or false, color or defaultColor)
end

local function DrawLine(startPosition, endPosition, color)
  DrawLineOrArrow(startPosition, endPosition, color, false)
end

local function DrawArrow(startPosition, endPosition, color)
  DrawLineOrArrow(startPosition, endPosition, color, true)
end

local function DrawX(position, color, size)
  if not position then return end

  size = size or 50
  local tl = Vector3.Create(0.5, -0.5) * size
  local bl = Vector3.Create(0.5, 0.5) * size

  DrawLine(position - tl, position + tl, color)
  DrawLine(position - bl, position + bl, color)
end

local function ChangeDefaultColor(color)
  defaultColor = color
end

function Drawings()
  local functions = {}
  functions.DrawLine = DrawLine
  functions.DrawArrow = DrawArrow
  functions.DrawX = DrawX
  functions.ChangeDefaultColor = ChangeDefaultColor
  return functions
end
