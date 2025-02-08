local config = require("/cfg/inventory")
local item   = require("/lib/item")



---Represents the internal state of a turtle's inventory
---Indices are valid in the range [1, config.InventorySlots]
---Methods are never dependent on the selected slot
---@class inventory
local inventory = {}

---Returns true if the given index is valid
---@param index integer
function inventory.in_bounds(index)
    return index >= 1 and index <= config.InventorySlots
end

---Updates the inventory slot at index or selected if no index is given
---@param index integer
function inventory.update(index)
    if not inventory.in_bounds(index) then error("Index out of range!", 2) end

    local data = turtle.getItemDetail(index)

    if data then inventory[index] = item.new(data.name, data.count, data.count + turtle.getItemSpace(index), data.damage)
    else         inventory[index] = item.empty()
    end
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
    if not inventory.in_bounds(index) then error("Index out of range!", 2) end

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
    if not inventory.in_bounds(from) then error("Index out of range!", 2) end
    if not inventory.in_bounds(to)   then error("Index out of range!", 2) end

    if turtle.select(from) and turtle.transferTo(to, amount) then
        inventory.update(from)
        inventory.update(to)

        return true
    end

    return false
end

---Swap two item slots
---@param  left  integer
---@param  right integer
---@return       boolean
function inventory.swap(left, right)
    if not inventory.in_bounds(left)  then error("Index out of range!", 2) end
    if not inventory.in_bounds(right) then error("Index out of range!", 2) end

    if left == right then return true  end

    local empty = item.empty()

    if     inventory[left].identifier ~= empty.identifier and inventory[right].identifier ~= empty.identifier then
        local placeholder = inventory.find(item.empty().identifier)
        if not placeholder then return false end

        if not inventory.transfer(left,        placeholder) or
           not inventory.transfer(right,       left)        or
           not inventory.transfer(placeholder, right)       then return false end
    elseif inventory[left].identifier ~= empty.identifier and inventory[right].identifier == empty.identifier then
        return inventory.transfer(left, right)
    elseif inventory[left].identifier == empty.identifier and inventory[right].identifier ~= empty.identifier then
        return inventory.transfer(right, left)
    end

    return true
end

---Drops an amount of items from the given index
---@param index   integer
---@param amount? integer
function inventory.drop(index, amount)
    if not inventory.in_bounds(index) then error("Index out of range!", 2) end
    if not amount or amount < 1       then return end

    turtle.select(index)
    turtle.drop(math.min(amount, inventory[index].count))

    inventory.update(index)
end

---Drops all items
function inventory.drop_all()
    for index, _ in ipairs(inventory) do
        turtle.select(index)
        turtle.drop()
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
            if value == it then
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



---Initializes the inventory
---@return inventory
local function __()
    for i = 1, config.InventorySlots, 1 do
        inventory.update(i)
    end

    setmetatable(inventory,
    {
        __metatable = {},
        __newindex  = function (t, k, v)
            local n = tonumber(k)

            if not n or not inventory.in_bounds(n) then error("Updating non-item keys is not allowed!", 2) end
            if getmetatable(t) ~= item             then error("Table must be of type 'item'!") end

            t[k] = v
        end,
    })

    return inventory
end

return __()
