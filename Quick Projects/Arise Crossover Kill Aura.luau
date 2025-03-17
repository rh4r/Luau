--[[ 
    Game Link: https://www.roblox.com/games/87039211657390/Arise-Crossover
    Description: Arise GUI with a whole ton of features!
    Credits:
        rh4r - Everything
]]--


pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/rh4r/Luau/refs/heads/main/Enviroment%20Files/cyn.luau'))() end)

local cyn = getgenv()
local PlayerFunctions = cyn.PlayerFunctions

cyn.Configs = {
    ["EnableMainFarm"] = true,
    ["EnableAura"] = false,
    ["EnablePetAura"] = false,
    ["ProxPrompts"] = {
        ["AutoArise"] = true,
        ["AutoDestroy"] = false
    },
    ["EnemyChoices"] = {
        ["Name"] = "LongIn",
    }
}

ReturnLocalChar = PlayerFunctions.ReturnLocalChar
ReturnLocalRoot = PlayerFunctions.ReturnLocalRoot
ReturnLocalHumanoid = PlayerFunctions.ReturnLocalHumanoid

local Configs = cyn.Configs 
local ProxPrompts = Configs["ProxPrompts"]
local EnemyChoices = Configs["EnemyChoices"]

local insert = table.insert

local TweenService = cloneref(game:GetService("TweenService")) or game:GetService("TweenService") -- the "or game:GetService("TweenService") is for VSC auto completetion.
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local GameItems = {
    ["Enemies"] = workspace.__Main.__Enemies.Client,
}

local EnemyChoices = {}
-- workspace.__Main.__Enemies.Client["41aa95854381483eba3bf65b4a3874f5"].HealthBar.Main.Title

task.spawn(function() for a,b in GameItems["Enemies"]:GetDescendants() do if b:IsA("TextLabel") and b.Parent.Parent.Name == "HealthBar" then insert(EnemyChoices, b.Text) end end end)
task.spawn(function() for a,b in GameItems do rawset(GameItems, a, cloneref(b)) end end)

-- Copy enemey names to clipboard
--[[
task.spawn(function()
    local str = ""

    for c,d in EnemyChoices do
        str = str .. tostring(d) .. "\n"
        print('added:', d)
    end
    setclipboard(str)
end)
]]--

ReturnQueueFunc = function(env: ModuleScript)
    for string_name, function_found in env do 
        if string_name == "addToQueue" then
            return function_found
        end
    end
end

ReturnClosestInFolder = function(fold: Folder)
    local ClosestMob = nil
    local ClosestRange = math.huge  
    local PlayerRoot = ReturnLocalRoot()

    for _, Mob in pairs(fold:GetChildren()) do
        local MobRoot = Mob.HumanoidRootPart or Mob.PrimaryPart

        local MVPDistance = (MobRoot.Position - PlayerRoot.Position).Magnitude
        
        if MVPDistance <= ClosestRange then
            ClosestMob = Mob
            ClosestRange = MVPDistance 
        end
    end
    return ClosestMob
end

ReturnNPCName = function(NPC: Model)
    for Index, Child in pairs(NPC:GetDescendants()) do 
        if Child:IsA("TextLabel") and Child.Parent.Parent.Name == "HealthBar" then
            return Child.Text
        end
    end
end

AutoArise = function(PromptParent: Part)
    if PromptParent and PromptParent:FindFirstChild("ArisePrompt") then
        local ProxPrompt = PromptParent:FindFirstChild("ArisePrompt")
        fireproximityprompt(ProxPrompt)
        print'fired'
    end
end

AutoDestroy = function(PromptParent: Part)
    if PromptParent and PromptParent:FindFirstChild("DestroyPrompt") then
        local ProxPrompt = PromptParent:FindFirstChild("DestroyPrompt")
        fireproximityprompt(ProxPrompt)
    end
end

AutoKillAura = function()
    while Configs["EnableAura"] and task.wait() do
        local ModuleEnviroment = require(ReplicatedStorage.BridgeNet2.src.Client.ClientProcess)
        local QueueFunc = ReturnQueueFunc(ModuleEnviroment)
        local ClosestMob = ReturnClosestInFolder(GameItems["Enemies"])
    
        if ClosestMob then
            local MobRoot = ClosestMob.HumanoidRootPart
            local ConstructedArgs = {
                [1] = {
                    ["Event"] = "PunchAttack",
                    ["Enemy"] = tostring(ClosestMob)
                },
                [2] = "\4"
            }
        
            QueueFunc(ConstructedArgs[2], ConstructedArgs[1]) 

            if ProxPrompts["AutoArise"] then
                AutoArise(MobRoot)
            elseif ProxPrompts["AutoDestroy"] then
                AutoDestroy(MobRoot)
            end
        end
    end
