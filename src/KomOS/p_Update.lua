--p_Update
local args = {...}

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
	if has_value (programs, name) then
		print(name.." Is already Installed, deleting and reinstalling")
		shell.run("delete", name)
	end
	shell.run("wget", Link, name)
	print("\n")
	sleep(0.8)
end

function SetupStartup()
	if fs.exists("startup") then
		shell.run("delete", "startup")
	end
	startup = fs.open("startup", "w")
	startup.writeLine("shell.run(\"KomOS\")")
	startup.close()
end

function has_value (tab, val)
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

	--OS
	InstallReq("KomOS", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/KomOS.lua?v=1")

	--programs
	InstallReq("p_Refuel", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Refuel.lua?v=1")

	--Debug
	InstallReq("Debug_Test", "https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/src/KomOS/Debug_Test.lua?v=1")
	
	--Create startup
	SetupStartup()
end

--Start
term.setCursorPos(1, 1)
term.clear()

function InstallOptions()
	InstallOptinal("p_TreeFarmer", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_TreeFarm.lua?v=1")
	InstallOptinal("p_Miner", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Mine.lua?v=1")
	InstallOptinal("p_Farm", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Farm.lua?v=1")
end

--Instal requireds (update system)
if OptionOnly == false then
	InstallAllReq()
end

--Instal optionals (setup system)
if ReqOnly == false then
	InstallOptions()
end

--finish
term.clear()
term.setCursorPos(1, 1)
print("\nInstallation finished\nStarting KomOS")
sleep(1)
shell.run("KomOS")