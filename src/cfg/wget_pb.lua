local urls =
{
    base = "https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/", 
    
    required = 
    {
        { url = "src/wget_pb", identifier = "mine_area", config = { url = "", identifier = "mine_area" } }, 
    }, 
    optional = 
    {
        { url = "", identifier = "", config = {} }, 
    }
}

return urls
