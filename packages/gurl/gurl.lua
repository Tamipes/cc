-- local download = require "pastebin.download"
---@alias Registry { packages: {[string]: Package} }
---@alias Package  {files: Files, dependencies: [string]}
---@alias Files {[string]: {upstream : string, fs: string} }

local Input = { ... }

function PrintUsage()
  print("gurl <SUBCOMMAND>")
  print("   ls")
  print("     - Lists the available packages")
  print("   install <PACKAGE_NAME>")
  print("     - Installs a package")
  print("   update")
  print("     - Updates the local regisgtry")
  print("   upgrade <PACKAGE_NAME>")
  print("     - Upgrades a package")
  print("     - If no package name given, updates all")
  print("   del <PACKAGE_NAME>")
  print("     - Deletes a package")
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
    print()
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
  local install_temp = {}
  for fname, file in pairs(_files) do
    success = download.GetFile(file.upstream, true, fs.combine(tempDir, file.fs)) and success
    if success then
      table.insert(install_temp, file)
    else
      break
    end
  end

  if success then
    -- Delete the old package files; These may differ from the new ones, if the package definition changed
    if _old_files ~= nil then
      for key, val in pairs(_old_files) do
        Root:delete(val.fs)
      end
    end
    -- Install the files from the temp dir to the actual definitions
    for key, val in pairs(install_temp) do
      if Root:exists(val.fs) then Root:delete(val.fs) end
      fs.move(fs.combine(tempDir, val.fs), Root:combine(val.fs))
    end
  else
    for key, value in pairs(install_temp) do
      Root:delete(value.fs)
    end
  end
  fs.delete(tempDir)
  return success
end

--- Internal function. Installs the deps for _pname
---@param _pname string
---@return boolean
function InstallDeps(_pname)
  local package = Registry.packages[_pname]
  if package.dependencies ~= nil then
    for i = 1, #package.dependencies do
      if not Install(package.dependencies[i]) then
        term.write("Failed to resolve dependency for: ")
        term.setTextColor(colors.red)
        print(_pname)
        term.setTextColor(colors.white)
        return false
      end
    end
  end
  return true
end

---Installs the given package
---@param _pname string
---@return boolean
function Install(_pname)
  ---@type Package
  local package = Registry.packages[_pname]
  if package == nil then
    printPackageNotFound(_pname)
    return false
  end

  local success = InstallDeps(_pname)
  if not success then return false end

  success = downloadFiles(Registry.packages[_pname].files)
  if success then
    local lr = LoadLocalDatabase()
    if lr.packages == nil then lr.packages = {} end
    lr.packages[_pname] = Registry.packages[_pname]

    term.write("Sucessfully installed: ")
    term.setTextColor(colors.green)
    print(_pname)
    term.setTextColor(colors.white)


    if package.files.startup ~= nil then
      term.setTextColor(colors.lightGray)
      print("Running startup script: ")
      term.setTextColor(colors.gray)

      shell.run(Root:combine(package.files.startup.fs))

      term.setTextColor(colors.green)
      print("Done!")
      term.setTextColor(colors.white)
    end
    SaveLocalDatabase(lr)
    return true
  else
    term.setTextColor(colors.red)
    print("Failed to install: " .. _pname)
    term.setTextColor(colors.white)
    return false
  end
end

---Deletes the given package
---@param _pname string
---@return boolean
function Delete(_pname)
  local ldb = LoadLocalDatabase()
  local package = ldb.packages[_pname]
  if package == nil then
    printPackageNotFound(_pname)
    return false
  end
  ---@cast package Package

  local deps = {}
  for pname, pack in pairs(ldb.packages) do
    if pack.dependencies ~= nil then
      for i = 1, #pack.dependencies do
        if pack.dependencies[i] == _pname then table.insert(deps, pname) end
      end
    end
  end

  if #deps ~= 0 then
    print("This package cannot be deleted, cuz it has dependents: ")
    for i = 1, #deps do
      print("  - " .. deps[i])
    end
    return false
  end

  for key, val in pairs(package.files) do
    Root:delete(val.fs)
  end
  ldb.packages[_pname] = nil
  SaveLocalDatabase(ldb)
  print("Package successfully deleted!")
  return true
end

function UpgradeAll()
  local ldb = LoadLocalDatabase()
  for pname, package in pairs(ldb.packages) do
    local success = Upgrade(pname)
    if not success then return false end
  end
end

function Upgrade(_pname)
  local success = false
  local ldb = LoadLocalDatabase()
  local package = ldb.packages[_pname]
  if package == nil then
    printPackageNotFound(_pname)
    return false
  end

  success = InstallDeps(_pname)
  if not success then
    term.write("Failed to upgrade: ")
    term.setTextColor(colors.red)
    print(_pname)
    term.setTextColor(colors.white)
    return false
  end

  success = downloadFiles(Registry.packages[_pname].files, package.files)
  if success then
    term.write("Upgraded: ")
    term.setTextColor(colors.green)
    print(_pname)
    term.setTextColor(colors.white)
    ldb.packages[_pname] = Registry.packages[_pname]
    return true
  else
    term.write("Failed to upgrade: ")
    term.setTextColor(colors.red)
    print(_pname)
    term.setTextColor(colors.white)
    return false
  end
end

---Loads in the registry
---@return Registry
function LoadLocalDatabase()
  local file = Root:open(".tami/local_database", "r")
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
  if Root:exists(".tami/local_database") then Root:delete(".tami/local_database") end
  local file = Root:open(".tami/local_database", "w") --[[@as ccTweaked.fs.WriteHandle]]
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
  if Root:exists(".tami/local_registry") then Root:delete(".tami/local_registry") end
  local file = Root:open(".tami/local_registry", "w") --[[@as ccTweaked.fs.WriteHandle]]
  file.write(str)
  file.close()
  print("Updated the registry!")
  return true
end

function printPackageNotFound(_pname)
  term.write("No package named: ")
  term.setTextColor(colors.red)
  term.write(_pname)
  term.setTextColor(colors.white)
  print()
end

for i = 1, #Input do
  if Input[i] == "-r" or Input[i] == "--root" then
    Root = RootFS.new(Input[i + 1])
    table.remove(Input, i)
    table.remove(Input, i)
  end
end
if Root == nil then
  Root = RootFS.new("/")
end

if Root:exists(".tami/local_registry") then
  local file = Root:open(".tami/local_registry", "r") --[[@as ccTweaked.fs.ReadHandle]]

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
  if Input[2] ~= nil then
    Upgrade(Input[2])
  else
    UpgradeAll()
  end
elseif Input[1] == "update" then
  UpdateLocalRegistry()
elseif Input[1] == "del" then
  Delete(Input[2])
else
  PrintUsage()
end
Root = nil
