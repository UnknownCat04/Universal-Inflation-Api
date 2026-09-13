local popping = {}
---@class UNInf
local UNInf

function popping.patch(core)
    UNInf = core
    UNInf.poppingScraps = {}
    UNInf.poppingScraps.__index = UNInf.poppingScraps

    UNInf.deadPops = {}

    for _, path in ipairs(listFiles("/", true)) do
        if string.find(path, "confetti") then UNInf.confetti = require(path) break end
    end

    ---Handles popping logic, allowing you manipulate what popping looks like
    ---@param scraps table [REQUIRED!] The model parts for your scraps
    ---@param count number? [32] How many scrap will generate, on average (Influenced by permission level, High caps at 128. Default caps at 32, Low caps at 16)
    ---@param opacity number? [0] How opaque will you be when you pop. 
    ---@param model ModelPart? [nil] What model will have their transparency modified
    ---@param reformTimer number? [20] How many ticks does it take to reform after popping
    ---@param sound string|table? ["entity.generic.explode"] What sounds will play when you pop.
    ---@param onDeath boolean? [true] Should death call popping?
    ---@param minInf number? [0] What is the minimum pressure you must have before you will pop
    ---@param maxInf number? [1] What is the maximum pressure you can have to call this pop
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.poppingScraps:new(scraps, count, opacity, model, reformTimer, sound, onDeath, minInf, maxInf, conditionals)
        self = setmetatable({},UNInf.poppingScraps)
        
        --Set all self variables here

        self.scraps = {}
        self.count = count or 32
        self.opacity = opacity or 0
        self.sound = sound  or {"entity.generic.explode"}
        if(type(self.sound) == "string") then
            self.sound = {self.sound}
        end
        self.model = model
        self.reformTimer = reformTimer or 20
        self.onDeath = onDeath or true
        self.minInf = minInf or 0
        self.maxInf = maxInf or 1
        self.conditionals = conditionals or {"any"}
        
        self.playSound = true
        if(UNInf.confetti == nil) then
            
        end
        assert(UNInf.confetti, "Confetti was not located in your model! Please add it before using this function")
        for _, part in pairs(scraps) do
            assert(type(part) == "ModelPart", "One or more of your scrap entries are not a valid model part. Please check the file path given")
        end
        assert(type(self.count) == "number", "Count must be a number or nil")
        assert(self.count > 0, "Count must be a number greater than 0")
        assert(type(self.opacity) == "number" or type(self.opacity) == nil, "Opacity must be a number or nil")
        assert(type(self.sound) == "table", "Sound names must be stored in a table")
        for _, sound in pairs(self.sound) do
            assert(sounds:isPresent(sound), sound.." is not a valid sound path. Please check your spelling and ensure the path is correct")
        end
        assert(type(self.model) == "ModelPart" or type(self.model) == "nil")

        for i,v in pairs(scraps) do
            UNInf.confetti.registerMesh(v:getName(),v)
            self.scraps[i] = v:getName()
        end

        --log(avatar:getPermissionLevel())
        if(avatar:getPermissionLevel() == "HIGH") then
            self.count = math.clamp(self.count, 0 ,128)
        end
        if(avatar:getPermissionLevel() == "DEFAULT") then
            self.count = math.clamp(self.count, 0 ,32)
        end
        if(avatar:getPermissionLevel() == "LOW") then
            self.count = math.clamp(self.count, 0 ,16)
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
            UNInf.confetti.defaultTicker(particle)
        end

        self.popped = false
        self.reforming = false
        self.dead = false
        self.reformStartClock = 0
        self.reformEndClock = 0
        self.passedPrv = false
        function self:tick()
            --Tick behaviors go here
            if(not player:isLoaded()) then return end
            if(self.popped) then
                if(UNInf.clock > self.reformStartClock) then
                    self.reforming = true
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
        ---@param void boolean? Determines if popping should fully deflate you
        function self:pop(void)
            if(not self.popped and player:isLoaded()) then
                if(self.model ~= nil) then
                    self.model:setOpacity(self.opacity)
                    self.reformStartClock = UNInf.clock + math.ceil(self.reformTimer / 2)
                    self.reformEndClock = UNInf.clock + self.reformTimer
                    if(self.dead) then
                        self.reformStartClock = UNInf.clock + 10000000000000000000
                        self.reformEndClock = UNInf.clock + 1000000000000000000000
                    end
                    self.popped = true
                end

                for i = 1, math.round(math.random(self.count * 0.75, self.count * 1.25)), 1 do
                    --log(i,scrap)

                    UNInf.confetti.newParticle(
                        self.scraps[math.random(1,#self.scraps)],
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

                if(self.playSound) then
                    for _, sound in pairs(self.sound) do
                        sounds:playSound(sound, player:getPos())
                    end
                end
                if(void and UNInf.manualAllowed) then
                    UNInf.deflate(UNInf.maxPressure)
                end
            end
            if(not player:isLoaded()) then
                UNInf.annoyLog("You cannot call a pop while the player is unloaded!",3,"badpop")
            end
        end

        ---Triggers the pop manaully, and acknowledges conditions like max pressure and conditionals
        ---@param void boolean? Determines if popping should fully deflate you
        function self:safePop(void)
            if(UNInf.checkWhitelist(self.conditionals) and UNInf.checkPressureRange(self.minInf,self.maxInf)) then
                self:pop(void)
            end
        end

        function self.respawned()
            self.reformStartClock = 0
            self.reformEndClock = 0
            self.dead = false
        end

        -- Insert it into UNInf's groups to run in the proper events. Ticks for tick only, Renders for render only, and hybrid for both
        if(self.onDeath) then
            table.insert(UNInf.deadPops,self)
        end
        table.insert(UNInf.hybrid,self)
        return self
    end

    events.ON_PLAY_SOUND:register(function(id, pos, vol, pitch, loop, category)
        if(id == "minecraft:entity.player.death" and (pos - player:getPos()):length() < 1 and category == "PLAYERS")then
            for _, p in pairs(UNInf.deadPops) do
                p.dead = true
                p:safePop(true)
            end
        end
    end)

end

return popping