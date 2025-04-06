---@meta

---Get the file name and its extension from the path.
---@param _path string
---@return string
function GetFilenameInPath(_path)
  while string.find(_path, "/") do
    _path = string.sub(_path, string.find(_path, "/") + 1)
  end
  return _path
end

---Check if the url is loadable
---@param _url string
---@return boolean
function IsUrlAvailable(_url)
  ---@diagnostic disable-next-line: unused-local
  local res, err = http.get(_url)
  if res ~= nil and res.getResponseCode() == 200 then
    return true
  end
  return false
end

local function getFolderPath(_path)
  return string.sub(_path, 1, #_path - #GetFilenameInPath(_path))
end

---Tries to download a file from a given path, uses multiple links.
---If it cant find any that work, it returns false.
---@param _path string
---@param _override boolean
---@param _fileName string
---@param _url string
---@return boolean
local function downloadFile(_path, _override, _fileName, _url)
end

--- Downloads a file from the internally defined urls
---@param _path string
---@return string|nil
function GetAsString(_path)
  Urls = { "https://static.tami.moe/computercraft/%s", "https://raw.githubusercontent.com/Tamipes/cc/refs/heads/main/%s" }
  if settings == nil then
    Link = -1
  else
    Link = settings.get("http_optimal_link", -1)
  end

  if Link ~= -1 then
    local request, err = http.get(string.format(Link, _path))
    if request ~= nil and (request.getResponseCode() == 200) then
      return request.readAll() --[[@as string]]
    else
      if DoLog then print("TPD: Failed to download: " .. string.format(Link, _path)) end
      Link = -1
      if settings ~= nil then
        settings.set("http_optimal_link", -1)
        settings.save(".settings")
      end
    end
  end

  for i = 1, #Urls do
    local request, err = http.get(string.format(Urls[i], _path))
    if request ~= nil and (request.getResponseCode() == 200) then
      Link = Urls[i]
      if settings ~= nil then
        settings.set("http_optimal_link", Urls[i])
        settings.save(".settings")
      end
      return request.readAll()
    end
    if DoLog then print("TPD: Failed to download: " .. string.format(Urls[i], _path)) end
  end
  return nil
end

--- Downloads a file from the internally defined urls
---@param _path string
---@param _override boolean
---@param _fileName string
---@return boolean
function GetFile(_path, _override, _fileName)
  if _fileName == nil then _fileName = GetFilenameInPath(_path) end
  local request = GetAsString(_path)
  if request ~= nil then
    if _override and fs.exists(_fileName) then fs.delete(_fileName) end
    if fs.exists(_fileName) then return false end

    local file = fs.open(_fileName, "w")
    ---@cast file ccTweaked.fs.WriteHandle
    file.write(request)
    file.close()

    if DoLog then print('TPD: Downloaded: ' .. _fileName) end
    return true
  end
  return false
end

-- Init settings api, and if it is not present, then download it as well
--- @return boolean
function InitSettingsApi()
  if settings ~= nil then return true end
  local settings_path = "apis/settings"
  local expect_path = "/modules/main/cc/expect.lua"
  local folder_cc = ".tami/cc"
  if fs.exists(string.format("%s/%s", folder_cc, settings_path)) and fs.exists(string.format("%s/%s", folder_cc, expect_path)) then
    return os.loadAPI(string.format("%s/%s", folder_cc, settings_path))
  end
  print("TPD: settings API: Getting the settings.lua API")
  local success = GetFile(string.format("cc_extensions/%s", settings_path),
    false, string.format("%s/%s", folder_cc, settings_path))
  if not success then
    print(success)
    print("TPD: settings API: could not download settings api")
    return false
  end
  success = GetFile(string.format("cc_extensions/%s", expect_path),
    false, string.format("%s/%s", folder_cc, expect_path))
  if not success then
    print("TPD: settings API: could not download expect module")
    return false
  end
  if fs.exists(string.format("%s/%s", folder_cc, settings_path)) and fs.exists(string.format("%s/%s", folder_cc, expect_path)) then
    return os.loadAPI(string.format("%s/%s", folder_cc, settings_path))
  else
    print("TPD: settings API:  Failed to load settings API;(No error during download??))")
    return false
  end
end

-- Input[1]: string = Path
-- Input[2]: bool|nil = Override(should it overwrite the file?)
-- Input[3]: string = filename
-- Input[4]: int = num of retries
local Input = { ... }
if Input[1] == nil then
  return
end
if Input[1] == "update" then
  Input[1] = "pastebin/download.lua"
  Input[2] = "true"
  Input[3] = shell.getRunningProgram()
end
if Input[1] == "bootstrap" then
  if not GetFile("packages/bootstrap.lua", true, "/temp/bootstrap.lua") then
    print("TPD: Could not get bootstrap.lua")
    return
  end

  shell.run("/temp/bootstrap.lua", shell.getRunningProgram(), GetFilenameInPath(shell.getRunningProgram()))
  return
end
if Input[2] ~= nil then
  local override = string.find(Input[2], "true")
  if override then
    Override = true
  else
    Override = false
  end
end
if Input[4] ~= nil then
  if Input[4] > 1 then
    print("TPD: Enough of this chatter!(Exiting, too much retry)")
    return
  end
end


if settings == nil then
  if not InitSettingsApi() then
    print("TPD: Failed to init settings api!")
    return
  end
end
DoLog = settings.get("logDownloads", true)

local successful = GetFile(Input[1], Override, Input[3])

--Self update if not downloading
if not (successful) then
  if IsUrlAvailable("https://pastebin.com") then
    -- make this into this:
    print("TPD: Download failed... updating from pastebin. (Use ctrl+T to terminate the script.)")
    sleep(5)
    shell.run("pastebin", "get", "QzYCbZqL", "temp/download.lua")
    shell.run("delete", ".tami/download.lua")
    shell.run("rename", ".tami/temp", ".tami/download.lua")
    shell.run(".tami/download.lua", ...)
  else
    print("TPD: Download failed... and no pastebin...")
  end
end
