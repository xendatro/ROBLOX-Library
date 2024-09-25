--[[
arguably the greatest piece of code i've ever written
- xendatro
]]

return function(t: {}, ...: {} | Instance)
    local extensions = table.pack(...)
    local function findTarget(index: string)
        for _, extension in ipairs(extensions) do
            local success, v = pcall(function() 
                if type(extension) == "table" then
                    if extension[index] == nil then
                        error()
                    end
                elseif typeof(extension) == "Instance" then
                    return extension[index]
                end
            end)
            if success then
                return extension
            end
        end
    end
    local mt = {
        __index = function(_, index: string)
            local targetExtension = findTarget(index)
            if targetExtension == nil then
                return nil
            elseif type(targetExtension[index]) == "function" then
                return function(t, ...)
                    return targetExtension[index](targetExtension, ...)
                end
            else
                return targetExtension[index]
            end
        end,
        __newindex = function(_, index: string, value: any)
            local targetExtension = findTarget(index)
            if targetExtension == nil then
                rawset(t, index, value)
            else
                targetExtension[index] = value
            end
        end,
    }
    return setmetatable(t, mt)
end