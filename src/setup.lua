local function main()
    local directories =
    {
        "/bin",
        "/cfg",
        "/dev",
        "/lib",
        "/log",
    }
    local programs =
    {
        git_clone_bin = { path = "bin/git_clone", url = [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/src/bin/git_clone.lua]] },
        git_clone_cfg = { path = "cfg/git_clone", url = [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/src/cfg/git_clone.lua]] },
    }

    for _, value in ipairs(directories) do
        if not fs.exists(value) then fs.makeDir(value) end
    end

    for _, value in pairs(programs) do
        local path = value.path
        local url  = value.url

        if fs.exists(path) then fs.delete(path) end
        shell.run("wget", url, path)
    end
end

main()
