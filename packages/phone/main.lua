function main()
  rednet.open("back")
  local id = rednet.lookup("cc.tami.swarm.request", "mother")
  ---@cast id number
  local x, y, z = gps.locate()
  rednet.send(id, { x = math.floor(x), y = math.floor(y), z = math.floor(z) })
  print("It was requested!")
end

main()
