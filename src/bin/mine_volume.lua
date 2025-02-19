local config    = require("/cfg/mine_volume")
local fuel      = require("/cfg/fuel")
local mathext   = require("/lib/math_ext")
local terra     = require("/lib/terra")
local inventory = require("/lib/inventory")
local item      = require("/lib/item")
local cmd       = require("/lib/cmd_utils")

---@param  distance integer
---@return          boolean
local function refuel(distance)
    if distance <= 0 then return true end

    inventory.select(config.FuelSlot)
    if not turtle.refuel(0) then error("Invalid fuel source!") end

    local slot   = inventory.at(config.FuelSlot)
    local energy = fuel[slot.identifier] or fuel.DefaultBurnTime --May severely overestimate
    local amount = distance / energy

    return turtle.refuel(amount)
end

---@param  distance integer
---@return          boolean
local function refuel_until(distance)
    return refuel(distance - turtle.getFuelLevel())
end

local function validate_inventory()
    if not fuel[inventory.at(1).identifier]                     then error("Fuel slot does not contain a valid fuel source!") end
    if inventory.at(2).identifier ~= "minecraft:redstone_torch" then error("Beacon slot does not contain a valid item!")      end
end

---@param dimensions any
local function mine_volume(dimensions)
    if dimensions.x == 0 or dimensions.y == 0 or dimensions.z == 0 then error("Dimensions may not be 0!") end

    local position              = vector.new()
    local orientation           = terra.Orientation.new()
    local rotation              = terra.Rotation.Right

    local verticalMoveDirection = terra.Movement.Up
    local verticalDigDirection  = terra.Direction.Up



    --Adjust initial setup according to given dimensions
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



    local volume        = math.volume(dimensions)
    local distance      = math.manhattan_distance(dimensions)
    local totalDistance = volume + distance + 2

    if not refuel_until(totalDistance) then error("Not enough fuel!") end

    io.write("Beginning excavation...\n")
    io.write("Volume: " .. volume .. " blocks\n")



    --Move into the to-be-mined volume
    terra.dig(terra.Direction.Forward)
    terra.move(terra.Movement.Forward)



    for _ = 1, dimensions.y do
        for _ = 1, dimensions.x do
            for _ = 1, dimensions.z - 1 do
                while terra.detect(terra.Direction.Forward) do
                    inventory.select(config.InspectSlot)
                    terra.dig(terra.Direction.Forward)
                    inventory.update(config.InspectSlot)

                    local index           = 1
                    local destinationSlot =
                        inventory.find_if(function(value)
                            local result = value.identifier == inventory.at(config.InspectSlot).identifier and value.count < value.limit and index ~= config.InspectSlot
                            index = index + 1

                            return result
                        end) or
                        inventory.find(item.empty().identifier)

                    if destinationSlot then
                        inventory.transfer(config.InspectSlot, destinationSlot)
                    else
                        for _ = position.y, 1, -1 do terra.move(terra.Movement.Down) end

                        if position.x > 0 then terra.orient_to(orientation, terra.Orientation.Left)
                        else                   terra.orient_to(orientation, terra.Orientation.Right)
                        end

                        for _ = position.x, 1, -1 do terra.move(terra.Movement.Forward) end
                        terra.orient_to(orientation, terra.Orientation.Backward)
                        for _ = position.z, 1, -1 do terra.move(terra.Movement.Forward) end

                        if config.OnChest then
                            --deposit items
                        else
                            goto END
                        end

                        terra.orient_to(orientation, terra.Orientation.Forward)
                        for _ = 1, position.z do terra.move(terra.Movement.Forward)     end

                        if position.x > 0 then terra.orient_to(orientation, terra.Orientation.Right)
                        else                   terra.orient_to(orientation, terra.Orientation.Left)
                        end

                        for _ = 1, position.x do terra.move(terra.Movement.Forward) end
                        for _ = 1, position.y do terra.move(terra.Movement.Up)      end
                   end
               end

               terra.move(terra.Movement.Forward, position, orientation)
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

    ::END::

    io.write("Excavation complete.\n")
end



local function main(args)
    term.clear()
    term.setCursorPos(1, 1)

    io.write("--Mine Area--\n")



    local dimensions = vector.new()
    local keys       = { "x", "y", "z" }
    local repeating  = false

    repeat
        if repeating then term.clear(); term.setCursorPos(1, 1)
        else              repeating = true
        end

        if     args["d"] and #args["d"] == 3 then
            for index, value in ipairs(args["d"]) do
                dimensions[keys[index]] = math.floor(value)
            end
        elseif args["t"] and #args["t"] == 1 then
            dimensions.x = 1
            dimensions.y = 2
            dimensions.z = args["t"][1]
        else
            for _, value in ipairs(keys) do
                io.write("Enter " .. value .. " coordinate: ")
                dimensions[value] = math.floor(read())
            end
        end

        if     args["c"]   then
            config.OnChest = true
        elseif args["nc"]  then
            config.OnChest = false
        else
            io.write("Is the turtle on a chest? [y/N] ")
            config.OnChest = cmd.validate_confirmation(read(), "y", "n", false)
        end

        if     args["b"]   then
            config.PlaceBeacon = true
        elseif args["nb"]  then
            config.PlaceBeacon = false
        else
            io.write("Should the turtle place a beacon? [y/N] ")
            config.PlaceBeacon = cmd.validate_confirmation(read(), "y", "n", false)
        end

        io.write("Dimensions:   <", dimensions:tostring(),       ">\n")
        io.write("On chest:     ",  tostring(config.OnChest),     "\n")
        io.write("Place beacon: ",  tostring(config.PlaceBeacon), "\n")
        io.write("\n")

        io.write("Is this correct? [Y/n] ")
    until cmd.validate_confirmation(read(), "y", "n", true)



    mine_volume(dimensions)
end



main(cmd.parse_arguments({...}))
