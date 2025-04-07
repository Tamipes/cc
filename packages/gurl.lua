-- local download = require "pastebin.download"
---@alias Registry { packages: {[string]: {files: Files}} }
---@alias Files {[string]: {upstream : string, fs: string} }

local Input = { ... }

function PrintUsage()
  print("gurl <SUBCOMMAND>")
  print("   ls")
  print("     - Lists the available packages")
  print("   install <PACKAGE_NAME>")
  print("     - Installs a package")
  print("   update<PACKAGE_NAME>")
  print("     - Updates all packages")
  print("   del<PACKAGE_NAME>")
  print("     - Updates all packages")
end

-- Lists the packages
function List()
  local lr = LoadLocalDatabase()
  for key, value in pairs(Registry.packages) do
    if lr.packages[key] ~= nil then
      term.setTextColor(colors.green)
      term.write("Installed ")
      term.setTextColor(colors.white)
    else
      term.setTextColor(colors.gray)
      term.write("available ")
      term.setTextColor(colors.white)
    end
    term.write(" - " .. key)
    local x, y = term.getCursorPos()
    term.setCursorPos(1, y + 1)
  end
end

--- Internal function to download the specified files
--- @param _files Files
--- @param _old_files Files|nil
--- @return boolean
local function downloadFiles(_files, _old_files)
  local tempDir = "temp/" .. tostring(math.random(10000, 99999))
  local success = true
  ---@type {[string]: {upstream: string, fs: string}}
  local installed = {}
  for key, value in pairs(_files) do
    success = download.GetFile(value.upstream, true, fs.combine(tempDir, value.fs)) and success
    if success then
      table.insert(installed, value)
    else
      break
    end
  end

  if success then
    if _old_files ~= nil then
      for key, val in pairs(_old_files) do
        fs.delete(val.fs)
      end
    end
    for key, val in pairs(installed) do
      if fs.exists(val.fs) then fs.delete(val.fs) end
      fs.move(fs.combine(tempDir, val.fs), val.fs)
    end
  else
    for key, value in pairs(installed) do
      fs.delete(value.fs)
    end
  end
  fs.delete(tempDir)
  return success
end

---Installs the given package
---@param _pname string
function Install(_pname)
  if Registry.packages[_pname] == nil then
    print("No package named: " .. _pname)
    return
  end
  local success = downloadFiles(Registry.packages[_pname].files)
  if success then
    local lr = LoadLocalDatabase()
    if lr.packages == nil then lr.packages = {} end
    lr.packages[_pname] = Registry.packages[_pname]
    print("Sucessfully installed " .. _pname)
    SaveLocalDatabase(lr)
  else
    print("Failed to install " .. _pname)
  end
end

---Deletes the given package
---@param _pname string
function Delete(_pname)
  local lr = LoadLocalDatabase()
  if lr.packages[_pname] ~= nil then
    package = lr.packages[_pname]
    for key, val in pairs(package.files) do
      fs.delete(val.fs)
    end
    lr.packages[_pname] = nil
    SaveLocalDatabase(lr)
    print("Package successfully deleted!")
  else
    print("Package \"" .. _pname .. "\" not found.")
  end
end

function Upgrade()
  local lr = LoadLocalDatabase()
  for pname, package in pairs(lr.packages) do
    local success = false
    success = downloadFiles(package.files)
    if success then
      print("Updated: " .. pname)
    else
      print("Failed to update: " .. pname)
    end
  end
end

---Loads in the registry
---@return Registry
function LoadLocalDatabase()
  local file = fs.open(".tami/local_database", "r")
  ---@type Registry
  local registry = { packages = {} }
  if file then
    local reg = textutils.unserialise(file.readAll() --[[@as string]])
    if reg ~= nil and reg.packages ~= nil then registry = reg end
    file.close()
  end
  return registry
end

---Loads in the registry
---@param _lr Registry
function SaveLocalDatabase(_lr)
  if fs.exists(".tami/local_database") then fs.delete(".tami/local_database") end
  local file = fs.open(".tami/local_database", "w") --[[@as ccTweaked.fs.WriteHandle]]
  file.write(textutils.serialise(_lr))
  file.close()
end

function UpdateLocalRegistry()
  local str = download.GetAsString("packages/registry.lua")
  if str == nil then
    print("Error updating registry!")
    return false
  end
  Registry = textutils.unserialise(str --[[@as string]])
  if fs.exists(".tami/local_registry") then fs.delete(".tami/local_registry") end
  local file = fs.open(".tami/local_registry", "w") --[[@as ccTweaked.fs.WriteHandle]]
  file.write(str)
  file.close()
  print("Updated the registry!")
  return true
end

if fs.exists(".tami/local_registry") then
  local file = fs.open(".tami/local_registry", "r") --[[@as ccTweaked.fs.ReadHandle]]

  ---@type Registry
  ---@diagnostic disable-next-line: assign-type-mismatch
  Registry = textutils.unserialise(file.readAll() --[[@as string]])
else
  if not UpdateLocalRegistry() then return end
end


if Input == nil then
  PrintUsage()
elseif Input[1] == "ls" then
  List()
elseif Input[1] == "install" then
  Install(Input[2])
elseif Input[1] == "upgrade" then
  Upgrade()
elseif Input[1] == "update" then
  UpdateLocalRegistry()
elseif Input[1] == "del" then
  Delete(Input[2])
else
  PrintUsage()
end
