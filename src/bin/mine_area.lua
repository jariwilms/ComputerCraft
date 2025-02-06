local config = require("/cfg/mine_area")
local math   = require("/lib/math_ext")
local mine   = require("/lib/mining")

local argv = {...}
local argc = #argv



local function turn(rotation, repetitions, orientation)
    repetitions = repetitions or 1
    orientation = orientation or mine.Orientation.Forward

    for _ = 1, repetitions do
        if     rotation == mine.Rotation.Left  then
            if turtle.turnLeft() then
                orientation = orientation + 1
                if orientation == 5 then orientation = mine.Orientation.Forward end
            end
        elseif rotation == mine.Rotation.Right then
            if turtle.turnRight() then
                orientation = orientation - 1
                if orientation == 0 then orientation = mine.Orientation.Right end
            end
        else   error("Invalid Rotation!")
        end
    end

    return orientation
end

local function move(direction, distance, position, orientation)
    for _ = 1, distance do
        if     direction == mine.Direction.Forward  then
            if turtle.forward() then
                if orientation == mine.Orientation.Forward  then position.z = position.z + 1 end
                if orientation == mine.Orientation.Left     then position.x = position.x - 1 end
                if orientation == mine.Orientation.Backward then position.z = position.z - 1 end
                if orientation == mine.Orientation.Right    then position.x = position.x + 1 end

                return true
            end
        elseif direction == mine.Direction.Backward then
            if turtle.back() then
                if orientation == mine.Orientation.Forward  then position.z = position.z - 1 end
                if orientation == mine.Orientation.Left     then position.x = position.x + 1 end
                if orientation == mine.Orientation.Backward then position.z = position.z + 1 end
                if orientation == mine.Orientation.Right    then position.x = position.x - 1 end

                return true
            end
        elseif direction == mine.Direction.Left     then
            orientation = turn(mine.Rotation.Left, 1, orientation)
            move(mine.Direction.Forward, 1, position, orientation)
            orientation = turn(mine.Rotation.Right, 1, orientation)

            return true
        elseif direction == mine.Direction.Right    then
            orientation = turn(mine.Rotation.Right, 1, orientation)
            move(mine.Direction.Forward, 1, position, orientation)
            orientation = turn(mine.Rotation.Left, 1, orientation)

            return true
        elseif direction == mine.Direction.Up       then
            if turtle.up()   then
                position.y = position.y + 1

                return true
            end
        elseif direction == mine.Direction.Down     then
            if turtle.down() then
                position.y = position.y - 1

                return true
            end
        else   error("Invalid Direction!")
        end
    end

    return false
end

local function dig(digDirection)
    if     digDirection == mine.DigDirection.Front then return turtle.dig()
    elseif digDirection == mine.DigDirection.Up    then return turtle.digUp()
    elseif digDirection == mine.DigDirection.Down  then return turtle.digDown()
    else   error("Invalid DigDirection!")
    end
end

local function mine_area(dimensions)
    local position    = { x = 0, y = 0, z = 0 }
    local orientation = mine.Orientation.Forward
    local rotation    = mine.Rotation.Right



    if dimensions.z < 0 then turn(mine.Rotation.Left, 2); dimensions.x = -dimensions.x end
    if dimensions.x < 0 then rotation = mine.Rotation.Left                             end
    if dimensions.y < 0 then error("Y dimensions < 0 are not yet supported")           end

    dimensions.x = math.abs(dimensions.x)
    dimensions.y = math.abs(dimensions.y)
    dimensions.z = math.abs(dimensions.z)

    turtle.dig()
    turtle.forward()



    for _ = 1, dimensions.y do
        for _ = 1, dimensions.x do
            for _ = 1, dimensions.z - 1 do
                dig(mine.DigDirection.Front)
                move(mine.Direction.Forward, 1, position, orientation)
            end

            if _ < dimensions.x then
                orientation = turn(rotation, 1, orientation)
                dig(mine.DigDirection.Front)
                move(mine.Direction.Forward, 1, position, orientation)
                orientation = turn(rotation, 1, orientation)

                if     rotation == mine.Rotation.Left  then rotation = mine.Rotation.Right
                elseif rotation == mine.Rotation.Right then rotation = mine.Rotation.Left
                end
            end
        end

        if _ < dimensions.y then
            dig(mine.DigDirection.Up)
            move(mine.Direction.Up, 1, position, orientation)
            orientation = turn(mine.Rotation.Left, 1, orientation)
            orientation = turn(mine.Rotation.Left, 1, orientation)
        end
    end
end

local function validate_confirmation(response, pass, fail, default)
    local response = string.lower(response)

    if  response == string.lower(pass) then return true    end
    if  response == string.lower(fail) then return false   end
    if #response == 0                  then return default end

    return false
end

local function main()
    term.clear()
    term.setCursorPos(1, 1)

    io.write("--Mine Area--\n")




    local dimensions      = { x = 0, y = 0, z = 0 }

    if     argc == 3 then
        dimensions.x = math.floor(argv[1]) or error("Invalid input!")
        dimensions.y = math.floor(argv[2]) or error("Invalid input!")
        dimensions.z = math.floor(argv[3]) or error("Invalid input!")
    elseif argc == 0 then
        while true do
            io.write("Enter x coordinate: ")
            dimensions.x = math.floor(read())

            io.write("Enter y coordinate: ")
            dimensions.y = math.floor(read())

            io.write("Enter z coordinate: ")
            dimensions.z = math.floor(read())

            io.write("Is the turtle on a chest? [y/N] ")
            config.OnChest = validate_confirmation(read(), "y", "n", false)

            io.write("Dimensions: <", dimensions.x, ', ', dimensions.y, ', ', dimensions.z, ">\n")
            io.write("OnChest:    ",  tostring(config.OnChest), "\n")
            io.write("\n")

            io.write("Is this correct? [Y/n] ")
            if validate_confirmation(read(), "y", "n", true) then break
            else                                                  term.clear(); term.setCursorPos(1, 1)
            end
        end
    else   error("Invalid number of arguments!\nExpected: 3, Received: ", argc)
    end



    local distance     = math.volume(dimensions) + math.manhattan_distance(dimensions) --worst case distance
    local fuelLevel    = turtle.getFuelLevel()
    local requiredFuel = distance - fuelLevel

    if requiredFuel > 0 then
        io.write("Fuel level inadequate, refueling...\n")

        turtle.select(1)
        if turtle.refuel(0) and not turtle.refuel(requiredFuel) then error("Not enough fuel")
        else error("Invalid fuel source!")
        end
    end



    term.clear()
    term.setCursorPos(1, 1)

    io.write("Beginning excavation\n")
    io.write("Mining " .. math.volume(dimensions) .. " blocks\n")

    mine_area(dimensions)

    io.write("Excavation complete!\n")
end

main()
