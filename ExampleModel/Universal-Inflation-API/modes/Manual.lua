---@class UNInf
local UNInf

local manual = {}
manual.priority = 10
manual.maxInflation = 20
manual.name = "Manual"
manual.allowed = true
manual.pressure = 0
manual.manualAllowed = true
manual.overPressure = 0
manual.defOverPressureMax = 20

function manual.patch(core)
    UNInf = core
end

function manual.checkPressure()
    return manual.pressure
end

function manual.setPressure(val)
    manual.pressure = math.clamp(val,0,manual.maxInflation)
    manual.overPressure = 0
    return manual.pressure
end

function manual.adjustPressure(val)
    if(manual.pressure + val > manual.maxInflation) then
        manual.overPressure = math.clamp(manual.overPressure + ((manual.pressure + val) - manual.maxInflation),0,UNInf.maxOverPressure)
    end
    local rawPrs = manual.pressure + val
    manual.pressure = math.clamp(manual.pressure + val,0,manual.maxInflation)
    if(manual.pressure ~= manual.maxInflation and manual.overPressure > 0) then
        local gap = manual.maxInflation - rawPrs
        if (gap > manual.overPressure) then
            manual.pressure = math.clamp(manual.pressure + (manual.overPressure - (gap - manual.maxInflation)),0,manual.maxInflation)
            manual.overPressure = 0
        else
            manual.pressure = manual.maxInflation
            manual.overPressure = manual.overPressure - gap
        end
    end
    log(manual.pressure,manual.overPressure)
    return manual.pressure
end

function manual.checkOverPressure()
    return manual.overPressure
end


return manual