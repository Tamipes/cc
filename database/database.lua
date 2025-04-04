xCoord = -168
yCoord = 64
zCoord = 588

yTravel = 50

xHome = -167
yHome = 64
zHome = 588

orientation = 4
orientations = {"north", "east", "south", "west"}

zDiff = {-1, 0, 1, 0}
xDiff = {0, 1, 0, -1}

returning = false

--Move functions
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
--Inventory functions
function invFull()
	full = turtle.getItemCount(14) > 0
	return full
end
function returnItems()
	returning = true
	local xReturn = xCoord
	local yReturn = yCoord
	local zReturn = zCoord
	
	local orientationReturn = orientation
	
	goto(xHome,yHome,zHome)
	goto(xHome,yHome+2,zHome)
	look("north")
	for i=1,14 do
		turtle.select(i)
		turtle.drop()
	end
	returning=false
	goto(xReturn,yHome,zReturn)
	goto(xReturn,yReturn,zReturn)
	look(orientations[orientationReturn])
end
function fuel(f,till)
	local sel = turtle.getSelectedSlot()
	if turtle.getFuelLevel() < f then
        turtle.select(16)
		turtle.refuel(1)
    end
	turtle.select(sel)
end
function FullCheck()
	fuel(60,600)
end
--Goto functions
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
function gotoOffset(xOffset, yOffset)
	xT = xHome-1
	yT = yHome+(yOffset-1)
	zT = zHome-(xOffset-1)
	while yT > yCoord do
		moveUp()
	end
	
	while yT < yCoord do
		moveDown()
	end
	
	if xT < xCoord then
		look("west")
		while xT < xCoord do
			moveForward()
		end
	end
	
	if xT > xCoord then
		look("east")
		while xT > xCoord do
			moveForward()
		end
	end
	
	if zT < zCoord then
		look("north")
		while zT < zCoord do
			moveForward()
		end
	end
	
	if zT > zCoord then
		look("south")
		while zT > zCoord do
			moveForward()
		end
	end
	look("west")
end
function saveHome()
	xHome = xCoord
	yHome = yCoord
	zHome = zCoord
end

--Settings load and save plus ERROR message
function saveRareSettings()
	settings.set("leftSide",leftSide)
	settings.set("sideBranchId",sideBranchId)
	settings.set("mainBranchLength", mainBranchLength)
	settings.save(".settings")
end
---Shows a message and stops the computer.
---@param msg string The message to output.
function showErrorMessage(msg)
	print("An error has occured with this message: "..msg)
	os.sleep(4200)
end


--Table save functions here
function saveTable(table,name)
	local file = fs.open(name,"w")
	file.write(textutils.serialise(table))
	file.close()
end
function loadTable(name)
	if not (fs.exists(name)) then
		print(string.format("Could not load table: %s",name))
		return {}
	end
	local file = fs.open(name,"r")
	local data = file.readAll()
	file.close()
	return textutils.unserialise(data)
end

function load()
	return loadTable("items.txt")
end
function save()
		saveTable(itemsX,"items.txt")
end


--Database functions from here

