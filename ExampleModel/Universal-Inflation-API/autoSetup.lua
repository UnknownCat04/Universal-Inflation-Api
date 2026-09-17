local auto = {}
---@class UNInf

auto.moduleInit = {}

function auto.runStart()
    for _, startUp in pairs(auto.moduleInit) do
        startUp()
    end
end

return auto