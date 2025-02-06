local math =
{
    volume = function (dimensions)
        local volume = 1

        for key, _ in pairs(dimensions) do
            volume = volume * math.abs(dimensions[key])
        end

        return volume
    end,
    manhattan_distance = function(dimensions)
        local distance = 0

        for key, _ in pairs(dimensions) do
            distance = distance + math.abs(dimensions[key])
        end

        return distance
    end,
}

return math
