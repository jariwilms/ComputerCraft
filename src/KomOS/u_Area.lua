--Area Mapper

--Globals

--Class
local AreaMapper = {data = {
		x = 0,
		y = 0,
		Z = 0,
	}}
	
function AreaMapper.__init__ (data)
  local self = {data=data}
  setmetatable (self, {__index=AreaMapper})
  return self
end

setmetatable (AreaMapper, {__call=AreaMapper.__init__})

--functions
function AreaMapper:MapAreaPlanar()
	if turtle.getFuelLevel() < 100 then
		term.setCursorPos(1,1)
		term.clear()
		print("Need Fuel to map area")
		return false
	end

	term.setCursorPos(1,1)
	term.clear()
	print("Mapping Area...")
	
	--Check X
	local X = MapAxisArea()
	print("x axis = "..tostring(X))
	
	--Check Y
	turtle.turnRight()
	local Y = MapAxisArea()
	print("Y axis = "..tostring(Y))
	
	--Double Check X
	turtle.turnRight()
	XDoubleCheck = MapAxisArea()
	if X ~= XDoubleCheck then
		PrintError("Error: Something wnet wrong mapping the X area size")
		return false
	end
	print("2nd X axis = "..tostring(XDoubleCheck))
	
	--Double Check Y
	turtle.turnRight()
	YDoubleCheck = MapAxisArea()
	if Y ~= YDoubleCheck then
		PrintError("Error: Something wnet wrong mapping the Y area size")
		return false
	end
	print("2nd Y axis = "..tostring(YDoubleCheck))
	
	turtle.turnRight()
	AreaMapper.data = {X,Y,0}
	
	return X,Y
end

function MapAxisArea()
	print("Mapping axis")
	Mapping = true
	local size = 1
	while Mapping do
		if turtle.inspect() == false then
			size = size + 1 
			turtle.forward()
		else 
			print("axis complete")
			Mapping = false
		end
	end
	return size
end

function PrintError (str)
	term.setCursorPos(1,1)
	term.clear()
	print("str")
end

return AreaMapper