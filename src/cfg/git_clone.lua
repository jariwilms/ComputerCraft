local urls =
{
    repository = [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/]],

    required =
    {
        {
            url = "src/lib/inventory.lua", path = "/lib/inventory",
            dependencies =
            {
                { url = "src/cfg/inventory.lua", path = "/cfg/inventory" },
                { url = "src/lib/item.lua",      path = "/lib/item"      },
            },
        },
        {
            url = "src/bin/mine_area.lua", path = "/bin/mine_area",
            dependencies =
            {
                { url = "src/cfg/mine_area.lua", path = "/cfg/mine_area" },
                { url = "src/cfg/fuel.lua",      path = "/cfg/fuel"      },
                { url = "src/lib/math_ext.lua",  path = "/lib/math_ext"  },
                { url = "src/lib/terra.lua",     path = "/lib/terra"     },
                { url = "src/lib/inventory.lua", path = "/lib/inventory" },
                { url = "src/lib/item.lua",      path = "/lib/item"      },
            },
        },
    },
    optional =
    {

    },
}

return urls