end

AutoPetAura = function()
    while Configs["EnablePetAura"] and task.wait() do
        local ClosestMob = ReturnClosestInFolder(GameItems["Enemies"])
        local LocalRoot = PlayerFunctions:ReturnLocalRoot()
        
        local ModuleEnviroment = require(ReplicatedStorage.BridgeNet2.src.Client.ClientProcess)
        local QueueFunc = ReturnQueueFunc(ModuleEnviroment)
        
        if ClosestMob and (ClosestMob.HumanoidRootPart.Position - LocalRoot.Position).Magnitude <= 50 then
            local MobRoot = ClosestMob.HumanoidRootPart
            local StringSplit = string.split(ClosestMob.HealthBar.Main.Bar.Amount.Text, " ")[1]
            local MobHealth = tonumber(StringSplit)

            task.wait()
            QueueFunc("\7", {["PetPos"] = {},["AttackType"] = "All",["Event"] = "Attack",["Enemy"] = tostring(ClosestMob)})
            task.wait()

            while MobHealth ~= 0 and (ClosestMob.HumanoidRootPart.Position - LocalRoot.Position).Magnitude <= 50 do
                MobHealth = tonumber(string.split(ClosestMob.HealthBar.Main.Bar.Amount.Text, " ")[1])

                task.wait()
            end

            if ProxPrompts["AutoArise"] then
                AutoArise(MobRoot)
            elseif ProxPrompts["AutoDestroy"] then
                AutoDestroy(MobRoot)
            end
            task.wait(1)
        end
    end
end

MainAutoFarm = function()
    local ModuleEnviroment = require(ReplicatedStorage.BridgeNet2.src.Client.ClientProcess)
    local QueueFunc = ReturnQueueFunc(ModuleEnviroment)

    while Configs["EnableMainFarm"] and task.wait() do
        for Index, Enemy in pairs(GameItems["Enemies"]:GetChildren()) do
            if Enemy and Enemy.HumanoidRootPart then
                local EnemyName = ReturnNPCName(Enemy)
                local LocalRoot = PlayerFunctions:ReturnLocalRoot()
                local MobRoot = Enemy.HumanoidRootPart
                local StringSplit = string.split(Enemy.HealthBar.Main.Bar.Amount.Text, " ")[1]
                local MobHealth = tonumber(StringSplit)
    
                if EnemyName == EnemyChoices["Name"] then
                    local CreatedTween = TweenService:Create(LocalRoot, TweenInfo.new(1), {CFrame = CFrame.new(MobRoot.Position)})
        
                    CreatedTween:Play()
                    CreatedTween.Completed:Wait()

                    task.spawn(function()
                        local ConstructedArgs = {
                            [1] = {
                                ["Event"] = "PunchAttack",
                                ["Enemy"] = tostring(Enemy)
                            },
                            [2] = "\4"
                        }
                        while MobHealth ~= 0 and (Enemy.HumanoidRootPart.Position - LocalRoot.Position).Magnitude <= 50 do
                            QueueFunc(ConstructedArgs[2], ConstructedArgs[1]) 
                            task.wait()
                        end
                    end)
    
                    task.spawn(function()
                        local StringSplit = string.split(Enemy.HealthBar.Main.Bar.Amount.Text, " ")[1]
                        local MobHealth = tonumber(StringSplit)
            
                        task.wait()
                        QueueFunc("\7", {["PetPos"] = {},["AttackType"] = "All",["Event"] = "Attack",["Enemy"] = tostring(Enemy)})
                        task.wait()
            
                        while MobHealth ~= 0 and (Enemy.HumanoidRootPart.Position - LocalRoot.Position).Magnitude <= 50 do
                            MobHealth = tonumber(string.split(Enemy.HealthBar.Main.Bar.Amount.Text, " ")[1])
            
                            task.wait()
                        end
                    end)
        
                    if ProxPrompts["AutoArise"] then
                        AutoArise(MobRoot)
                    elseif ProxPrompts["AutoDestroy"] then
                        AutoDestroy(MobRoot)
                    end
                end
            end
        end 
    end
end

MainAutoFarm()
