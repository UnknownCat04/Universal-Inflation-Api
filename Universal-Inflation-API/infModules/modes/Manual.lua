local UNInf

local manual = {}
manual.priority = 1000000
manual.maxInflation = 20
manual.name = "Manual"
manual.allowed = true
manual.pressure = 0

function manual.rig(core)
    UNInf = core
end

function manual.checkPressure()
    return manual.pressure
end

function manual.setPressure(val)
    manual.pressure = math.clamp(val,0,manual.maxInflation)
    return manual.pressure
end

function manual.adjustPressure(val)
    manual.pressure = math.clamp(manual.pressure + val,0,manual.maxInflation)
    return manual.pressure
end


--UNInf.infSystems[manual.name] = manual
--UNInf.systemSelectUpd(manual)

return manual