local UNInf

local hunger = {}
hunger.priority = 5
hunger.maxInflation = 20
hunger.name = "Saturation"
hunger.allowed = true
hunger.pressure = 0

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
    log("Pressure cannot be set in this mode")
end

function hunger.adjustPressure(val)
    log("Pressure cannot be adjusted in this mode")
end


--UNInf.infSystems[hunger.name] = hunger
--UNInf.systemSelectUpd(hunger)

return hunger