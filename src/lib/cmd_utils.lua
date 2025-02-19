local cmd = {}

---@param  argv table
---@return      table
function cmd.parse_arguments(argv)
    local t = {}
    local k = nil

    for _, value in ipairs(argv) do
        if string.sub(value, 1, 1) == "-" then
            k = string.sub(value, 2, #value)
            t[k] = {}
        else
            if not t[k] then error("Argument given without flag!") end

            table.insert(t[k], value)
        end
    end

    return t
end

---@param  response string
---@param  pass     string
---@param  fail     string
---@param  default  boolean
---@return          boolean
function cmd.validate_confirmation(response, pass, fail, default)
    response = string.lower(response)
    pass     = string.lower(pass)
    fail     = string.lower(fail)

    if #response == 0    then return default end
    if  response == pass then return true    end
    if  response == fail then return false   end

    return false
end

return cmd
