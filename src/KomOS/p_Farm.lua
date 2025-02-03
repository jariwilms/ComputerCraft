--Farm Program
function ShowSetup()
	term.clear()
	term.setCursorPos(1,1)
	print("Place Turtle 1 block above farm")
	print("X = farm, T = turtle")
	print("XXXX")
	print("XXXX")
	print("TXXX")
	print("Open c_Farm to set details")
	print("Press enter once to begin, twice to exit")
end

--Includes
os.loadAPI("u_Area")
os.loadAPI("u_Config")

--Config
local Area = u_Area.AreaMapper()
local AreaX, AreaY = Area.MapAreaPlanar()
print("size: "..tostring(AreaX).."-"..tostring(AreaY))

local FarmConfig = u_Config.ConfigReader()
if not fs.exists("c_Farm") then
	FarmFile = fs.open("c_Farm", "w")
	FarmFile.writeLine("Replant: Seed")
	FarmFile.writeLine("Age: 5")
	FarmFile.close()
	
	ShowSetup()
	event,key = os.pullEvent("key")
end
FarmConfig:setPath("c_Farm")
--Global

--Data

--Class

--Function
function CheckCrop(Replant, ReadyAge)
	local success, data = turtle.inspectDown()
	if success then
		local CropAge = tonumber(data["state"]["age"])
		print(tostring(CropAge))
		if CropAge == ReadyAge then
			return Farm(Replant)
		end
		print("Not aged, correct age: "..tostring(ReadyAge))
		return false
	else
		print("Plant")
		Plant(Replant)
	end
	return false
end

function Plant(Replant)
	local SeedIndex = FindSeed(Replant)
	if SeedIndex == -1 then
		return
	end
	if turtle.inspectDown() == false then
		print("seeds found on index "..tostring(SeedIndex))
        turtle.select(SeedIndex)
        turtle.placeDown()
		print("placed")
	end
	if turtle.inspectDown() == false then
		print("Til Check")
		TilCheck()
		Plant(Replant)
	end
end

function Farm(Replant)
	print("Farming")
	local SeedIndex = FindSeed(Replant)
	if SeedIndex == -1 then
		return false
	end
	turtle.digDown()
	turtle.suckDown()
	Plant(Replant)
	return true
end

function TilCheck()
	turtle.down()
	local success, data = turtle.inspectDown()
	if success then
		if string.find(data["name"],"farmland") then
			return
		else
			print("til")
			turtle.digDown()
		end
	end
	turtle.up()
end

function FindSeed(Replant)
	for i=1, 16 do
		local dataInv = turtle.getItemDetail(i)
		if dataInv ~= nil and Replant ~= nil then
			if string.find(dataInv["name"], Replant) then
				return i
			end
		end
	end
	print("No Seeds")
	return -1
end

function CanStart()
	if turtle.getFuelLevel() < 100 then
		term.setCursorPos(1,1)
		term.clear()
		print("Need Fuel")
		return false
	end
	
	if turtle.getItemCount(16) < 1 then
		term.setCursorPos(1,1)
		term.clear()
		print("Need Seeds")
		return false
	end
	
	fullinv = true
	for i=1,14 do
		if turtle.getItemCount(i) < 64 then
			fullinv = false
		end
	end
	if fullinv then
		term.setCursorPos(1,1)
		term.clear()
		print("Inventory full")
		return false
	end
	return true
end

--Main

function RunFarm()
	local TimesMovedY = 0
	
	local Seed = FarmConfig:getData("Replant")
	local Age = tonumber(FarmConfig:getData("Age"))
	
	print(type(Seed).." "..tostring(Seed))
	print(type(Age).." "..tostring(Age))
	sleep(2)
	
	while CanStart() do
		print("Start farming")
		local Farming = true
		while Farming do
		
			if TimesMovedY == AreaY then
				print("Returning to Start pos")
				if TimesMovedY % 2 == 0 then
					turtle.turnLeft()
				else
					turtle.turnRight()
				end
				
				for i=1, AreaX-1 do
					turtle.forward()
				end
				
				if TimesMovedY % 2 == 0 then
					turtle.turnLeft()
					for i=1, AreaX-1 do
						turtle.forward()
					end
					turtle.turnLeft()
					turtle.turnLeft()
					Farming = false
				else
					turtle.turnRight()
					Farming = false
				end
			else
				
				print("Returning to Start pos")
				for i=1, AreaX-1 do
					print("Check Crop")
					CheckCrop(Seed, Age)
					print("Forward")
					turtle.forward()
				end
				
				print("Check Crop")
				CheckCrop(Seed, Age)
				
				print("Moving to next row")
				if TimesMovedY+1 ~= AreaY then
					if TimesMovedY % 2 == 0 then
						turtle.turnRight()
						turtle.forward()
						turtle.turnRight()
					else
						turtle.turnLeft()
						turtle.forward()
						turtle.turnLeft()
					end
				end
			end
			
			TimesMovedY = TimesMovedY+1
		end
		sleep(200)
		TimesMovedY = 0
	end
end

function Stop()
    event,key = os.pullEvent("key")
    return
end

print("farming...\n <press any key to stop>")
parallel.waitForAny(RunFarm, Stop)