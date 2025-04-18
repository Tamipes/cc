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

function RootFS:list(path)
  return fs.list(fs.combine(self.path, path))
end

function RootFS:combine(...)
  local path = self.path
  for _, part in ipairs({ ... }) do
    path = fs.combine(path, part)
  end
  return path
end
