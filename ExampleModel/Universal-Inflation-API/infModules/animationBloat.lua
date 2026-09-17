local animationBloat = {}
---@class UNInf
local UNInf

--CONFIGURATION VALUES!
local autoBloat = false

function animationBloat.patch(core)
    UNInf = core
    
    UNInf.animbloat = {}
    UNInf.animbloat.__index = UNInf.animbloat
    ---Uses an animation to scale your model as you inflate
    ---@param infAnim Animation [REQUIRED!] What plays to represent your inflation progress
    ---@param time number? [7] How many ticks does it take for your inflation to fully update
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.animbloat:new(infAnim, time, conditionals)
        self = setmetatable({},UNInf.animbloat)
        self.infAnim = infAnim
        self.time = time or 7
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

        self.start = 0
        self.stop = 0
        self.timer = 0

        function self.toggle(val)
            if(self.isOn ~= val) then
                if(val) then
                    self.infAnim:play()
                    self.infAnim:pause()
                    self.infAnim:setTime(math.lerp(self.length * self.prvInf / 20, self.length * self.pressure / UNInf.maxPressure,0))
                else
                    self.infAnim:stop()
                end
                self.isOn = val
            end
        end

        function self:tick()
            if(self.prvInf ~= UNInf.pressure) then
                self.prvInf = self.pressure
                self.pressure = UNInf.pressure
                self.timer = UNInf.clock + self.time
                self.start = self.infAnim:getTime()
                self.stop = self.infAnim:getLength() * self.pressure / UNInf.maxPressure
            end
            self.toggle(UNInf.checkWhitelist(self.conditionals))
        end

        function self:render(delta)
            --self.infAnim:setTime(math.lerp(self.infAnim:getLength() * self.prvInf / 20, self.infAnim:getLength() * self.pressure / UNInf.maxPressure, delta))
            --log(math.clamp((self.time - (self.timer - (UNInf.clock + delta))) / self.time, 0, 1))
            self.infAnim:setTime(math.lerp(self.start,self.stop,math.clamp((self.time - (self.timer - (UNInf.clock + delta))) / self.time, 0, 1)))
        end
        
        function self:hotSwap(new)
            if(type(new) ~= "Animation") then
                UNInf.annoyLog("You are swapping to an invalid animation, please check your animation path.",3,"badswap")
                return
            end
            self.infAnim:setTime(0)
            self.infAnim:stop()
            --assert(type(new) == "Animation" , "You are swapping to an invalid animation, please check your animation path.")
            self.infAnim = new
            self.infAnim:play()
            self.infAnim:pause()
            self.infAnim:setTime(math.lerp(self.infAnim:getLength() * self.prvInf / 20, self.infAnim:getLength() * self.pressure / UNInf.maxPressure, 0))
        end
        
        -- Insert it into UNInf's groups to run in the proper events. This function handles it automatically, based on all present events that are supported
        UNInf.insertToGroups(self)
        return self
    end
    UNInf.animoverbloat = {}
    UNInf.animoverbloat.__index = UNInf.animoverbloat
    ---Uses an animation to scale your model as you inflate
    ---@param infAnim Animation [REQUIRED!] What plays to represent your overinflation progress
    ---@param time number? [7] How many ticks does it take for your overinflation to fully update
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.animoverbloat:new(infAnim, time, conditionals)
        self = setmetatable({},UNInf.animoverbloat)
        self.infAnim = infAnim
        self.time = time or 7
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

        self.start = 0
        self.stop = 0
        self.timer = 0

        function self.toggle(val)
            if(self.isOn ~= val) then
                if(val) then
                    self.infAnim:play()
                    self.infAnim:pause()
                    self.infAnim:setTime(math.lerp(self.length * self.prvInf / 20, self.length * self.pressure / UNInf.maxPressure,0))
                else
                    self.infAnim:stop()
                end
                self.isOn = val
            end
        end

        function self:tick()
            if(self.prvInf ~= UNInf.overPressure) then
                self.prvInf = self.pressure
                self.pressure = UNInf.overPressure
                self.timer = UNInf.clock + self.time
                self.start = self.infAnim:getTime()
                self.stop = self.infAnim:getLength() * self.pressure / UNInf.maxOverPressure
            end
            self.toggle(UNInf.checkWhitelist(self.conditionals))
        end

        function self:render(delta)
            --self.infAnim:setTime(math.lerp(self.infAnim:getLength() * self.prvInf / 20, self.infAnim:getLength() * self.pressure / UNInf.maxPressure, delta))
            --log(math.clamp((self.time - (self.timer - (UNInf.clock + delta))) / self.time, 0, 1))
            self.infAnim:setTime(math.lerp(self.start,self.stop,math.clamp((self.time - (self.timer - (UNInf.clock + delta))) / self.time, 0, 1)))
        end
        
        function self:hotSwap(new)
            if(type(new) ~= "Animation") then
                UNInf.annoyLog("You are swapping to an invalid animation, please check your animation path.",3,"badswapOP")
                return
            end
            self.infAnim:setTime(0)
            self.infAnim:stop()
            --assert(type(new) == "Animation" , "You are swapping to an invalid animation, please check your animation path.")
            self.infAnim = new
            self.infAnim:play()
            self.infAnim:pause()
            self.infAnim:setTime(math.lerp(self.infAnim:getLength() * self.prvInf / 20, self.infAnim:getLength() * self.pressure / UNInf.maxOverPressure, 0))
        end

        UNInf.insertToGroups(self)
        return self
    end

    UNInf.pushAutoStart(function()
        for i, v in pairs(models:getChildren()) do
            modelName = v:getName()
            anims = animations[modelName] or {}
            for _, y in pairs(anims) do
                cur = y:getName()
                if(string.sub(cur, 1, 5) == "bloat") then
                    --UNInf.animbloat:new(y)
                    --log(y,string.find(cur,"/"))
                    if(string.find(cur,"/") ~= nil) then
                        is = string.sub(cur,string.find(cur,"/") + 1 ,string.len(cur))
                        conds = {}
                        --log(string.sub(cur,string.find(cur,"/") + 1 ,string.len(cur)))
                        --logTable(string.gmatch(cur,"%g+"))
                        for w in string.gmatch(is,"%g+") do
                            table.insert(conds,w)
                        end
                    else
                        conds = nil
                    end
                    new = UNInf.animbloat:new(y, nil, conds)
                end
            end
        end
        modelName = nil
        new = nil
        cur = nil
        is = nil
        anims = nil
    end)

    UNInf.pushAutoStart(function()
        for i, v in pairs(models:getChildren()) do
            modelName = v:getName()
            anims = animations[modelName] or {}
            for _, y in pairs(anims) do
                cur = y:getName()
                if(string.sub(cur, 1, 9) == "overbloat") then
                    --UNInf.animbloat:new(y)
                    --log(y,string.find(cur,"/"))
                    if(string.find(cur,"/") ~= nil) then
                        is = string.sub(cur,string.find(cur,"/") + 1 ,string.len(cur))
                        conds = {}
                        --log(string.sub(cur,string.find(cur,"/") + 1 ,string.len(cur)))
                        --logTable(string.gmatch(cur,"%g+"))
                        for w in string.gmatch(is,"%g+") do
                            table.insert(conds,w)
                        end
                    else
                        conds = nil
                    end
                    new = UNInf.animoverbloat:new(y, nil, conds)
                end
            end
        end
        modelName = nil
        new = nil
        cur = nil
        is = nil
        anims = nil
    end)
end



return animationBloat