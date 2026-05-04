local UNInf

local bwbcomp = {}
local viewer = client:getViewer()
bwbcomp.priority = 0
bwbcomp.maxInflation = 20
bwbcomp.name = "BwBComp"
bwbcomp.allowed = client:isModLoaded("better_with_blimps")

bwbcomp.myConds = {
"inflating",
"ballooned",
"juiced",
"grog",
"sporebloat",
"gum",
"hotair",
"gumsnare",
"fizzing"
}

bwbcomp.infSlot = 1
bwbcomp.infVal = nil

function bwbcomp.rig(core)
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

local specialEfx = ""

--Check conditions are run if the mode has anything in the myConds variable. It is run once per tick, and utilized to update any conditions. It is seperate from the 
bwbcomp.prvClock = -1
function bwbcomp.checkConditions()
    if(UNInf.clock % 5 == 0 and UNInf.clock ~= bwbcomp.prvClock) then
        bwbcomp.prvClock = UNInf.clock
        specialEfx = ""
        for _, effect in pairs(viewer:getStatusEffects()) do
            if(effect["name"]:find("better_with_blimps") == nil) then
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.ballooned") then
                --Ballooned effect
                specialEfx = specialEfx.."b"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.juiced") then
                --Juiced effect
                specialEfx = specialEfx.."j"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.bubbling") then
                --Bubbling effect
                specialEfx = specialEfx.."g"
            goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.spore_filled") then
                --Spore effect
                specialEfx = specialEfx.."s"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.bubble_gum_filled") then
                --Gum effect
                specialEfx = specialEfx.."u"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.hot_air") then
                --Hot Air effect
                specialEfx = specialEfx.."h"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.bubble_gum_snared") then
                --Hot Air effect
                specialEfx = specialEfx.."y"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.fizzing") then
                --Hot Air effect
                specialEfx = specialEfx.."f"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.inflating") then
                --Inflating effect
                specialEfx = specialEfx.."i"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.bloat_rot") then
                --Bloat Rot effect
                specialEfx = specialEfx.."r"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.waterlogged") then
                --Waterlogged effect
                specialEfx = specialEfx.."w"
                goto skip
            end
            if(effect["name"] == "effect.better_with_blimps.smoke_filled") then
                --Smoke Filled effect
                specialEfx = specialEfx.."m"
                goto skip
            end
            ::skip::
        end
        pings.bwbcompeffects(specialEfx)
    end
end

function pings.bwbcompeffects(a)
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



function bwbcomp.setPressure(val)
    log("Pressure cannot be set in this mode")
end

function bwbcomp.adjustPressure(val)
    log("Pressure cannot be adjusted in this mode")
end

--UNInf.infSystems[bwbcomp.name] = bwbcomp
--UNInf.systemSelectUpd(bwbcomp)

return bwbcomp