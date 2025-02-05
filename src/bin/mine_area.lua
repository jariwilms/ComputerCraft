local config = require("/cfg/mine_area")

local argv = {...}
local argc = #argv

local Direction = 
{
    Forward  = 1,
    Backward = 2, 
    Left     = 3, 
    Right    = 4, 
    Up       = 5, 
    Down     = 6, 
}
local Orientation = 
{
    Forward  = 1,
    Left     = 2, 
    Backward = 3, 
    Right    = 4, 
}
local Rotation = 
{
    Left  = 1, 
    Right = 2, 
}
local Cardinal = 
{
    North = 1, 
    East  = 2, 
    South = 3, 
    West  = 4, 
}
local DigDirection = 
{
    Front = 1, 
    Up    = 2, 
    Down  = 3, 
}

function turn(rotation, repetitions, orientation)
    for _ = 1, repetitions do
        if rotation == Rotation.Left then
            if turtle.turnLeft() then
                orientation = orientation + 1
                if orientation == 5 then orientation = Orientation.Forward end
            end
        end
        if rotation == Rotation.Right then
            if turtle.turnRight() then
                orientation = orientation - 1
                if orientation == 0 then orientation = Orientation.Right end
            end
        end
    end

    return orientation
end

function move(direction, distance, position, orientation)
    for _ = 1, distance do
        if     direction == Direction.Forward  then
            if turtle.forward() then
                if orientation == Orientation.Forward  then position.z = position.z + 1 end
                if orientation == Orientation.Left     then position.x = position.x - 1 end
                if orientation == Orientation.Backward then position.z = position.z - 1 end
                if orientation == Orientation.Right    then position.x = position.x + 1 end
            end
        elseif direction == Direction.Backward then
            if turtle.back() then
                if orientation == Orientation.Forward  then position.z = position.z - 1 end
                if orientation == Orientation.Left     then position.x = position.x + 1 end
                if orientation == Orientation.Backward then position.z = position.z + 1 end
                if orientation == Orientation.Right    then position.x = position.x - 1 end
            end
        elseif direction == Direction.Left     then
            orientation = turn(Rotation.Left, 1, orientation)
            move(Direction.Forward, 1, position, orientation)
            orientation = turn(Rotation.Right, 1, orientation)
        elseif direction == Direction.Right    then
            orientation = turn(Rotation.Right, 1, orientation)
            move(Direction.Forward, 1, position, orientation)
            orientation = turn(Rotation.Left, 1, orientation)
        elseif direction == Direction.Up       then
            if turtle.up() then
                position.y = position.y + 1
            end
        elseif direction == Direction.Down     then
            if turtle.down() then
                position.y = position.y - 1
            end
        end
    end
end

function dig(digDirection)
    local block = turtle.inspect()

    if block then
        if     digDirection == DigDirection.Front then turtle.dig()
        elseif digDirection == DigDirection.Up    then turtle.digUp()
        elseif digDirection == DigDirection.Down  then turtle.digDown()
        end
    end
end

function mine_area(dimensions)
    local position    = { x = 0, y = 0, z = 0 }
    local orientation = Orientation.Forward
    local rotation    = Rotation.Right

    turtle.dig()
    turtle.forward()
    
    for _ = 1, dimensions.y do
        for _ = 1, dimensions.x do
            for _ = 1, dimensions.z - 1 do
                dig(DigDirection.Front)
                move(Direction.Forward, 1, position, orientation)
            end
        
            if _ < dimensions.x then
                orientation = turn(rotation, 1, orientation)
                dig(DigDirection.Front)
                move(Direction.Forward, 1, position, orientation)
                orientation = turn(rotation, 1, orientation)
            end

            if     rotation == Rotation.Left  then rotation = Rotation.Right
            elseif rotation == Rotation.Right then rotation = Rotation.Left
            end
        end
    
        if _ < dimensions.y then
            dig(DigDirection.Up)
            move(Direction.Up, 1, position, orientation)
            orientation = turn(Rotation.Left, 1, orientation)
            orientation = turn(Rotation.Left, 1, orientation)
        end
    end

    io.write("Excavation complete!\n")
end

function calculate_distance(dimensions)
    local endPosition = { x = 0, y = 0, z = 0 }
    
    if math.fmod(dimensions.x, 2) ~= 0 then endPosition.z = dimensions.z end
    if math.fmod(dimensions.y, 2) ~= 0 then endPosition.x = dimensions.x end
                                            endPosition.y = dimensions.y

      for key, _ in pairs(endPosition) do
        if endPosition[key] > 0 then endPosition[key] = endPosition[key] - 1 end
      end

    return endPosition.x + endPosition.y + endPosition.z
end

function validate_inventory()
    local firstSlot  = turtle.getItemDetail(1)
    local secondSlot = turtle.getItemDetail(2)

    if not firstSlot  then error() end
    if not secondSlot then error() end

    if firstSlot.name ~= "coal" then end
    if firstSlot.name ~= "redstone_torch" then end
end

function main()
    term.clear()
    term.setCursorPos(1, 1)

    io.write("Starting Turtle\n")



    local dimensions      = { x = 0, y = 0, z = 0 }
    local dimensionString = { "x", "y", "z" }

    if argc == 3 then
        local index = 1

        for key, _ in pairs(dimensions) do
            dimensions[key] = tonumber(argv[index]) or error("Could not convert argument '" .. argv[index] .. "' to number")
            index = index + 1
        end
    elseif argc == 0 then
        while true do
            local reply = ""
            local index = 1

            for key, _ in pairs(dimensions) do
                io.write("Enter " .. dimensionString[index] .. " coordinate: ")
                index = index + 1
                
                reply = read()
                if reply == nil or #reply == 0 then 
                    io.write("Invalid input\n")
                    break 
                end

                dimensions[key] = math.floor(reply)
            end

            io.write("Is the turtle on a chest? [y/N] ")
            reply = string.lower(read())
            
            if #reply == 0 or reply == "n" then
                config.OnChest = false
            else
                config.OnChest = true
            end

            io.write("Dimensions: <", dimensions.x, ', ', dimensions.y, ', ', dimensions.z, ">\n")
            io.write("OnChest:    ",  tostring(config.OnChest), "\n")
            io.write("\n")

            io.write("Is this correct? [Y/n] ")
            reply = string.lower(read())

            if #reply == 0 or reply == "y" then
                break
            else
                term.clear()
                term.setCursorPos(1, 1)
            end
        end
    else
        error("Invalid number of arguments!\nExpected: 3, Received: ", argc)
    end



    local fuelLevel     = turtle.getFuelLevel()
    local totalDistance = calculate_distance(dimensions)

    if fuelLevel < totalDistance then
        io.write("Fuel level inadequate, refueling...\n")

        turtle.select(1)
        if turtle.refuel(0) then 
            if not turtle.refuel(totalDistance - fuelLevel) then 
                error("Not enough fuel") 
            end
        else 
            error("Invalid fuel source!")
        end
    end



    term.clear()
    term.setCursorPos(1, 1)

    io.write("Beginning excavation\n")
    io.write("Mining " .. dimensions.x * dimensions.y * dimensions.z .. " blocks\n")

    mine_area(dimensions)
end

main()
