local auto = {}
---@class UNInf

auto.hunt = {
    "animbloat",
    "deflateAnimation"
}

auto.here = {}

local UNInf = require("./UNInf")
for _, check in pairs(auto.hunt) do
    auto.here[check] = UNInf[check] ~= nil
end

--log(auto.here)

if(auto.here["animbloat"]) then
    for i, v in pairs(models:getChildren()) do
        auto.modelName = v:getName()
        auto.anims = animations[auto.modelName] or {}
        for _, y in pairs(auto.anims) do
            if(string.sub(y:getName(), 1, 5) == "bloat") then
                UNInf.animbloat:new(y)
            end
        end
    end
    auto.modelName = nil
    auto.anims = nil
end

if(auto.here["deflateAnimation"]) then
    auto.defAnims = {}
    for i, v in pairs(models:getChildren()) do
        auto.modelName = v:getName()
        auto.anims = animations[auto.modelName] or {}
        for _, y in pairs(auto.anims) do
            auto.cur = y:getName()
            if(string.sub(auto.cur, 1, 7) == "deflate") then
                --UNInf.animbloat:new(y)
                --log(y,string.find(auto.cur,"/"))
                if(string.find(auto.cur,"/") ~= nil) then
                    auto.is = string.sub(auto.cur,string.find(auto.cur,"/") + 1 ,string.len(auto.cur))
                    auto.conds = {}
                    --log(string.sub(auto.cur,string.find(auto.cur,"/") + 1 ,string.len(auto.cur)))
                    --logTable(string.gmatch(auto.cur,"%g+"))
                    for w in string.gmatch(auto.is,"%g+") do
                        table.insert(auto.conds,w)
                    end
                else
                    auto.conds = nil
                end
                auto.new = UNInf.deflateAnimation:new(y, nil, nil, nil, auto.conds)
                table.insert(auto.defAnims,auto.new)
            end
        end
    end
    auto.modelName = nil
    auto.new = nil
    auto.cur = nil
    auto.is = nil
    auto.anims = nil
end

return auto