---Adds a item to the Database in a new slot. ONLY DATABASE
---@param item table Has to be database ready. If not use writeItem.
function addNewItem(item)
	if #itemsX == 0 then
		table.insert(itemsX,{item})
		return
	end
	for i=1 ,#itemsX do
		if #itemsX[i] < (maxY) then
			table.insert(itemsX[i],item)
		else
			if (i == #itemsX) then
				if i == (maxX) then
					showErrorMessage("Max slot reached with y and the x axis.")
				else
					table.insert(itemsX,{item})
				end
			else
				table.insert(itemsX,{item})
			end
			--move to next x
		end
	end
end
function findInDatabase(_itemName)
	for _x=1 ,#itemsX do
		for _y=1 ,#itemsX[_x] do
			if not (string.find(tostring( itemsX[_x][_y].name),tostring(_itemName))== nil) then
				return {x = _x,y = _y,returnVal = true}
			end
		end
	end
	return {x = 0,y = 0,returnVal = false}
end
function findInDatabaseOpenSlot(_itemName)
	for _x=1 ,#itemsX do
		for _y=1 ,#itemsX[_x] do
			if not (string.find(tostring( itemsX[_x][_y].name),tostring(_itemName))== nil) then
				if itemsX[_x][_y].quantity < 3000 then
					return {x = _x,y = _y,returnVal = true}
				end
			end
		end
	end
	return {x = 0,y = 0,returnVal = false}
end
function findInDatabaseWithItem(_itemName)
	for _x=1 ,#itemsX do
		for _y=1 ,#itemsX[_x] do
			if not (string.find(tostring( itemsX[_x][_y].name),tostring(_itemName))== nil) then
				if itemsX[_x][_y].quantity > 0 then
					return {x = _x,y = _y,returnVal = true}
				end
			end
		end
	end
	return {x = 0,y = 0,returnVal = false}
end
function countAllItemsInDatabase(_itemName)
	local itemCount = 0
	for _x=1 ,#itemsX do
		for _y=1 ,#itemsX[_x] do
			if not (string.find(tostring( itemsX[_x][_y].name),tostring(_itemName))== nil) then
				itemCount = itemCount+ itemsX[_x][_y].quantity
			end
		end
	end
	return itemCount
end

function writeItem(item)
	return (item.name.." db:"..item.quantity)
end
function newItemCreation(_name,_quantity)
	local newItem = {name = _name,quantity = _quantity}
	return newItem
end
function addItemToDatabase(itemName,quantity)
	local data = findInDatabase(itemName)
	--print(data.returnVal)
	if data.returnVal then
		--term.write("x: "..data.x..",y: "..data.y.." ")
		--print(itemsX[data.x][data.y].quantity < 3400)
		--print("is already in database \""..itemName.."\" found: \""..itemsX[data.x][data.y].name.."\"")
		
		local secData = findInDatabaseOpenSlot(itemName)
		if secData.returnVal then
			itemsX[secData.x][secData.y].quantity = itemsX[secData.x][secData.y].quantity+quantity
			gotoOffset(secData.x,secData.y)
			turtle.drop()
		else
			gotoOffset(2,1)
			turtle.dropDown()
			if countAllItemsInDatabase("ironchest:iron_chest") < 1 then
				craftItem("ironchest:iron_chest")
			else
				retrieveItem("ironchest:iron_chest",1)
			end
			gotoOffset(2,1)
			turtle.suckDown()
			gotoOffset(#itemsX,#itemsX[#itemsX])
			turtle.place()
			turtle.select(2)
			turtle.drop()
			turtle.select(1)
		end
	else
		addNewItem(newItemCreation(itemName,quantity))
		gotoOffset(2,1)
		turtle.dropDown()
		if countAllItemsInDatabase("ironchest:iron_chest") < 1 then
			craftItem("ironchest:iron_chest")
		else
			retrieveItem("ironchest:iron_chest",1)
		end
		gotoOffset(2,1)
		turtle.suckDown()
		gotoOffset(#itemsX,#itemsX[#itemsX])
		turtle.place()
		turtle.select(2)
		turtle.drop()
		turtle.select(1)
	end
end
function retrieveItem(itemName,quantity)
	if quantity == nil then
		quantity = 64
	end
	local data = findInDatabaseWithItem(itemName)
	if data.returnVal then
		gotoOffset(data.x,data.y)
		turtle.suck(quantity)
		--print(itemsX[data.x][data.y].quantity)
		removeQuantity(data.x,data.y,quantity)
	else
		print("Item not in database: "..itemName)
	end
end
function removeQuantity(xOff,yOff,count)
	if (tonumber(itemsX[xOff][yOff].quantity) < tonumber(count)) then
		--triing to remove more than in the inventory, sets the remaining to 0
		itemsX[xOff][yOff].quantity = 0
	else
		itemsX[xOff][yOff].quantity = itemsX[xOff][yOff].quantity - count
		if itemsX[xOff][yOff].quantity < 0 then
			--itemsX[xOff][yOff].quantity = 0
		end
	end
	save()
end
---Returns the selected item t
---@param selected any
function returnSelected(selected)
	if not(selected == nil) then
		turtle.select(selected)
	end
	
	local data = turtle.getItemDetail()
	addItemToDatabase(data.name,data.count)
	save()
end
--Crafting functions here

function craftItem(name)
	for i = 1, #crafting_recipes do
		if name == crafting_recipes[i].result.name then
			--check all items to craft
				--Count all items
					local neededItems = {}
					for x=1,#crafting_recipes[i].recipe do
						local found = false
						for z=1,#neededItems do
							if neededItems[z].name == crafting_recipes[i].recipe[x] then
								neededItems[z].quantity = neededItems[z].quantity +1
							end
						end
						if not found then
							table.insert( neededItems,{name = crafting_recipes[i].recipe[x],quantity = 1})
						end
					end
					
				--Check if all needed items are in database
					for x = 1,#neededItems do
						if not (neededItems[x].name == "nothing") then
							while neededItems[x].quantity > countAllItemsInDatabase(neededItems[x].name) do
								local result = craftItem(neededItems[x].name)
								if not (result == "done") then
									print("Could not craft: "..name.." Needed: "..neededItems[x].name)
									return name
								else
									returnSelected()
								end
							end
						end
					end
					
			--craft after item collection has been completed
			for x = 1,#crafting_recipes[i].recipe do
				if not (crafting_recipes[i].recipe[x] == "nothing") then
					turtle.select(x)
					retrieveItem( crafting_recipes[i].recipe[x],1)
				end
			end
			turtle.select(1)
			turtle.craft()
			return "done"
		end
	end
	return name
end
function craftTillNumber(name,number)
	while countAllItemsInDatabase(name) < number do
		craftItem(name)
	end
end
function saveCraftingRecipe()
	i = 0
	_recipe = {}
	for temp = 1, 12 do
		if(temp%4 ~=0)then
			i = i+1
			turtle.select(temp)
			item = turtle.getItemDetail()
			if item ~= nil then
				_recipe[i] = item.name
			else
				--What to put if there is "nothing" in the space on the crafting recipe
				_recipe[i] = nil
			end
		end
	end
	turtle.select(16)
	item = turtle.getItemDetail()
	if item == nil then
		print("Cant make a recipe, there is no result at the end.")
		return false
	end
	_result = item.name

	table.insert(crafting_recipes,{recipe = _recipe,result = _result})
	print({recipe = _recipe,result = _result})
	saveTable(crafting_recipes,"crafting_recipes.txt")
	print(string.format( "Saved the recipe for: %s",_result))
	return true
end

maxY = 10
maxX = 10


--Check for first start
if #fs.find("items.txt") == 0 then
	saveTable({{}},"items.txt")
	saveTable({},"crafting_recipes.txt")
	os.sleep(0.1)
end

--Load from file
itemsX = load()
--Load form file
crafting_recipes = loadTable("crafting_recipes.txt")

saveCraftingRecipe()

--TESTING HERE
--url = "https://computercraft.zomzi.moe/upload/crafting_recipes.txt"
--http.post(url,textutils.serialiseJSON(crafting_recipes))

showErrorMessage("It has been done")

--retrieveItem("minecraft:planks",1)
--craftItem("minecraft:chest")


--showErrorMessage("Ends here")
save()

--Program from here

print("Write \"ret\" to get an item.")
input = read()
if input == "ret" then
	while true do
		if turtle.suckDown() then
			local data = turtle.getItemDetail()
			turtle.dropDown()
			
			print("Ther are "..countAllItemsInDatabase(data.name).." number of items. How many you want to retrieve?")
			retrieveItem(data.name,tonumber(read()))
			gotoOffset(1,1)
		end
	end
else
	while true do
		if turtle.suckDown() then
			returnSelected()
			gotoOffset(1,1)
		end
	end
end








--table.insert(itemsX,"minecraft:log:1")
for i = 1, #itemsX do
	for key,value in pairs( itemsX[1] ) do
	   print(i.."-"..tostring(key)..": "..writeItem(value))
	end
end