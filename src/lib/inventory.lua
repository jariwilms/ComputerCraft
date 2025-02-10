local config = require("/cfg/inventory")
local item   = require("/lib/item")



---Represents the internal state of a turtle's inventory
---Indices are valid in the range [1, config.InventorySlots]
---Methods are never dependent on the selected slot
---@class inventory
local inventory = {}

---@param index integer
function inventory.in_bounds(index)
    return index >= 1 and index <= config.InventorySlots
end

---@param index integer
function inventory.update(index)
    if not inventory.in_bounds(index) then error("Index out of range!", 2) end

    local data = turtle.getItemDetail(index)

    if data then inventory[index] = item.new(data.name, data.count, data.count + turtle.getItemSpace(index), data.damage)
    else         inventory[index] = item.empty()
    end
end

function inventory.update_all()
    for index, _ in ipairs(inventory) do
        inventory.update(index)
    end
end

---@param  index integer
---@return       item
function inventory.at(index)
    if not inventory.in_bounds(index) then error("Index out of range!", 2) end

    return item.copy(inventory[index])
end

function inventory.select(index)
    if not inventory.in_bounds(index)    then error("Index out of range!", 2) end
    if index == inventory.selected.index then return end

    turtle.select(index)
    inventory.selected = index

    return index
end

function inventory.select_free_or_empty(identifier)
    local predicate = function(_) return _.identifier == identifier and _.count < _.limit end
    local slot      = inventory.find_if(predicate) or inventory.find(item.empty().identifier)

    if slot then return inventory.select(slot)
    else         return nil
    end
end

---@param  identifier string
---@return            integer?
function inventory.find(identifier)
    for index, value in ipairs(inventory) do
        if identifier == value.identifier then return index end
    end

    return nil
end

---@param  predicate function(_: item): boolean
---@return           integer?
function inventory.find_if(predicate)
    for index, value in ipairs(inventory) do
        if predicate(value) then return index end
    end

    return nil
end

---@param  identifier string
---@return            table
function inventory.find_all(identifier)
    local list = {}

    for index, value in ipairs(inventory) do
        if identifier == value.identifier then list[index] = item.copy(value) end
    end

    return list
end

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

---@param index   integer
---@param amount? integer
function inventory.drop(index, amount)
    if not inventory.in_bounds(index) then error("Index out of range!", 2) end
    if not amount or amount < 1       then return end

    turtle.select(index)
    turtle.drop(math.min(amount, inventory[index].count))

    inventory.update(index)
end

function inventory.drop_all()
    for index, _ in ipairs(inventory) do
        turtle.select(index)
        turtle.drop()
    end

    inventory.update_all()
end

---@return boolean
function inventory.full()
    local empty = item.empty()

    for _, value in ipairs(inventory) do
        if value == empty then return false end
    end

    return true
end

---@return boolean
function inventory.empty()
    local empty = item.empty()

    for _, value in ipairs(inventory) do
        if value ~= empty then return true end
    end

    return false
end

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



---@return inventory
local function __()
    for i = 1, config.InventorySlots, 1 do
        inventory.update(i)
    end

    inventory.selected = turtle.getSelectedSlot()

    setmetatable(inventory,
    {
        __metatable = {},
        __newindex  = function (table, key, value)
            local kn = tonumber(key)

            if     key == "selected" then
                local vn = tonumber(value)

                if vn and inventory.in_bounds(vn) then inventory.selected = vn
                else                                   error("Selected index must be a number!")
                end
            elseif kn and inventory.in_bounds(kn) then
                if getmetatable(value) == item then table[key] = value
                else                                error("Inventory index keys must be of type 'Item'!")
                end
            else   error("Invalid key and/or value!\nKey: " .. key .. "\nValue: " .. value, 2)
            end
        end,
    })

    return inventory
end

return __()
