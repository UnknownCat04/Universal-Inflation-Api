local animationBloat = {}
local UNInf

--CONFIGURATION VALUES!
local autoBloat = true

function animationBloat.patch(core)
    UNInf = core
    
    UNInf.animbloat = {}
    UNInf.animbloat.__index = UNInf.animbloat
    function UNInf.animbloat:new(infAnim, conditionals)
        self = setmetatable({},UNInf.animbloat)
        self.infAnim = infAnim
        self.conditionals = conditionals or {"any"}

        if(type(self.conditionals) == "string") then
            self.conditionals = {self.conditionals}
        end

        -- Error Check
        if(type(self.infAnim) ~= "Animation") then
            log("Error Cause: ", self.infAnim)
            error("Your inflation animation is improperly set up. Please check your animation path. An inflation animation is required for this module.")
        end

        self.length = infAnim:getLength()
        self.prvInf = 0
        self.pressure = 0

        self.infAnim:play()
        self.infAnim:pause()
        self.infAnim:setTime(0)
        self.isOn = true

        function self.toggle(val)
            if(self.isOn ~= val) then
                if(val) then
                    self.infAnim:play()
                    self.infAnim:pause()
                    self.infAnim:setTime(math.lerp(self.infAnim:getLength() * self.prvInf / 20, self.infAnim:getLength() * self.pressure / UNInf.maxPressure,0))
                else
                    self.infAnim:stop()
                end
                self.isOn = val
            end
        end

        function self:tick()
            self.prvInf = self.pressure
            self.pressure = UNInf.pressure
            self.toggle(UNInf.checkWhitelist(self.conditionals))
        end

        function self:render(delta)
            self.infAnim:setTime(math.lerp(self.infAnim:getLength() * self.prvInf / 20, self.infAnim:getLength() * self.pressure / UNInf.maxPressure, delta))
        end
        
        function self:hotSwap(new)
            self.infAnim:setTime(0)
            self.infAnim:stop()
            assert(type(new) == "Animation" , "You are swapping to an invalid animation, please check your animation path.")
            self.infAnim = new
            self.infAnim:play()
            self.infAnim:pause()
            self.infAnim:setTime(math.lerp(self.infAnim:getLength() * self.prvInf / 20, self.infAnim:getLength() * self.pressure / UNInf.maxPressure, 0))
        end

        table.insert(UNInf.hybrid,self)
        return self
    end

end

function events.entity_init()
    if(autoBloat) then
        for i, v in pairs(models:getChildren()) do
        modelName = v:getName()
        anims = animations[modelName] or {}
        for _, y in pairs(anims) do
            if(string.sub(y:getName(), 1, 5) == "bloat") then
                UNInf.animbloat:new(y)
            end
        end
    end
    modelName = nil
    anims = nil
  end
end

return animationBloat