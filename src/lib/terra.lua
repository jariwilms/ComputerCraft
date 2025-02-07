local meta = require("/lib/meta")

local terra =
{
    Direction    = meta.read_only
    ({
        Forward  = 1,
        Backward = 2,
        Left     = 3,
        Right    = 4,
        Up       = 5,
        Down     = 6,
    }),
    Orientation  = meta.read_only
    ({
        Forward  = 1,
        Left     = 2,
        Backward = 3,
        Right    = 4,
    }),
    Rotation     = meta.read_only
    ({
        Left  = 1,
        Right = 2,
    }),
    Cardinal     = meta.read_only
    ({
        North = 1,
        East  = 2,
        South = 3,
        West  = 4,
    }),
    DigDirection = meta.read_only
    ({
        Front = 1,
        Up    = 2,
        Down  = 3,
    }),
}

function terra.turn(rotation, repetitions, orientation)
    repetitions = repetitions or 1
    orientation = orientation or terra.Orientation.Forward

    for _ = 1, repetitions do
        if     rotation == terra.Rotation.Left  then
            if turtle.turnLeft() then
                orientation = orientation + 1
                if orientation == 5 then orientation = terra.Orientation.Forward end
            end
        elseif rotation == terra.Rotation.Right then
            if turtle.turnRight() then
                orientation = orientation - 1
                if orientation == 0 then orientation = terra.Orientation.Right end
            end
        else   error("Invalid Rotation!")
        end
    end

    return orientation
end

function terra.move(direction, distance, position, orientation)
    for _ = 1, distance do
        if     direction == terra.Direction.Forward  then
            if turtle.forward() then
                if orientation == terra.Orientation.Forward  then position.z = position.z + 1 end
                if orientation == terra.Orientation.Left     then position.x = position.x - 1 end
                if orientation == terra.Orientation.Backward then position.z = position.z - 1 end
                if orientation == terra.Orientation.Right    then position.x = position.x + 1 end

                return true
            end
        elseif direction == terra.Direction.Backward then
            if turtle.back() then
                if orientation == terra.Orientation.Forward  then position.z = position.z - 1 end
                if orientation == terra.Orientation.Left     then position.x = position.x + 1 end
                if orientation == terra.Orientation.Backward then position.z = position.z + 1 end
                if orientation == terra.Orientation.Right    then position.x = position.x - 1 end

                return true
            end
        elseif direction == terra.Direction.Left     then
            orientation = terra.turn(terra.Rotation.Left, 1, orientation)
            terra.move(terra.Direction.Forward, 1, position, orientation)
            orientation = terra.turn(terra.Rotation.Right, 1, orientation)

            return true
        elseif direction == terra.Direction.Right    then
            orientation = terra.turn(terra.Rotation.Right, 1, orientation)
            terra.move(terra.Direction.Forward, 1, position, orientation)
            orientation = terra.turn(terra.Rotation.Left, 1, orientation)

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

function terra.dig(digDirection)
    if     digDirection == terra.DigDirection.Front then return turtle.dig()
    elseif digDirection == terra.DigDirection.Up    then return turtle.digUp()
    elseif digDirection == terra.DigDirection.Down  then return turtle.digDown()
    else   error("Invalid DigDirection!")
    end
end

return terra
