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

---@param rotation     terra.Rotation
---@param repetitions? integer
---@param orientation? terra.Orientation
---@return             boolean
function terra.turn(rotation, repetitions, orientation)
    repetitions = repetitions or 1
    orientation = orientation or terra.Orientation.new()

    for _ = 1, repetitions do
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
    end

    return false
end

---@param direction    terra.Direction
---@param distance?    integer
---@param position?    any
---@param orientation? terra.Orientation
---@return             boolean
function terra.move(direction, distance, position, orientation)
    distance    = distance    or 1
    position    = position    or vector.new()
    orientation = orientation or terra.Orientation.new()

    for _ = 1, distance do
        if     direction == terra.Direction.Forward  then
            if turtle.forward() then
                if orientation[0] == terra.Orientation.Forward  then position.z = position.z + 1 end
                if orientation[0] == terra.Orientation.Left     then position.x = position.x - 1 end
                if orientation[0] == terra.Orientation.Backward then position.z = position.z - 1 end
                if orientation[0] == terra.Orientation.Right    then position.x = position.x + 1 end

                return true
            end
        elseif direction == terra.Direction.Backward then
            if turtle.back() then
                if orientation[0] == terra.Orientation.Forward  then position.z = position.z - 1 end
                if orientation[0] == terra.Orientation.Left     then position.x = position.x + 1 end
                if orientation[0] == terra.Orientation.Backward then position.z = position.z + 1 end
                if orientation[0] == terra.Orientation.Right    then position.x = position.x - 1 end

                return true
            end
        elseif direction == terra.Direction.Left     then
            terra.turn(terra.Rotation.Left, 1, orientation)
            terra.move(terra.Direction.Forward, 1, position, orientation)
            terra.turn(terra.Rotation.Right, 1, orientation)

            return true
        elseif direction == terra.Direction.Right    then
            terra.turn(terra.Rotation.Right, 1, orientation)
            terra.move(terra.Direction.Forward, 1, position, orientation)
            terra.turn(terra.Rotation.Left, 1, orientation)

            return true
        elseif direction == terra.Direction.Up       then
            if turtle.up()   then
                position.y = position.y + 1

                return true
            end
        elseif direction == terra.Direction.Down     then
            if turtle.down() then
                position.y = position.y - 1

                return true
            end
        else   error("Invalid Direction!")
        end
    end

    return false
end

---@param digDirection terra.DigDirection
---@return             boolean
function terra.dig(digDirection)
    digDirection = digDirection or terra.DigDirection.Front

    if     digDirection == terra.DigDirection.Front then return turtle.dig()
    elseif digDirection == terra.DigDirection.Up    then return turtle.digUp()
    elseif digDirection == terra.DigDirection.Down  then return turtle.digDown()
    else   error("Invalid DigDirection!")
    end
end

return terra
