local _G = getfenv(0)

local M = {}

local DEFAULT_COLOR = "red"

local function DrawLineOrArrow(startPosition, endPosition, color, arrow)
  if not startPosition or not endPosition then return end
  HoN.DrawDebugLine(startPosition, endPosition, arrow or false, color or DEFAULT_COLOR)
end

local function DrawLine(startPosition, endPosition, color)
  DrawLineOrArrow(startPosition, endPosition, color, false)
end
M.DrawLine = DrawLine

local function DrawArrow(startPosition, endPosition, color)
  DrawLineOrArrow(startPosition, endPosition, color, true)
end
M.DrawArrow = DrawArrow

local function DrawX(position, color, size)
  if not position then return end

  size = size or 50
  local tl = Vector3.Create(0.5, -0.5) * size
  local bl = Vector3.Create(0.5, 0.5) * size

  DrawLine(position - tl, position + tl, color)
  DrawLine(position - bl, position + bl, color)
end
M.DrawX = DrawX

Utils_Drawings = M
