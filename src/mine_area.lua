local config = require("cfg.mine_area")

local argv = {...}
local argc = #argv

local Cardinal = 
{
	North = 1, 
	East  = 2, 
	South = 3, 
	West  = 4, 
}
local CardinalString = 
{
	North = "North", 
	East  = "East", 
	South = "South", 
	West  = "West", 
}



function hasValue(Table, String, Exact)
	Exact = Exact or false

	if Exact then --Ja ik ben bewust dat de if in de for loop kan zodat het niet dubbel moet worden geschreven
		for Index, Value in ipairs(Table) do
			if Value == String then
				return true
			end
		end
	else
		for Index, Value in ipairs(Table) do
			if string.find(string.lower(String), string.lower(Value)) then
				return true
			end
		end
	end

	return false
end

function shouldKeep(Blockname)	
	if hasValue(config.TargetBlocktable, Blockname) then
		if config.Debug then io.write("[DEBUG] Keeping ", Blockname, '\n') end
		return true 
	end
		
	return false
end

function inInventory(Blockname)
	for i = 1, 15 do
		Slotdata = turtle.getItemDetail(i)
		
		if Slotdata then
			if Slotdata.name == Blockname and turtle.getItemSpace(i) then return i end
		end
	end
	
	return false
end

function getFreeSlot()
    for i = 1, 15 do
        if turtle.getItemCount(i) == 0 then return i end
    end
    
    return false
end

function storeBlock()
    local Blockdata = turtle.getItemDetail(16) --Get data from slot 16
    
	if Blockdata then --If there is a block
		if shouldKeep(Blockdata.name) then --And we should keep it
			if inInventory(Blockdata.name) then --Then we check if it is in our inventory already with stacksize < 64
				turtle.transferTo(inInventory(Blockdata.name)) --And we transfer it to that slot
			elseif getFreeSlot() then --Otherwise we look for an empty slot
				turtle.transferTo(getFreeSlot()) --And we transfer it to that slot
			elseif config.onChest then
				depositItems(C) --If we can not get a free slot either, we empty the turtle.
			else
				io.write("No more inventory space for new blocks, returning to origin.\n")
				resetPosition()
			end
		else
			turtle.select(16)
			turtle.drop() --Drop down the item in slot 16, which was selected above
		end
	end
end

function Move(Direction, Distance)
	if not Direction then error("Direction must be given") end
	if Distance then Distance = math.abs(Distance) else Distance = 1 end
	
	for i = 1, Distance do
		if Direction == "Forward" then
			if turtle.forward() then
				if Facing == 1 then
					C.z = C.z + 1
				elseif Facing == 2 then
					C.x = C.x + 1
				elseif Facing == 3 then
					C.z = C.z - 1
				elseif Facing == 4 then
					C.x = C.x - 1
				end
			end
		elseif Direction == "Up" then
			if turtle.up() then
				C.y = C.y + 1
			end
		elseif Direction == "Down" then
			if turtle.down() then
				C.y = C.y - 1
			end
		end
		
		if config.Debug then
			io.write("[DEBUG] Moving forward, C<", C.x, ', ', C.y, ', ', C.z, ">\n")
		end
	end
end

function Turn(Direction, Rotations)
	if not Direction then error("Direction must be given") end
	if Rotations then Rotations = math.abs(Rotations) else Rotations = 1 end

	if Direction == "Left" then
		for i = 1, Rotations do
			Facing = Facing - 1
			turtle.turnLeft()
			
			if Facing == 0 then
				Facing = 4
			end
		end
	elseif Direction == "Right" then
		for i = 1, Rotations do
			Facing = Facing + 1
			turtle.turnRight()
			
			if Facing == 5 then
				Facing = 1
			end
		end
	end
	
	if config.Debug then
		io.write("[DEBUG] Turning ", Direction, ", now facing ", Cardinal[Facing], '\n')
	end
end

function Dig()
	local Success, Block = turtle.inspect()
	
	if Success then
		if hasValue(config.Fallingblocks, Block.name) then
			while true do
				turtle.select(16)
				turtle.dig()
				storeBlock()
				os.sleep(1)
				
				if config.Debug then
					io.write("[DEBUG] Inspecting\n")
				end
				
				if not turtle.inspect() then break end --buggy shite
			end
		else
			turtle.select(16)
			turtle.dig()
			storeBlock()
		end
	end
end

function setBeacon(B)
	if B then
		Turn("Left", 2)
		turtle.select(15)
		turtle.place()
		Turn("Right", 2)
		
		if config.Debug then
			io.write("Mining beacon placed")
		end
	else
		Turn("Right", 2)
		turtle.select(15)
		turtle.dig()
		Turn("Left", 2)
		
		if config.Debug then
			io.write("Mining beacon destroyed")
		end
	end
end

