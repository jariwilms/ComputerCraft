--p_Update
local args = {...}

--utils

local LogExists = fs.exists("u_Log")
if not LogExists then --Download u_Log if missing
	local default = term.current()
    local x,y = term.getCursorPos()
    local newWindow = window.create(term.current(), 60, 60, 1, 1)
    term.redirect(newWindow)
    shell.run("wget", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Log.lua", "u_Log")
	term.redirect(default)
    term.setCursorPos(x,y)
	
end

local Log = require("u_Log")
Log.Init("l_Update",true)

--Globals
local ReqOnly = false
if args[1] == "ReqOnly" then
	ReqOnly = true
end
local OptionOnly = false
if args[1] == "OptionOnly" then
	OptionOnly = true
end
local programs = {}
programs = shell.programs()

local InstallList = {}

--Class

--functions
function InstallOptinal(name, Link)
	print("Do you want to install: "..name.."?")
	print("type y to install")
	local reply = read()
	if reply == "y" then
		InstallReq(name, Link)
	end
end

function InstallReq (name, Link)
	table.insert(InstallList, {name = name,status = "started"})
	if Has_value(programs, name) then
		Log.Log(name.." Is already Installed, deleting and reinstalling")
		shell.run("delete", name)
	end
	local success, errorMsg = Log.Redirect(function () shell.run("wget", Link, name) end)
	if success then
	InstallList[name] = "Success"
	else
	InstallList[name] = "Error"
	Log.LogError(errorMsg)
	end
end

function SetupStartup()
	if fs.exists("startup") then
		shell.run("delete", "startup")
	end
	local startup = fs.open("startup", "w")
	startup.writeLine("shell.run(\"KomOS\")")
	startup.close()
end

function Has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function InstallAllReq()
    --Install utils
	InstallReq("u_Sprite", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Sprite.lua?v=1")
	InstallReq("u_Config", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Config.lua?v=1")
	InstallReq("u_Area", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Area.lua?v=1")
	InstallReq("u_Inv", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Inv.lua?v=1")
	InstallReq("u_Log", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Log.lua?v=1")
	InstallReq("u_Chest", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Chest.lua?v=1")

	--OS
	InstallReq("KomOS", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/KomOS.lua?v=1")

	--programs
	InstallReq("p_Refuel", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Refuel.lua?v=1")

	--Debug
	InstallReq("Debug_Test", "https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/src/KomOS/Debug_Test.lua?v=1")
	
	--Create startup
	SetupStartup()
	sleep(1)
end

function InstallAllReqParallel()
	local Funcs = {}

    --Install utils
	table.insert(Funcs, function() InstallReq("u_Sprite", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Sprite.lua?v=1") end)
	table.insert(Funcs, function() InstallReq("u_Config", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Config.lua?v=1") end)
	table.insert(Funcs, function() InstallReq("u_Area", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Area.lua?v=1") end)
	table.insert(Funcs, function() InstallReq("u_Inv", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/u_Inv.lua?v=1") end)

	--OS
	table.insert(Funcs, function() InstallReq("KomOS", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/KomOS.lua?v=1") end)

	--programs
	table.insert(Funcs, function() InstallReq("p_Refuel", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Refuel.lua?v=1") end)

	--Debug
	table.insert(Funcs, function() InstallReq("Debug_Test", "https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/src/KomOS/Debug_Test.lua?v=1") end)

	parallel.waitForAll(table.unpack(Funcs))
	
	--Create startup
	SetupStartup()
	sleep(1)
end

function ShowStatus()
	while true do
		term.clear()
		for i, Install in pairs(InstallList) do
			print(Install.name.."\t - "..Install.status)
		end
		sleep(0.05)
	end
end

--Start
term.setCursorPos(1, 1)
term.clear()

function InstallOptions()
	InstallOptinal("p_TreeFarm", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_TreeFarm.lua?v=1")
	InstallOptinal("p_Miner", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Mine.lua?v=1")
	InstallOptinal("p_Farm", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Farm.lua?v=1")
end

--Instal requireds (update system)
if args == nil or ReqOnly == true then
	--InstallAllReq()
	parallel.waitForAny(InstallAllReqParallel(),ShowStatus())
end

--Instal optionals (setup system)
if OptionOnly == true then
	InstallOptions()
end

--finish
term.clear()
term.setCursorPos(1, 1)
print("\nInstallation finished\nStarting KomOS")
sleep(1)
shell.run("KomOS")