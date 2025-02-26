    --Storage Program

    --Includes
    local ChestAPI = require("u_Chest")
    local Log = require("u_Log")
    local Config = require("u_Config")

    --Config
    Log.Init("l_Storage",true)

    if not fs.exists("c_Storage") then
        ConfigFile = fs.open("c_Storage", "w")
        ConfigFile.writeLine("Output: minecraft:barrel_0")
        ConfigFile.close()
    end

    Config:setPath("c_Storage")

    --Global
    local monitor = peripheral.wrap("top")
    --local chests = {peripheral.find("inventory")}
    local Output
    local item = {name = "", count = 0}
    local TotalList = {}
    local TotalCapacity = 0
    local CurrentCapacity = 0
    local DisplayList = {}
    local AutoFillNames = {}
    local filter = ""
    local minCount = 0
    local defaultTerm = term.current()

    --Data

    --Class

    --Functionw2
    function ScanAllChest()
        local chests = {peripheral.find("create:item_vault")}
        TotalList = {}

        Log.ClearLog()
        Log.Log(tostring(#chests).." chests found")
        for i = 1, #chests do
            local chestItems = chests[i].list()
            for j=1, #chestItems do
                if chestItems[j] ~= nil then
                    Log.Log(chestItems[j]["name"].." - "..tostring(chestItems[j]["count"]))
                    AddToTotalList(chestItems[j]["name"], chestItems[j]["count"])
                    
                end
            end
            Log.Log(tostring(#chestItems).." items added")
        end
    end

    function ScanAllChestDisplay()
        local chests = {peripheral.find("create:item_vault")}
        DisplayList = {}
        TotalCapacity = 0
        CurrentCapacity = 0

        for i = 1, #chests do
            local chestItems = chests[i].list()
            TotalCapacity = TotalCapacity + chests[i].size()
            for j=1, #chestItems do
                if chestItems[j] ~= nil then
                    AddToDisplayList(chestItems[j]["name"], chestItems[j]["count"])
                    CurrentCapacity = CurrentCapacity+1
                end
            end
        end
    end

    function AddToTotalList(ItemName, ItemCount)
        if TotalList then
            for index, value in pairs(TotalList) do
                if value["name"] == ItemName then
                    value["count"] = value["count"] + ItemCount
                    return true
                end
            end
        end
        table.insert(TotalList, {name = ItemName, count = ItemCount})
        return true
    end

    function AddToDisplayList(ItemName, ItemCount)
        if (filter == "" or string.find(ItemName, filter)) and ItemCount >= minCount then
            if DisplayList then
                for index, value in pairs(DisplayList) do
                    if value["name"] == ItemName then
                        value["count"] = value["count"] + ItemCount
                        return true
                    end
                end
            end
            table.insert(DisplayList, {name = ItemName, count = ItemCount})
            return true
        end
    end

    function GetInvSlot(Chest, idx, InvData)
        local data = Chest.getItemDetail(idx)
        if data ~= nil then
            table.insert(InvData, data)
        end
    end

    function GetDetailedInvFast(Chest) --return InvData{name, count, displayName, damage, maxDamage, durability}
        local Funcs = {}
        local InvData = {}
        for i=1, Chest.size() do
            table.insert(Funcs, i, function() GetInvSlot(Chest, i, InvData) end)
        end
        parallel.waitForAll(table.unpack(Funcs))
        return InvData
    end

    function PrintTotalList()
        if TotalList then
            for index, value in pairs(TotalList) do
            print(value.name..":\t\t"..value.count)
            end
        end
    end

    --Main
    --ScanAllChest()
    --PrintTotalList()

    function SetupOutput()
        Output = peripheral.wrap(Config:getData("Output"))
        Log.TermLog("Output: "..Config:getData("Output"))
        if not Output then
            Log.LogError("Output not found")
        end
    end

    function DrawMonitor()
        monitor.setTextScale(0.5)
        local xsize,ysize = monitor.getSize()
        local Scroll = 0
        local Run = true
        while Run do

            ScanAllChestDisplay()

            --Create Background window
            local WindowBackground = window.create(monitor, 1, 1, xsize, ysize)
            WindowBackground.setBackgroundColor(colors.gray)
            WindowBackground.clear()

            --Create Capacity window
            local WindowCapacity = window.create(monitor, 2, 2, 10, ysize-2)
            local XCap, yCap = WindowCapacity.getSize()
            WindowCapacity.setBackgroundColor(colors.white)
            WindowCapacity.clear()
            WindowCapacity.setCursorPos(2, 1)
            WindowCapacity.setTextColor(colors.black)
            WindowCapacity.write("Capacity")
            term.redirect(WindowCapacity)
            paintutils.drawFilledBox(2,2,XCap-1,yCap-1,colors.gray)
            local MaxBoxSize = yCap-1-2
            local CrrOverTotal = CurrentCapacity/TotalCapacity
            local Capsize = math.floor(MaxBoxSize*CrrOverTotal)
            paintutils.drawFilledBox(2,yCap-1-Capsize,XCap-1,yCap-1,colors.green)
            WindowCapacity.setCursorPos(2, yCap-2)
            WindowCapacity.setTextColor(colors.white)
            WindowCapacity.setBackgroundColor(colors.green)
            WindowCapacity.write(tostring(CurrentCapacity).."/")
            WindowCapacity.setCursorPos(2, yCap-1)
            WindowCapacity.write(tostring(TotalCapacity))


            --Create Item List window
            local WindowList = window.create(monitor, 14, 2, xsize-14-2, ysize-2)
            local XList, yList = WindowList.getSize()
            WindowList.setBackgroundColor(colors.white)
            WindowList.clear()
            WindowList.setCursorPos(2, 1)
            WindowList.setTextColor(colors.black)
            WindowList.write("List")
            term.redirect(WindowList)

            local TabLength = 41
            local TabAmount = math.floor(XList/TabLength)
            local ItemsPerTab = yList-4
            for iTab = 0, TabAmount-1 do
                local WindowTable = window.create(monitor, 15 + TabLength*iTab + 1*iTab, 3, TabLength, yList-2)
                local XTable, yTable = WindowTable.getSize()
                term.redirect(WindowTable)
                paintutils.drawFilledBox(2,2,XTable-1,yTable-1,colors.gray)

                for i = 1, yTable-2 do
                    WindowTable.setBackgroundColor(colors.gray)
                    if i % 2 == 0 then
                        paintutils.drawFilledBox(2,i+1,XTable-1,i+1,colors.lightGray)
                        WindowTable.setBackgroundColor(colors.lightGray)
                    end
                    if (i+Scroll+ItemsPerTab*iTab) < #DisplayList or (Scroll+ItemsPerTab*(iTab+1)) < #DisplayList then
                        WindowTable.setCursorPos(2, i+1)
                        local name = DisplayList[(i+Scroll+ItemsPerTab*iTab) % #DisplayList]["name"]
                        local displayname = name:gsub(".*:", "")
                        WindowTable.write(string.sub(displayname, 1, 32))
                        WindowTable.setCursorPos(2+31, i+1)
                        WindowTable.write(" - "..DisplayList[(i+Scroll+ItemsPerTab*iTab) % #DisplayList]["count"])
                    end
                end
            end

            Scroll = Scroll + ItemsPerTab*TabAmount
            if Scroll > #DisplayList then
                Scroll = 0
            end
            term.redirect(defaultTerm)
            sleep(2)
        end
    end

    function string.starts(String,Start)
        return string.sub(String,1,string.len(Start))==Start
    end

    function ParseCommand(String)
        local Args = {}
        for word in String:gmatch("%S+") do table.insert(Args, word) end
        local Command = Args[1]
        local Content = Args[2]
        local Count = tonumber(Args[3])
        return Command, Content, Count
    end

    function FetchItems(Name, Count)
        local CountReturned = 0
        local chests = {peripheral.find("create:item_vault")}
        for i, Chest in pairs(chests) do
            local InvData = Chest.list()
            if InvData then
                for j, Item in pairs(InvData) do
                    if string.find(Item["name"], Name) then
                        if Item["count"] < (Count - CountReturned) then
                            Output.pullItems(peripheral.getName(Chest), j, Item["count"])
                            CountReturned = CountReturned + Item["count"]
                        else
                            Output.pullItems(peripheral.getName(Chest), j, Count - CountReturned)
                            CountReturned = Count
                            return
                        end
                    end
                end
            end
        end
    end

    function CheckAvailability(Name, Count)
        for i, Item in pairs(TotalList) do
            if string.find(Item["name"], Name) then
                return Count <= Item["count"], Item["count"]
            end
        end
        Log.TermError("Given Item not found in storage")
    end

    function Stop()
        local Run = true
        while Run do
            ScanAllChest()
            term.redirect(defaultTerm)
            local Input = read()
            local Command, Content, Count = ParseCommand(Input)

            if Command == "get" then
                local success, ActualCount = CheckAvailability(Content, Count)
                if success then
                    FetchItems(Content, Count)
                else
                    Log.TermError("Given Count ("..tostring(Count)..") is bigger than amount in storage ("..tostring(ActualCount)..")")
                end
            end

            if Command == "filter" then
                local ContentAsNumber = tonumber(Content)
                if ContentAsNumber then
                    minCount = ContentAsNumber
                else
                    if Content then
                        filter = Content
                    end
                    if Count then
                        minCount = Count
                    end
                end
            end

            if Command == "reset" then
                filter = ""
                minCount = 0
            end

            if Command == "stop" then
                return
            end
        end
    end

    SetupOutput()
    --print("farming...\n <press any key to stop>")
    parallel.waitForAny(DrawMonitor, Stop)