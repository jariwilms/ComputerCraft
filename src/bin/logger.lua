local logger =
{
    file = "", 

    log = function()
        io.output("/log/<filename hier>")
    end
}

return logger
