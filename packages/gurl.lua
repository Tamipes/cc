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
  print("   del<PACKAGE_NAME>")
  print("     - Updates all packages")
end

-- Lists the packages
function List()
  local lr = LoadLocalRegistry()
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
--- @return boolean
local function downloadFiles(_files)
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
    local lr = LoadLocalRegistry()
    if lr.packages == nil then lr.packages = {} end
    lr.packages[_pname] = Registry.packages[_pname]
    print("Sucessfully installed " .. _pname)
    SaveLocalRegistry(lr)
  else
    print("Failed to install " .. _pname)
  end
end

---Deletes the given package
---@param _pname string
function Delete(_pname)
  local lr = LoadLocalRegistry()
  if lr.packages[_pname] ~= nil then
    package = lr.packages[_pname]
    for key, val in pairs(package.files) do
      fs.delete(val.fs)
    end
    lr.packages[_pname] = nil
    SaveLocalRegistry(lr)
    print("Package successfully deleted!")
  else
    print("Package \"" .. _pname .. "\" not found.")
  end
end

function UpdateAll()
  local lr = LoadLocalRegistry()
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
function LoadLocalRegistry()
  local file = fs.open(".tami/local_registry", "r")
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
function SaveLocalRegistry(_lr)
  if fs.exists(".tami/local_registry") then fs.delete(".tami/local_registry") end
  local file = fs.open(".tami/local_registry", "w")
  ---@cast file ccTweaked.fs.WriteHandle
  file.write(textutils.serialise(_lr))
  file.close()
end

res, err = http.get("https://static.tami.moe/computercraft/packages/registry.lua")
if not res or err ~= nil then
  print("Gurl: Err:  " .. err)
  print("Gurl: failed to fetch registry")
  return
end
---@alias Registry { packages: {[string]: {files: Files}} }

---@alias Files {[string]: {upstream : string, fs: string} }

---@type Registry
Registry = textutils.unserialise(res.readAll() --[[@as string]])


if Input == nil then
  PrintUsage()
elseif Input[1] == "ls" then
  List()
elseif Input[1] == "install" then
  Install(Input[2])
elseif Input[1] == "update" then
  UpdateAll()
elseif Input[1] == "del" then
  Delete(Input[2])
else
  PrintUsage()
end
