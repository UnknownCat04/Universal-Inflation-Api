local UNInf

local template = {}
template.priority = 1000000 -- Determines which mode is selected between multiple allowed modes. The lowest priority wins 
template.maxInflation = 20 -- How high the inflation score can go. 20 is a good baseline, but can be any number you desire
template.name = "Template" -- The name of the mode. Used when toggling into it and identifying it
template.allowed = true -- This determines if this mode is even allowed to be selected. Set to a check of some sort if you want it to be mod dependant
template.pressure = 0 -- The mode's internal pressure. Seperated from the UNInf's pressure
template.manualAllowed = true -- This determines if the command inflate, deflate, and setPressure are allowed. Set to false if it isn't possible or allowed in this mode

function template.patch(core)
    UNInf = core
end

function template.checkPressure()
    -- This is ran once every tick on its own. It is also ran whenever the command UNInf.getPressure() is ran.
    return template.pressure
end

function template.setPressure(val)
    -- This is ran whenever setPressure is ran, and should be how the player forces a specific value into their inflation value. Return false if it is refused
    template.pressure = math.clamp(val,0,template.maxInflation)
    return template.pressure
end

function template.adjustPressure(val)
    -- This is ran whenever inflate or deflate is ran, and should be how the player adjusts their inflation value via the input amount. Return false if it is not allowed
    template.pressure = math.clamp(template.pressure + val,0,template.maxInflation)
    return template.pressure
end

return template