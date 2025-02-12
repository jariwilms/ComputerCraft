--Tutre OS Program

--Includes

--os.loadAPI("u_Utils")
local Sprite = require("u_Sprite")

--Global
local Selected = 1
local SelectableX = 3
local MaxSelectable = 6
local CurrentExec = "Agent OS"
local RunningExec = "Agent OS"
local Run = true
local Pause = false
local exit = false
local Window = 1
local modem = peripheral.wrap("left")
local LastPackageSent = "00:00"
local LastPackageReceived = "00:00"

local DefaultTerm = term.current()
local XTermSize,YTermSize = term.getSize()
local BorderWindow = window.create(term.current(), 1, 1, XTermSize, 1)
local AppWindow = window.create(term.current(), 1, 2, XTermSize, YTermSize-1)

--Images

local i_Program ={".------.",
			"| |__| |",
			"|  ()  |",
			"|______|",
	}

local i_ProgramS={" ___ ",
			"| U |",
			"|_"..string.char(8).."_|",
	}
	
local i_FileS =  {" __ ",
			"| `|",
			"|__|",
	}

local i_folder = {".--.___ ",
			"|  ____|",
			"| /    |",
			"|/_____|",
	}
	
local i_tinfo = {	"^.-----.",
			"H| === |",
			"V|     |",
			"||_____|",
	}
	
local i_exit = {	"   ||   ",
			" / || \\ ",
			"|      |",
			" \\____/ ",
	}
local i_exitS = {	"  |  ",
			"/ | \\",
		   "\\___/",
	}
	
local i_signal = {" .-----.",
			"  .---. ",
			"   .-.  ",
			"    O   ",
	}

--Config

--Data

--Class
Agent = {ID = os.getComputerID()	,
		 label = os.getComputerLabel(),
		 runningProgram = "",
		 X = 0,
		 Y = 0,
		 Z = 0,
		 GlobalPos = false,
		 Connection = "None",
		 ping = 0,
	}

function Agent.__init__ (data)
  local self = {data=data}
  setmetatable (self, {__index=Agent})
  return self
end

setmetatable (Agent, {__call=Agent.__init__})

--OS self
local agent = Agent

------------------------------------------------------------------------------------------

--Function
function Agent:OnLoad()
	local x, y, z = gps.locate(2)
	if x ~= nil then
		self.X = x
		self.Y = y
		self.Z = z
		self.GlobalPos = true
	end
end

function Agent:DrawApp(img,name,bselected,x,y)
	Sprite.DrawImage(x,y,img)
	
	
	local imagesizeX, imagesizey = Sprite.GetSize(img)
	local len = #name
	local xtextpos = (x+imagesizey-len/2)
	
	if bselected then 
		xtextpos = xtextpos - 1
	end
	
	term.setCursorPos(xtextpos, y + imagesizey)
	if bselected then
		term.write("["..name.."]")
	else
		term.write(name)
	end
end

------------------------------------------------------------------------------------------

--Windows

function Agent:MainMenu()
		
		SelectableX = 3
		MaxSelectable = 9
		
		if Selected < 7 then
			self:DrawApp(i_tinfo, 	"Stats", 		Selected==1, 5,	 2)
			self:DrawApp(i_folder, 	"Programs", 	Selected==2, 16, 2)
			self:DrawApp(i_folder, 	"Config", 		Selected==3, 27, 2)
			self:DrawApp(i_folder, 	"Utils", 		Selected==4, 5,	 8)
			self:DrawApp(i_signal, 	"Connection", 	Selected==5, 16, 8)
			self:DrawApp(i_exit, 	"Exit", 		Selected==6, 27, 8)
		else
			self:DrawApp(i_Program, "Update", 		Selected==7, 5,	 2)
			self:DrawApp(i_folder, 	"Setups", 		Selected==8, 16, 2)
			self:DrawApp(i_exit, 	"Exit", 		Selected==9, 27, 2)
		end
end

function Agent:TurtleInfo()

	self:DrawApp(i_tinfo, "  " , false, 2, 3)
	term.setCursorPos(1,8)
	print("ID             ~\t\t"..self.ID )
	if self.label ~= nil then
		print("Label          ~\t\t"..self.label )
	else
		print("Label          ~\t\t".."No Label" )
	end
	local str = "Local"
	if	self.GlobalPos then str = "Global" end
	print("Location space	~\t\t"..str )
	print("Location      	~\t\t"..self.X ..","..self.Y ..","..self.Z  )
	print("Fuel          	~\t\t"..turtle.getFuelLevel() )
	self:DrawApp(i_exitS, "Exit", true, 32, 10)
end

