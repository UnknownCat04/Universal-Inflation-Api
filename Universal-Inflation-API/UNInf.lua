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

UNInf.clock = 0

--log(listFiles(UNInf.path))


-- Here's where the inflation system is loaded and selected. It defaults to the system in the list with the lowest priority that is allowed

for _, file in pairs(listFiles("./infModules.modes")) do
    --log(i, file)
    loaded = require(file)
    UNInf.infModes[loaded.name] = require(file)
    if(UNInf.curSystem == nil and loaded.allowed) then
        UNInf.curSystem = loaded.name
    end
    if(loaded.priority < UNInf.infModes[UNInf.curSystem].priority and loaded.allowed) then
        UNInf.curSystem = loaded.name
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
    assert(UNInf.infModes[mode] ~= nil,"You set the mode to an invalid entry. Please log UNInf.infModes to see what modes you currently have available")
    if(UNInf.infModes[UNInf.curSystem].myConds ~= nil) then
        for _, v in pairs(UNInf.infModes[UNInf.curSystem].myConds) do
            UNInf.conditional[v] = false
        end
    end
    UNInf.curSystem = mode
    UNInf.maxPressure = UNInf.infModes[UNInf.curSystem].maxInflation
end

function UNInf.getPressure()
    if(player:isLoaded()) then
        return UNInf.infModes[UNInf.curSystem].checkPressure()
    else
        return 0
    end
end

function UNInf.setPressure(val)
    if(player:isLoaded()) then
        return UNInf.infModes[UNInf.curSystem].setPressure(val)
    else
        return false
    end
end

function UNInf.inflate(val)
    if(player:isLoaded()) then
        return UNInf.infModes[UNInf.curSystem].adjustPressure(val)
    else
        return false
    end
end

function UNInf.defalte(val)
    if(player:isLoaded()) then
        return UNInf.infModes[UNInf.curSystem].adjustPressure(-val)
    else 
        return false
    end
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

-- This is where the events are run. Ticks are run in events.tick, Renders are run in events.render, and hybrid are run in both

function events.tick()
    UNInf.pressure = UNInf.getPressure()
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