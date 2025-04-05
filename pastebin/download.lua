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

local function downloadComplete()
  if fs.exists(".uninstall") then
    local file = fs.open(".uninstall", "r")
    ---@diagnostic disable-next-line: param-type-mismatch, need-check-nil
    Programs = textutils.unserialise(file.readAll())
  end
end

---Tries to download a file from a given path, uses multiple links.
---If it cant find any that work, it returns false.
---@param _path string
---@param _override boolean
---@param _fileName string
---@param _url string
---@return boolean
local function downloadFile(_path, _override, _fileName, _url)
  local url = string.format(_url, _path)
  if _fileName == nil then _fileName = GetFilenameInPath(_path) end
  local request, err = http.get(url)
  if request ~= nil and (request.getResponseCode() == 200) then
    if _override and fs.exists(_fileName) then shell.run("delete", _fileName) end
    local file = fs.open(_fileName, "w")
    ---@diagnostic disable-next-line: need-check-nil
    file.write(request.readAll())
    ---@diagnostic disable-next-line: need-check-nil
    file.close()

    --What to do if download succeded.
    if DoLog then print('TPD: Downloaded: ' .. _fileName) end
    -- downloadComplete()
    return true
  else
    write("TPD: Error during request to: ")
    write(url)
    write("\n    ")
    write(err)
    write("\n")
  end
  return false
end

--- Downloads a file from the internally given urls
---@param _path string
---@param _override boolean
---@param _fileName string
---@return boolean
function GetFile(_path, _override, _fileName)
  local downloaded = false

  if settings == nil then
    Link = -1
  else
    Link = settings.get("http_optimal_link", -1)
  end

  if not (Link == -1) then
    downloaded = downloadFile(_path, _override, _fileName, Link)
    if not downloaded then
      Link = -1
      if settings ~= nil then
        settings.set("http_optimal_link", -1)
        settings.save(".settings")
      end
    else
      return true
    end
  end

  if not (downloaded) then
    for i = 1, #Urls do
      if (downloadFile(_path, _override, _fileName, Urls[i])) then
        downloaded = true
        Link = Urls[i]
        if settings ~= nil then
          settings.set("http_optimal_link", Urls[i])
          settings.save(".settings")
        end
        break
      end
    end
  end
  return downloaded
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

Urls = { "https://static.tami.moe/computercraft/%s", "https://raw.githubusercontent.com/Tamipes/cc/refs/heads/main/%s" }

local successful = GetFile(Input[1], Override, Input[3])

--Self update if not downloading
if not (successful) then
  if IsUrlAvailable("https://pastebin.com") then
    print("TPD: Download failed... updating from pastebin. (Use ctrl+T to terminate the script.)")
    sleep(5)
    shell.run("pastebin", "get", "QzYCbZqL", "Tami/temp")
    shell.run("delete", "Tami/download.lua")
    shell.run("rename", "Tami/temp", "Tami/download.lua")
    shell.run("Tami/download.lua", Input[1], Input[2], Input[3], Input[4])
  else
    print("TPD: Download failed... and no pastebin...")
  end
end
