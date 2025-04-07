local function main()
  local monitor = peripheral.wrap("monitor_0")
  ---@cast monitor ccTweaked.peripherals.Monitor

  monitor.setTextColor(colors.white)
  monitor.setBackgroundColor(colors.black)
  monitor.clear()

  me_system = peripheral.wrap("mekanism_machine_1")

  DrawLineVertical(monitor, 24, 1, 19)
  while true do
    local num = drawReactors(monitor)
    num = num + (me_system.getMaxEnergyStored() / 2)
    monitor.setTextColor(colors.green)
    monitor.setBackgroundColor(colors.black)
    monitor.setCursorPos(30, 10)
    monitor.write(tostring(num))
    sleep(0.1)
  end
end

---@param _term ccTweaked.peripherals.Monitor
function drawReactors(_term)
  local start_x = 25
  local reactors = { "BigReactors-Turbine_1", "BigReactors-Turbine_2" }
  local generated = 0
  for i, reactor_name in pairs(reactors) do
    local reactor = peripheral.wrap(reactor_name)
    ---@cast reactor {}

    ---@diagnostic disable-next-line: undefined-field
    local p = reactor.getEnergyStored() / 1000000
    p = p + 0.02
    ---@diagnostic disable-next-line: undefined-field
    local produced = reactor.getEnergyProducedLastTick()
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
