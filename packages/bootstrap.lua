-- [1]: string shell.getRunningProgram() for the original invoker
-- [2]: string filename of [1]
local Input = { ... }

os.loadAPI(Input[1])
download = _G[Input[2]]
-- local download = require "pastebin.download"

local success = download.GetFile("pastebin/download.lua", true, ".tami/bin/download")
if not success then
  print("TPD: Failed to download download.lua")
  return
end
if Input[1] ~= ".tami/bin/download" then
  fs.delete(shell.getRunningProgram())
end

success = download.GetFile("packages/startup.lua",true,"startup")
if not success then
  print("TPD: Failed to download startup.lua")
  return
end

success = download.GetFile("packages/gurl.lua",true,".tami/bin/gurl")
if not success then
  print("TPD: Failed to download startup.lua")
  return
end

fs.delete("temp")
os.reboot()
