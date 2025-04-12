shell.run("clear")
print("*nix-os v0.1")

Input = { ... }
if Input[1] ~= nil then
  if not os.loadAPI(fs.combine(Input[1], ".tami/lib/RootFS")) then print("boot: Failed to *load* RootFS(_lib)") end
  RootFS = RootFS.RootFS
  Root = RootFS.new(Input[1])
else
  os.loadAPI(".tami/lib/RootFS")
  RootFS = RootFS.RootFS
  Root = RootFS.new("/")
end

fs.delete("/temp")
if not os.loadAPI(Root:combine(".tami/bin/download")) then print("boot: Failed to *load* download api") end
download.InitSettingsApi()

shell.setPath(shell.path() .. ":" .. Root:combine("/.tami/bin/"))

if Root:exists(".tami/startups/") then
  local files = Root:list(".tami/startups/")
  for i = 1, #files do
    shell.run(Root:combine(".tami/startups/") .. files[i])
  end
end
