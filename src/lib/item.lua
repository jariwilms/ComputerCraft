---Represents an item in a turtle's inventory
---@class item
---@field identifier string
---@field count      integer
---@field limit      integer
---@field damage     number
local item  = {}
local empty = {}

---@param identifier string
---@param count      integer
---@param limit      integer
---@param damage?    number
---@return           item
function item.new(identifier, count, limit, damage)
    return setmetatable({ identifier = identifier, count = count, limit = limit, damage = damage or 0 }, getmetatable(item))
end

---@param  other item
---@return       item
function item.copy(other)
    return item.new(other.identifier, other.count, other.limit, other.damage)
end

---@return item
function item.empty()
    return empty
end



local function __()
    setmetatable(item,
    {
        __eq        = function (left, right) return left.identifier == right.identifier end,
        __tostring  = function (_)           return _.identifier .. ", [" .. _.count .. "/" .. _.limit .. "], " .. _.damage end,
    })

    empty = item.new("cc:none", 0, 0, 0)

    return item
end

return __()
