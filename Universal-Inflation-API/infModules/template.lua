local template = {}
---@class UNInf
local UNInf

function template.patch(core)
    UNInf = core
    UNInf.template = {}
    UNInf.template.__index = UNInf.template
    ---Template Module. Put description here
    ---@param val any What variables do you need
    ---@return table self Returns itself for on the fly modification
    function UNInf.template:new(val)
        self = setmetatable({},UNInf.template)
        
        --Set all self variables here

        self.val = val

        function self:tick()
            --Tick behaivors go here

        end

        function self:render(delta)
            --Render behaviors go here

        end

        -- Insert it into UNInf's groups to run in the proper events. Ticks for tick only, Renders for render only, and hybrid for both
        table.insert(UNInf.hybrid,self)
        return self
    end
end

return template