--[[
    SkidNC:
    Version: 0
    Credits: sulfur
    Update:
        nil
]]--

local env = getgenv() or _G or getfenv(script)

env.Holding = {}

local Holding = env.Holding

Holding.hookfunction = function(func1, func2)
    if not newcclosure then game:GetService("Players"):ResetLocalPlayer("Not Supported.") else;
        if table.find(_G, func1) then 
            _G[func1] = newcclosure(func2)
        else
            func1 = newcclosure(func2)
        end
    end
end

Holding.hookmetamethod = function(object, metamethod, new_func)
    if not getrawmetatable and not newcclosure then game:GetService("Players"):ResetLocalPlayer("Not Supported.") else;
        xpcall(function() setmetatable(object, {[metamethod] = newcclosure(new_func)}) end, 
        function()
            local mt = getrawmetatable(object)
            
            if mt then
                setreadonly(mt, false)
                rawset(mt, metamethod, newcclosure(new_func)) 
                setreadonly(mt, true)
            end
        end)
    end
end

Holding.islclosure = function(func)
    if not islclosure then 
        local info = debug.getinfo

        if info(func, "what") == "Lua" or info(func, "what") == "main" then
            return true
        else
            return false
        end
    end
end

task.spawn(function()
    if not islclosure then
        env.islclosure = Holding.islclosure
    end
    if not hookfunction then
        env.hookfunction = Holding.hookfunction
    end
    if not hookmetamethod then
        env.hookmetamethod = Holding.hookmetamethod
    end
end)
