local meta =
{
    ---@param  t table
    ---@return   table
    read_only = function(t)
        local proxy = {}
        local meta =
        {
            __index    = t,
            __newindex = function (_,__,___) error("attempt to update a read-only table", 2) end
        }

        setmetatable(proxy, meta)

        return proxy
    end
}

return meta
