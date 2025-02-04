--tree farm Program

--Includes
local TreeConfig  = require("u_Config")

--Global

--Config
if not fs.exists("c_TreeFarm") then
		TreeFile = fs.open("c_TreeFarm", "w")
		TreeFile.writeLine("Lenght: 5")
		TreeFile.close()
end

TreeConfig:setPath("c_TreeFarm")

--Data

--Class

--Function
function IsthereTreeLeft()
	turtle.turnLeft()
	local success, data = turtle.inspect()
	if success then
		if string.find(data.name,"log") then
			return true
		end
	end
	return false
end

function IsthereTreeInFront()
	local success, data = turtle.inspect()
	if success then
		if string.find(data.name,"log") then
			return true
		end
	end
	return false
end

function IsthereTreeUp()
	local success, data = turtle.inspectUp()
	if success then
		if string.find(data.name,"log") then
			return true
		end
	end
	return false
end

function IsLeavesForward()
	local success, data = turtle.inspectUp()
	if success then
		if string.find(data.name,"leaves") then
			return true
		end
	end
	return false
end

function CutTree()
	local timesWentUp = 0
	turtle.dig()
	turtle.forward()
	turtle.digDown()
	
	while IsthereTreeUp() do
		turtle.digUp()
		turtle.up()
		timesWentUp = timesWentUp + 1
	end
	
	for i=1, timesWentUp do 
		turtle.down()
	end
	
	
	turtle.select(16)
	turtle.placeDown()
	
	if IsthereTreeInFront() then
		CutTree()
	end
	
	turtle.back()
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
		print("Need Saplings")
		return false
	end
	
	fullinv = true
	for i=1,14 do
		if turtle.getItemCount(i) < 64 then
			dataInv = turtle.getItemDetail(i)
			if dataInv ~= nil and string.match(dataInv.name, "stick") then
				turtle.select(i)
				turtle.drop()
			end
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

function ShowSetup()
	term.clear()
	term.setCursorPos(1,1)
	print("example setup with legnth = 3:")
	print("X = trees, T = turtle")
	print("XX")
	print("XX")
	print("XX")
	print("  T")
	print("open c_TreeFarm to set length")
end

--Main

function RunTreeFarm()
	local TimesMovedForward = 0
	local Maxforward = tonumber(TreeConfig:getData("Lenght"))
	
	while CanStart() do
		for i=1, Maxforward do
			if IsLeavesForward() then
				turtle.dig()
			end
			turtle.forward()
			TimesMovedForward = TimesMovedForward + 1
			if IsthereTreeLeft() then
				CutTree()
				turtle.turnRight()
			else 
				turtle.turnRight()
			end
		end
		
		for i=1, TimesMovedForward do
			turtle.back()
		end
		
		TimesMovedForward = 0
		
		sleep(500)
	end
end

function Stop()
    event,key = os.pullEvent("key")
    return
end

print("farming trees\n <press any key to stop>")
parallel.waitForAny(RunTreeFarm, Stop)