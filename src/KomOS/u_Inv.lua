--Inventory utils

--Globals

--Class
Inventory = {data = {
}}

function Inventory.__init__ (data)
    local self = {data=data}
    setmetatable (self, {__index=Inventory})
    return self
end

setmetatable (Inventory, {__call=Inventory.__init__})

--functions
function Inventory:GetInv()
    InvData = {}
    for i=1, 16 do
		local data = turtle.getItemDetail(i)
		if data == nil then
			InvData[i] = {name = "nil", count = 0}
        else
            InvData[i] = {name = data["name"], count = data["count"]}
        end
	end
    return InvData
end

function Inventory:GetFirstItem(Item)
    for i=1, 16 do
        local success, data = turtle.getItemDetail(i)
        if success then
            if string.find(data["name"], Item) then
                return true, i, data["count"]
            end
        end
    end
    return false, -1, 0
end

function Inventory:GetAllItem(Item)
    local ItemSlotsFound = 0
    local ItemData = {}
    for i=1, 16 do
        local data = turtle.getItemDetail(i)
        if data ~= nil then
            if string.find(data["name"], Item) then
                ItemSlotsFound = ItemSlotsFound + 1
                ItemData[ItemSlotsFound] = {slot = i,  count = data["count"]}
            end
        end
    end
    return ItemData, ItemSlotsFound
end

function Inventory:GetItemCount(Item)
    local InvData, Slots = Inventory:GetAllItem(Item)
    local count = 0
    for i=1, Slots do
        count = count +InvData[i][2]
    end
    return count
end

function Inventory:SelectItem(Item)
    local success, slot, count = Inventory:GetFirstItem(Item)
    if success then
        turtle.select(slot)
    end
    return success
end

function Inventory:DropAllOfItem(Item)
    local InvData, Slots = Inventory:GetAllItem(Item)
    local count = 0
    for i=1, Slots do
        turtle.select(InvData[i][1])
        turtle.drop(InvData[i][2])
    end
    return count
end

function Inventory:Defrag()
    for i=1, 15 do
        local data = turtle.getItemDetail(i)
        if data ~= nil then
            print(data["name"].. " Found")
            local DefragInProc = true
            while DefragInProc do
                local InvData, Slots = Inventory:GetAllItem(data["name"])
                print(tostring(Slots).. " number of slots found")
                if Slots > 1 and data["count"] > 0 then
                    for j=1, Slots do
                        if i ~= InvData[j]["slot"] then
                            local NextSlot = j+1
                            if NextSlot > Slots then
                                NextSlot = 1
                            end
                            local SpaceLeft = turtle.getItemSpace(InvData[j]["slot"])
                            print(tostring(SpaceLeft).. " space left")
                            if SpaceLeft > 0 and InvData[NextSlot]["count"] > 0 and turtle.getItemSpace(InvData[NextSlot]["slot"]) ~= 0 then
                                print("Moving")
                                turtle.select(InvData[j]["slot"])
                                turtle.transferTo(InvData[NextSlot]["slot"], math.min(SpaceLeft,InvData[NextSlot]["count"]))
                            end
                        end
                    end
                end
                InvData, Slots = Inventory:GetAllItem(data["name"])
                local SlotsNotFilled = 0
                print("Checking if defrag is complete for item")
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