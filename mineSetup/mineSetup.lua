xCoord = 10
yCoord = 10
zCoord = 189

yTravel = 50

xHome = 9
yHome = 10
zHome = 190

orientation = 1
orientations = {"north", "east", "south", "west"}

zDiff = {-1, 0, 1, 0}
xDiff = {0, 1, 0, -1}

mineIgnoreList = {"computercraft:turtle","minecraft:stone", "minecraft:gravel", "minecraft:dirt","minecraft:lava","minecraft:flowing_lava","minecraft:water","minecraft:flowing_water","minecraft:torch","minecraft:bedrock","minecraft:cobblestone","minecraft:grass",
"computercraft:peripheral","minecraft:chest","minecraft:obsidian","minecraft:stone_stairs","minecraft:diorite","minecraft:andesite","minecraft:granite","minecraft:wall_torch"}

returning = false

function left()
	orientation = orientation - 1
	orientation = (orientation - 1) % 4
	orientation = orientation + 1
	turtle.turnLeft()
end
function right()
	orientation = orientation - 1
	orientation = (orientation + 1) % 4
	orientation = orientation + 1
	turtle.turnRight()
end
function moveForward()
	FullCheck()
	xCoord = xCoord + xDiff[orientation]
	zCoord = zCoord + zDiff[orientation]
	turtle.dig()
	moved = false
	while not(moved) do
		if turtle.detect() then
			turtle.dig()
		end
		moved = turtle.forward()
	end
end
function moveBack()
	FullCheck()
	xCoord = xCoord - xDiff[orientation]
	zCoord = zCoord - zDiff[orientation]
	moved = false
	moved = turtle.back()
	if not moved then
		print("Could not move back, skipping move.")
	end
end
function moveDown()
	FullCheck()
	yCoord = yCoord - 1
	
	turtle.digDown()
	moved = false
	while not(moved) do
		moved = turtle.down()
	end
end
function moveUp()
	FullCheck()
	yCoord = yCoord + 1
	
	turtle.digUp()
	moved = false
	while not(moved) do
		moved = turtle.up()
	end
end
function look(dir)
	while dir ~= orientations[orientation] do
		right()
	end
end

function invFull()
	full = turtle.getItemCount(14) > 0
	turtle.select(1)
	return full
end
function returnItems()
	returning = true
	local xReturn = xCoord
	local yReturn = yCoord
	local zReturn = zCoord
	
	local orientationReturn = orientation
	
	goto(xHome,yHome,zHome)
	goto(xHome,yHome,zHome)
	look("south")
	for i=1,14 do
		turtle.select(i)
		turtle.drop()
	end
	returning=false
	goto(xReturn,yHome,zReturn)
	goto(xReturn,yReturn,zReturn)
	look(orientations[orientationReturn])
end
function fuel(f)
	if turtle.getFuelLevel() < f then
        turtle.select(16)
		turtle.refuel(1)
    end
	turtle.select(1)
end
function FullCheck()
	
	if invFull() and not returning then
		returnItems()
	end
	fuel(60)
end

function goto(xTarget, yTarget, zTarget)
	while yTarget > yCoord do
		moveUp()
	end
	
	while yTarget < yCoord do
		moveDown()
	end
	
	if xTarget < xCoord then
		look("west")
		while xTarget < xCoord do
			moveForward()
		end
	end
	
	if xTarget > xCoord then
		look("east")
		while xTarget > xCoord do
			moveForward()
		end
	end
	
	if zTarget < zCoord then
		look("north")
		while zTarget < zCoord do
			moveForward()
		end
	end
	
	if zTarget > zCoord then
		look("south")
		while zTarget > zCoord do
			moveForward()
		end
	end

end

function saveHome()
	xHome = xCoord
	yHome = yCoord
	zHome = zCoord
end

function saveRareSettings()
	settings.set("leftSide",leftSide)
	settings.set("sideBranchId",sideBranchId)
	settings.set("mainBranchLength", mainBranchLength)
	settings.save(".settings")
end

function forwardThreeTall()
	moveForward()
	turtle.digUp()
	turtle.digDown()
end
function tunnel(x)
	for i = 1, lastTunnelLength do
		moveForward()
	end
	for i=1+lastTunnelLength,x do
		moveForward()
		moveDown()
		inspectDown()
		inspectSides()
		moveUp()
		inspectSides()
		inspectUp()
		if invFull() then
			returnItems()
		end
		--save current tunnel lenght if it is destoroyed it can get back there without mining aimlessly
		settings.set("lastTunnelLength",i)
		settings.save(".settings")
	end
	settings.set("lastTunnelLength",0)
	lastTunnelLength = 0
	settings.save(".settings")
end
function makeBranch(x)
	right()
	forwardThreeTall()
	left()
	for i=0,x do
		--right end
		forwardThreeTall()
		left()
		forwardThreeTall()
		forwardThreeTall()
		right()
		--left end
		forwardThreeTall()
		right()
		forwardThreeTall()
		forwardThreeTall()
		left()
	end
end

function decisiveLeft()
	if leftSide then
		left()
	else
		right()
	end
end
function decisiveRight()
	if leftSide then
		right()
	else
		left()
	end
end


function endOfTest()
	print("End of testing. Freezing program.")
	while true do
		
	end
end
