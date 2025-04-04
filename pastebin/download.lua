---Get the file name and its extension from the path.
---@param _path string
---@return string
function GetFileInPath(_path)
  while string.find(_path, "/") do
    _path = string.sub(_path, string.find(_path, "/") + 1)
  end
  return _path
end

function GetFolderPath(_path)
  return string.sub(_path, 1, #_path - #GetFileInPath(_path))
end

function DownloadComplete()
  Downloaded = true
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
function DownloadFile(_path, _override, _fileName, _url)
  local url = string.format(_url, _path)
  if _fileName == nil then _fileName = GetFileInPath(_path) end
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
    DownloadComplete()
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

-- Input[1] = Path
-- Input[2] = Override(should it overwrite the file?)
Input = { ... }
if Input[2] ~= nil then
  local override = string.find(Input[2], "true")
  if override then
    Override = true
  else
    Override = false
  end
end

DoLog = settings.get("logDownloads", true)

Downloaded = false

Urls = { "https://computercraft.zomzi.moe/download/%s" }
Link = settings.get("http_optimal_link", -1)

if not (Link == -1) then
  local success = DownloadFile(Input[1], Override, Input[3], Link)
  if not success then
      settings.set("http_optimal_link",-1)
      settings.save(".settings")
  end
else
  for i = 1, #Urls do
    if (DownloadFile(Input[1], Override, Input[3], Urls[i])) then
      settings.set("http_optimal_link", Urls[i])
      settings.save(".settings")
      break
    end
  end
end


--Self update
if not (Downloaded) then
  shell.run("pastebin", "get", "QzYCbZqL", "Tami/temp")
  shell.run("delete", "Tami/download.lua")
  shell.run("rename", "Tami/temp", "Tami/download.lua")
  shell.run("Tami/download.lua", Input[1], Input[2], Input[3], Input[4])
end
