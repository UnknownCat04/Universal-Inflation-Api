local CondEffector = {}
---@class UNInf
local UNInf

function CondEffector.patch(core)
    UNInf = core

    UNInf.colorPile = {}
    CondEffector.ids = 0

    UNInf.ConditionalEffector = {}
    UNInf.ConditionalEffector.__index = UNInf.ConditionalEffector
    ---Preforms some premade reactions to conditionals being turned on or off
    ---@param condtional string [REQUIRED!] What conditional actually triggers this module
    ---@param minColor number? [nil] What color is initially applied when the effector is activated
    ---@param maxColor number? [nil] What color is applied when the effector is at max inflation
    ---@param newTexture Texture? [nil] What texture is applied when the effector is activated
    ---@param origTexture Texture? [nil] What texture is applied when the effector is deactivated
    ---@param textureTarget Texture? [nil] What model parts are the textures applied to
    ---@param animation Animation? [nil] What animation is played when this module is activated
    ---@param minInf number? [0] What percentage of inflation is required for this module to activate
    ---@param maxInf number? [1] What percentage of inflation before the module is deactivated
    ---@return table self Returns itself for on the fly modification
    function UNInf.ConditionalEffector:new(condtional, minColor, maxColor, newTexture, origTexture, textureTarget, animation, minInf, maxInf)
        self = setmetatable({},UNInf.ConditionalEffector)
        
        --Set all self variables here

        self.condtional = condtional
        self.minColor = minColor
        self.maxColor = maxColor
        self.newTexture = newTexture
        self.origTexture = origTexture
        self.textureTarget = textureTarget
        self.animation = animation
        self.minInf = minInf or 0
        self.maxInf = maxInf or 1

        self.id = condtional..CondEffector.ids
        CondEffector.ids = CondEffector.ids + 1

        assert(type(self.condtional) == "string", "Your conditional Effector was given something other than a string. It can only track a single conditional at a time")
        if(self.minColor ~= nil and self.maxColor ~= nil) then
            assert(type(self.minColor) == "Vector3", "Your minimum color is not a valid Vector3. Please input a Vector3, with the colors being in R G B order!")
            assert(type(self.maxColor) == "Vector3", "Your minimum color is not a valid Vector3. Please input a Vector3, with the colors being in R G B order!")
        end
        if(self.newTexture ~= nil) then
            assert()
        end
        if(self.textureTarget ~= nil) then
            if(type(self.textureTarget) == "ModelPart") then
                self.textureTarget = {self.textureTarget}
            end
            assert(type(self.textureTarget) == "table", "Your texture target is not set properly. Please set it to a model part, or a table of model parts")
            assert(type(self.origTexture) == "Texture", "Your original texture is not set properly. It must be a texture you wish to use when you're not under the tracked effect")
            assert(type(self.newTexture) == "Texture", "Your new texture is not set properly. It must be a texture you wish to use when you're under the tracked effect")
        end
        if(self.animation ~= nil) then
            assert(type(self.animation) == "Animation", "Your inflation animation is not set properly. Please set it to the animation path in your model")
        end
        assert(type(self.minInf) == "number", "The status effector's minimum inflation value is not set to a number. Please set it to a value between 0 and 1.")
        assert(type(self.maxInf) == "number", "The status effector's maximum inflation value is not set to a number. Please set it to a value between 0 and 1.")

        self.active = false

        function self:tick()
            --Tick behaivors go here
            if(UNInf.checkPressureRange(self.minInf,self.maxInf) and UNInf.checkWhitelist({self.condtional})) then
                if(not self.active) then
                    self.active = true
                    if(self.textureTarget ~= nil) then
                        for i, part in pairs(self.textureTarget) do
                            part:setPrimaryTexture("Custom", self.newTexture)
                        end
                    end
                end
                if(self.minColor ~= nil and self.maxColor ~= nil) then
                    UNInf.colorPile[self.id] = math.lerp(self.minColor,self.maxColor,(UNInf.pressure - (self.minInf * UNInf.maxPressure)) / ((self.maxInf -self.minInf) * UNInf.maxPressure))
                end
            else
                if(self.active) then
                    UNInf.colorPile[self.id] = nil
                    if(self.textureTarget ~= nil) then
                        for i, part in pairs(self.textureTarget) do
                            part:setPrimaryTexture("Custom", self.origTexture)
                        end
                    end
                end
            end
            if(self.animation ~= nil) then
                self.animation:setPlaying(self.active)
            end
        end

        -- Insert it into UNInf's groups to run in the proper events. Ticks for tick only, Renders for render only, and hybrid for both
        table.insert(UNInf.ticks,self)
        return self
    end
    events.TICK:register(function() 
        UNInf.colorsIn = 0
        for i, v in pairs(UNInf.colorPile) do
            UNInf.colorsIn= UNInf.colorsIn + 1
        end
        if(UNInf.colorsIn > 0) then
            UNInf.desiredColor = vec(0,0,0)
            for i, v in pairs(UNInf.colorPile) do
                UNInf.desiredColor:add(v)
            end
            UNInf.desiredColor:div(UNInf.colorsIn,UNInf.colorsIn,UNInf.colorsIn)
            models:setColor(UNInf.desiredColor)
            UNInf.colorChanged = true
        else
            if(UNInf.colorChanged) then
                models:setColor(nil)
                UNInf.colorChanged = false
            end
        end
    end, "colorUpdate")
end

return CondEffector