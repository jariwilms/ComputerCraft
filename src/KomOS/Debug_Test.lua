--Chest Program

--Includes
local ChestAPI = require("u_Chest")
local Log = require("u_Log")

--Config
Log.Init("l_Chest",true)

--Global
local chests = {peripheral.find("Inventory")}
local item = {name = "", count = 0}
local TotalList

--Data

--Class

--Functionw2
function ScanAllChest()
    local ChestAPITable
    table.clear(item)
    for i = 1, #chests do
        table.insert(ChestAPITable, i, ChestAPI)
        ChestAPITable[i].Init(chests[i])
        local chestItems = ChestAPITable[i].GetSimpleInv()
        for j=1, #chestItems do
            AddToTotalList(chestItems[i]["name"], chestItems[i]["count"])
        end
    end
end

function AddToTotalList(name, count)
    for index, value in ipairs(TotalList) do
        if value["name"] == name then
            value.count = value.count + count
            return true
        end
    end
    TotalList[name] = count
    return true
end

function PrintTotalList()
    for index, value in ipairs(TotalList) do
       print(value.name..":\t\t"..value.count)
       sleep(0.2)
    end
end

--Main
ScanAllChest()
PrintTotalList()

function Stop()
    local event,key = os.pullEvent("key")
    return
end

--print("farming...\n <press any key to stop>")
--parallel.waitForAny(RunFarm, Stop)