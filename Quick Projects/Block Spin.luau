--[[
  Game Link: https://www.roblox.com/games/104715542330896/BlockSpin
  Description / Feautres: 
    Inf Stamia
    Lower Punch CD
    Auto Punch Aura (Kinda?)
    WalkSpeed setter
]]--

local cyn = getgenv()
cyn.IsEnabled = true

-- variables that'll be key for the scripts functionality
local NoStam = require(game:GetService("ReplicatedStorage").Modules.Game.Sprint)
local env = require(game:GetService("ReplicatedStorage").Modules.Game.ItemTypes.Melee)
local oldfunc
local tosend = {
    ["instance"] = game:GetService("Players").LocalPlayer.Character.Fists
}

-- Set the Fist speed to "6" to attack as fast as possible. (higher number = faster but i don't recommend changing)
game:GetService("Players").LocalPlayer.Character.Fists:SetAttribute("Speed", 6)
-- Set the angle to 365 to have a full range of hitbox
game:GetService("Players").LocalPlayer.Character.Fists:SetAttribute("ConeAngle", 365)
-- Set the range to 40 to hit anythign within 40 studs?
game:GetService("Players").LocalPlayer.Character.Fists:SetAttribute("Range", 100)

-- Inf Stamia Function
if NoStam.consume_stamina then
    hookfunction(NoStam.consume_stamina, function(arg1)
        return true
    end)    
end

-- Set Player WalkSpeed function, argument1 is the new WalkSpeed the second is a placeholder to delay the function to never change the WalkSpeed
NoStam.set_walk_speed(29, 9e9)

-- Remove WalkSpeed limiter (removes like 2 walkspeed per punch so if u don't change this u end up moving so slow like < 10 WalkSpeed)
debug.setconstant(env.melee_attack, 21, function(...) task.wait() end)

-- Store melee_attack function to auto-punch (Intakes one argument, a table with an "instance" it normally has other things within but all we need is the instance.)
for a,b in env do 
    if type(b) == "function" and a == "melee_attack" then
        oldfunc = b
    end
end


-- Call the auto-punch
while cyn.IsEnabled and task.wait() do
    pcall(function()
        oldfunc(tosend) 
    end)
end
