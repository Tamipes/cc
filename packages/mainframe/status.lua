local function main()
  ---@type ccTweaked.peripherals.Monitor
  Monitor = peripheral.wrap("monitor_0") --[[@as ccTweaked.peripherals.Monitor]]

  Monitor.setTextColor(colors.white)
  Monitor.setBackgroundColor(colors.black)
  Monitor.clear()


  Monitor.setTextColor(colors.pink)
  Monitor.setBackgroundColor(colors.pink)
  DrawLineVertical(Monitor, 25, 1, 19)
  M_width, M_height = Monitor.getSize()
  DebugWindow = window.create(Monitor, 1, 1, 24, M_height, true)

  local mod = getRednetSide()
  if mod == nil then return false end
  rednet.open(mod)
  parallel.waitForAny(updateScreen, updateData, BigTerminal, Hosting)
  rednet.unhost("cc.tami.log")
  print("Info: only *one* of them has failed!")
end

function BigTerminal()
  DebugWindow.setTextColor(colors.white)
  DebugWindow.setBackgroundColor(colors.black)
  Log("Status running! \n\t(Day: " .. os.day() .. ")")
  while true do
    sleep(999)
  end
end

---comment
---@return string | nil
function getRednetSide()
  rednet.host("cc.tami.log", "status")
  local sides = { "top", "bottom", "left", "right", "front", "back" }
  for _, side in pairs(sides) do
    t = peripheral.wrap(side)
    if t ~= nil and t.isWireless ~= nil and not t.isWireless() then return side end
  end
  return nil
end

---comment
---@param s string
function Log(s)
  local x, y = DebugWindow.getCursorPos()
  if y > M_height then
    DebugWindow.scroll(1)
    y = y - 1
    DebugWindow.setCursorPos(1, y)
  end
  DebugWindow.write("[" .. textutils.formatTime(os.time(), true) .. "]: " .. s)
  DebugWindow.setCursorPos(1, y + 1)
end

function Hosting()
  while true do
    local sender, msg, prot = rednet.receive("cc.tami.log")
    if msg ~= nil then
      Log(msg.msg)
    end
  end
end

function updateScreen()
  while true do
    drawReactors(Monitor)
    Monitor.setTextColor(colors.green)
    Monitor.setBackgroundColor(colors.black)
    Monitor.setCursorPos(30, 10)
    Monitor.write(tostring(Data.sum))
    sleep(0.1)
  end
end

function updateData()
  while true do
    local reactors = { "BigReactors-Turbine_1", "BigReactors-Turbine_2" }
    local ener_sum = 0
    for i, reactor_name in pairs(reactors) do
      local reactor = peripheral.wrap(reactor_name)
      ---@cast reactor table

      ---@diagnostic disable-next-line: undefined-field
      Data.reactors[i] = {}
      Data.reactors[i].energyStored = reactor.getEnergyStored()
      ---@diagnostic disable-next-line: undefined-field
      Data.reactors[i].energyProducedLastTick = reactor.getEnergyProducedLastTick()
      ener_sum = ener_sum + Data.reactors[i].energyProducedLastTick
    end

    Data.sum = ener_sum - Data.me_energy
    sleep(0.1)
  end
end

-- function sloowDataUpdate()
--   while true do
--     local me_system = peripheral.wrap("mekanism_machine_1")
--     ---@cast me_system table

--     ---@diagnostic disable-next-line: undefined-field
--     Data.me_energy = me_system.getMaxEnergyStored() / 2
--     local ener_sum = 0
--     for i, val in pairs(Data.reactors) do
--       ener_sum = ener_sum + val.energyProducedLastTick
--     end
--     ener_sum = ener_sum - Data.me_energy
--     Data.sum = ener_sum
--     sleep(5)
--   end
-- end

Data = { reactors = {}, me_energy = 0, sum = 0 }
---@param _term ccTweaked.peripherals.Monitor
---@return integer
function drawReactors(_term)
  local start_x = 25
  local generated = 0
  if Data.reactors == nil then return 0 end
  for i, val in pairs(Data.reactors) do
    local p = val.energyStored / 1000000
    p = p + 0.02
    local produced = val.energyProducedLastTick
    local generating = math.floor(produced / 1000)
    generated = produced + generated
    drawReactor(_term, start_x + 4 * i, 1, p, tostring(generating))
  end
  return generated
end

FillText = "x"
--- Draw a box on the terminal
---@param _term ccTweaked.peripherals.Monitor
---@param _x integer
---@param _y integer
---@param _width integer
---@param _height integer
function DrawBox(_term, _x, _y, _width, _height)
  _term.setCursorPos(_x, _y)
  for y = _y, _y + _height - 1 do
    _term.setCursorPos(_x, y)
    for x = _x, _x + _width - 1 do
      _term.write(FillText)
    end
  end
end

--- Draw a line on the terminal
---@param _term ccTweaked.peripherals.Monitor
---@param _x integer
---@param _y integer
---@param _length integer
function DrawLineHorizontal(_term, _x, _y, _length)
  _term.setCursorPos(_x, _y)
  for x = _x, _x + _length - 1 do
    _term.write(FillText)
  end
end

--- Draw a line on the terminal
---@param _term ccTweaked.peripherals.Monitor
---@param _x integer
---@param _y integer
---@param _length integer
function DrawLineVertical(_term, _x, _y, _length)
  _term.setCursorPos(_x, _y)
  for y = _y, _y + _length - 1 do
    _term.setCursorPos(_x, y)
    _term.write(FillText)
  end
end

--- reactor illustration
---@param _term ccTweaked.peripherals.Monitor
---@param _x integer
---@param _y integer
---@param _p integer
---@param _gen string
function drawReactor(_term, _x, _y, _p, _gen)
  _term.setTextColor(colors.gray)
  _term.setBackgroundColor(colors.gray)
  DrawBox(_term, _x, _y, 3, 5)
  FillText = "x"
  if _p > 0.9 then
    _term.setTextColor(colors.green)
    _term.setBackgroundColor(colors.green)
  elseif _p > 0.5 then
    _term.setTextColor(colors.orange)
    _term.setBackgroundColor(colors.orange)
  else
    _term.setTextColor(colors.red)
    _term.setBackgroundColor(colors.red)
  end
  DrawLineVertical(_term, _x + 1, _y, 4 * _p)
  FillText = "x"
  -- term.setTextColor(colors.white)
  -- term.setBackgroundColor(colors.black)
  -- print(_gen)
  if _gen ~= 0 then
    _term.setCursorPos(_x, _y + 5)
    _term.setTextColor(colors.white)
    _term.setBackgroundColor(colors.black)
    _term.write(_gen .. "k")
  else
    _term.setCursorPos(_x, _y + 5)
    _term.setTextColor(colors.red)
    _term.setBackgroundColor(colors.red)
    _term.write("---")
  end
end

main()
