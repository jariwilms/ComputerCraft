local meta = require("lib/meta")

local mining =
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

return mining