function mineArea(x, y, z) --Keep in mind that the turtle is already in the to-be-mined volume
	term.clear()
	term.setCursorPos(1, 1)
	io.write("Mining ", x * y * z, " blocks\n")
	
	setBeacon(true)
	
	for i = 1, y do --Height
		for j = 1, x do --Width
			for k = 1, z - 1 do --Depth
				Dig()
				Move("Forward")
			end
			
			if j < x then --Every time we need to rotate
				if math.fmod(j - 1 + (i - 1) * math.fmod(x + 1, 2), 2) == 0 then
					Turn("Right")
					turtle.dig()
					Move("Forward")
					Turn("Right")
				else
					Turn("Left")
					turtle.dig()
					Move("Forward")
					Turn("Left")
				end
			end
		end
		
		if i < y then
			turtle.digUp()
			Move("Up")
			Turn("Left", 2)
		end
	end
	
	resetPosition()
	
	if config.onChest then
		for i = 1, 16 do
			turtle.select(i)
			turtle.dropDown()
		end
	end
	
	setBeacon(false)
	io.write("Excavation complete!\n")
end

function checkFuel(Distance)
	local FuelLevel = turtle.getFuelLevel()
	
	if Distance < FuelLevel then
		return true
	else
		return false
	end
end

function setFace(Direction)
	if Facing ~= Direction then
		Rotations = Direction - Facing
	
		if Rotations > 0 then
			Turn("Right", Rotations)
		elseif Rotations < 0 then
			Turn("Left", Rotations)
		end
	end
end

function Clear() --For when resetPosition is running, and blocks placed by players are found
	if turtle.detect() then
		turtle.dig()
	end
	
	if turtle.detectUp() then
		turtle.digUp()
	end
	
	if turtle.detectDown() then
		turtle.digDown()
	end
end

function resetPosition()
	term.clear()
	term.setCursorPos(1,1)
	io.write("Resetting position\n")
	
	if C.x > 0 then
		setFace(4)
		
		for i = 1, C.x do
			Clear()
			Move("Forward", 1)
		end
	end
	
	if C.y > 0 then
		Move("Down", C.y)
	end
	
	if C.z > 0 then
		setFace(3)
		
		for i = 1, C.z do
			Clear()
			Move("Forward", 1)
		end
	end
	
	if Facing ~= 1 then
		setFace(1)
	end
end

function depositItems(OldC)
	resetPosition()
	
	for i = 1, 16 do
		turtle.select(i)
		turtle.dropDown()
	end
	
	if OldC.x then --turtle faces forward after reset
		Move("Forward", OldC.x)
	end
	
	if OldC.y then
		Move("Up", OldC.y)
	end
	
	if OldC.z then
		Turn("Right")
		Move("Forward", OldC.z)
		
		if math.fmod(OldC.z, 2) == 0 then
			Turn("Left")
		else
			Turn("Right")
		end
	end
end

function main()
	term.clear()
	term.setCursorPos(1, 1)
	io.write("Starting Turtle\n")

	local dimensions = { x = 0, y = 0, z = 0 }
	local reply      = ""
	
	if argc == 3 then
		for index, value in ipairs(dimensions) do
			value = tonumber(argv[index])
			if (type(value) ~= "number") then error("Invalid coordinate value given!") end
		end
	elseif argc == 0 then
		while true do
			term.clear()
			term.setCursorPos(1, 1)
			
			local dimensionStrings = {"width", "height", "depth"}

			for index, value in ipairs(dimensions) do
				io.write("Enter " + dimensionStrings[index] + ":\t")
				value = read("*n")
			end

			io.write("Is the turtle on a chest? [y/N]")
			reply = read()
			
			if reply == 'y' then
				config.onChest = true;
			end
			
			io.write("dimensions -> <", dimensions.x, ', ', dimensions.y, ', ', dimensions.z, ">\n")
			io.write("Volume -> <", dimensions.x * dimensions.y * dimensions.z, "b>\n")
			io.write("config.onChest -> ", tostring(config.onChest), '\n')
			io.write("Is this correct? [Y/n] ")
			reply = read()
			io.write('\n')
			
			if reply == "y" or reply == "\n" then break end
		end
	else
		error("Received invalid number of arguments\nExpected: 3, Received: ", argc)
	end
	
	if dimensions.x < 1 or dimensions.y < 1 or dimensions.z < 1 then
		error("Supplied values were not valid, axis length must be at least 1")
	end
			
	if checkFuel(dimensions.x * dimensions.y * dimensions.z + dimensions.y - 1) then
		io.write("Fuel level adequate\n")
		mineArea(dimensions.x, dimensions.y, dimensions.z)
	else
		io.write("Fuel level too low, refueling\n")
		shell.run("Refuel")
		--todo: make turtle return to its position before refuel, and start mining
	end
end

main()