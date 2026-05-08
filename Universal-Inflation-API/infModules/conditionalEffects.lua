local CondEffector = {}
local UNInf

function CondEffector.patch(core)
    UNInf = core

    UNInf.colorPile = {}
    CondEffector.ids = 0

    UNInf.ConditionalEffector = {}
    UNInf.ConditionalEffector.__index = UNInf.ConditionalEffector
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
                    if(self.animation ~= nil) then
                        self.animation:play()
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
                    if(self.animation ~= nil) then
                        self.animation:stop()
                    end
                end
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