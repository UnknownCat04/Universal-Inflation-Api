local deflateAnim = {}
---@class UNInf
local UNInf

function deflateAnim.patch(core)
    UNInf = core

    UNInf.pingableDefAnims = {}
    UNInf.defAnimList = {}

    UNInf.deflateAnimation = {}
    UNInf.deflateAnimation.__index = UNInf.deflateAnimation
    ---Plays a deflation animation whenever you call it, or in the case of BwB deflate via its keybind
    ---@param defAnim Animation [REQUIRED!] What should play when you run this module
    ---@param chargeAnim Animation? [nil] What should play while you are charging this module
    ---@param chargeTicks number? [30] How many ticks will pass before a charged deflation is run
    ---@param chargeOnly string? ["any"] Should this animation only play if you were charging? Or only if you don't. The accepted values are "uncharged", "charged", and "any"
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for calling and on the fly modification
    function UNInf.deflateAnimation:new(defAnim,chargeAnim,chargeTicks,chargeOnly,conditionals)
        self = setmetatable({},UNInf.deflateAnimation)
        
        --Set all self variables here

        self.defAnim = defAnim

        table.insert(UNInf.pingableDefAnims,self.defAnim)
        self.ID = #UNInf.pingableDefAnims
        --log(self.ID,UNInf.pingableDefAnims[self.ID],self.defAnim,UNInf.pingableDefAnims)

        self.chargeAnim = chargeAnim
        table.insert(UNInf.pingableDefAnims,self.chargeAnim)
        self.chargeID = #UNInf.pingableDefAnims
        self.chargeCount = chargeTicks or 30
        self.chargeOnly = chargeOnly or "any"
        self.conditionals = conditionals or {"any"}

        self.holdTicks = 0
        self.defMeter = 0
        self.prvDefMeter = 0
        self.charging = false
        function self:tick()
            --Tick behaivors go here
            if(UNInf.checkWhitelist(self.conditionals)) then
                if(UNInf.curSystem == "BwBComp") then
                    if(player:isLoaded()) then
                        self.defMeter = player:getNbt()["ForgeCaps"]["better_with_blimps:player_variables"]["DeflateCharge"]
                    else
                        self.defMeter = 0
                    end
                    if (self.defMeter > 0) then
                        self.charging = true
                    end
                    if(self.charging) then
                        if(self.holdTicks > 5 and self.defMeter <= 0) then
                            self.charging = false
                            self.holdTicks = 0
                        end
                        self.holdTicks = self.holdTicks + 1
                    end
                else
                    self.charging = UNInf.chargingDef
                end
                if(self.chargeAnim ~= nil) then
                    --self.chargeAnim:setPlaying(self.charging)
                    if((not self.chargeAnim:isPlaying() or not self.chargeAnim:isPaused()) and self.charging) then
                        pings.playDefAnim(self.chargeID)
                    end
                    if(self.chargeAnim:getPlayState() ~= "STOPPED" and not self.charging) then
                        pings.stopDefAnim(self.chargeID)
                    end
                end
                self.prvDefMeter = self.defMeter
            else
                self.defMeter = 0
                self.prvDefMeter = 0
            end
        end

        function self:forcedCall()
            pings.playDefAnim(self.ID)
            if(self.chargeAnim ~= nil) then
                pings.stopDefAnim(self.chargeID)
            end
        end

        function self:call()
            if(UNInf.checkWhitelist(self.conditionals) and ((UNInf.chargingDef and self.chargeOnly == "charged") or self.chargeOnly == "any" or (not UNInf.chargingDef and self.chargeOnly == "uncharged"))) then
                pings.playDefAnim(self.ID)
                if(self.chargeAnim ~= nil) then
                    pings.stopDefAnim(self.chargeID)
                end
            end
        end

        -- Insert it into UNInf's groups to run in the proper events. This function handles it automatically, based on all present events that are supported
        UNInf.insertToGroups(self)
        table.insert(UNInf.defAnimList,self)
        return self
    end

    UNInf.chargePower = 0
    UNInf.chargingDef = false
    ---Allows a charged deflation to occur, when returned true it will start charging. When it is then returned false it will release the charge and deflate the player
    ---@param chargingUp boolean
    ---@param val number
    function UNInf.chargeDeflate(chargingUp,val)
        if(not UNInf.manualAllowed) then
            UNInf.annoyLog("Manual pressure adjustment is not allowed in current mode",2, "NoManuDeflate")
            return
        end
        if(chargingUp) then
            UNInf.chargingDef = true
        elseif(UNInf.chargingDef) then
            UNInf.deflate(math.ceil(val * UNInf.chargePower))
            UNInf.chargingDef = false
            UNInf.chargePower = 0
        end
    end
    function events.tick()
        if(UNInf.chargingDef and UNInf.manualAllowed) then
            UNInf.chargePower = math.clamp(UNInf.chargePower + 0.05,0,1)
        end
    end
    UNInf.setOnPressureChange(function(delta)
        if delta < 0 then
            for _, anim in pairs(UNInf.defAnimList) do
                anim:call()
            end
        end
    end)

    function UNInf.playDefAnim(animId)
        UNInf.pingableDefAnims[animId]:stop()
        UNInf.pingableDefAnims[animId]:play()
    end
    function UNInf.stopDefAnim(animID)
        UNInf.pingableDefAnims[animID]:stop()
    end
    pings.playDefAnim = UNInf.playDefAnim
    pings.stopDefAnim = UNInf.stopDefAnim

    UNInf.pushAutoStart(function()
        for i, v in pairs(models:getChildren()) do
        modelName = v:getName()
        anims = animations[modelName] or {}
        for _, y in pairs(anims) do
            cur = y:getName()
            if(string.sub(cur, 1, 7) == "deflate") then
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
                new = UNInf.deflateAnimation:new(y, nil, nil, nil, conds)
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

return deflateAnim