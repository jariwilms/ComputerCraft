---@class item
---@field identifier string
---@field count      integer
---@field limit      integer
---@field damage     number
local item = {}

---Creates a new item
---@param identifier string
---@param count      integer
---@param limit      integer
---@param damage?    number
---@return           item
function item.new(identifier, count, limit, damage)
    return setmetatable({ identifier = identifier, count = count, limit = limit, damage = damage or 0 },
    {
        __tostring = function (self) return self.identifier .. ", [" .. self.count .. "/" .. self.limit .. "], " .. self.damage end
    })
end

---Copies an item
---@param  other item
---@return       item
function item.copy(other)
    return item.new(other.identifier, other.count, other.limit, other.damage)
end

---Creates an empty item
---@return item
function item.empty()
    return item.new("None", 0, 0, 0)
end

---Compares items by identifier
---@param  left  item
---@param  right item
---@return       boolean
function item.__eq(left, right)
    return
        left.identifier == right.identifier --and
        --left.count      == right.count      and
        --left.limit      == right.limit      and
        --left.damage     == right.damage
end




---@class inventory
local inventory =
{
    [ 1] = item.empty(),
    [ 2] = item.empty(),
    [ 3] = item.empty(),
    [ 4] = item.empty(),
    [ 5] = item.empty(),
    [ 6] = item.empty(),
    [ 7] = item.empty(),
    [ 8] = item.empty(),
    [ 9] = item.empty(),
    [10] = item.empty(),
    [11] = item.empty(),
    [12] = item.empty(),
    [13] = item.empty(),
    [14] = item.empty(),
    [15] = item.empty(),
    [16] = item.empty(),
}

function inventory.check_bounds(index)
    if index < 1 or index > 16 then error("Index out of range!", 2) end
end

---Updates the inventory slot at index or selected if no index is given
---@param index? integer
function inventory.update(index)
    index = index or turtle.getSelectedSlot()
    inventory.check_bounds(index)

    local data = turtle.getItemDetail(index)
    if data then inventory[index] = item.new(data.name, data.count, turtle.getItemSpace(index), data.damage) end
end

---Updates all inventory slots
function inventory.update_all()
    for index, _ in ipairs(inventory) do
        inventory.update(index)
    end
end

---Returns the item at the given index
---@param  index integer
---@return       item
function inventory.at(index)
    inventory.check_bounds(index)

    return item.copy(inventory[index])
end

---Returns the first index of an item with the given identifier
---@param  identifier string
---@return            integer?
function inventory.find(identifier)
    for index, value in ipairs(inventory) do
        if identifier == value.identifier then return index end
    end

    return nil
end

---Returns a table with indices of items with the given identifier
---@param  identifier string
---@return            table
function inventory.find_all(identifier)
    local list = {}

    for index, value in ipairs(inventory) do
        if identifier == value.identifier then list[index] = item.copy(value) end
    end

    return list
end

---Transfer an amount of items from one slot to another
---@param  from    integer
---@param  to      integer
---@param  amount? integer
---@return         boolean
function inventory.transfer(from, to, amount)
    if from ~= to and turtle.select(from) and turtle.transferTo(to, amount) then
        inventory[to]   = inventory[from]
        inventory[from] = item.empty()

        return true
    end

    return false
end

---Swap two item slots
---@param  left  integer
---@param  right integer
---@return       boolean
function inventory.swap(left, right)
    if left == right    then return false end
    if inventory.full() then return false end

    local placeholder = inventory.find(item.empty().identifier)
    if not placeholder then return false end

    inventory.transfer(left,        placeholder)
    inventory.transfer(right,       left)
    inventory.transfer(placeholder, right)

    return true
end

---Drops an amount of items from the given index
---@param index   integer
---@param amount? integer
function inventory.drop(index, amount)
    inventory.check_bounds(index)

    if amount and amount > 0 then amount = math.min(amount, inventory[index].count)
    else                          amount = inventory[index].count
    end

    turtle.select(index)
    turtle.drop(amount)

    inventory[index] = item.empty()
end

---Drops all items
function inventory.drop_all()
    for index, _ in ipairs(inventory) do
        turtle.select(index)
        turtle.drop(index)
    end

    inventory.update_all()
end

---Returns true if all slots are full
---@return boolean
function inventory.full()
    local empty = item.empty()

    for _, value in ipairs(inventory) do
        if value == empty then return false end
    end

    return true
end

---Returns true if all slots are empty
---@return boolean
function inventory.empty()
    local empty = item.empty()

    for _, value in ipairs(inventory) do
        if value ~= empty then return true end
    end

    return false
end

---Groups blocks of the same type that have not reached their maximum stack size
---@param offset integer
function inventory.defragment(offset)
    error("Not implemented!")

    local startIndex = 1
    local endIndex   = 16

    if offset > 0 then startIndex = startIndex + offset end
    if offset < 0 then endIndex   = endIndex   - offset end

    if startIndex > 15 or endIndex < 2 then error("Offset out of range") end


    local candidates = {}
    for i = startIndex, endIndex, 1 do
        local it        = inventory.at(i)

        for key, value in pairs(candidates) do
            if value.identifier == it.identifier then
                while true do --while the amount of space in the current slot is gt 0 and candidate => transfer

                end
                inventory.transfer(i, key, value.spaceLeft)
            end
        end



        local spaceLeft = it.limit - it.count

        if spaceLeft then
            candidates[i] = { identifier = it.identifier, spaceLeft = spaceLeft }
        end
    end
end


setmetatable(inventory,
{
    __tostring = function(self)
        local str = ""
        for _, value in ipairs(self) do
            str = str .. tostring(value) .. "\n"
        end

        return str
    end
})






