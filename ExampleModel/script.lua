-- Auto generated script file --

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

--hide vanilla armor model
vanilla_model.ARMOR:setVisible(false)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

--hide vanilla elytra model
vanilla_model.ELYTRA:setVisible(false)

local UNInf = require("Universal-Inflation-API.UNInf")




local partsList = {
    --Model parts go here
    models.model.root.Body.InfParts.Belly,
    models.model.root.Body.InfParts.Chest.Masc,
    models.model.root.LeftLeg.InfPartsLegL,
    models.model.root.RightLeg.InfPartsLegR
}
UNInf.modelpartInflation:new(
    partsList, -- [!] inflated parts. Must be filled by a table (It's handled up above)
    nil, -- [nil] Activation animation. Plays when the parts are toggled on
    nil, -- [0.01] Minimum inflation. The percentage of inflation that toggles these parts on 
    nil, -- [1] Maximum inflation. The percentage of inflation you can reach before these parts are toggled off
    nil  -- [{"any"}] Conditionals. The conditionals for this module
)

UNInf.thirdPersonCam:new(
    nil, -- [0] Minimum pull. How much the camera is pulled back by this module at the minimum inflation
    nil, -- [-3] Maximum pull. How much the camera is pulled back by this module at the maximum inflation
    nil, -- [0] Minimum lift. How much the camera is raised by this module at the minimum inflation
    nil, -- [2] Maximum lift. much the camera is raised by this module at the maximum inflation
    nil, -- [nil] Default offset. What the camera returns to when this module is disabled. Nil is the default minecraft perspective
    nil, -- [0] Minimum inflation. How inflated you must be for this module to be activated
    nil, -- [1] Maximum inflation. How inflated you can be before this module is ignored
    nil  -- [{"any"}] Condtionals. Toggles the module in response to condtionals
)

UNInf.firstPersonCam:new(
    models.model.root.cameraBone, -- [!] Camera bone. What is the actual model part that the first person camera will follow
    nil, -- [nil] Default offset. What the camera returns to when this module is disabled. Nil is the default minecraft perspective
    nil, -- [0] Minimum inflation. How inflated you must be for this module to be activated
    nil, -- [1] Maximum inflation. How inflated you can be before this module is ignored
    nil  -- [{"any"}] Condtionals. Toggles the module in response to condtionals
)

UNInf.ConditionalEffector:new(
    "any", -- [!] Conditional. What conditional actually triggers this module
    nil, -- [nil] Minimum Color. What color is initially applied when the effector is activated
    nil, -- [nil] Maximum color. What color is applied when the effector is at max inflation
    nil, -- [nil] New Texture. What texture is applied when the effector is activated
    nil, -- [nil] Original Texture. What texture is applied when the effector is deactivated
    nil, -- [nil] Texture Target. What model parts are the textures applied to
    nil, -- [nil] Animation. What animation is played when this module is activated
    nil, -- [0] Minimum inflation. What percentage of inflation is required for this module to activate
    nil  -- [1] Maximum inflation. What percentage of inflation before the module is deactivated
)








local scraps = {
models.scraps.Scrap1,
models.scraps.Scrap2,
models.scraps.Scrap3
}

local popping = UNInf.poppingScraps:new(
scraps, -- [!] The model parts for your scraps
nil, -- [32] How many scrap will generate, on average (Influenced by permission level, High caps at 128. Default caps at 32, Low caps at 16)
nil, -- [0] How opaque will you be when you pop. 
nil, -- [nil] What model will have their transparency modified 
nil, -- [20] How many ticks does it take to reform after popping
nil, -- ["entity.generic.explode"] What sounds will play when you pop.
nil, -- [true] Should death call popping?
nil, -- [0] What is the minimum pressure you must have before you will pop
nil, -- [1] What is the maximum pressure you can have to call this pop
nil  -- [{"any"}] Toggles the module in response to condtionals
)

local mainPage = action_wheel:newPage()
mainPage:setAction(1,UNInf.modeToggleAction())
action_wheel:setPage(mainPage)

UNInf.setOnPressureChange(function(delta,deltaP,total,totalP)
    --log(delta,deltaP,total,totalP)
end)