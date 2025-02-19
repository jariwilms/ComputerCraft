--Chest utils

--Globals

--Class
local Chest = {
    ChestInventory = {}
}

--functions
function Chest.Init(Inventory)
    local givenType = peripheral.getType(Inventory)
    if string.find(givenType, "inventory") then
        Chest.ChestInventory = Inventory
    end
end

function Chest.GetInvSlot(idx, InvData)
    local data = Chest.ChestInventory.getItemDetail(idx)
    if data ~= nil then
        table.insert(InvData, data)
    end
end

function Chest.GetDetailedInvParallel() --return InvData{name, count, displayName, damage, maxDamage, durability}
    local Funcs = {}
    local InvData = {}
    for i=1, Chest.ChestInventory.size() do
        table.insert(Funcs, i, function() Chest.GetInvSlot(i,InvData) end)
    end
    parallel.waitForAll(table.unpack(Funcs))
    return InvData
end


function Chest.GetSimpleInv() --return table{name, count}
    return Chest.ChestInventory.list() 
end

function Chest.GetFirstItem(Item) --return found, slot, count
    local list = Chest.GetDetailedInvParallel()
    for i=1, #list do
        local data = list[i]
        if data then
            if string.find(data["name"], Item) then
                return true, i, data["count"]
            end
        end
    end
    return false, -1, 0
end

function Chest.GetAllItem(Item) --return ItemData{name, count, displayName, damage, maxDamage, durability}, ItemSlotsFound
    local ItemSlotsFound = 0
    local ItemData = {}
    for i=1, 16 do
        local data = Chest.ChestInventory.getItemDetail(i)
        if data ~= nil then
            if string.find(data["name"], Item) then
                ItemSlotsFound = ItemSlotsFound + 1
                ItemData[ItemSlotsFound] = {slot = i,  count = data["count"]}
            end
        end
    end
    return ItemData, ItemSlotsFound 
end

function Chest.GetItemCount(Item) --return count
    local InvData, Slots = Chest.ChestInventory.GetAllItem(Item)
    local count = 0
    for i=1, Slots do
        count = count +InvData[i][2]
    end
    return count
end

function Chest.IsFull() --return full, ItemsMissing
    local ChestData = Chest.GetSimpleInv()
    local ItemsMissing = 0
    for i = 1, #ChestData do
        ItemsMissing = ItemsMissing + ChestData[i]["count"]
    end
    return ItemsMissing == 0, ItemsMissing
end

function Chest.HasFreeSlots() --return full, ItemsMissing
    local ChestData = Chest.GetSimpleInv()
    local total = 0
    for i = 1, #ChestData do
        if not ChestData[i] then
            total = total + 1
        end
    end
    return total == 0, total
end

function Chest.Defrag() --return success
    for i=1, Chest.ChestInventory.size() do
        local data = Chest.ChestInventory.getItemDetail(i)
        if data ~= nil then
            print(data["name"].. " Found")

            local DefragInProc = true
            while DefragInProc do
                local InvData, Slots = Chest.GetAllItem(data["name"])
                print(tostring(Slots).. " number of slots found")
                if Slots > 1 and data["count"] > 0 then
                    for j=1, Slots do
                        if i ~= InvData[j]["slot"] then
                            local SpaceLeft = Chest.ChestInventory.getItemSpace(i)
                            print(tostring(SpaceLeft).. " space left")
                            if SpaceLeft > 0 and InvData[j]["count"] > 0 and Chest.ChestInventory.getItemSpace(InvData[j]["slot"]) ~= 0 then
                                print("Moving")
                                Chest.ChestInventory.select(InvData[j]["slot"])
                                Chest.ChestInventory.transferTo(i, math.min(SpaceLeft,InvData[j]["count"]))
                            end
                        end
                    end
                end

                print("Checking if defrag is complete for item")
                InvData, Slots = Chest.GetAllItem(data["name"])
                local SlotsNotFilled = 0

                for k=1, Slots do
                    if InvData[k]["count"] ~= 0 and turtle.getItemSpace(InvData[k]["slot"]) ~= 0 then
                        SlotsNotFilled = SlotsNotFilled + 1
                    end
                end

                print("Number of slots not finished: "..tostring(SlotsNotFilled))
                if SlotsNotFilled < 2 then
                    DefragInProc = false
                end
            end
        end
    end
    return true
end

return Chest