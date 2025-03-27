--[[
  Game Link: https://www.roblox.com/games/104715542330896/BlockSpin
  Description / Feautres: 
    Inf Stamia
    Lower Punch CD
    Auto Punch Aura (Kinda?)
    WalkSpeed setter
]]--

local NoStam = require(game:GetService("ReplicatedStorage").Modules.Game.Sprint)

if NoStam.consume_stamina then
    hookfunction(NoStam.consume_stamina, function(arg1)
        return true
    end)    
end

NoStam.set_walk_speed(200, 9e9)

game:GetService("Players").LocalPlayer.Character.Fists:SetAttribute("Speed", 6)
print'set speed'


local env = require(game:GetService("ReplicatedStorage").Modules.Game.ItemTypes.Melee)
local oldfunc
local tosend = {
    ["instance"] = game:GetService("Players").LocalPlayer.Character.Fists
}
print(tosend.instance)

for a,b in env do 
    if type(b) == "function" and a == "melee_attack" then
        oldfunc = b
    end
end

while task.wait() do
    pcall(function()
        oldfunc(tosend) 
    end)
end
