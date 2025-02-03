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
function InstallOptinal(name, PastebinLink)
	print("Do you want to install: "..name.."?")
	print("type y to install")
	local reply = read()
	if reply == "y" then
		InstallReq(name, PastebinLink)
	end
end

function InstallReq (name, PastebinLink)
	if has_value (programs, name) then
		print(name.." Is already Installed, deleting and reinstalling")
		shell.run("delete", name)
	end
	shell.run("pastebin", "get", PastebinLink, name)
	print("\n")
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
	InstallReq("u_Utils", "1ER4YDVy")
	InstallReq("u_Sprite", "ch2vDQmA")
	InstallReq("u_Config", "CRM2JH0S")
	InstallReq("u_Area", "NFn54B08")

	--OS
	InstallReq("KomOS", "byxjwqMv")

	--programs
	InstallReq("p_Refuel", "3Gq09d8G")
	
	--Create startup
	SetupStartup()
end

--Start
term.setCursorPos(1, 1)

function InstallOptions()
    InstallOptinal("p_TreeFarmer", "3TPy8Ewx")
	InstallOptinal("p_Miner", "PV36b31K")
	InstallOptinal("p_Farm", "7y2RqRmA")
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