if (not fs.exists("Tami/download.lua")) then
    shell.run("pastebin","get","QzYCbZqL","Tami/download.lua")
end

shell.run("Tami/download.lua",'diamonds/startup.lua', "true")
shell.run("Tami/download.lua",'diamonds/diamonds.lua',"true")

settings.set("motd.enable", false)
settings.save()
print("---------------------------------------")
shell.run("diamonds.lua")
