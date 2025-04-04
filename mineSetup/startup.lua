fileName = "mineSetup"

if (not fs.exists("Tami/download.lua")) then
    shell.run("pastebin","get","QzYCbZqL","Tami/download.lua")
end

shell.run("Tami/download.lua",fileName..'/startup.lua', "true")
shell.run("Tami/download.lua",fileName.."/"..fileName..".lua","true")

settings.set("motd.enable", false)
settings.save()
print("---------------------------------------")
shell.run(fileName..".lua")