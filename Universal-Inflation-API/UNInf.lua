local UNInf = {}

UNInf.VERSION = "1.0"

UNInf.infModes = {}
UNInf.ticks = {}
UNInf.renders = {}
UNInf.hybrid = {}
UNInf.pressure = 0
UNInf.maxPressure = 20
UNInf.curSystem = nil
UNInf.conditional = {}
UNInf.conditional["any"] = true
UNInf.retportLogs = true

UNInf.clock = 0

--log(listFiles(UNInf.path))

-- Here's where the inflation system is loaded and selected. It defaults to the system in the list with the lowest priority that is allowed

for _, file in pairs(listFiles("./infModules.modes")) do
    --log(i, file)
    loaded = require(file)
    assert(UNInf.infModes[loaded.name] == nil, "You have a duplicate mode in your modes folder. Please remove it")
    UNInf.infModes[loaded.name] = require(file)
    if(loaded.allowed) then
        if(UNInf.curSystem == nil) then
            UNInf.curSystem = loaded.name
        else
            if(loaded.priority < UNInf.infModes[UNInf.curSystem].priority and loaded.allowed) then
                UNInf.curSystem = loaded.name
            end
        end
    end
    loaded.rig(UNInf)
end
UNInf.maxPressure = UNInf.infModes[UNInf.curSystem].maxInflation

-- Here's where all the modules are loaded and initialized. It is designed this way to ensure that no race conditions can occur, since Figura scripts normally activate in a somewhat random manner if not specified

for _, file in pairs(listFiles("./infModules")) do
    loaded = require(file)
    loaded.patch(UNInf)
end
loaded = nil


-- These are the associated commands for controlling and engaging with pressure

function UNInf.setMode(mode)
    if(UNInf.infModes[mode] == nil) then
        --assert(UNInf.infModes[mode] ~= nil,"You set the mode to an invalid entry. Please log UNInf.infModes to see what modes you currently have available")
        
        UNInf.annoyLog("You've tried to set the mode to an invalid entry: "..mode.. " Please log UNInf.infModes to see what modes you currently have available")
        return
    end
    if(UNInf.infModes[UNInf.curSystem].myConds ~= nil) then
        for _, v in pairs(UNInf.infModes[UNInf.curSystem].myConds) do
            UNInf.conditional[v] = false
        end
    end
    if(UNInf.infModes[mode].allowed) then
        UNInf.curSystem = mode
        UNInf.infModes[UNInf.curSystem].pressure = (UNInf.pressure / UNInf.maxPressure) * UNInf.infModes[UNInf.curSystem].maxInflation
        UNInf.maxPressure = UNInf.infModes[UNInf.curSystem].maxInflation
    else
        UNInf.annoyLog("The mode you are attempting to swap to is currently disabled. Please check what the mode requires before trying again","invmode")
    end
end

function UNInf.getPressure()
    if(player:isLoaded()) then
        return UNInf.infModes[UNInf.curSystem].checkPressure()
    else
        return 0
    end
end

function UNInf.setPressure(val)
    UNInf.pressure = UNInf.infModes[UNInf.curSystem].setPressure(val)
    return UNInf.pressure
end

function UNInf.inflate(val)
    UNInf.pressure = UNInf.infModes[UNInf.curSystem].adjustPressure(val)
    return UNInf.pressure
end

function UNInf.deflate(val)
    UNInf.pressure = UNInf.infModes[UNInf.curSystem].adjustPressure(-val)
    return UNInf.pressure
end


local passed = false

function UNInf.checkWhitelist(wlist)
    passed = false
    for _, v in pairs(wlist) do
        if(v:find("-") == 1) then
            v = string.sub(v,2)
            if(UNInf.conditional[v] == true) then
                passed = false
                break
            else
                passed = true
            end
        end
        if(UNInf.conditional[v] == true) then
            passed = true
        end
    end
    return passed
end

function UNInf.checkPressureRange(minInf, maxInf)
    return UNInf.pressure / UNInf.maxPressure >= minInf and UNInf.pressure / UNInf.maxPressure <= maxInf
end

UNInf.sentMsg = {}
function UNInf.annoyLog(msg,id)
    if(UNInf.retportLogs == false) then return end
    if(id == nil) then
        id = "inf"
    end
    if(UNInf.sentMsg[id] ~= true) then
        newMess  = {
             "",
            {text = "Warning: ", color = "#a30000"},
            {text = msg, color = "#FF5555"},
            {text = "\n" }
        }
        UNInf.sentMsg[id] = true
        printJson(toJson(newMess))
        newMess = nil
    end
    UNInf.sentMsg["inf"] = false
end

-- This is where the events are run. Ticks are run in events.tick, Renders are run in events.render, and hybrid are run in both

function events.tick()
    UNInf.pressure = UNInf.getPressure()
    --log(UNInf.pressure)
    for _, v in pairs(UNInf.ticks) do
        v:tick()
    end
    for _, v in pairs(UNInf.hybrid) do
        v:tick()
    end
    UNInf.clock = UNInf.clock + 1
end

function events.render(delta,context,matrix)
    for _, v in pairs(UNInf.renders) do
        v:render(delta,context,matrix)
    end
    for _, v in pairs(UNInf.hybrid) do
        v:render(delta,context,matrix)
    end
end

return UNInf