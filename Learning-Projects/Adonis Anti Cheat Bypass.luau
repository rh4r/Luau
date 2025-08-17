--[[
    Adonis Anti-Cheat Bypass
        Game: https://www.roblox.com/games/13796645198/5X-FLASHPOINT
        Credits: Mac0014 (Teaching how to bypass), rh4r (Small Adjustments)
            Post: https://v3rm.net/threads/beginner-reverse-engineering-tutorial-0-adonis.14455/
]]--


local ginfo = debug.getinfo

ReturnAdonisDtcTable = function()
    for _, potDtc in next, getgc(true) do
        if type(potDtc) == "table" then
            if 
            rawget(potDtc, "indexInstance") and
            rawget(potDtc, "newindexInstance") and
            rawget(potDtc, "namecallInstance") then
                if potDtc["indexInstance"][1] == "kick" and type(potDtc["indexInstance"][2]) == "function" then
                    return potDtc
                end
            end
        end
    end
end

local dtcTable = ReturnAdonisDtcTable()

if dtcTable then
    task.spawn(function()
        for _, dtcChildTable in next, dtcTable do
            for _, dtcVectorFunction in next, dtcChildTable do
                if type(dtcVectorFunction) == "function" and islclosure(dtcVectorFunction) then
                    hookfunction(dtcVectorFunction, function()
                        return pcall(coroutine.close, coroutine.running())
                    end)

                    warn("HOOKED FUNCTION: ", dtcVectorFunction, " SOURCE: ", ginfo(dtcVectorFunction, "s").source)
                end
            end 
        end
    end)
end
