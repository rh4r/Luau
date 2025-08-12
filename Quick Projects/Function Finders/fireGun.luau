--[[
  game link: https://www.roblox.com/games/4639625707/War-Tycoon
  description: Find function responsible for the firing of weapons
]]--

local Services = {}
setmetatable(Services, {
    __index = function(original, service)
        return cloneref(game:GetService(service))
    end
})
local info = debug.info
local ginfo = debug.getinfo
local getupvalues = debug.getupvalues
local debugprefix = "rh3r: "

local Players = Services["Players"]
local LocalPlayer = Players.LocalPlayer
local CombatEngine = LocalPlayer.Character.ACS_Client
local CastingRayFunction
local FireGunFunction

if CombatEngine then
    local ComabtEnv = getsenv(CombatEngine)
    for irrelivant, CastRay in pairs(ComabtEnv) do
        if type(CastRay) == "function" and info(CastRay, "n") == "CastRay" then
            CastingRayFunction = CastRay
        end
    end 
end

if CastingRayFunction then
    for index, ParentFunction in pairs(getgc(false)) do
        if type(ParentFunction) == "function" then
            local NupAmount = ginfo(ParentFunction).nups

            if NupAmount == 35 then
                print(debugprefix.."Function name with 35 upvalues: "..info(ParentFunction, "n"))
                if info(ParentFunction, "n") == "fireGun" then  
                    FireGunFunction = ParentFunction
                    print(FireGunFunction[1])
                    warn(debugprefix.."fireGun Source Location "..ginfo(FireGunFunction).source)
                end
            end
        end
    end 
end
