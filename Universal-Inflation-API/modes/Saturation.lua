local UNInf

local hunger = {}
hunger.priority = 5
hunger.maxInflation = 20
hunger.name = "Saturation"
hunger.allowed = true
hunger.pressure = 0
hunger.manualAllowed = false

function hunger.rig(core)
    UNInf = core
end

function hunger.checkPressure()
    if(player:getFood() >= 15) then
        return player:getSaturation()
    else
        return(player:getSaturation() * (player:getFood() / 15))
    end
end

function hunger.setPressure(val)
    UNInf.annoyLog("Pressure cannot be set in Saturation mode","satset")
    return false
end

function hunger.adjustPressure(val)
    UNInf.annoyLog("Pressure cannot be adjusted in Saturation mode","satadj")
    return false
end


--UNInf.infSystems[hunger.name] = hunger
--UNInf.systemSelectUpd(hunger)

return hunger