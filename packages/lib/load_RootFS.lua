if RootFS ~= nil then
  os.unloadAPI("RootFS")
end
os.loadAPI(".tami/lib/RootFS")

if RootFS.new == nil then
  RootFS = RootFS.RootFS
end
