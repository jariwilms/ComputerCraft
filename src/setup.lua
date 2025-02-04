function main()
    local directories = 
    {
        "/bin", 
        "/cfg", 
        "/dev", 
        "/lib", 
        "/log", 
    }

    for _, value in ipairs(directories) do
        fs.makeDir(value)
    end
end

main()
