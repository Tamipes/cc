shell.run("clear")
print("*nix-os v0.1")

if not os.loadAPI(".tami/bin/download") then print("startup: Failed to *load* download api") end
download.InitSettingsApi()

shell.setPath(shell.path() .. ":.tami/bin/")

if fs.exists(".tami/startups/") then
  local files = fs.list(".tami/startups/")
  for i = 1 ,#files do
    shell.run(files[i])
  end
end
