local math = {}

function math.volume(vector)
    local volume = 1

    for _, value in pairs(vector) do
        volume = volume * math.abs(value)
    end

    return volume
end

function math.manhattan_distance(vector)
    local distance = 0

    for _, value in pairs(vector) do
        distance = distance + math.abs(value)
    end

    return distance
end

return math
