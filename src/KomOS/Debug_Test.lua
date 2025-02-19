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
    local chests = {peripheral.find("inventory")}
    local Output = Config:getData("Output")
    local item = {name = "", count = 0}
    local TotalList = {}
    local TotalCapacity = 0
    local CurrentCapacity = 0
    local DisplayList = {}
    local filter = ""
    local minCount = 0

    --Data

    --Class

    --Functionw2
    function ScanAllChest()
        chests = {peripheral.find("create:item_vault")}
        TotalList = {}
        TotalCapacity = 0
        CurrentCapacity = 0

        Log.Log(tostring(#chests).." chests found")
        for i = 1, #chests do
            local chestItems = chests[i].list()
            TotalCapacity = TotalCapacity + chests[i].size()
            for j=1, #chestItems do
                if chestItems[j] ~= nil then
                    print(chestItems[j]["name"])
                    AddToTotalList(chestItems[j]["name"], chestItems[j]["count"])
                    CurrentCapacity = CurrentCapacity+1
                end
            end
            Log.Log(tostring(#chestItems).." items added")
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

    function PrintTotalList()
        if TotalList then
            for index, value in pairs(TotalList) do
            print(value.name..":\t\t"..value.count)
            end
        end
    end

    --Main
    ScanAllChest()
    PrintTotalList()

    function DrawMonitor()
        monitor.setTextScale(0.5)
        local xsize,ysize = monitor.getSize()
        local defaultTerm = term.current()
        local Scroll = 0
        local Run = true
        while Run do
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
            sleep(5)
            term.redirect(defaultTerm)
            ScanAllChest()
            FilterList()
        end
    end

    function FilterList()
        DisplayList = {}
        if filter ~= "" then
            for i = 1, #TotalList do
                if string.find(TotalList[i]["name"], filter) then
                    table.insert(DisplayList, TotalList[i])
                end
            end
        else
            DisplayList = TotalList
        end
    end

    function string.starts(String,Start)
        return string.sub(String,1,string.len(Start))==Start
    end

    function ParseCommand(String)
        local Args
        for word in String:gmatch("%w+") do table.insert(Args, word) end
        local Command = Args[0]
        local Content = Args[1]
        local Count = Args[2]
        return Command, Content, Count
    end

    function FetchItems(Name, Count)
        local CountReturned
        for i, Chest in pairs(chests) do
            local InvData = Chest.GetDetailedInvParallel()
            for j, Item in pairs(InvData) do
                if Item then
                    if string.find(Name, Item["name"]) then
                        if Item["count"] < (Count - CountReturned) then
                            Output.pullItems(Chest, j, Item["count"])
                            CountReturned = CountReturned + Item["count"]
                        else
                            Output.pullItems(Chest, j, Count - CountReturned)
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
            if string.find(Name, Item["name"]) then
                return Count <= Item["count"], Item["count"]
            end
        end
    end

    function Stop()
        local Run = true
        while Run do
            local Input = read()
            local Command, Content, Count = ParseCommand(Input)
            if string.starts(Command, "Get") then
                local success, ActualCount = CheckAvailability(Content, Count)
                if success then
                    FetchItems(Content, Count)
                else
                    Log.LogError("Given Count ("..tostring(Count)..") is bigger than amount in storage ("..tostring(ActualCount)..")")
                end
            end
            if string.starts(Command, "Filter") then
                local ContentAsNumber = tonumber(Content)
                if ContentAsNumber then
                    minCount = ContentAsNumber
                else
                    filter = Content
                end
            end
            if string.starts(Command, "Reset") then
                filter = ""
                minCount = 0
            end
            if string.starts(Command, "Stop") then
                return
            end
        end
    end

    --print("farming...\n <press any key to stop>")
    parallel.waitForAny(DrawMonitor, Stop)