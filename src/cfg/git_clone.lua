local urls =
{
    repository = [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/]], 
    
    required = 
    {
        { url = "src/mine_area.lua", identifier = "mine_area", config = { url = "src/cfg/mine_area.lua", identifier = "cfg/mine_area" } }, 
    }, 
    optional = 
    {
        { url = "", identifier = "", config = {} }, 
    }
}

return urls
