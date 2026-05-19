local UNInf

local manual = {}
manual.priority = 10
manual.maxInflation = 20
manual.name = "Manual"
manual.allowed = true
manual.pressure = 0
manual.manualAllowed = true

function manual.patch(core)
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


return manual