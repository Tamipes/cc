if not fs.exists("Tami/download.lua")then
    shell.run("pastebin","get","QzYCbZqL","Tami/download.lua")
end

shell.run("download",'database/startup.lua', "true")
shell.run("download",'database/database.lua',"true")

settings.set("motd.enable", false)
settings.save()
print("---------------------------------------")
shell.run("database.lua")
