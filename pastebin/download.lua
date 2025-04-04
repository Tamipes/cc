---Get the file name and its extension from the path.
---@param _path string
---@return string
function getFileInPath(_path)
    while string.find(_path, "/") do
        _path = string.sub(_path, string.find(_path, "/") + 1)
    end
    return _path
end
function getFolderPath(_path)
    return string.sub(_path,1,#_path-#getFileInPath(_path))
end
function downloadComplete()
    downloaded = true
    if fs.exists(".uninstall") then
        file = fs.open(".uninstall","r")
        programs = textutils.unserialise(file.readAll())
    end
end

---Trys to download a file from a given path, uses multiple links.
--- If it cant find any that work, it returns false.
---@param _path string
---@param _override boolean
---@param _fileName string
---@param _url string
---@return boolean
function downloadFile(_path, _override, _fileName,_url)
    url = string.format(_url, _path)
    if _fileName == nil then _fileName = getFileInPath(_path) end
    request ,err = http.get(url)
    if request ~= nil and (request.getResponseCode() == 200) then
        if _override and fs.exists(_fileName) then shell.run("delete", _fileName) end
        file = fs.open(_fileName, "w")
        file.write(request.readAll())
        file.close()

        --What to do if download succeded.
        if doLog then print('Downloaded: '.._fileName) end
        downloadComplete()
        return true
    else
        print(err)
    end
    return false
end



input = {...}
if input[2] ~=nil then
    override = string.find( input[2],"true")
end

doLog = settings.get("logDownloads", true)

downloaded = false

urls = {"https://computercraft.zomzi.moe/download/%s"}
link = settings.get("http_optimal_link", -1)

if not (link == -1)then
    downloadFile(input[1],override,input[3],link)
else
    for i = 1, #urls do
        if (downloadFile(input[1],override,input[3],urls[i])) then
            settings.set("http_optimal_link",urls[i])
            settings.save(".settings")
            break
        end
    end
end


--Self update
if not(downloaded) then
    shell.run("pastebin","get","QzYCbZqL","Tami/temp")
    shell.run("delete","Tami/download.lua")
    shell.run("rename","Tami/temp","Tami/download.lua")
    shell.run("Tami/download.lua",input[1],input[2],input[3],input[4])
end
