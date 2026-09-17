---@class UNInf
local UNInf = {}

---@version Pre-release

UNInf.infModes = {}
UNInf.ticks = {}
UNInf.renders = {}
UNInf.postWorldRenders = {}
UNInf.pressure = 0
UNInf.maxPressure = 20
UNInf.overPressure = 0
UNInf.maxOverPressure = 20
UNInf.overrideOverPressure = nil
UNInf.curSystem = nil
UNInf.manualAllowed = false
UNInf.conditional = {}
UNInf.conditional["any"] = true
UNInf.reportLogs = true

UNInf.clock = 0


UNInf.autoStart = false

for _, file in pairs(listFiles("./")) do
    if(file:find("autoSetup") ~= nil) then
        UNInf.autoStart = require(file)
        break
    end
end

--log(UNInf.autoStart)
--log(listFiles(UNInf.path))

-- This script allows functions to be pushed into auto setup, if it is present
if(UNInf.autoStart ~= false) then
    ---Pushes something ot the autostart script if it exists. If it does not, the function does nothing
    ---@param func function The function that is run at the start of the API, after everything is used. Intended for automatically starting the API in response to certain preset conditions
    function UNInf.pushAutoStart(func)
        table.insert(UNInf.autoStart.moduleInit,func)
    end
else
    function UNInf.pushAutoStart(func)

    end
end
-- This handles the pressure change event, which must be set up BEFORE UNInf loads its modules so that it is available within them

local pressureChangeEvents = {}
---Sets the function provided to occure whenever pressure is changed
---@param func function The function that occurs whenever a pressure change occurs. The function supports delta, deltaP, total, and totalP. Delta is the change, total is the end result. P means it is the percentage change
function UNInf.setOnPressureChange(func)
    table.insert(pressureChangeEvents,func)
end

local curPressure = 0
local function onPressureChange()
    local delta = UNInf.pressure + UNInf.overPressure - curPressure
    local deltaP = delta / UNInf.maxPressure
    local total = UNInf.pressure + UNInf.overPressure
    local totalP = total / UNInf.maxPressure
    if (delta == 0) then return end
    for _, func in pairs(pressureChangeEvents) do
        func(delta,deltaP,total,totalP)
    end

    curPressure = total
end


-- Here's where the inflation system is loaded and selected. It defaults to the system in the list with the lowest priority that is allowed

for _, file in pairs(listFiles("./modes")) do
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
    loaded.patch(UNInf)
end
UNInf.maxPressure = UNInf.infModes[UNInf.curSystem].maxInflation

-- Here's where all the modules are loaded and initialized. It is designed this way to ensure that no race conditions can occur, since Figura scripts normally activate in a somewhat random manner if not specified

for _, file in pairs(listFiles("./infModules")) do
    loaded = require(file)
    loaded.patch(UNInf)
end
loaded = nil


-- These are the associated commands for controlling and engaging with pressure

---Swaps the current mode to a new one, transfering pressures over appropriately
---@param mode string The name of the new mode you want to use
function UNInf.setMode(mode)
    if(UNInf.infModes[mode] == nil) then
        --assert(UNInf.infModes[mode] ~= nil,"You set the mode to an invalid entry. Please log UNInf.infModes to see what modes you currently have available")
        
        UNInf.annoyLog("You've tried to set the mode to an invalid entry: "..mode.. " Please log UNInf.infModes to see what modes you currently have available", 3)
        return
    end
    if(UNInf.infModes[UNInf.curSystem].myConds ~= nil) then
        for _, v in pairs(UNInf.infModes[UNInf.curSystem].myConds) do
            UNInf.conditional[v] = false
        end
    end
    if(UNInf.infModes[mode].allowed) then
        UNInf.curSystem = mode
        UNInf.manualAllowed = UNInf.infModes[UNInf.curSystem].manualAllowed
        UNInf.infModes[UNInf.curSystem].pressure = (UNInf.pressure / UNInf.maxPressure) * UNInf.infModes[UNInf.curSystem].maxInflation
        UNInf.overPressure = 0
        UNInf.infModes[UNInf.curSystem].overPressure = 0
        UNInf.maxOverPressure = UNInf.infModes[UNInf.curSystem].defOverPressureMax
        if(UNInf.overrideOverPressure ~= nil) then
            UNInf.maxOverPressure = UNInf.overrideOverPressure
        end
        UNInf.maxPressure = UNInf.infModes[UNInf.curSystem].maxInflation
    else
        UNInf.annoyLog("The mode you are attempting to swap to is currently disabled. Please check what the mode requires before trying again",2,"invmode")
    end
end



---Get the current pressure you're at
---@return number
function UNInf.getPressure()
    local val
    if(player:isLoaded()) then
        UNInf.overPressure = UNInf.infModes[UNInf.curSystem].checkOverPressure()
        return UNInf.infModes[UNInf.curSystem].checkPressure()
    else
        return 0
    end
end
function UNInf.getOverPressure()
    return UNInf.infModes[UNInf.curSystem].checkOverPressure()
end
---Set the current pressure to the provided value, if allowed
---@param val integer The desired pressure given
---@return number|false "What is the new current pressure score. Returns false if the process had failed"
function UNInf.setPressure(val)
    if(UNInf.infModes[UNInf.curSystem].setPressure(val) ~= false) then
        onPressureChange()
        return UNInf.getPressure()
    end
    return false
end

local newPrs = false
---Raise the current pressure by the provided value, if allowed
---@param val integer The desired inflation given
---@return number|false "What is the new current pressure score. Returns false if the process had failed"
function UNInf.inflate(val)
    newPrs = UNInf.infModes[UNInf.curSystem].adjustPressure(val)
    if(newPrs ~= false) then
        UNInf.pressure = newPrs
        onPressureChange()
        return UNInf.getPressure()
    end
    return false
