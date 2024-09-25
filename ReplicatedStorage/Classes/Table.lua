local Signal = require(script.Parent.Classes.Signal)

local Table = {}
type Table<T> = {
    Changed: typeof(Signal.new()),
    Raw: T,
    DestroySignals: () -> nil
}

function Table.new<T>(table: T): T & Table<T>
    local self = {}
    self.Changed = Signal.new()
    self.Raw = table
    
    function self:Destroy()
        self.Changed:Destroy()
        self = nil
    end

    local mt = {
        __index = function(t, i)
            return table[i]            
        end,
        __newindex = function(t, i, v)
            if table[i] ~= v then
                self.Changed:Fire()
            end
            table[i] = v
            return table[i]
        end,
    }
    
    for k, v in table do
        if type(v) == "table" then
            self[k] = Table.of(v)
            self[k].Changed:Connect(function()
                self.Changed:Fire()
            end)
            self.Changed.Destroying:Once(function()
                self[k].Changed:Destroy()
            end)
        end
    end

    setmetatable(self, mt)
    
    return self
end

return Table