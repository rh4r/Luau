--[[
    Description: Remote scanner to find potential destruction remotes, which can be used to pseudo admin abuse
    Inspiration: https://v3rm.net/threads/release-quirkycmd-remote-abuse-fe-admin-script.10555/#post-72511
    Credits:
            rh4r - Script Developer

    Tested and working on:
        https://www.roblox.com/games/11302512567/UPDATE-Realistic-Plane-Crash-Simulator
    

    Recommended usage:
        instanceScan usually works better, metamethodScan is just an alternative.
]]--

local wordList = {"delete", "destroy", "remove", "despawn", "clear", "bullet"}

local cloneref = cloneref or function(...) return ... end
local Services = {}; setmetatable(Services, {__index = function(_, key) return cloneref(game:GetService(key)) end})
local Players = Services["Players"]
local LocalPlayer = Players.LocalPlayer

local match = string.match
local insert = table.insert
local foreach = table.foreach

metamethodScan = function()
    local o
    
   o = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local namecallmethod = getnamecallmethod()

        if namecallmethod == "Destroy" and self:IsA("RemoteEvent") then
            local Args = {...}
            local CallingScript = getcallingscript()

            if CallingScript then
                print("Destroy has been called from: ", CallingScript)
                print("Passed parameters: ")
                foreach(Args, warn)
            end
        end
        return o(self, ...)
    end)) 
end

instanceScan = function()
    getgenv().DeathRemote = nil

    local Remotes = {}

    for _, potChild in next, game:GetDescendants() do
        local NewName = string.lower(potChild.Name)
        local HasWordls

        foreach(wordList, function(s, k)
            if match(NewName, k) then
                HasWordls = true
            end
        end)

        if HasWordls and potChild:IsA("RemoteEvent") then
            print(potChild.ClassName, potChild:GetFullName())
            insert(Remotes, potChild)
        end
    end

    if #Remotes > 0 then
        for _, desRemote in next, Remotes do
            local CurrentPlrHealth = LocalPlayer.Character.Humanoid.Health

            desRemote:FireServer(LocalPlayer.Character.Head)
            task.wait(1)

            if LocalPlayer.Character.Humanoid.Health ~= CurrentPlrHealth then
                getgenv().DestroyRemote = desRemote
                break
            end
        end

    end
    if getgenv().DestroyRemote then
        print(getgenv().DestroyRemote:GetFullName(), " Is the location of the death remote! Stored as {getgenv().DestroyRemote}")
    end
end

if getgenv().DestroyRemote ~= nil then
    local DeathRemote = getgenv().DestroyRemote
    local PassedArgs = Players.isma_pro6678.Character.Head

    if PassedArgs ~= nil then
       DeathRemote:FireServer(PassedArgs) -- Here goes the instance you wish to destroy, can be used to remove Players from the Players service (kicks them from the game) 
       print("KILLED: ", PassedArgs:GetFullName())
    end
else
    instanceScan()
end