function Agent:Programs()
	local programs = shell.programs()
	
	local callablePrograms = {}
	for i,v in ipairs(shell.programs()) do
		if string.find(v,"p_") then
			table.insert(callablePrograms, v)
		end
	end
	
	SelectableX = 4 
	MaxSelectable = #callablePrograms
	
	if #callablePrograms > 0 then
		for i, v in ipairs(callablePrograms) do
			local x,y
			if i <= SelectableX then y = 2 else y = 6 end
			x = 3 + (math.fmod(i - 1,SelectableX))*10
			local str = string.gsub(v,"p_","")
			self:DrawApp(i_ProgramS, str, i==Selected, x, y)
			if i == Selected then CurrentExec = v end
		end
	end
end

function Agent:Utils()
	local programs = shell.programs()
	
	local callablePrograms = {}
	for i,v in ipairs(shell.programs()) do
		if string.find(v,"u_") then
			table.insert(callablePrograms, v)
		end
	end
	
	SelectableX = 4 
	MaxSelectable = #callablePrograms
	
	if #callablePrograms > 0 then
		for i, v in ipairs(callablePrograms) do
			local x,y
			if i <= SelectableX then y = 2 else y = 6 end
			x = 2 + (math.fmod(i - 1,SelectableX))*10
			local str = string.gsub(v,"u_","")
			self:DrawApp(i_FileS, str, false, x, y)
			if i == Selected then CurrentExec = v end
		end
	end
	
	self:DrawApp(i_exitS, "Exit", true, 32, 10)
	
end

function Agent:Configs()
	local programs = shell.programs()
	
	local callablePrograms = {}
	for i,v in ipairs(shell.programs()) do
		if string.find(v,"c_") then
			table.insert(callablePrograms, v)
		end
	end
	
	SelectableX = 4 
	MaxSelectable = #callablePrograms
	
	if #callablePrograms > 0 then
		for i, v in ipairs(callablePrograms) do
			local x,y
			if i <= SelectableX then y = 2 else y = 6 end
			x = 2 + (math.fmod(i - 1,SelectableX))*10
			local str = string.gsub(v,"c_","")
			self:DrawApp(i_FileS, str, i==Selected, x, y)
			if i == Selected then CurrentExec = v end
		end
	end
	
	--self:DrawApp(i_exitS, "Exit", true, 32, 10)
	
end

function Agent:ConnectionInfo()

	self:DrawApp(i_signal, "  " , false, 16, 3)
	term.setCursorPos(1,8)
	print("Connection           ~\t\t"..self.Connection )
	print("ping                 ~\t\t"..self.ping )
	print("LastPackageSent      ~\t\t"..LastPackageSent  )
	print("LastPackageReceived  ~\t\t"..LastPackageReceived )
	self:DrawApp(i_exitS, "Exit", true, 32, 10)
	
end

function Agent:InProgress()
	term.clear()
	term.setCursorPos(1,1)
	print("This is in progress")
	sleep(2)
	Window = 1
end

------------------------------------------------------------------------------------------

--On enter

