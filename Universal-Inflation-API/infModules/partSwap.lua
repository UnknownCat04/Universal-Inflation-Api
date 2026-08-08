local partSwap = {}
---@class UNInf
local UNInf

function partSwap.patch(core)
    UNInf = core
    UNInf.modelpartInflation = {}
    UNInf.modelpartInflation.__index = UNInf.modelpartInflation
    ---Toggle modelparts on or off based off of your inflation level
    ---@param parts table [REQUIRED!] What model parts are toggled by this module
    ---@param infAnim Animation? [nil] Plays when the model is toggled
    ---@param minInf number? [0.01] How inflated you must be for this module to be activated
    ---@param maxInf number? [1] How inflated you can be before this module is ignored
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.modelpartInflation:new(parts,infAnim, minInf, maxInf, conditionals)
        self = setmetatable({},UNInf.modelpartInflation)
        
        --Set all self variables here

        self.parts = parts
        self.infAnim = infAnim
        self.minInf = minInf or 0.01
        self.maxInf = maxInf or 1
        self.conditionals = conditionals or {"any"}

        -- Error Check
        assert(type(self.parts)== "table", "Your part list is not a table! Please place all parts you wish for inflation to toggle into a table, then input it into the module.")
        for _, parts in pairs(self.parts) do
            if(type(parts) ~= "ModelPart") then
                log("Error caused by: ", parts, " in ", self.parts)
                error("One or more of you model parts in the provided model part list are invalid!")
            end
        end
        assert(type(self.minInf) == "number", "Your minimum inflation for your modelspartInflation module is not a valid number!")
        assert(type(self.maxInf) == "number", "Your maximum inflation for your modelspartInflation module is not a valid number!")
        if(self.infAnim ~= nil) then
            assert(type(self.infAnim) == "Animation", "Your model part animation is not a valid animation!")
        end

        self.active = false
        self.wasActive = false

        function self:tick()
            --Tick behaivors go here
            self.active = UNInf.checkPressureRange(self.minInf,self.maxInf) and UNInf.checkWhitelist(self.conditionals)
            for _, part in pairs(self.parts) do
                part:setVisible(self.active)
            end
            if(self.wasActive ~= self.active and self.infAnim ~= nil) then
                self.infAnim:setPlaying(self.active)
                self.wasActive = self.active
            end
        end

        -- Insert it into UNInf's groups to run in the proper events. Ticks for tick only, Renders for render only, and hybrid for both
        table.insert(UNInf.ticks,self)
        return self
    end
end

return partSwap