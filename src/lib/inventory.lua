local config = require("/cfg/inventory")
local item   = require("/lib/item")



---Represents the internal state of a turtle's inventory
---Indices are valid in the range [1, config.InventorySlots]
---Methods are never dependent on the selected slot
---@class inventory
local inventory = {}

---@param index integer
function inventory.update(index)
    local data = turtle.getItemDetail(index)

    if data then inventory.items[index] = item.new(data.name, data.count, data.count + turtle.getItemSpace(index), data.damage)
    else         inventory.items[index] = item.empty()
    end
end

function inventory.update_all()
    for index, _ in ipairs(inventory.items) do
        inventory.update(index)
    end
end

---@param  index integer
---@return       item
function inventory.at(index)
    return item.copy(inventory.items[index])
end

---@param index integer
function inventory.select(index)
    if inventory.items[index] and index ~= inventory.selected then
        turtle.select(index)
        inventory.selected = index
    end
end

---@param identifier string
---@return           integer|nil
function inventory.select_free_or_empty(identifier)
    local predicate = function(_) return _.identifier == identifier and _.count < _.limit end
    local slot      = inventory.find_if(predicate) or inventory.find(item.empty().identifier)

    if slot then inventory.select(slot) return slot
    else                                return nil
    end
end

---@param  identifier string
---@return            integer?
function inventory.find(identifier)
    for index, value in ipairs(inventory.items) do
        if identifier == value.identifier then return index end
    end

    return nil
end

---@param  predicate function(_: item): boolean
---@return           integer?
function inventory.find_if(predicate)
    for index, value in ipairs(inventory.items) do
        if predicate(value) then return index end
    end

    return nil
end

---@param  identifier string
---@return            table
function inventory.find_all(identifier)
    local list = {}

    for index, value in ipairs(inventory.items) do
        if identifier == value.identifier then list[index] = item.copy(value) end
    end

    return list
end

---@param  from    integer
---@param  to      integer
---@param  amount? integer
---@return         boolean
function inventory.transfer(from, to, amount)
    local fromItem = inventory.items[from]
    local toItem   = inventory.items[to]

    if fromItem.identifier ~= toItem.identifier            then return false end
    if fromItem.count == 0 or toItem.count == toItem.limit then return false end

    amount = math.min(math.max(amount or 0, 0), fromItem.count)

    turtle.select(from)
    turtle.transferTo(to, amount)
    inventory.update(from)
    inventory.update(to)

    return true
end

---@param  left  integer
---@param  right integer
---@return       boolean
function inventory.swap(left, right)
    if left == right then return true end

    local eid = item.empty().identifier

    if     inventory.items[left].identifier ~= eid and inventory.items[right].identifier ~= eid then
        local placeholder = inventory.find(eid)

        return placeholder ~= nil                           and
               inventory.transfer(left,        placeholder) and
               inventory.transfer(right,       left)        and
               inventory.transfer(placeholder, right)
    elseif inventory.items[left].identifier ~= eid and inventory.items[right].identifier == eid then
        return inventory.transfer(left, right)
    elseif inventory.items[left].identifier == eid and inventory.items[right].identifier ~= eid then
        return inventory.transfer(right, left)
    end

    return true
end

---@param index   integer
---@param amount? integer
function inventory.drop(index, amount)
    if not amount or amount < 0 or amount > 64 then amount = inventory.items[index].count end

    turtle.select(index)
    turtle.drop(amount)

    inventory.update(index)
end

function inventory.drop_all()
    for index, _ in ipairs(inventory.items) do
        turtle.select(index)
        turtle.drop()
    end
end

---@return boolean
function inventory.full()
    local empty = item.empty()

    for _, value in ipairs(inventory.items) do
        if value == empty then return false end
    end

    return true
end

---@return boolean
function inventory.empty()
    local empty = item.empty()

    for _, value in ipairs(inventory.items) do
        if value ~= empty then return true end
    end

    return false
end

---@param offset integer
function inventory.defragment(offset)
    error("Not implemented!")

    -- local startIndex = 1
    -- local endIndex   = 16

    -- if offset > 0 then startIndex = startIndex + offset end
    -- if offset < 0 then endIndex   = endIndex   - offset end

    -- if startIndex > 15 or endIndex < 2 then error("Offset out of range") end


    -- local candidates = {}
    -- for i = startIndex, endIndex, 1 do
    --     local it        = inventory.at(i)

    --     for key, value in pairs(candidates) do
    --         if value == it then
    --             while true do --while the amount of space in the current slot is gt 0 and candidate => transfer

    --             end
    --             inventory.transfer(i, key, value.spaceLeft)
    --         end
    --     end



    --     local spaceLeft = it.limit - it.count

    --     if spaceLeft then
    --         candidates[i] = { identifier = it.identifier, spaceLeft = spaceLeft }
    --     end
    -- end
end



---@return inventory
local function __()
    inventory.items    = {}
    inventory.selected = turtle.getSelectedSlot()

    for i = 1, config.TurtleInventorySlots, 1 do
        inventory.update(i)
    end

    setmetatable(inventory.items,
    {
        __index = function(self, k)
            error("Index out of range!", 2)
        end,
        __newindex = function(self, k, v)
            if getmetatable(v) ~= getmetatable(item) then error("Attempting to set a non-item value!", 2) end

            self[k] = v
        end
    })

    return inventory
end

return __()
