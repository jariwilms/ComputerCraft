local urls =
{
    repository = [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/]], 
    
    required = 
    {
        { url = "src/mine_area.lua", path = "mine_area", config = { url = "src/cfg/mine_area.lua", path = "cfg/mine_area" } }, 
    }, 
    optional = 
    {
        { url = "", path = "", config = {} }, 
    }
}

return urls
