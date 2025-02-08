local meta =
{
    ---@param  _ table
    ---@return   table
    read_only = function(_)
        local proxy = {}
        local meta =
        {
            __index    = _,
            __newindex = function (_,__,___) error("attempt to update a read-only table", 2) end
        }

        setmetatable(proxy, meta)

        return proxy
    end
}

return meta
