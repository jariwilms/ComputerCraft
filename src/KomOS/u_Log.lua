--Log Program

--Includes

--Global

--Images

--Config

--Data

--Class

--Function
local Logger = {Logfile = "log", nilfile = "nil"}

function Logger.Init(Logfile,nilfile,ClearFiles)
    Logger.Logfile = Logfile
    Logger.nilfile = nilfile
    if ClearFiles then
        Logger.ClearLog()
        Logger.ClearNil()
    end
end

function Logger.Log(Text)
    io.output(io.open(Logger.Logfile,"a"))
    io.write("\n["..textutils.formatTime(os.time(),true).."][Log] "..Text)
    io.flush()
end

function Logger.LogWarning(Text)
    io.output(io.open(Logger.Logfile,"a"))
    io.write("\n["..textutils.formatTime(os.time(),true).."][Warning] "..Text)
    io.flush()
end

function Logger.LogError(Text)
    io.output(io.open(Logger.Logfile,"a"))
    io.write("\n["..textutils.formatTime(os.time(),true).."][Error] "..Text)
    io.flush()
end

function Logger.ClearLog()
    io.output(io.open(Logger.Logfile,"w+"))
    io.flush()
end

function Logger.ClearNil()
    io.output(io.open(Logger.nilfile,"w+"))
    io.flush()
end

function Logger.TermLog(Text)
    local date = textutils.formatTime(os.time(),true)
    local type = "Log"
    term.write("[")
    term.blit(date, string.rep("b", #date), string.rep("f", #date))
    term.write("]")
    term.write("[")
    term.blit(type, string.rep("0", #type), string.rep("f", #type))
    term.write("] ")
    term.blit(Text, string.rep("0", #Text), string.rep("f", #Text))
    print("")
end

function Logger.TermWarn(Text)
    local date = textutils.formatTime(os.time(),true)
    local type = "Warning"
    term.write("[")
    term.blit(date, string.rep("b", #date), string.rep("f", #date))
    term.write("]")
    term.write("[")
    term.blit(type, string.rep("4", #type), string.rep("f", #type))
    term.write("] ")
    term.blit(Text, string.rep("0", #Text), string.rep("f", #Text))
    print("")
end

function Logger.TermError(Text)
    local date = textutils.formatTime(os.time(),true)
    local type = "Error"
    term.write("[")   
    term.blit(date, string.rep("b", #date), string.rep("f", #date))
    term.write("]")
    term.write("[")
    term.blit(type, string.rep("e", #type), string.rep("f", #type))
    term.write("] ")
    term.blit(Text, string.rep("0", #Text), string.rep("f", #Text))
    print("")
end

function Logger.ClearTerm(Text)
    term.clear()    
end

function Logger.Redirect(Func, ...)
    local default = term.current()
    local x,y = term.getCursorPos()
    local newWindow = window.create(term.current(), 60, 60, 1, 1)
    term.redirect(newWindow)
	local result = Func(...)
	term.redirect(default)
    term.setCursorPos(x,y)
    return result
end

return Logger