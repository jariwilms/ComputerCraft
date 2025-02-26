    --StorageInterface Program

    --Includes
    local ChestAPI = require("u_Chest")
    local Log = require("u_Log")
    local Config = require("u_Config")

    --Config
    Log.Init("l_StorageInterface",true)

    if not fs.exists("c_StorageInterface") then
        ConfigFile = fs.open("c_StorageInterface", "w")
        ConfigFile.writeLine("Mode: Push")
        ConfigFile.writeLine("Input: minecraft:barrel_0")
        ConfigFile.writeLine("Item: minecraft:stone")
        ConfigFile.writeLine("Count: 64")
        ConfigFile.writeLine("Time: 10")
        ConfigFile.writeLine("Filter: ")
        ConfigFile.close()
        Log.TermLog("c_StorageInterface created, edit file for config")
    end

    Config:setPath("c_StorageInterface")

    local Mode = Config:getData("Mode")
    local Input = Config:getData("Input")

    function InsertAll()
        while true do
            local GlobalInput = peripheral.wrap(Config:getData(Input))
            local LocalChest = peripheral.wrap("top")
            if GlobalInput and LocalChest then
                local InvData = LocalChest.list()
                for Index, Item in pairs(InvData) do
                    GlobalInput.pullItems(peripheral.getName(LocalChest), Index)
                    sleep(0.2)
                end
            end
            sleep(5)
        end
    end

    function InsertAll()
        while true do
            local GlobalInput = peripheral.wrap(Config:getData(Input))
            local LocalChest = peripheral.wrap("top")
            if GlobalInput and LocalChest then
                local InvData = LocalChest.list()
                for Index, Item in pairs(InvData) do
                    GlobalInput.pullItems(peripheral.getName(LocalChest), Index)
                    sleep(0.2)
                end
            end
            sleep(5)
        end
    end

    function Main()
        if Mode == "Push" then
            InsertAll()
        elseif Mode == "Pull" then

        end
    end