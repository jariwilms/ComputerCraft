local urls =
{
    repository = [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/]],

    required =
    {
        {
            url = "src/bin/mine_area.lua", path = "bin/mine_area",
            dependencies =
            {
                { url = "src/cfg/mine_area.lua", path = "cfg/mine_area" },
            },
        },
    },
    optional =
    {
        --{ url = "", path = "", config = {} },
    }
}

return urls
