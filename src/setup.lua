local function main()
    local directories = 
    {
        "/bin", 
        "/cfg", 
        "/dev", 
        "/lib", 
        "/log", 
    }

    for _, value in ipairs(directories) do
        if not fs.exists(value) then fs.makeDir(value) end
    end

    shell.run("wget", [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/src/bin/git_clone.lua]], "bin/git_clone")
    shell.run("wget", [[https://raw.githubusercontent.com/jariwilms/ComputerCraft/refs/heads/main/src/cfg/git_clone.lua]], "cfg/git_clone")
end

main()
