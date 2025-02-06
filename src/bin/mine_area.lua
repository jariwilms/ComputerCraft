local config = require("/cfg/mine_area")

math.volume = function (dimensions)
    local volume = 1

    for key, _ in pairs(dimensions) do
        volume = volume * math.abs(dimensions[key])
    end

    return volume
end
math.manhattan_distance = function(dimensions)
    local distance = 0

    for key, _ in pairs(dimensions) do
        distance = distance + math.abs(dimensions[key])
    end

    return distance
end



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

local function turn(rotation, repetitions, orientation)
    repetitions = repetitions or 1
    orientation = orientation or Orientation.Forward

    for _ = 1, repetitions do
        if     rotation == Rotation.Left  then
            if turtle.turnLeft() then
                orientation = orientation + 1
                if orientation == 5 then orientation = Orientation.Forward end
            end
        elseif rotation == Rotation.Right then
            if turtle.turnRight() then
                orientation = orientation - 1
                if orientation == 0 then orientation = Orientation.Right end
            end
        else   error("Invalid Rotation!")
        end
    end

    return orientation
end

local function move(direction, distance, position, orientation)
    for _ = 1, distance do
        if     direction == Direction.Forward  then
            if turtle.forward() then
                if orientation == Orientation.Forward  then position.z = position.z + 1 end
                if orientation == Orientation.Left     then position.x = position.x - 1 end
                if orientation == Orientation.Backward then position.z = position.z - 1 end
                if orientation == Orientation.Right    then position.x = position.x + 1 end

                return true
            end
        elseif direction == Direction.Backward then
            if turtle.back() then
                if orientation == Orientation.Forward  then position.z = position.z - 1 end
                if orientation == Orientation.Left     then position.x = position.x + 1 end
                if orientation == Orientation.Backward then position.z = position.z + 1 end
                if orientation == Orientation.Right    then position.x = position.x - 1 end

                return true
            end
        elseif direction == Direction.Left     then
            orientation = turn(Rotation.Left, 1, orientation)
            move(Direction.Forward, 1, position, orientation)
            orientation = turn(Rotation.Right, 1, orientation)

            return true
        elseif direction == Direction.Right    then
            orientation = turn(Rotation.Right, 1, orientation)
            move(Direction.Forward, 1, position, orientation)
            orientation = turn(Rotation.Left, 1, orientation)

            return true
        elseif direction == Direction.Up       then
            if turtle.up()   then
                position.y = position.y + 1

                return true
            end
        elseif direction == Direction.Down     then
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
    if     digDirection == DigDirection.Front then return turtle.dig()
    elseif digDirection == DigDirection.Up    then return turtle.digUp()
    elseif digDirection == DigDirection.Down  then return turtle.digDown()
    else   error("Invalid DigDirection!")
    end
end

local function mine_area(dimensions)
    local position    = { x = 0, y = 0, z = 0 }
    local orientation = Orientation.Forward
    local rotation    = Rotation.Right



    if dimensions.z < 0 then turn(Rotation.Left, 2); dimensions.x = -dimensions.x end
    if dimensions.x < 0 then rotation = Rotation.Left                             end
    if dimensions.y < 0 then error("Y dimensions < 0 are not yet supported")      end

    dimensions.x = math.abs(dimensions.x)
    dimensions.y = math.abs(dimensions.y)
    dimensions.z = math.abs(dimensions.z)

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

                if     rotation == Rotation.Left  then rotation = Rotation.Right
                elseif rotation == Rotation.Right then rotation = Rotation.Left
                end
            end
        end

        if _ < dimensions.y then
            dig(DigDirection.Up)
            move(Direction.Up, 1, position, orientation)
            orientation = turn(Rotation.Left, 1, orientation)
            orientation = turn(Rotation.Left, 1, orientation)
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
