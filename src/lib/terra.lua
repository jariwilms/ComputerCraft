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
function terra.turn(rotation, repetitions, orientation)
    repetitions = repetitions or 1
    orientation = orientation or terra.Orientation.new()

    for _ = 1, repetitions do
        if     rotation == terra.Rotation.Left  then
            repeat until turtle.turnLeft()

            orientation[0] = orientation[0] + 1
            if orientation[0] == 5 then orientation[0] = terra.Orientation.Forward end
        elseif rotation == terra.Rotation.Right then
            repeat until turtle.turnRight()

            orientation[0] = orientation[0] - 1
            if orientation[0] == 0 then orientation[0] = terra.Orientation.Right end
        else   error("Invalid Rotation!")
        end
    end
end

---@param direction    terra.Direction
---@param distance?    integer
---@param position?    any
---@param orientation? terra.Orientation
function terra.move(direction, distance, position, orientation)
    distance    = distance    or 1
    position    = position    or vector.new()
    orientation = orientation or terra.Orientation.new()

    for _ = 1, distance do
        if     direction == terra.Direction.Forward  then
            repeat until turtle.forward()

            if orientation[0] == terra.Orientation.Forward  then position.z = position.z + 1 end
            if orientation[0] == terra.Orientation.Left     then position.x = position.x - 1 end
            if orientation[0] == terra.Orientation.Backward then position.z = position.z - 1 end
            if orientation[0] == terra.Orientation.Right    then position.x = position.x + 1 end
        elseif direction == terra.Direction.Backward then
            repeat until turtle.back()

            if orientation[0] == terra.Orientation.Forward  then position.z = position.z - 1 end
            if orientation[0] == terra.Orientation.Left     then position.x = position.x + 1 end
            if orientation[0] == terra.Orientation.Backward then position.z = position.z + 1 end
            if orientation[0] == terra.Orientation.Right    then position.x = position.x - 1 end
        elseif direction == terra.Direction.Left     then
            terra.turn(terra.Rotation.Left, 1, orientation)
            terra.move(terra.Direction.Forward, 1, position, orientation)
            terra.turn(terra.Rotation.Right, 1, orientation)
        elseif direction == terra.Direction.Right    then
            terra.turn(terra.Rotation.Right, 1, orientation)
            terra.move(terra.Direction.Forward, 1, position, orientation)
            terra.turn(terra.Rotation.Left, 1, orientation)
        elseif direction == terra.Direction.Up       then
            repeat until turtle.up()

            position.y = position.y + 1
        elseif direction == terra.Direction.Down     then
            repeat until turtle.down()

            position.y = position.y - 1
        else   error("Invalid Direction!")
        end
    end
end

---@param digDirection? terra.DigDirection
function terra.dig(digDirection)
    digDirection = digDirection or terra.DigDirection.Front

    if     digDirection == terra.DigDirection.Front then repeat until turtle.dig()
    elseif digDirection == terra.DigDirection.Up    then repeat until turtle.digUp()
    elseif digDirection == terra.DigDirection.Down  then repeat until turtle.digDown()
    else   error("Invalid DigDirection!")
    end
end

return terra
