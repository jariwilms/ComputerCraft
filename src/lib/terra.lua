local meta = require("/lib/meta")

local terra =
{
    ---@enum terra.Movement
    Movement    = meta.read_only
    ({
        Forward  = 1,
        Backward = 2,
        Up       = 3,
        Down     = 4,
    }),
    ---@enum terra.Orientation
    Orientation  = meta.read_only
    ({
        ---Wraps an orientation so it can be passed as a reference
        ---@return terra.Orientation
        new = function()
            return { [0] = 1 }
        end,

        Forward  = 1,
        Left     = 2,
        Backward = 3,
        Right    = 4,
    }),
    ---@enum terra.Rotation
    Rotation     = meta.read_only
    ({
        Left  = 1,
        Right = 2,
    }),
    ---@enum terra.Cardinal
    Cardinal     = meta.read_only
    ({
        North = 1,
        East  = 2,
        South = 3,
        West  = 4,
    }),
    ---@enum terra.Direction
    Direction = meta.read_only
    ({
        Forward = 1,
        Up      = 2,
        Down    = 3,
    }),
}

---Inspects a block in a given direction
---@param   direction terra.Direction
---@returns           boolean, table/string
function terra.inspect(direction)
    if     direction == terra.Direction.Forward then return turtle.inspect()
    elseif direction == terra.Direction.Up      then return turtle.inspectUp()
    elseif direction == terra.Direction.Down    then return turtle.inspectDown()
    else   error("Invalid Direction!")
    end
end

---Move in a certain direction
---@param  movement     terra.Movement
---@param  position?    table
---@param  orientation? terra.Orientation ---Reference
---@return              boolean
function terra.move(movement, position, orientation)
    position    = position    or vector.new()
    orientation = orientation or terra.Orientation.new()

    if     movement == terra.Direction.Forward  then
        if turtle.forward() then
            if orientation[0] == terra.Orientation.Forward  then position.z = position.z + 1 end
            if orientation[0] == terra.Orientation.Left     then position.x = position.x - 1 end
            if orientation[0] == terra.Orientation.Backward then position.z = position.z - 1 end
            if orientation[0] == terra.Orientation.Right    then position.x = position.x + 1 end

            return true
        end
    elseif movement == terra.Direction.Backward then
        if turtle.back() then
            if orientation[0] == terra.Orientation.Forward  then position.z = position.z - 1 end
            if orientation[0] == terra.Orientation.Left     then position.x = position.x + 1 end
            if orientation[0] == terra.Orientation.Backward then position.z = position.z + 1 end
            if orientation[0] == terra.Orientation.Right    then position.x = position.x - 1 end

            return true
        end
    elseif movement == terra.Direction.Up       then
        if turtle.up() then
            position.y = position.y + 1

            return true
        end
    elseif movement == terra.Direction.Down     then
        if turtle.down() then
            position.y = position.y - 1

            return true
        end
    else   error("Invalid Direction!")
    end

    return false
end

---Force move in a certain direction
---@param  movement     terra.Movement
---@param  position?    table
---@param  orientation? terra.Orientation ---Reference
function terra.force_move(movement, position, orientation)
    repeat until terra.move(movement, position, orientation)
end

---
---@param  rotation     terra.Rotation
---@param  orientation? terra.Orientation ---Reference
---@return              boolean
function terra.rotate(rotation, orientation)
    orientation = orientation or terra.Orientation.new()

    if     rotation == terra.Rotation.Left  then
        if turtle.turnLeft() then
            orientation[0] = orientation[0] + 1
            if orientation[0] == 5 then orientation[0] = terra.Orientation.Forward end

            return true
        end
    elseif rotation == terra.Rotation.Right then
        if turtle.turnRight() then
            orientation[0] = orientation[0] - 1
            if orientation[0] == 0 then orientation[0] = terra.Orientation.Right end

            return true
        end
    else   error("Invalid Rotation!")
    end

    return false
end

---@param current terra.Orientation ---Reference
---@param target  terra.Orientation
function terra.orient_to(current, target)
    local difference = current[0] - target
    local rotation   = difference > 0 and terra.Rotation.Left or terra.Rotation.Right

    for _ = 1, difference, 1 do
        terra.rotate(rotation, current)
    end
end

---@param  rotation     terra.Rotation
---@param  orientation? terra.Orientation ---Reference
function terra.force_rotate(rotation, orientation)
    repeat until terra.rotate(rotation, orientation)
end

---Digs in a given direction if a block is detected
---@param  direction terra.Direction
---@return           table
function terra.dig(direction)
    local success, data = terra.inspect(direction)

    if success then
        if     direction == terra.Direction.Front then turtle.dig()
        elseif direction == terra.Direction.Up    then turtle.digUp()
        elseif direction == terra.Direction.Down  then turtle.digDown()
        else   error("Invalid Direction!")
        end

        return data
    end

    return {}
end

---@param direction terra.Direction
function terra.force_dig(direction)
    repeat until terra.dig(direction)
end

return terra
