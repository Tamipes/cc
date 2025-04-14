DB_loc = "map_database.db"
DB_changed = false

local function main()
  local mod = getRednetSide()
  if mod == nil then
    print("Error with finding side with wireless modems")
  end
  ---@cast mod string
  rednet.open(mod)
  loadDataBase()
  parallel.waitForAny(handleUploads, DBSaveService, handleRequest, handleJoin)
end

function loadDataBase()
  local file = fs.open(DB_loc, "r")
  if file ~= nil then
    ---@type {map: { [integer]: { [integer]: { [integer]: { block: string } } } } }
    ---@diagnostic disable-next-line: assign-type-mismatch
    DB = textutils.unserialise(file.readAll() --[[@as string]])
  else
  end
end

function handleJoin()
  rednet.host("cc.tami.swarm.join", "mother")
  while true do
    local sender_id, msg, prot = rednet.receive("cc.tami.swarm.join")
    if msg ~= nil then
      table.insert(DB.turtles, msg)
    end
  end
end

function handleUploads()
  rednet.host("cc.tami.swarm.upload", "mother")
  while true do
    local sender_id, msg, prot = rednet.receive("cc.tami.swarm.upload")
    if msg ~= nil and msg.x ~= nil and msg.y ~= nil and msg.z ~= nil and msg.block ~= nil then
      if DB.map[msg.x] == nil then DB.map[msg.x] = {} end
      if DB.map[msg.x][msg.y] == nil then DB.map[msg.x][msg.y] = {} end
      DB.map[msg.x][msg.y][msg.z] = { block = msg.block }
      DB_changed = true
    end
  end
end

function handleRequest()
  rednet.host("cc.tami.swarm.request", "mother")
  while true do
    local sender_id, msg, prot = rednet.receive("cc.tami.swarm.request")
    if msg ~= nil and msg.x ~= nil and msg.y ~= nil and msg.z ~= nil then
      ---@cast msg { x: integer, y: integer, z: integer }
      local node = Astar(DB.map, DB.turtles[1], msg)
      local path = {}
      if node == nil or not node then print("Error with request") end
      while node.prev ~= nil do
        node = node.prev
        table.insert(path, node)
      end

      local turt = nil
      for k, v in pairs(DB.turtles) do
        turt = v
        if not v.using then break end
      end
      if turt ~= nil then
        rednet.send(turt.id, path, "cc.tami.swarm.job")
        print("Job sent to turtle!")
      else
        print("No free turtle")
      end
    end
  end
end

function DBSaveService()
  while true do
    if DB_changed then
      DB_changed = false
      saveDB()
    end
    sleep(5)
  end
end

function saveDB()
  if fs.exists(DB_loc) then fs.delete(DB_loc) end
  local file = fs.open(DB_loc, "w")
  ---@cast file ccTweaked.fs.WriteHandle
  file.write(textutils.serialise(DB))
  file.close()
end

function getRednetSide()
  rednet.host("cc.tami.log", "status")
  local sides = { "top", "bottom", "left", "right", "front", "back" }
  for _, side in pairs(sides) do
    t = peripheral.wrap(side)
    if t ~= nil and t.isWireless ~= nil and t.isWireless() then return side end
  end
  return nil
end

main()