end
---Lower the current pressure by the provided value, if allowed
---@param val integer The desired deflation given
---@return number|false "What is the new current pressure score. Returns false if the process had failed"
function UNInf.deflate(val)
    newPrs = UNInf.infModes[UNInf.curSystem].adjustPressure(-val)
    if(newPrs ~= false) then
        UNInf.pressure = newPrs
        onPressureChange()
        return UNInf.getPressure()
    end
    return false
end
--Set the maximum overpressure your model can recoginize. This overides all default values. Nil reinstates the default
---@param val number? The new overpressure maximum
function UNInf.setOverpressureMax(val)
    UNInf.overrideOverPressure = val
end

local passed = false
local checks = 0
---Checks if the passed table of conditionals passes the white list
---@param wlist table The whitelist you wish to test. Should be a table of strings
---@return boolean result The test result
function UNInf.checkWhitelist(wlist)
    passed = false
    checks = 0
    for _, v in pairs(wlist) do
        if(v:find("-") == 1) then
            v = string.sub(v,2)
            if(UNInf.conditional[v] == true) then
                passed = false
                break
            else
                checks = checks + 1
            end
        end
        if(UNInf.conditional[v] == true) then
            passed = true
        end
    end
    if(checks == #wlist) then
        passed = true
    end
    return passed
end
---Checks to see if you are within a certain range of inflation
---@param minInf number The minimum inflation you want to be utilized in this check
---@param maxInf number The maximum inflation you want to be utilized in this check
---@return boolean Whether you passed or failed the check
function UNInf.checkPressureRange(minInf, maxInf)
    return UNInf.pressure / UNInf.maxPressure >= minInf and UNInf.pressure / UNInf.maxPressure <= maxInf
end

local warningDict = {
    [1] = {
        ["Name"] = "Notice: ",
        ["headColor"] = "#FFFFFF",
        ["msgColor"] = "#BDB8B8"
    },
    [2] = {
        ["Name"] = "Warning: ",
        ["headColor"] = "#D9FF00",
        ["msgColor"] = "#EAFF76"
    },
    [3] = {
        ["Name"] = "Error: ",
        ["headColor"] = "#a30000",
        ["msgColor"] = "#FF5555"
    },
    [4] = {
        ["Name"] = "CRITICAL ERROR: ",
        ["headColor"] = "#7E0000",
        ["msgColor"] = "#a30000"
    }
}

UNInf.sentMsg = {}
---Sends a message to the ingame chat, to inform players of when things are going wrong. Pass an ID to make it so the message only sends once per load
---@param msg string The message you wish to use
---@param type number The kind of message you want to send. 1 = Notice, 2 = Warning, 3 = Error, 4 = Critical Error
---@param id string? string The ID of the message. Pass this to ensure the message can only be sent once
function UNInf.annoyLog(msg,type,id)
    if(UNInf.reportLogs == false) then return end
    if(id == nil) then
        id = "inf"
    end
    if(warningDict[type] == nil) then
        type = 2
    end
    if(UNInf.sentMsg[id] ~= true) then
        newMess  = {
             "",
            {text = warningDict[type].Name, color = warningDict[type].headColor},
            {text = msg, color = warningDict[type].msgColor},
            {text = "\n" }
        }
        UNInf.sentMsg[id] = true
        printJson(toJson(newMess))
        newMess = nil
    end
    UNInf.sentMsg["inf"] = false
end
--- Handles table insertion automatically. What table(s) the module is inserted into is based off of the name of the event you have added
---@param module table -- The actual module to insert into UNInf
function UNInf.insertToGroups(module)
    --log(module.tick)
    if(module.tick ~= nil) then
        table.insert(UNInf.ticks,module)
    end
    if(module.render ~= nil) then
        table.insert(UNInf.renders,module)
    end
    if(module.post_world_render ~= nil) then
        table.insert(UNInf.postWorldRenders,module)
    end
end


-- This is where the events are run. Ticks are run in events.tick, Renders are run in events.render


function events.tick()
    UNInf.pressure = UNInf.getPressure()
    if(UNInf.pressure + UNInf.overPressure ~= curPressure) then
        onPressureChange()
    end
    --log(UNInf.pressure)
    for _, v in pairs(UNInf.ticks) do
        v:tick()
    end
    UNInf.clock = UNInf.clock + 1
end

function events.render(delta,context,matrix)
    for _, v in pairs(UNInf.renders) do
        v:render(delta,context,matrix)
    end
end

function events.post_world_render(delta)
    for _, v in pairs(UNInf.postWorldRenders) do
        v:post_world_render(delta)
    end
end

local targetedMode = 1
local namesList = {}
for i, _ in pairs(UNInf.infModes) do
    table.insert(namesList,i)
    if(i == UNInf.curSystem) then
        targetedMode = #namesList
    end
end

function updateTarget(scroll)
    targetedMode = (((targetedMode + scroll) - 1) % #namesList) + 1
    updateModeSwap()
end

function actionModeSet()
    UNInf.setMode(namesList[targetedMode])
    UNInf.annoyLog("Mode has been set to: "..UNInf.curSystem,1)
end
pings.actionModeSet = actionModeSet

local modeSwapperAction = action_wheel:newAction()
    :title("Change Mode to: "..namesList[targetedMode])
    :item("minecraft:apple")
    :onScroll(updateTarget)
    :onLeftClick(pings.actionModeSet)

function updateModeSwap()
    modeSwapperAction:title("Change Mode to: "..namesList[targetedMode])
end

function UNInf.modeToggleAction()
    return modeSwapperAction
end

if(UNInf.autoStart ~= false) then
    UNInf.autoStart.runStart()
end
return UNInf