--[[
    Game Link: https://www.roblox.com/games/109588872144583/Tribe-Survival
    Description: Shitty semi-working "No Cooldown" and auto attack for this bum ahh game
]]--

clr_output = getgenv().clr_output or function() for i = 1,100 do print'' end end
clr_output()

local AttackCast

for a,b in getgc(false) do 
    if type(b) == "function" then
        local upvalues = debug.getupvalues(b)

        if upvalues and #upvalues > 0 then
            if #upvalues >= 8 then
                local info = debug.getinfo

                if info then
                    for c,d in info(b) do 
                        if type(d) == "string" and c == "short_src" and string.match(d, "Axe") and string.match(d, "ToolClient") then
                            AttackCast = b
                        end
                    end
                end
            end
        end
    end
end

if AttackCast then
    local AnotherUpvalues = debug.getupvalues(AttackCast)

    for name, value in AnotherUpvalues do 
        if type(value) == "number" then
            if value == 0.5 then
                debug.setupvalue(AttackCast, name, 0.01)
            elseif value == 6 then
                debug.setupvalue(AttackCast, name, 20)
            end
        end
    end

    --[[
    warn("---\n")

    table.foreach(debug.getupvalues(AttackCast), function(n,v)
        if type(v) == "number" then
            warn(n,v)
        else
            print(n,v)
        end
    end)
    ]]--

    while task.wait() do 
        AttackCast()
    end
end
