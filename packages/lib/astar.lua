function Main()
  term.clear()
  local width, height = term.getSize()
  local m = {}
  for x = 1, width do
    m[x][0] = {}
    for z = 1, height do
      m[x][0][z] = { block = "minecraft:air" }
      term.setCursorPos(x, z)
    end
  end
  local event, button, x, y = os.pullEvent("mouse_click")
  ColorPixel(x, y, colors.green)
  local s = { x = x, y = y }
  local event, button, x, y = os.pullEvent("mouse_click")
  local g = { x = x, y = y }
  ColorPixel(x, y, colors.red)

  while true do
    term.setCursorPos(1, 1)
    term.blit("x", "6", "8")
    local event, button, x, y = os.pullEvent("mouse_click")
    if x == 1 and y == 1 then break end
    ColorPixel(x, y, colors.gray)
    m[x][y].block = "minecraft:stone"
  end

  term.setCursorPos(1, 1)
  local node, errnum = Astar(m, s, g)
  if node == false then
    term.setCursorPos(1, height - 1)
    print(errnum .. "Error in calculation!: " .. s.x .. ", " .. s.y)
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
  while curr.prev ~= nil do
    curr = curr.prev
    ColorPixel(curr.x, curr.y, colors.yellow)
  end
end

---@alias bl { block: string, x: integer, y: integer, z: integer }
---@alias blid { block: string, x: integer, y: integer, z: integer, fscore: integer, gscore: integer}

---A* pathfinding algorithm
---comment
---@param m { [integer]: { [integer]: { [integer]: { block: string } } } }
---@param start bl
---@param goal bl
---@return nil
---@return integer | nil
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
    -- term.write("num: "..#openSet.."; "..tostring(current) .. ": " .. current.x .. ", " .. current.y)

    -- sleep(5)
    if current.x == goal.x and current.y == goal.y and current.z == goal.z then return current end
    max = math.max(max, #openSet)
    if m[current.x] == nil or m[current.x][current.y] == nil then
      term.setCursorPos(1, 1)
      print("noooooooooooooooooooooooope")
    else
      if m[current.x][current.y][current.z].block ~= "minecraft:air" then
        ColorPixel(current.x, current.y, colors.gray)
      else
        ColorPixel(current.x, current.y, "0")

        for key, neighbor in pairs(GetNeighbors(current)) do
          local tentative_gscore = current.gscore + 1

          if tentative_gscore < ((gScore[neighbor.x] and gScore[neighbor.x][neighbor.y]) or math.huge) then
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
              ColorPixel(neighbor.x, neighbor.y, "d")
              table.insert(openSet, neighbor)
            end
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
  for x = -1, 1 do
    for y = -1, 1 do
      for z = -1, 1 do
        if x == 0 and y == 0 and z == 0 then else
          table.insert(que, { x = cord.x + x, y = cord.y + y, z = cord.z + z, })
        end
      end
    end
  end
  return que
end

---Manhattan distance
---@return integer
function H_dist(from, to)
  return math.abs(from.x - to.x) + math.abs(from.y - to.y)
end

---Euclidean distance
---@return integer
function H_dist_euc(from, to)
  local _x = from.x - to.x
  local _y = from.y - to.y
  return math.sqrt(_x * _x + _y * _y)
end

Main()
