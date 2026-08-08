local cameras = {}
---@class UNInf
local UNInf

function cameras.patch(core)
    UNInf = core
    UNInf.thirdPersonCam = {}
    UNInf.thirdPersonCam.__index = UNInf.thirdPersonCam
    ---Contols your third person camera based off of your inflation
    ---@param minPull number? [0] How much the camera is pulled back by this module at the minimum inflation
    ---@param maxPull number? [-3] How much the camera is pulled back by this module at the maximum inflation
    ---@param minLift number? [0] How much the camera is raised by this module at the minimum inflation
    ---@param maxLift number? [2] much the camera is raised by this module at the maximum inflation
    ---@param defOffset Vector3? [nil] What the camera returns to when this module is disabled. Nil is the default minecraft perspective
    ---@param minInf number? [0] How inflated you must be for this module to be activated. Acknowledges overpressure, as a percentage
    ---@param maxInf number? [2] How inflated you can be before this module is ignored. Acknowledges overpressure, as a percentage
    ---@param conditionals string? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.thirdPersonCam:new(minPull, maxPull, minLift, maxLift, defOffset, minInf, maxInf, conditionals)
        self = setmetatable({},UNInf.thirdPersonCam)
        
        --Set all self variables here

        self.maxPull = maxPull or -3
        self.minPull = minPull or 0
        self.maxLift = maxLift or 2
        self.minLift = minLift or 0
        self.minInf = minInf or 0
        self.maxInf = maxInf or 2
        self.conditionals = conditionals or {"any"}

        self.defOffset = defOffset

        --Error checker
        assert(type(self.maxPull) == "number", "Max pull is not set to a number. Please set it to a negative number.")
        assert(type(self.minPull) == "number", "Minimum pull is not set to a number. Please set it to a negative number.")
        assert(type(self.maxLift) == "number", "Max Lift is not set to a number. Please set it to a number.")
        assert(type(self.minLift) == "number", "Minimum Lift is not set to a number. Please set it to a number.")
        if(self.defOffset ~= nil) then
            assert(type(self.defOffset) == "Vector3", "The default offset is not set to a vector 3 value. Please set it to a vector 3 value. You can als0 set it to disabled as a string to disable the default offset.")
        end
        --Error checker

        self.active = false
        self.truePull = 0
        self.trueList = 0
        self.progress = 0
        self.goal = 0
        self.prvInf = 0
        self.prvPoint = 0
        self.frame = 0
        self.fpsCalc = 10

        function self:render(delta)
            --Render behaviors go here
            if((UNInf.pressure + UNInf.overPressure) / UNInf.maxPressure >= self.minInf and (UNInf.pressure + UNInf.overPressure) / UNInf.maxPressure <= self.maxInf and UNInf.checkWhitelist(self.conditionals) and not renderer:isFirstPerson()) then
                self.active = true
                --self.progress = (UNInf.pressure - (self.minInf * UNInf.maxPressure)) / ((self.maxInf -self.minInf) * UNInf.maxPressure)
                if(self.prvInf ~= UNInf.pressure) then
                    self.prvPoint = self.progress
                    self.prvInf = UNInf.pressure
                    self.goal = (UNInf.pressure - (self.minInf * UNInf.maxPressure)) / ((self.maxInf -self.minInf) * UNInf.maxPressure)
                    self.frame = 0
                    self.fpsCalc = client:getFPS() / 12
                end
                self.progress = math.lerp(self.prvPoint,self.goal,self.frame / self.fpsCalc)
                self.frame = math.clamp(self.frame + 1,0,self.fpsCalc)
                self.truePull = math.lerp(self.minPull, self.maxPull, self.progress)
                self.trueLift = math.lerp(self.minLift, self.maxLift, self.progress)
                renderer:setOffsetCameraPivot(client:getCameraDir().x * self.truePull, (client:getCameraDir().y *self.truePull) + self.trueLift,client:getCameraDir().z * self.truePull)
            else
                if(self.active) then
                    renderer:setOffsetCameraPivot(self.defOffset)
                    self.active = false
                end
            end
        end

        -- Insert it into UNInf's groups to run in the proper events. Ticks for tick only, Renders for render only, and hybrid for both
        table.insert(UNInf.renders,self)
        return self
    end

    UNInf.firstPersonCam = {}
    UNInf.firstPersonCam.__index = UNInf.firstPersonCam
    ---Sets up a bone to move the first person camera in response to inflation
    ---@param cameraBone ModelPart [REQUIRED!] The bone that the camera actually links to
    ---@param defOffset Vector3? [nil] What the camera returns to when this module is disabled. Nil is the default minecraft perspective
    ---@param minInf number? [0] How inflated you must be for this module to be activated
    ---@param maxInf number? [1] How inflated you can be before this module is ignored
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for on the fly modification
    function UNInf.firstPersonCam:new(cameraBone,defOffset,minInf,maxInf,conditionals)
        self = setmetatable({},UNInf.firstPersonCam)

        self.cameraBone = cameraBone
        self.defOffset = defOffset
        self.minInf = minInf or 0
        self.maxInf = maxInf or 1
        self.conditionals = conditionals or {"any"}

        self.parts = {cameraBone}
        self.allParents = false
        while self.allParents == false do
            if( self.parts[#self.parts]:getParent() ~= nil) then
                table.insert(self.parts, self.parts[#self.parts]:getParent())
            else
                self.allParents = true
            end
        end

        --self.origPos = self.cameraBone:getPivot() / 16
        --self.origRot = self.cameraBone:getRot()
        --log(self.parts)
        --self.pos = vec(0,0,0)
        --self.rot = vec(0,0,0)
        

        self.active = false

        function self:post_world_render(delta)
            if(not player:isLoaded()) then return end
            if(UNInf.checkPressureRange(self.minInf,self.maxInf) and UNInf.checkWhitelist(self.conditionals) and renderer:isFirstPerson() and self.cameraBone:getVisible()) then
                self.active = true
                --renderer:setOffsetCameraPivot(self.cameraBone:getPos():add(self.cameraBone:getAnimPos()) / 16)
                renderer:setOffsetCameraPivot(self.cameraBone:partToWorldMatrix():apply():sub(player:getPos(delta):add(0,player:getEyeHeight(),0)))
                --[[self.pos = vec(0,0,0):add(self.origPos)
                self.prvAngle = vec(0,0,0)
                self.prvPivot = vec(0,0,0)
                self.rot = vec(0,0,0):add(self.origRot)
                for _, p in pairs(self.parts) do
                    self.pos = self.pos:add(p:getAnimPos() / 16)
                    --self.pos = self.pos:add()
                    self.rot = self.rot:add(p:getAnimRot())
                    self.prvPivot = p:getPivot()
                    self.prvAngle = self.rot
                end
                log(self.pos)
                renderer:setOffsetCameraPivot(self.pos:sub(vec(0,player:getEyeHeight(),0)))
                renderer:setOffsetCameraRot(self.rot)]]
            else
                if(self.active) then
                    self.active = false
                    renderer:setOffsetCameraPivot(self.defOffset)
                    --renderer:setOffsetCameraRot(nil)
                end
            end
        end
        
        table.insert(UNInf.postWorldRenders,self)
        return self
    end
end

return cameras