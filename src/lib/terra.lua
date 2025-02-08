local meta = require("/lib/meta")

local terra =
{
    ---@enum terra.Direction
    Direction    = meta.read_only
    ({
        Forward  = 1,
        Backward = 2,
        Left     = 3,
        Right    = 4,
        Up       = 5,
        Down     = 6,
    }),
    ---@enum terra.Orientation
    Orientation  = meta.read_only
    ({
        new = function()
            return setmetatable({ [0] = 1 }, {})
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
    ---@enum terra.DigDirection
    DigDirection = meta.read_only
    ({
        Front = 1,
        Up    = 2,
        Down  = 3,
    }),
}

---@param  rotation     terra.Rotation
---@param  orientation? terra.Orientation
---@return              boolean
function terra.turn(rotation, orientation)
    orientation = orientation or terra.Orientation.new()

    if     rotation == terra.Rotation.Left  then
        if not turtle.turnLeft() then return false end

        orientation[0] = orientation[0] + 1
        if orientation[0] == 5 then orientation[0] = terra.Orientation.Forward end
    elseif rotation == terra.Rotation.Right then
        if not turtle.turnRight() then return false end

        orientation[0] = orientation[0] - 1
        if orientation[0] == 0 then orientation[0] = terra.Orientation.Right end
    else   error("Invalid Rotation!")
    end

    return true
end

---@param  rotation     terra.Rotation
---@param  orientation? terra.Orientation
function terra.force_turn(rotation, orientation)
    repeat until terra.turn(rotation, orientation)
end

---@param  direction    terra.Direction
---@param  position?    any
---@param  orientation? terra.Orientation
---@return              boolean
function terra.move(direction, position, orientation)
    position    = position    or vector.new()
    orientation = orientation or terra.Orientation.new()

    if     direction == terra.Direction.Forward  then
        if not turtle.forward() then return false end

        if orientation[0] == terra.Orientation.Forward  then position.z = position.z + 1 end
        if orientation[0] == terra.Orientation.Left     then position.x = position.x - 1 end
        if orientation[0] == terra.Orientation.Backward then position.z = position.z - 1 end
        if orientation[0] == terra.Orientation.Right    then position.x = position.x + 1 end
    elseif direction == terra.Direction.Backward then
        if not turtle.back() then return false end

        if orientation[0] == terra.Orientation.Forward  then position.z = position.z - 1 end
        if orientation[0] == terra.Orientation.Left     then position.x = position.x + 1 end
        if orientation[0] == terra.Orientation.Backward then position.z = position.z + 1 end
        if orientation[0] == terra.Orientation.Right    then position.x = position.x - 1 end
    elseif direction == terra.Direction.Left     then
        terra.turn(terra.Rotation.Left, orientation)
        terra.move(terra.Direction.Forward, position, orientation)
        terra.turn(terra.Rotation.Right, orientation)
    elseif direction == terra.Direction.Right    then
        terra.turn(terra.Rotation.Right, orientation)
        terra.move(terra.Direction.Forward, position, orientation)
        terra.turn(terra.Rotation.Left, orientation)
    elseif direction == terra.Direction.Up       then
        if not turtle.up() then return false end

        position.y = position.y + 1
    elseif direction == terra.Direction.Down     then
        if not turtle.down() then return false end

        position.y = position.y - 1
    else   error("Invalid Direction!")
    end

    return true
end

---@param  direction    terra.Direction
---@param  position?    any
---@param  orientation? terra.Orientation
function terra.force_move(direction, position, orientation)
    repeat until terra.move(direction, position, orientation)
end

---@param  direction? terra.DigDirection
---@return            boolean
function terra.dig(direction)
    direction = direction or terra.DigDirection.Front

    if     direction == terra.DigDirection.Front then return turtle.dig()
    elseif direction == terra.DigDirection.Up    then return turtle.digUp()
    elseif direction == terra.DigDirection.Down  then return turtle.digDown()
    else   error("Invalid DigDirection!")
    end
end

---@param  direction? terra.DigDirection
function terra.force_dig(direction)
    repeat until terra.dig(direction) and not turtle.inspect()
end

return terra
