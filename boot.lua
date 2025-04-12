shell.run("clear")
local os_semver = "0.1"
print("*nix-os v" .. os_semver)

local success = true
Input = { ... }
if Input[1] ~= nil then
  print("boot: Loading with custom root!")
  success = os.loadAPI(fs.combine(Input[1], ".tami/lib/RootFS"))
  if not success then print("boot: Failed to *load* RootFS(_lib)") end
  RootFS = RootFS.RootFS
  Root = RootFS.new(Input[1])
else
  success = os.loadAPI(".tami/lib/RootFS")
  if not success then print("boot: Failed to *load* RootFS(_lib)") end
  RootFS = RootFS.RootFS
  Root = RootFS.new("/")
end

fs.delete("/temp")
if not os.loadAPI(Root:combine(".tami/bin/download")) then
  print("boot: Failed to *load* download api")
  success = false
end
download.InitSettingsApi()

shell.setPath(shell.path() .. ":" .. Root:combine("/.tami/bin/"))

if Root:exists(".tami/startups/") then
  local files = Root:list(".tami/startups/")
  for i = 1, #files do
    print("boot: Running startup: " .. Root:combine(".tami/startups/", files[i]))
    success = success and shell.run(Root:combine(".tami/startups/", files[i]))
  end
end

if success then
  shell.run("clear")
  print("*nix-os v" .. os_semver)
else
  print("There was an error while booting!")
end