function Agent:MainMenuOnEnter()
	if Selected==1 then
		Window = 2
	elseif Selected==2 then
		Window = 3
	elseif Selected==3 then
		Window = 4
	elseif Selected==4 then
		Window = 5
	elseif Selected==5 then
		Window = 6
	elseif Selected==6 then
		exit = true
	elseif Selected==7 then
		term.clear()
		Run = false
		term.setCursorPos(1, 1)
		shell.run("delete", "p_Update")
		shell.run("wget", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Update.lua", "p_Update")
		shell.run("p_Update", "ReqOnly")
		exit = true
	elseif Selected==8 then
		term.clear()
		Run = false
		term.setCursorPos(1, 1)
		shell.run("delete", "p_Update")
		shell.run("wget", "https://github.com/jariwilms/ComputerCraft/raw/refs/heads/main/src/KomOS/p_Update.lua", "p_Update")
		shell.run("p_Update", "OptionOnly")
		exit = true
	elseif Selected==9 then
		exit = true
	end
end

function Agent:ProgramOnEnter()
	Run = false
	term.clear()
	term.setCursorPos(1,2)
	RunningExec = CurrentExec
	shell.run(RunningExec)
	print("<Press any key to return to OS>")
	os.pullEvent("key")
	RunningExec = "Agent OS"
	Run = true
end

function Agent:ConfigOnEnter()
	Run = false
	term.clear()
	term.setCursorPos(1,2)
	RunningExec = CurrentExec
	shell.run("edit",RunningExec)
	print("<Press any key to return to OS>")
	os.pullEvent("key")
	RunningExec = "Agent OS"
	Run = true
end

function Agent:DefaultExitOnEnter()
	Window = 1
end

function Agent:OnEnter()
	if Window == 1 then
		self:MainMenuOnEnter()
	elseif Window == 2 then
		self:DefaultExitOnEnter()
	elseif Window == 3 then
		self:ProgramOnEnter()
	elseif Window == 4 then
		self:ConfigOnEnter()
	elseif Window == 5 then
		self:DefaultExitOnEnter()
	elseif Window == 6 then
		self:DefaultExitOnEnter()
	end
	
	self:ResetSelected()
end


------------------------------------------------------------------------------------------

--Keys

function Agent:ResetSelected()
	Selected = 1
end

function Agent:UpdateKey()
	while true do
		local event,key = os.pullEvent("key")
		if key == keys.up or key == keys.w then
			if Selected > SelectableX then
				Selected = Selected - SelectableX
			end
		end
		if key == keys.down or key == keys.s then
			if Selected <= MaxSelectable - (SelectableX - math.fmod(MaxSelectable,SelectableX)) then
				local tempSelected = Selected + SelectableX
				if tempSelected <= MaxSelectable then 
					Selected = tempSelected
				end
			end
		end
		if key == keys.left or key == keys.a then
			local tempSelected = Selected - 1
			if tempSelected > 0 then
				Selected = tempSelected
			end
		end
		if key == keys.right or key == keys.d then
			local tempSelected = Selected + 1
			if tempSelected <= MaxSelectable then
				Selected = tempSelected
			end
		end
		if key == keys.enter or key == keys.space then
			self:OnEnter()
		end
		if key == keys.backspace or key == keys.e then
			Window = 1
			self:ResetSelected()
		end
	end
end


------------------------------------------------------------------------------------------

--Core

function Agent:DrawBorder()
	term.redirect(BorderWindow)
	term.setCursorPos(1,1)
	
	term.blit("KomOS Agent                            "
	,"fffffffffffffffffffffffffffffffffffffff"
	,"000000000000000000000000000000000000000")

	term.setCursorPos(14,1)
	term.blit(RunningExec
	,string.rep("f", #RunningExec)
	,string.rep("6", #RunningExec))

	term.setCursorPos(34,1)
	local str = textutils.formatTime(os.time(),true)
	local curX = 34
	for i = 1, #str do
		term.setCursorPos(curX,1)
		term.blit(string.sub(str, i, i), "f", "0")
		curX = curX+1
	end
	term.redirect(AppWindow)
end

function Agent:DrawWindow()
	while exit == false do
		if Run then
			term.clear()
			agent:DrawBorder()
			if Window == 1 then
				self:MainMenu()
			elseif Window == 2 then
				self:TurtleInfo()
			elseif Window == 3 then
				self:Programs()
			elseif Window == 4 then
				self:Configs()
			elseif Window == 5 then
				self:Utils()
			elseif Window == 6 then
				self:ConnectionInfo()
			end
			sleep(0.05)
		else
			sleep(0.5)
		end
	end
end



function Agent:ReceiveNetwork(time)
	local ignore = true
	while ignore do
		local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
		
		if replyChannel ~= self.ID then
			ignore = false
			if message == "Connected "..self.ID then
				self.Connection = "Connected"
				self.ping = os.time() - time
				LastPackageReceived = textutils.formatTime(os.time(),true)
			end
		end
	end
end

function GetNetwork(time)
	agent:ReceiveNetwork(time)
	return true
end

function WaitNetwork()
	sleep(5)
	return false
end


function Agent:UpdateNetwork()
	local time = os.time()
	LastPackageSent = textutils.formatTime(os.time(),true)
	local str = "Local"
	if	self.GlobalPos then str = "Global" end
	local msg = "Ping server , ID "..self.ID..", Label "..self.label..", Program "..RunningExec..", Location space "..str..", X  "..self.X..", Y  "..self.Y..", Z  "..self.Z
	modem.transmit(1000, self.ID, msg) 
	
	local received
	parallel.waitForAny(function() received = GetNetwork(time) end ,function() received = WaitNetwork() end)
	
	if self.Connection == "Pending" and received == false then
		self.Connection = "None"
	elseif	self.Connection == "Connected" and received == false then
		self.Connection = "Pending"
	end
end

function Agent:HandleNetwork()
	while true do
		if peripheral.isPresent("left") and peripheral.getType("left") == "modem" then
		modem.open(self.ID)
			while true do
				if self.Connection == "None" then
					self:UpdateNetwork()
					sleep(5)
				elseif self.Connection == "Pending" then
					self:UpdateNetwork()
					sleep(2)
				elseif self.Connection == "Connected" then
					self:UpdateNetwork()
					sleep(2)
				end
				sleep(2)
			end
		end
		sleep(25)
	end
end

function Loop()
	agent:DrawWindow()
end

function Keys()
	agent:UpdateKey()
end

function Network()
	agent:HandleNetwork()
end

function OsHeading()
	while true do
		if RunningExec ~= "Agent OS" then
			agent:DrawBorder()
			sleep(0.05)
		else
			sleep(0.1)
		end
	end
end

term.redirect(AppWindow)
parallel.waitForAny(Loop, Keys, Network, OsHeading)
term.clear()
term.setCursorPos(1,2)
textutils.slowPrint("KomOS shutdown...",25)
sleep(0.25)
term.redirect(DefaultTerm)
term.clear()
term.setCursorPos(1,1)
