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
                { url = "src/lib/meta.lua",      path = "lib/meta" },
                { url = "src/lib/math_ext.lua",  path = "lib/math_ext" },
                { url = "src/lib/terra.lua",     path = "lib/terra" },
            },
        },
    },
    optional =
    {
        --{ url = "", path = "", config = {} },
    }
}

return urls
