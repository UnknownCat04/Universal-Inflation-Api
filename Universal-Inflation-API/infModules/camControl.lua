local cameras = {}
local UNInf

function cameras.patch(core)
    UNInf = core
    UNInf.thirdPersonCam = {}
    UNInf.thirdPersonCam.__index = UNInf.thirdPersonCam
    function UNInf.thirdPersonCam:new(minPull, maxPull, minLift, maxLift, defOffset, minInf, maxInf, conditionals)
        self = setmetatable({},UNInf.thirdPersonCam)
        
        --Set all self variables here

        self.maxPull = maxPull or -3
        self.minPull = minPull or 0
        self.maxLift = maxLift or 2
        self.minLift = minLift or 0
        self.minInf = minInf or 0
        self.maxInf = maxInf or 1
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
            if(UNInf.pressure / UNInf.maxPressure >= self.minInf and UNInf.pressure / UNInf.maxPressure <= self.maxInf and UNInf.checkWhitelist(self.conditionals) and not renderer:isFirstPerson()) then
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
    function UNInf.firstPersonCam:new(cameraBone,defOffset,minInf,maxInf,conditionals)
        self = setmetatable({},UNInf.firstPersonCam)

        self.cameraBone = cameraBone
        self.defOffset = defOffset
        self.minInf = minInf or 0
        self.maxInf = maxInf or 1
        self.conditionals = conditionals or {"any"}



        self.active = false

        function self:render(delta)
            if(UNInf.pressure / UNInf.maxPressure >= self.minInf and UNInf.pressure / UNInf.maxPressure <= self.maxInf and UNInf.checkWhitelist(self.conditionals) and renderer:isFirstPerson() and (player:getPose() == "STANDING" or player:getPose() == "CROUCHING") and self.cameraBone:getVisible()) then
                self.active = true
                renderer:setOffsetCameraRot(self.cameraBone:getRot():add(self.cameraBone:getAnimRot()))
                renderer:setOffsetCameraPivot(self.cameraBone:getPos():add(self.cameraBone:getAnimPos()) / 16)
            else
                if(self.active) then
                    self.active = false
                    renderer:setOffsetCameraPivot(self.defOffset)
                    renderer:setOffsetCameraRot(nil)
                end
            end
        end
        
        table.insert(UNInf.renders,self)
        return self
    end
end

return cameras