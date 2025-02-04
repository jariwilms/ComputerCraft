for i=1, 16 do
    local success, data = turtle.getItemDetail(i)
    if success then
        local InvData, Slots = Inventory:GetAllItem(data["name"])
        if Slots > 1 and data.count > 0 then
            for j=1, Slots do
                if i == InvData[j].slot then
                    break
                end
                local SpaceLeft = turtle.getItemSpace(InvData[j].slot)
                if SpaceLeft > 0 and InvData.count > 0 and turtle.getItemSpace(InvData[j+1].slot) ~= 0 then
                    turtle.select(InvData[j].slot)
                    turtle.transferTo(InvData[j+1].slot, math.min(SpaceLeft,InvData[j+1].count))
                end
            end
        end
    end
end
