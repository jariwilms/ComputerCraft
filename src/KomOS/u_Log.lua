--Log Program

--Includes

--Global

--Images

--Config

--Data

--Class

--Function
local Logger = {Logfile = "log"}

function Logger.Init(Logfile,ClearFiles)
    Logger.Logfile = Logfile
    if ClearFiles then
        Logger.ClearLog()
    end
end

function Logger.Log(Text)
    local file, errmsg = io.open(Logger.Logfile,"a")
    io.output(file)
    io.write("\n["..textutils.formatTime(os.time(),true).."][Log] "..Text)
    io.flush()
end

function Logger.LogWarning(Text)
    local file, errmsg = io.open(Logger.Logfile,"a")
    io.output(file)
    io.write("\n["..textutils.formatTime(os.time(),true).."][Warning] "..Text)
    io.flush()
end

function Logger.LogError(Text)
    local file, errmsg = io.open(Logger.Logfile,"a")
    io.output(file)
    io.write("\n["..textutils.formatTime(os.time(),true).."][Error] "..Text)
    io.flush()
end

function Logger.ClearLog()
    local file, errmsg  = io.open(Logger.Logfile,"w+")
    io.output(file)
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
    print("") --term.write doesn't allow \n... sorry
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
    print("") --term.write doesn't allow \n... sorry
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
    print("") --term.write doesn't allow \n... sorry
end

function Logger.ClearTerm(Text)
    term.clear()    
end

function Logger.Redirect(Func, ...)
    local default = term.current()
    local x,y = term.getCursorPos()
    local newWindow = window.create(term.current(), 60, 60, 1, 1)
    term.redirect(newWindow)
    local success, errorMsg = pcall(Func,...)
	term.redirect(default)
    term.setCursorPos(x,y)
    return success, errorMsg
end

return Logger