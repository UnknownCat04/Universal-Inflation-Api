local deflateAnim = {}
---@class UNInf
local UNInf

function deflateAnim.patch(core)
    UNInf = core

    UNInf.pingableDefAnims = {}


    UNInf.deflateAnimation = {}
    UNInf.deflateAnimation.__index = UNInf.deflateAnimation
    ---Plays a deflation animation whenever you call it, or in the case of BwB deflate via its keybind
    ---@param defAnim Animation [REQUIRED!] What should play when you run this module
    ---@param chargeAnim Animation? [nil] What should play while you are charging this module
    ---@param chargeTicks number? [30] How many ticks will pass before a charged deflation is run
    ---@param chargedDeflate number? [0.25] How much should you deflate by when a fully charged deflation occurs. Percentage
    ---@param conditionals table? [{"any"}] Toggles the module in response to condtionals
    ---@return table self Returns itself for calling and on the fly modification
    function UNInf.deflateAnimation:new(defAnim,chargeAnim,chargeTicks,chargedDeflate,conditionals)
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
        self.chargedDeflate = chargedDeflate or 0.25
        self.conditionals = conditionals or {"any"}

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
                    self.charging = self.defMeter > 0
                else
                    if(self.charging) then
                        self.defMeter = self.defMeter + 1
                    else
                        self.defMeter = 0
                    end
                    if(self.defMeter > self.chargeCount) then
                        self.defMeter = 0
                        self.prvDefMeter = self.chargeCount
                        self.charging = false
                    end
                end
                if(self.chargeAnim ~= nil) then
                    --self.chargeAnim:setPlaying(self.charging)
                    if(self.chargeAnim:getPlayState() ~= "PLAYING" and self.charging) then
                        pings.playDefAnim(self.chargeID)
                    end
                    if(self.chargeAnim:getPlayState() ~= "STOPPED" and not self.charging) then
                        pings.stopDefAnim(self.chargeID)
                    end
                end
                if(self.prvDefMeter > self.defMeter) then
                    if(UNInf.curSystem == "BwBComp") then
                        pings.playDefAnim(self.ID)
                    else
                        self:call(self.prvDefMeter / self.chargeCount * (self.chargedDeflate * UNInf.maxPressure))
                    end
                end
                self.prvDefMeter = self.defMeter
            else
                self.defMeter = 0
                self.prvDefMeter = 0
            end
        end

        function self:call(val)
            if(UNInf.deflate(val) ~= false) then
                pings.playDefAnim(self.ID)
            end
        end

        function self:charge(val)
            if(val ~= false) then
                val = true
            end
            self.charging = val
        end

        -- Insert it into UNInf's groups to run in the proper events. Ticks for tick only, Renders for render only, and hybrid for both
        table.insert(UNInf.ticks,self)
        return self
    end
    function UNInf.playDefAnim(animId)
        UNInf.pingableDefAnims[animId]:stop()
        UNInf.pingableDefAnims[animId]:play()
    end
    function UNInf.stopDefAnim(animID)
        UNInf.pingableDefAnims[animID]:stop()
    end
    pings.playDefAnim = UNInf.playDefAnim
    pings.stopDefAnim = UNInf.stopDefAnim
end

return deflateAnim