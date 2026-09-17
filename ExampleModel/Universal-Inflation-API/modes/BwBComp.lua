---@class UNInf
local UNInf

local bwbcomp = {}
local viewer = client:getViewer()
bwbcomp.priority = 0
bwbcomp.maxInflation = 20
bwbcomp.pressure = 0
bwbcomp.name = "BwBComp"
bwbcomp.allowed = client:isModLoaded("better_with_blimps",1)
bwbcomp.manualAllowed = false
bwbcomp.overPressure = 0
bwbcomp.defOverPressureMax = 20

bwbcomp.myConds = {
"inflating",
"ballooned",
"juiced",
"grog",
"sporebloat",
"gum",
"hotair",
"gumsnare",
"fizzing",
"bloatrot",
"waterlogged",
"smoke"
}

bwbcomp.infSlot = 1
bwbcomp.infVal = nil

function bwbcomp.patch(core)
    UNInf = core
    UNInf.conditional["inflating"] = false
    UNInf.conditional["ballooned"] = false
    UNInf.conditional["juiced"] = false
    UNInf.conditional["grog"] = false
    UNInf.conditional["sporebloat"] = false
    UNInf.conditional["gum"] = false
    UNInf.conditional["hotair"] = false
    UNInf.conditional["gumsnare"] = false
    UNInf.conditional["fizzing"] = false
    UNInf.conditional["bloatrot"] = false
    UNInf.conditional["waterlogged"] = false
    UNInf.conditional["smoke"] = false
end

-- Establishes the local variables, used to identify what effects should be tracked and how, as well as ensuring specialEfx is present
local specialEfx = ""
local bwbefx = {
    ["effect.better_with_blimps.ballooned"] = "b",
    ["effect.better_with_blimps.juiced"] = "j",
    ["effect.better_with_blimps.bubbling"] = "g",
    ["effect.better_with_blimps.spore_filled"] = "s",
    ["effect.better_with_blimps.bubble_gum_filled"] = "u",
    ["effect.better_with_blimps.hot_air"] = "h",
    ["effect.better_with_blimps.bubble_gum_snared"] = "y",
    ["effect.better_with_blimps.fizzing"] = "f",
    ["effect.better_with_blimps.inflating"] = "i",
    ["effect.better_with_blimps.bloat_rot"] = "r",
    ["effect.better_with_blimps.waterlogged"] = "w",
    ["effect.better_with_blimps.smoke_filled"] = "m"
}


--Check conditions are run if the mode has anything in the myConds variable. It is run once per tick, and utilized to update any conditions. It is seperate from checkPressure()
bwbcomp.prvClock = -1
bwbcomp.forcePing = 0
bwbcomp.lastSent = ""
function bwbcomp.checkConditions()
    --First, check that you're on a 5th tick, and that it is the first time this ahs been called this tick
    if(UNInf.clock % 5 == 0 and UNInf.clock ~= bwbcomp.prvClock and host:isHost()) then
        --Set the new values, prvClock is used to prevent repeat calls on the same tick, and specialEfx is used to actually ping the new value
        bwbcomp.prvClock = UNInf.clock
        specialEfx = ""
        for _, effect in pairs(viewer:getStatusEffects()) do
            --Then, for every status effect the player has, 
            if(bwbefx[effect["name"]] ~= nil) then
                specialEfx = specialEfx..bwbefx[effect["name"]]
            end
        end
        --Checks to see if the effect list has changed OR if 100 ticks has passed since the last ping, and if either has update the conditional list and set the forced ping to the next 100 ticks
        if(specialEfx ~= bwbcomp.lastSent or UNInf.clock >= bwbcomp.forcePing) then
            pings.bwbcompeffects(specialEfx)
            bwbcomp.lastSent = specialEfx
            bwbcomp.forcePing = UNInf.clock + 100
        end
    end
end

function pings.bwbcompeffects(a)
    --This reads through the provided string, looking to see if specific characters appear and updating the conditionals based off of which are present
    UNInf.conditional["inflating"] = a:find("i") ~= nil
    UNInf.conditional["ballooned"] = a:find("b") ~= nil
    UNInf.conditional["juiced"] = a:find("j") ~= nil
    UNInf.conditional["grog"] = a:find("g") ~= nil
    UNInf.conditional["sporebloat"] = a:find("s") ~= nil
    UNInf.conditional["gum"] = a:find("u") ~= nil
    UNInf.conditional["hotair"] = a:find("h") ~= nil
    UNInf.conditional["gumsnare"] = a:find("y") ~= nil
    UNInf.conditional["fizzing"] = a:find("f") ~= nil
    UNInf.conditional["bloatrot"] = a:find("r") ~= nil
    UNInf.conditional["waterlogged"] = a:find("w") ~= nil
    UNInf.conditional["smoke"] = a:find("m") ~= nil
end

function bwbcomp.checkPressure()

    --We first clear the inflation Value, that way we can also store IF it was set alongside whatever it was set to
    bwbcomp.infVal = nil

    if(player:isLoaded() and player:isAlive()) then
        --Afterwards, we make an anti break check to ensure that the bookmarked location is not invalid, and if it is we reset the bookmark to prevent an infinite break and skip this check entirely
        if(player:getNbt()["Attributes"][bwbcomp.infSlot] == nil) then
            bwbcomp.infSlot = 1
            return 0
        end
        --Then we check the bookmarked location for the value. If it is right we use that
        if(player:getNbt()["Attributes"][bwbcomp.infSlot]["Name"] == "better_with_blimps:inflated_attribute") then
            bwbcomp.infVal = player:getNbt()["Attributes"][bwbcomp.infSlot]["Base"]
        else

            --if it fails, we then search to find it, and break once we do to prevent unneeded searches
            for i, v in pairs(player:getNbt()["Attributes"]) do
                if(player:getNbt()["Attributes"][i]["Name"] == "better_with_blimps:inflated_attribute") then
                    --We also set a new bookmark here, via a second value called InfSlot. This gives us an easy way to skip searches in the future
                    
                    bwbcomp.infSlot = i
                    bwbcomp.infVal = player:getNbt()["Attributes"][i]["Base"]
                    break
                end
            end
        end
    end

    --If the number is invalid, or was never set because the player isn't loaded / alive, we default it to 0
    if(type(bwbcomp.infVal) ~= "number") then
        bwbcomp.infVal = 0
    end

    --We can also run any other functions here that influence things, but it is recommended to utilize the UNInf's internal clock to minimize the chance of repeat calls in the case the user is using getPressure()
    bwbcomp.checkConditions()

    --Finally, we return the stored inflation value
    return bwbcomp.infVal
end

function events.on_play_sound(id, pos)
  if(not player:isLoaded()) then return end
  if(id == "better_with_blimps:overinflate") then
    if((pos - player:getPos()):length() < 1) then
      bwbcomp.overPressure = math.clamp(bwbcomp.overPressure + 1,0, bwbcomp.defOverPressureMax)
    end
  end
end

function bwbcomp.setPressure(val)
    UNInf.annoyLog("Pressure cannot be set in bwbcomp mode",1,"bwbset")
    return false
end

function bwbcomp.adjustPressure(val)
    UNInf.annoyLog("Pressure cannot be adjusted in bwbcomp mode",1,"bwbadj")
    return false
end

function bwbcomp.checkOverPressure()
    if(bwbcomp.infVal ~= bwbcomp.maxInflation) then
        bwbcomp.overPressure = 0
    end
    return bwbcomp.overPressure
end

return bwbcomp