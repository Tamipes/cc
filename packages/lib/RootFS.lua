RootFS = {}
RootFS.__index = RootFS

function RootFS.new(path)
  local self = setmetatable({}, RootFS)
  self.path = path
  return self
end

function RootFS:exists(path)
  return fs.exists(fs.combine(self.path, path))
end

function RootFS:delete(path)
  return fs.delete(fs.combine(self.path, path))
end

function RootFS:open(path, mode)
  return fs.open(fs.combine(self.path, path), mode)
end

function RootFS:combine(path)
  return fs.combine(self.path, path)
end
