local modelSwap = {}
local UNInf

function modelSwap.patch(core)
    UNInf = core
    UNInf.modelSwapInflation = {}
    UNInf.modelSwapInflation.__index = UNInf.modelSwapInflation
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
            self.active = UNInf.pressure / UNInf.maxPressure >= self.minInf and UNInf.pressure / UNInf.maxPressure <= self.maxInf
            if(not UNInf.checkWhitelist(self.conditionals)) then
                self.active = false
            end
            self.newModel:setVisible(self.active)
            self.origModel:setVisible(not self.active)
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

return modelSwap