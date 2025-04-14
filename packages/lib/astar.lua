function Main()
  term.clear()
  local width, height = term.getSize()
  local m = {}
  for x = 1, width do
    m[x] = {}
    m[x][0] = {}
    for z = 1, height do
      m[x][0][z] = { block = "minecraft:air" }
      term.setCursorPos(x, z)
    end
  end
  local _, _, x, z = os.pullEvent("mouse_click")
  ColorPixel(x, z, colors.green)
  local s = { x = x, y = 0, z = z }
  local _, _, x, z = os.pullEvent("mouse_click")
  local g = { x = x, y = 0, z = z }
  term.setCursorPos(x, z)
  term.blit("x", "6", "7")
  -- ColorPixel(x, z, colors.red)

  while true do
    term.setCursorPos(1, 1)
    term.blit("x", "6", "7")
    local event, button, x, z = os.pullEvent("mouse_click")
    if x == 1 and z == 1 then break end
    ColorPixel(x, z, colors.gray)
    m[x][0][z].block = "minecraft:stone"
  end

  term.setCursorPos(1, 1)
  local node, errnum = Astar(m, s, g)
  if node == false then
    term.setCursorPos(1, height - 1)
    print(errnum .. ": Could not find route!: " .. s.x .. ", " .. s.y)
  else
    DrawPath(node)
    term.setCursorPos(1, 1)
  end
end

function ColorPixel(x, y, col)
  if colors.green == col then
    col = "5"
  elseif colors.red == col then
    col = "e"
  elseif colors.gray == col then
    col = "8"
  elseif colors.yellow == col then
    col = "4"
  end
  term.setCursorPos(x, y)
  term.blit("x", col, col)
end

function DrawPath(node)
  local curr = node
  local n = 2
  while curr.prev ~= nil do
    curr = curr.prev
    term.setCursorPos(1, n)
    -- print(tostring(curr.y) .. ", " .. tostring(curr.block))
    n = n + 1
    if curr.y == 0 then
      ColorPixel(curr.x, curr.z, colors.yellow)
    else
      ColorPixel(curr.x, curr.z, colors.red)
    end
  end
end

---@alias bl { block: string, x: integer, y: integer, z: integer }
---@alias blid { block: string, x: integer, y: integer, z: integer, fscore: integer, gscore: integer}

---A* pathfinding algorithm
---comment
---@param m { [integer]: { [integer]: { [integer]: { block: string } } } }
---@param start bl
---@param goal { x: integer, y: integer, z: integer }
---@return nil
---@return nil | { x: integer, y: integer: z: integer, prev: any | nil }
function Astar(m, start, goal)
  if m == nil or start == nil or goal == nil then return nil end
  ---@type { [integer]: { [integer]: { [integer]: integer } } }
  local gScore = {}
  ---@type { [integer]: blid}
  local openSet = {}
  ---@cast start blid
  start.gscore = 0
  start.fscore = 0
  table.insert(openSet, start)
  gScore[start.x] = {}
  gScore[start.x][start.y] = {}
  gScore[start.x][start.y][start.z] = 0

  local max = 0
  while #openSet ~= 0 do
    local current = returnLowesFscore(openSet)
    -- term.setCursorPos(1, 1)
    -- term.write("num: " ..
    --   #openSet .. "; " .. tostring(current) .. ": " .. current.x .. ", " .. current.y .. ", " .. current.z)

    -- sleep(5)
    if current.x == goal.x and current.y == goal.y and current.z == goal.z then return current end
    max = math.max(max, #openSet)
    if m[current.x] == nil or m[current.x][current.y] == nil or m[current.x][current.y][current.z] == nil or m[current.x][current.y][current.z].block == "minecraft:air" then
      -- if current.y == 0 then ColorPixel(current.x, current.z, "0") end

      for key, neighbor in pairs(GetNeighbors(current)) do
        -- term.setCursorPos(1, 3)
        -- sleep(1)
        -- print(key)
        local tentative_gscore = current.gscore + 1

        if tentative_gscore < ((gScore[neighbor.x] and gScore[neighbor.x][neighbor.y] and gScore[neighbor.x][neighbor.y][neighbor.z]) or math.huge) then
          neighbor.prev = current

          ---@diagnostic disable-next-line: inject-field
          neighbor.gscore = tentative_gscore
          if gScore[neighbor.x] == nil then gScore[neighbor.x] = {} end
          if gScore[neighbor.x][neighbor.y] == nil then gScore[neighbor.x][neighbor.y] = {} end
          gScore[neighbor.x][neighbor.y][neighbor.z] = tentative_gscore

          ---@diagnostic disable-next-line: inject-field
          neighbor.fscore = tentative_gscore + H_dist(neighbor, goal)

          local doAdd = true
          for _, val in pairs(openSet) do
            if val.x == neighbor.x and val.y == neighbor.y and val.z == neighbor.z then
              doAdd = false
              break
            end
          end
          if doAdd then
            if neighbor.y == 0 then
              neighbor.block = m[neighbor.x][0][neighbor.z].block
              -- ColorPixel(neighbor.x, neighbor.z, "d")
            end
            table.insert(openSet, neighbor)
          end
        end
      end
    end
  end
  return false, max
end

---comment
---@param tab { [integer]: blid }
---@return blid
function returnLowesFscore(tab)
  local lowest
  local key_low
  for key, val in pairs(tab) do
    if lowest == nil then
      lowest = val
      key_low = key
    end
    if lowest.fscore > val.fscore then
      lowest = val
      key_low = key
    end
  end
  -- tab[key_low] = nil
  table.remove(tab, key_low)
  return lowest
end

---comment
---@param cord blid
---@return { [integer]: { x: integer, y: integer, z: integer } }
function GetNeighbors(cord)
  ---@type { [integer]: {x: integer, y: integer, z: integer } }
  local que = {}
  table.insert(que, { x = cord.x + 1, y = cord.y + 0, z = cord.z + 0, })
  table.insert(que, { x = cord.x - 1, y = cord.y + 0, z = cord.z + 0, })
  table.insert(que, { x = cord.x + 0, y = cord.y + 1, z = cord.z + 0, })
  table.insert(que, { x = cord.x + 0, y = cord.y - 1, z = cord.z + 0, })
  table.insert(que, { x = cord.x + 0, y = cord.y + 0, z = cord.z + 1, })
  table.insert(que, { x = cord.x + 0, y = cord.y + 0, z = cord.z - 1, })
  return que
end

---Manhattan distance
---@return integer
function H_dist(from, to)
  return math.abs(from.x - to.x) + math.abs(from.y - to.y) + math.abs(from.z - to.z)
end

---Euclidean distance
---@return integer
function H_dist_euc(from, to)
  local _x = from.x - to.x
  local _y = from.y - to.y
  local _z = from.z - to.z
  return math.sqrt(_x * _x + _y * _y + _z * _z)
end

Main()
