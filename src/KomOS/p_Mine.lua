function mineArea(x, y, z)
	io.write("Mining ", x * y * z, " blocks\n")
	for i = 0, y - 1 do
		for j = 0, z - 1 do
			for k = 0, x - 2 do
				turtle.dig()
				turtle.forward()
			end
			
			if j < z - 1 then
				if math.fmod(j + i * math.fmod(z + 1, 2), 2) == 0 then
					turtle.turnRight()
					turtle.dig()
					turtle.forward()
					turtle.turnRight()
				else
					turtle.turnLeft()
					turtle.dig()
					turtle.forward()
					turtle.turnLeft()
				end
			end
		end
		
		if i < y - 1 then
			turtle.digUp()
			turtle.up()
			turtle.turnLeft()
			turtle.turnLeft()
		else
			for i = 1, y - 1 do
				turtle.down()
			end
		end
	end
	io.write("Done")
end

function canMine(Volume)
	local FuelLevel = turtle.getFuelLevel()
	
	if Volume < FuelLevel then
		io.write("Fuel level adequate\n")
		return true
	else
		io.write("Fuel level too low")
		return false
	end
end

function getTableLength(Table)
	local count = 0
	for Index in pairs(Table) do 
		count = count + 1 
	end
	
	return count
end

function Setup(...)
	io.write("Starting Turtle\n")
	
	local Argv = {...}
	TableLength = getTableLength(Argv)
	local x, y, z = 0, 0, 0
	
	if TableLength == 3 then --If command line arguments were supplied
		x = Argv[0]
		y = Argv[1]
		z = Argv[2]
	elseif TableLength == 0 then --If they were not supplied, ask user for input
		while true do
			io.write("Enter x: ")
			x = tonumber(read())
			io.write("Enter y: ")
			y = tonumber(read())
			io.write("Enter z: ")
			z = tonumber(read())
			
			io.write("Area -> <", x, ', ', y, ', ', z, ">\n")
			io.write("Volume -> <", x * y * z, "b>\n")
			io.write("Is this correct? [y/n] ")
			local reply = read()
			io.write('\n')
			
			if reply == 'y' then break end
		end
	else --Otherwise, throw an error
		error("Received invalid number of arguments\nExpected: 3, Received: ", TableLength)

	end
	
	local HasSufficientFuel = canMine(x * y * z + y)
		
	if HasSufficientFuel then
		mineArea(x, y, z)
	else
		shell.run("Refuel")
	end
	
	term.clear()
	term.setCursorPos(1, 1)
end

Setup()
	