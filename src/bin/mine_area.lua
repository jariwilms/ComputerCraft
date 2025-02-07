local config  = require("/cfg/mine_area")
local terra   = require("/lib/terra")
local mathext = require("/lib/math_ext")

local argv = {...}
local argc = #argv



local function mine_area(dimensions)
    local position    = vector.new()
    local orientation = terra.Orientation.new()
    local rotation    = terra.Rotation.Right



    if dimensions.z < 0 then terra.turn(terra.Rotation.Left, 2); dimensions.x = -dimensions.x end
    if dimensions.x < 0 then rotation = terra.Rotation.Left                                   end
    if dimensions.y < 0 then error("Y dimensions < 0 are not yet supported")                  end

    dimensions.x = math.abs(dimensions.x)
    dimensions.y = math.abs(dimensions.y)
    dimensions.z = math.abs(dimensions.z)

    turtle.dig()
    turtle.forward()



    for _ = 1, dimensions.y do
        for _ = 1, dimensions.x do
            for _ = 1, dimensions.z - 1 do
                terra.dig(terra.DigDirection.Front)
                terra.move(terra.Direction.Forward, 1, position, orientation)
            end

            if _ < dimensions.x then
                terra.turn(rotation, 1, orientation)
                terra.dig(terra.DigDirection.Front)
                terra.move(terra.Direction.Forward, 1, position, orientation)
                terra.turn(rotation, 1, orientation)

                if     rotation == terra.Rotation.Left  then rotation = terra.Rotation.Right
                elseif rotation == terra.Rotation.Right then rotation = terra.Rotation.Left
                end
            end
        end

        if _ < dimensions.y then
            terra.dig(terra.DigDirection.Up)
            terra.move(terra.Direction.Up, 1, position, orientation)
            terra.turn(terra.Rotation.Left, 1, orientation)
            terra.turn(terra.Rotation.Left, 1, orientation)
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



    local dimensions = vector.new()
    local keys       = { "x", "y", "z" }

    if     argc == 3 then
        for index, value in ipairs(keys) do
            dimensions[value] = math.floor(argv[index])
        end
    elseif argc == 0 then
        while true do
            for _, value in ipairs(keys) do
                io.write("Enter " .. value .. " coordinate: ")
                dimensions[value] = math.floor(read())
            end

            io.write("Is the turtle on a chest? [y/N] ")
            config.OnChest = validate_confirmation(read(), "y", "n", false)

            io.write("Dimensions: <", dimensions:tostring(),    ">\n")
            io.write("OnChest:    ",  tostring(config.OnChest),  "\n")
            io.write("\n")

            io.write("Is this correct? [Y/n] ")
            if validate_confirmation(read(), "y", "n", true) then break
            else term.clear(); term.setCursorPos(1, 1)
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
