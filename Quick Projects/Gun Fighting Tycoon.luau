--[[
    Game Link: https://www.roblox.com/games/8571871474/Gun-Fighting-Tycoon
    Description: Kill All
]] -- 

local Players = game:GetService("Players")
local InflictRemote = game:GetService("ReplicatedStorage"):WaitForChild("InflictTarget")

task.spawn(function()
    local Pistol = Players.LocalPlayer:WaitForChild("Pistol")
    
    if Pistol then 
        Pistol.Parnet = Players.LocalPlayer.Character
    else
        return
    end
end)

print("running.")
while task.wait() do
    pcall(task.spawn(function()
        local LocalPlayer = Players.LocalPlayer
        
        for a,b in pairs(Players:GetPlayers()) do 
            if b ~= LocalPlayer and b.Character then 
                local Arguments = {
                    [1] = game:GetService("Players").LocalPlayer.Character:WaitForChild("Pistol"),
                    [2] = game:GetService("Players").LocalPlayer,
                    [3] = b.Character.Humanoid,
                    [4] = b.Character.HumanoidRootPart,
                    [5] = 15,
                    [6] = {
                        [1] = 0,
                        [2] = 0,
                        [3] = false
                    }
                }    
                
                if Arguments then 
                    InflictRemote:FireServer(unpack(Arguments))    
                end
            end
        end
    end))
end

--[[
    Gun Modds ( Equip ur weapon first)
    local Settings = require(workspace.rawestmetatable.Pistol.Setting)
    
    for a,b in Settings do print(a,b) end

    rawset(Settings, "Auto", true)
    rawset(Settings, "FireRate", 0.0001)
    rawset(Settings, "AmmoPerMag", math.huge)
    rawset(Settings, "BaseDamage", 1000)
    rawset(Settings, "Ammo", math.huge)
    rawset(Settings, "SpreadX", 0)
    rawset(Settings, "ExplosiveEnabled", true)
    rawset(Settings, "CustomExplosion", true)
    rawset(Settings, "DualEnabled", true)
    
    print("Done!")
    print(Settings["Auto"])
]]--
