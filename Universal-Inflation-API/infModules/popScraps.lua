local popping = {}
---@class UNInf
local UNInf

function popping.patch(core)
    UNInf = core
    UNInf.poppingScraps = {}
    UNInf.poppingScraps.__index = UNInf.poppingScraps
    ---Handles popping logic, allowing you manipulate what popping looks like
    ---@param scraps table [REQUIRED!] What variables do you need
    ---@param confettiPath string [REQUIRED!] The file path for your confetti instance
    ---@param count number|nil [32] How many of each scrap will generate, on average
    ---@param opacity number|nil [0] How opaque will you be when you pop. 
    ---@param sound string|table|nil ["entity.generic.explode"] What sounds will play when you pop.
    ---@param model ModelPart|nil What model will be modifed by this. 
    ---@param reformTimer number|nil How many ticks does it take to reform after popping
    ---@param onDeath boolean|nil Should death call popping?
    ---@param minInf number|nil What is the minimum pressure you must have before you will pop
    ---@param maxInf number|nil What is the maximum pressure you can have to call this pop
    ---@param conditionals table|nil Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.poppingScraps:new(scraps, confettiPath, count, opacity, sound, model, reformTimer, onDeath, minInf, maxInf, conditionals)
        self = setmetatable({},UNInf.poppingScraps)
        
        --Set all self variables here

        self.scraps = {}
        self.confetti = require(confettiPath)
        self.count = count or 32
        self.opacity = opacity or 0
        self.sound = sound  or {"entity.generic.explode"}
        if(type(self.sound) == "string") then
            self.sound = {self.sound}
        end
        self.model = model
        self.reformTimer = reformTimer or 20
        self.onDeath = onDeath or true
        self.minInf = minInf or 0.5
        self.maxInf = maxInf or 1
        self.conditionals = conditionals or {"any"}
        
        self.playSound = true

        for i,v in pairs(scraps) do
            self.confetti.registerMesh(v:getName(),v)
            self.scraps[i] = v:getName()
        end

        self.scrapFlutter = function(particle)
            local x,y,z = particle.velocity:unpack()
            if (world.getBlockState(particle._position+vec(x,0,0)):isSolidBlock() or world.getBlockState(particle._position-vec(x,0,0)):isSolidBlock() or world.getBlockState(particle._position+vec(0,y,0)):isSolidBlock() or world.getBlockState(particle._position-vec(0,y,0)):isSolidBlock() or world.getBlockState(particle._position+vec(0,0,z)):isSolidBlock() or world.getBlockState(particle._position-vec(0,0,z)):isSolidBlock()) then
                if(particle.lifetime < particle.options["lifetime"] - 5) then
                    particle.velocity = vec(0,0,0)
                    particle.position = particle.position:sub(x * 1.4,y * 1.4,z * 1.4)
                    particle.options["rotationOverTime"] = vec(0,0,0)
                    particle.options["acceleration"] = vec(0,0,0)
                    particle.options["friction"] = 0
                end
            end
            self.confetti.defaultTicker(particle)
        end

        self.popped = false
        self.reforming = false
        self.dead = false
        self.reformStartClock = 0
        self.reformEndClock = 0
        self.passedPrv = false
        function self:tick()
            --Tick behaivors go here
            if(not player:isLoaded()) then return end
            if(self.popped) then
                if(UNInf.clock > self.reformStartClock) then
                    self.reforming = true
                end
            else
                if(self.onDeath) then
                    if(player:isAlive() == false and UNInf.checkWhitelist(self.conditionals) and self.passedPrv) then
                        self:pop()
                        self.dead = true
                    end
                    self.passedPrv = UNInf.checkPressureRange(self.minInf,self.maxInf)
                end
            end
            if(self.dead and player:isAlive()) then
                self:respawned()
            end
        end

        function self:render(delta)
            --Render behaviors go here
            if(self.reforming) then
                if(UNInf.clock + delta > self.reformEndClock) then
                    self.popped = false
                    self.reforming = false
                    self.model:setOpacity(nil)
                else
                    self.model:setOpacity(math.lerp(self.opacity,1,(UNInf.clock + delta - self.reformStartClock) / (self.reformTimer / 2)))
                end
            end
        end

        ---Triggers the pop manually. Ignores all conditions
        ---@param void boolean|nil Determines if popping should fully deflate you
        function self:pop(void)
            if(not self.popped and player:isLoaded()) then
                if(self.model ~= nil) then
                    self.model:setOpacity(self.opacity)
                end
                self.reformStartClock = UNInf.clock + math.ceil(self.reformTimer / 2)
                self.reformEndClock = UNInf.clock + self.reformTimer

                for _,scrap in pairs(self.scraps) do
                    for i = 1, math.round(math.random(self.count * 0.75, self.count * 1.25)), 1 do
                        --log(i,scrap)
                        self.confetti.newParticle(
                            scrap,
                            player:getPos():add(vec(math.random(-100, 100) / 75, math.random(0, 200) / 100, math.random(-100, 100) / 75)),
                            vec((math.random(-100, 100) / 100)  * 1.5, (math.random(-25, 100) / 100) * 1.5, (math.random(-100, 100) / 100)  * 1.5),
                            {
                            lifetime = math.random(200,400),
                            friction = 0.90,
                            scale  = math.random(100,200) / 100,
                            acceleration = vec(0,-0.025,0),
                            rotation = vec(math.random(0,180),math.random(0,180),math.random(0,180)),
                            rotationOverTime = vec(math.random(-10,10),math.random(-10,10),math.random(-10,10)),
                            ticker  = self.scrapFlutter
                            }
                        )
                    end
                end
                if(self.playSound) then
                    for _, sound in pairs(self.sound) do
                        sounds:playSound(sound, player:getPos())
                    end
                end

                self.popped = true
                if(void and UNInf.manualAllowed) then
                    UNInf.deflate(UNInf.maxPressure)
                end
            end
            if(not player:isLoaded()) then
                UNInf.annoyLog("You cannot call pop while the player is unloaded!","badpop")
            end
        end

        ---Triggers the pop manaully, and acknowledges conditions like max pressure and conditionals
        ---@param void boolean|nil Determines if popping should fully deflate you
        function self:safePop(void)
            if(UNInf.checkWhitelist(self.conditionals) and UNInf.checkPressureRange(self.minInf,self.maxInf)) then
                self:pop(void)
            end
        end

        function self.respawned()
            self.reformStartClock = 0
            self.reformEndClock = 0
        end

        -- Insert it into UNInf's groups to run in the proper events. Ticks for tick only, Renders for render only, and hybrid for both
        table.insert(UNInf.hybrid,self)
        return self
    end
end

return popping