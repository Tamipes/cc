-- local download = require "pastebin.download"
local Input = { ... }

function PrintUsage()
  print("gurl <SUBCOMMAND>")
  print("   ls")
  print("     - Lists the available packages")
  print("   install <PACKAGE_NAME>")
  print("     - Installs a package")
  print("   update<PACKAGE_NAME>")
  print("     - Updates all packages")
end

-- Lists the packages
function List()
  local lr = LoadLocalRegistry()
  for key, value in pairs(Registry.packages) do
    if lr.packages[key] ~= nil then
      term.setTextColor(colors.green)
      term.write("Installed   -  ")
      term.setTextColor(colors.white)
    else
      term.setTextColor(colors.gray)
      term.write("unavailable -  ")
      term.setTextColor(colors.white)
    end
    term.write(key)
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y + 1)
  end
end

---Installs the given package
---@param _pname string
function Install(_pname)
  if Registry.packages[_pname] == nil then
    print("No package named: " .. _pname)
    return
  end
  local success = true
  ---@type {[string]: {upstream: string, fs: string}}
  local installed = {}
  for key, value in pairs(Registry.packages[_pname].files) do
    success = download.GetFile(value.upstream, true, value.fs) and success
    if success then
      table.insert(installed, value)
    else
      break
    end
  end

  if success then
    local lr = LoadLocalRegistry()
    if lr.packages == nil then lr.packages = {} end
    lr.packages[_pname] = Registry.packages[_pname]
    print("Sucessfully installed " .. _pname)
    SaveLocalRegistry(lr)
  else
    for key, value in pairs(installed) do
      fs.delete(value.fs)
    end
    print("Failed to install " .. _pname)
  end
end

function UpdateAll()
  local lr = LoadLocalRegistry()
  for pname, package in pairs(lr.packages) do
    local failed = false
    for key, val in pairs(package.files) do
      if not download.GetFile(val.upstream, true, val.fs) then
        print("Failed to update: " .. pname)
        failed = true
        break
      end
    end
    if not failed then print("Updated: "..pname) end
  end
end

---Loads in the registry
---@return Registry
function LoadLocalRegistry()
  local file = fs.open(".tami/local_registry", "r")
  local registry = {}
  if file then
    registry = textutils.unserialise(file.readAll() --[[@as string]])
    if registry == nil then registry = {} end
    file.close()
  end
  return registry
end

---Loads in the registry
---@param _lr Registry
function SaveLocalRegistry(_lr)
  if fs.exists(".tami/local_registry") then fs.delete(".tami/local_registry") end
  local file = fs.open(".tami/local_registry", "w")
  file.write(textutils.serialise(_lr))
  file.close()
end

res, err = http.get("https://static.tami.moe/computercraft/packages/registry.lua")
if not res or err ~= nil then
  print("Gurl: Err:  " .. err)
  print("Gurl: failed to fetch registry")
  return
end
---@class Registry
---@field packages {[string]: {files: {[string]: {upstream : string, fs: string} }}}
Registry = textutils.unserialise(res.readAll() --[[@as string]])


if Input == nil then
  PrintUsage()
elseif Input[1] == "ls" then
  List()
elseif Input[1] == "install" then
  Install(Input[2])
elseif Input[1] == "update" then
  UpdateAll()
else
  PrintUsage()
end
