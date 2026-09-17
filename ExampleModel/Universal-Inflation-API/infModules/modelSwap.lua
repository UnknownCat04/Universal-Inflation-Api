local modelSwap = {}
---@class UNInf

local UNInf

function modelSwap.patch(core)
    UNInf = core
    UNInf.modelSwapInflation = {}
    UNInf.modelSwapInflation.__index = UNInf.modelSwapInflation
    ---Toggle models in response to how inflated you are
    ---@param newModel ModelPart [REQUIRED!] What model becomes visible when the module is activated
    ---@param origModel ModelPart [REQUIRED!] What model becomes hidden when the module is activated
    ---@param infAnim Animation? [nil] Plays when the model is toggled
    ---@param minInf number? [0.01] How inflated you must be for this module to be activated
    ---@param maxInf number? [1] How inflated you can be before this module is ignored
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.modelSwapInflation:new(newModel, origModel, infAnim, minInf, maxInf, conditionals)
        self = setmetatable({},UNInf.modelSwap)
        
        --Set all self variables here

        self.newModel = newModel
        self.origModel = origModel
        self.infAnim = infAnim
        self.minInf = minInf or 0.01
        self.maxInf = maxInf or 1
        self.conditionals = conditionals or {"any"}

        -- Error Check
        assert(type(self.newModel) == "ModelPart", "Your input inflated model is not a valid model!")
        assert(type(self.origModel) == "ModelPart", "Your input original model is not a valid model!")
        assert(type(self.minInf) == "number", "Your minimum inflation for your modelSwapInflation module is not a valid number!")
        assert(type(self.maxInf) == "number", "Your maximum inflation for your modelSwapInflation module is not a valid number!")
        if(self.infAnim ~= nil) then
            assert(type(self.infAnim) == "Animation", "Your model part animation is not a valid animation!")
        end

        self.active = false
        self.wasActive = false

        function self:tick()
            --Tick behaivors go here
            self.active = UNInf.checkPressureRange(self.minInf,self.maxInf) and UNInf.checkWhitelist(self.conditionals)
            self.newModel:setVisible(self.active)
            self.origModel:setVisible(not self.active)
            if(self.wasActive ~= self.active and self.infAnim ~= nil) then
                self.infAnim:setPlaying(self.active)
                self.wasActive = self.active
            end
        end

        -- Insert it into UNInf's groups to run in the proper events. This function handles it automatically, based on all present events that are supported
        UNInf.insertToGroups(self)
        return self
    end
end

return modelSwap