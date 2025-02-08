local config = require("/cfg/inventory")
local item   = require("/lib/item")



---Represents the internal state of a turtle's inventory
---Indices are valid in the range [1, config.InventorySlots]
---Methods are never dependent on the selected slot
---@class inventory
local inventory = {}

---Creates a new inventory
---@return inventory
function inventory:new()
    setmetatable(self, inventory)

    self.__index = self
    self:update_all()

    return self
end

---Returns true if the given index is valid
---@param index integer
function inventory:in_bounds(index)
    return index >= 1 and index <= config.InventorySlots
end

---Updates the inventory slot at index or selected if no index is given
---@param index integer
function inventory:update(index)
    if not self:in_bounds(index) then error("Index out of range!", 2) end

    local data = turtle.getItemDetail(index)

    if data then self[index] = item.new(data.name, data.count, data.count + turtle.getItemSpace(index), data.damage)
    else         self[index] = item.empty()
    end
end

---Updates all inventory slots
function inventory:update_all()
    for index, _ in ipairs(self) do
        self:update(index)
    end
end

---Returns the item at the given index
---@param  index integer
---@return       item
function inventory:at(index)
    if not self:in_bounds(index) then error("Index out of range!", 2) end

    return item.copy(self[index])
end

---Returns the first index of an item with the given identifier
---@param  identifier string
---@return            integer?
function inventory:find(identifier)
    for index, value in ipairs(self) do
        if identifier == value.identifier then return index end
    end

    return nil
end

---Returns a table with indices of items with the given identifier
---@param  identifier string
---@return            table
function inventory:find_all(identifier)
    local list = {}

    for index, value in ipairs(self) do
        if identifier == value.identifier then list[index] = item.copy(value) end
    end

    return list
end

---Transfer an amount of items from one slot to another
---@param  from    integer
---@param  to      integer
---@param  amount? integer
---@return         boolean
function inventory:transfer(from, to, amount)
    if not self:in_bounds(from) then error("Index out of range!", 2) end
    if not self:in_bounds(to)   then error("Index out of range!", 2) end

    if turtle.select(from) and turtle.transferTo(to, amount) then
        self:update(from)
        self:update(to)

        return true
    end

    return false
end

---Swap two item slots
---@param  left  integer
---@param  right integer
---@return       boolean
function inventory:swap(left, right)
    if not self:in_bounds(left)  then error("Index out of range!", 2) end
    if not self:in_bounds(right) then error("Index out of range!", 2) end

    if left == right then return true  end

    local empty = item.empty()
    if     self[left].identifier ~= empty.identifier and self[right].identifier ~= empty.identifier then
        local placeholder = self:find(item.empty().identifier)
        if not placeholder then return false end

        if not self:transfer(left,        placeholder) or
           not self:transfer(right,       left)        or
           not self:transfer(placeholder, right)       then return false end
    elseif self[left].identifier ~= empty.identifier and self[right].identifier == empty.identifier then
        return self:transfer(left, right)
    elseif self[left].identifier == empty.identifier and self[right].identifier ~= empty.identifier then
        return self:transfer(right, left)
    end

    return true
end

---Drops an amount of items from the given index
---@param index   integer
---@param amount? integer
function inventory:drop(index, amount)
    if not self:in_bounds(index) then error("Index out of range!", 2) end
    if not amount or amount < 1       then return end

    turtle.select(index)
    turtle.drop(math.min(amount, self[index].count))

    self:update(index)
end

---Drops all items
function inventory:drop_all()
    for index, _ in ipairs(self) do
        turtle.select(index)
        turtle.drop()
    end

    self:update_all()
end

---Returns true if all slots are full
---@return boolean
function inventory:full()
    local empty = item.empty()

    for _, value in ipairs(self) do
        if value.identifier == empty.identifier then return false end
    end

    return true
end

---Returns true if all slots are empty
---@return boolean
function inventory:empty()
    local empty = item.empty()

    for _, value in ipairs(self) do
        if value.identifier ~= empty.identifier then return true end
    end

    return false
end

---Groups blocks of the same type that have not reached their maximum stack size
---@param offset integer
function inventory:defragment(offset)
    error("Not implemented!")

    local startIndex = 1
    local endIndex   = 16

    if offset > 0 then startIndex = startIndex + offset end
    if offset < 0 then endIndex   = endIndex   - offset end

    if startIndex > 15 or endIndex < 2 then error("Offset out of range") end


    local candidates = {}
    for i = startIndex, endIndex, 1 do
        local it        = self:at(i)

        for key, value in pairs(candidates) do
            if value.identifier == it.identifier then
                while true do --while the amount of space in the current slot is gt 0 and candidate => transfer

                end
                self:transfer(i, key, value.spaceLeft)
            end
        end



        local spaceLeft = it.limit - it.count

        if spaceLeft then
            candidates[i] = { identifier = it.identifier, spaceLeft = spaceLeft }
        end
    end
end



return inventory

