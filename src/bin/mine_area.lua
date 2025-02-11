local config    = require("/cfg/mine_area")
local mathext   = require("/lib/math_ext")
local terra     = require("/lib/terra")
local inventory = require("/lib/inventory")
local item      = require("/lib/item")



local function mine_area(dimensions)
    local position              = vector.new()
    local orientation           = terra.Orientation.new()
    local rotation              = terra.Rotation.Right

    local verticalMoveDirection = terra.Movement.Up
    local verticalDigDirection  = terra.Direction.Up



    if dimensions.z < 0 then
        terra.rotate(terra.Rotation.Left)
        terra.rotate(terra.Rotation.Left)

        dimensions.x = -dimensions.x
    end
    if dimensions.x < 0 then
        rotation = terra.Rotation.Left
    end
    if dimensions.y < 0 then
        verticalMoveDirection = terra.Movement.Down
        verticalDigDirection  = terra.Direction.Down
    end

    dimensions.x = math.abs(dimensions.x)
    dimensions.y = math.abs(dimensions.y)
    dimensions.z = math.abs(dimensions.z)



    terra.dig(terra.Direction.Forward)
    terra.move(terra.Movement.Forward)

    for _ = 1, dimensions.y do
        for _ = 1, dimensions.x do
            for _ = 1, dimensions.z - 1 do
                inventory.select(config.InspectSlot)
                terra.dig(terra.Direction.Forward)

                local stackSlot = inventory.find_free_or_empty(inventory.at(config.InspectSlot).identifier)
                if stackSlot and stackSlot ~= config.InspectSlot then
                    inventory.transfer(config.InspectSlot, stackSlot)
                    terra.move(terra.Movement.Forward, position, orientation)
                else
                    print("Depositing items")
                    error("Not implemented~")
                end
            end

            if _ < dimensions.x then
                terra.rotate(rotation, orientation)
                terra.dig(terra.Direction.Forward)
                terra.move(terra.Movement.Forward, position, orientation)
                terra.rotate(rotation, orientation)

                if     rotation == terra.Rotation.Left  then rotation = terra.Rotation.Right
                elseif rotation == terra.Rotation.Right then rotation = terra.Rotation.Left
                end
            end
        end

        if _ < dimensions.y then
            terra.dig(verticalDigDirection)
            terra.move(verticalMoveDirection, position, orientation)
            terra.rotate(terra.Rotation.Left, orientation)
            terra.rotate(terra.Rotation.Left, orientation)
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

local function refuel(amount)
    io.write("Fuel level inadequate, refueling...\n")

    turtle.select(1)
    if turtle.refuel(0) and not turtle.refuel(amount) then error("Not enough fuel")
    else error("Invalid fuel source!")
    end
end

local function main(argv, argc)
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



    local volume       = math.volume(dimensions)
    local distance     = math.manhattan_distance(dimensions)
    local maxDistance  = volume + distance + 2 --semi worst case (not calculating deposit runs)
    local requiredFuel = maxDistance - turtle.getFuelLevel()

    if requiredFuel > 0 then refuel(requiredFuel) end



    term.clear()
    term.setCursorPos(1, 1)

    io.write("Beginning excavation...\n")
    io.write("Volume: " .. math.volume(dimensions) .. " blocks.\n")

    mine_area(dimensions)

    io.write("Excavation complete.\n")
end



local argv = {...}
local argc = #argv

main(argv, argc)
