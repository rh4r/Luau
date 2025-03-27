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
    ["EnableNameFarm"] = false,
    ["EnableAura"] = false,
    ["EnablePetAura"] = false,
    ["EnableLevelFarm"] = true,
    ["ProxPrompts"] = {
        ["AutoArise"] = true,
        ["AutoDestroy"] = false
    },
    ["EnemyChoices"] = {
        ["Name"] = "Largalgan",
    }
}

ReturnLocalChar = PlayerFunctions.ReturnLocalChar
ReturnLocalRoot = PlayerFunctions.ReturnLocalRoot
ReturnLocalHumanoid = PlayerFunctions.ReturnLocalHumanoid

local Configs = cyn.Configs 
local ProxPrompts = Configs["ProxPrompts"]
local EnemyChoices = Configs["EnemyChoices"]

local find = table.find
local split = string.split
local insert = table.insert

local LocalPlayer = PlayerFunctions:InitializeLocalPlayer()

local TweenService = cloneref(game:GetService("TweenService")) or game:GetService("TweenService") -- the "or game:GetService("TweenService") is for VSC auto completetion.
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local dataRemoteEvent = cloneref(ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"))
local PetsFolder = LocalPlayer.leaderstats.Inventory.Pets

local GameItems = {
    ["Enemies"] = workspace.__Main.__Enemies.Client,
}

local WorldEnemies = {}
-- workspace.__Main.__Enemies.Client["41aa95854381483eba3bf65b4a3874f5"].HealthBar.Main.Title

task.spawn(function() for a,b in GameItems["Enemies"]:GetDescendants() do if b:IsA("TextLabel") and b.Parent.Parent.Name == "HealthBar" then insert(WorldEnemies, b.Text) end end end)
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

ReturnQueueFunc = function()
    local env = require(ReplicatedStorage.BridgeNet2.src.Client.ClientProcess)
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

ReturnHitDamage = function(PetName: string)
    for a,b in getgc(true) do
        if type(b) == "table" and rawget(b, "HitDMG") then
            if rawget(b, "Name") == PetName then
                local HitDMG = rawget(b, "HitDMG")

                return HitDMG
            end
        end
    end
end

ReturnRealNumber = function(Health: string) 
	local ValidEnds = {
		["K"] = 10,
		["M"] = 10000,
		["B"] = 10000000
	}

    local match = string.match
    local gsub = string.gsub
    local FixedStr
    local NewString

    if match(Health, ".") then
        FixedStr = gsub(Health, "%.", "")
    end
    Health = FixedStr

	local Converge = split(Health, "K")[2]

	if find(ValidEnds, Converge) then
		local Value = ValidEnds[Converge]

		NewString = gsub(Health, Converge, "")

		return tonumber(NewString) * Value
	--[[
    if match(Health, "K") then
        NewString = gsub(Health, "K", "")

        return tonumber(NewString) * 10
    elseif match(Health, "M") then
        NewString = gsub(Health, "M", "")

        return tonumber(NewString) * 10000
	]]--

    else
        return tonumber(Health)
    end
end

AutoArise = function(PromptParent: Part)
    if PromptParent and PromptParent:FindFirstChild("ArisePrompt") then
        local ProxPrompt = PromptParent:FindFirstChild("ArisePrompt")
        fireproximityprompt(ProxPrompt)
    end
    task.wait(1)
end

AutoDestroy = function(PromptParent: Part)
    if PromptParent and PromptParent:FindFirstChild("DestroyPrompt") then
        local ProxPrompt = PromptParent:FindFirstChild("DestroyPrompt")
        fireproximityprompt(ProxPrompt)
    end
    task.wait(1)
end

AutoKillAura = function()
    while Configs["EnableAura"] and task.wait() do
        local QueueFunc = ReturnQueueFunc()
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
        local LocalRoot = ReturnLocalRoot()
        local QueueFunc = ReturnQueueFunc()
        
        if ClosestMob and (ClosestMob.HumanoidRootPart.Position - LocalRoot.Position).Magnitude <= 50 then
            local MobRoot = ClosestMob.HumanoidRootPart

            local StringSplit = string.split(ClosestMob.HealthBar.Main.Bar.Amount.Text, " ")[1]
            local MobHealth = tonumber(StringSplit)

            task.wait(0.01)
            QueueFunc("\7", {["PetPos"] = {},["AttackType"] = "All",["Event"] = "Attack",["Enemy"] = tostring(ClosestMob)})
            task.wait(0.01)
            print'ran'

            while MobHealth ~= 0 and (ClosestMob.HumanoidRootPart.Position - LocalRoot.Position).Magnitude <= 50 do
                MobHealth = tonumber(string.split(ClosestMob.HealthBar.Main.Bar.Amount.Text, " ")[1])

                task.wait()
                print'awaiting'
            end

            print'broken'

            if ProxPrompts["AutoArise"] then
                AutoArise(MobRoot)
            elseif ProxPrompts["AutoDestroy"] then
                AutoDestroy(MobRoot)
            end
            task.wait(1)
        end
    end
end

MergedAuras = function(Enemey: Model, LocalRoot: Part, QueueFunc: any)
    pcall(function() 
        local StringSplit = string.split(Enemey.HealthBar.Main.Bar.Amount.Text, " ")[1]
        local MobHealth = tonumber(StringSplit)
        local ConstructedArgs = {
            [1] = {
                ["Event"] = "PunchAttack",
                ["Enemy"] = tostring(Enemey)
            },
            [2] = "\4"
        }
    
        local PetArgs = {
            [1] = {
                [1] = {
                    ["PetPos"] = {},
                    ["AttackType"] = "All",
                    ["Event"] = "Attack",
                    ["Enemy"] = tostring(Enemey)
                },
                [2] = "\t"
            }
        }
            
        dataRemoteEvent:FireServer(unpack(PetArgs))
    
        task.wait()
    
        while Configs["EnableMainFarm"] and MobHealth ~= 0 and (Enemey:WaitForChild("HumanoidRootPart").Position - LocalRoot.Position).Magnitude <= 50 do
            MobHealth = tonumber(string.split(Enemey:WaitForChild("HealthBar").Main.Bar.Amount.Text, " ")[1])
    
            QueueFunc(ConstructedArgs[2], ConstructedArgs[1]) 
            task.wait(0.5)
        end
    end)
end

NamedAutoFarm = function()
    local QueueFunc = ReturnQueueFunc()

    while Configs["EnableNameFarm"] and task.wait() do
        for Index, Enemy in pairs(GameItems["Enemies"]:GetChildren()) do
            if Enemy then
                local EnemyName = ReturnNPCName(Enemy)
                local LocalRoot = ReturnLocalRoot()
                local MobRoot = Enemy:FindFirstChild("HumanoidRootPart") or Enemy:FindFirstChild("Hitbox")
                if not MobRoot then
                    break
                end
                
    
                if EnemyName == EnemyChoices["Name"] then
                    local CreatedTween = TweenService:Create(LocalRoot, TweenInfo.new(1), {CFrame = CFrame.new(MobRoot.Position - Vector3.new(-2, 0, 0))})
                    CreatedTween:Play()
                    CreatedTween.Completed:Wait(0.5)

                    task.wait(1)
                    MergedAuras(Enemy, LocalRoot, QueueFunc)                

                    local StringSplit = string.split(Enemy:WaitForChild("HealthBar").Main.Bar.Amount.Text, " ")[1]
                    local MobHealth = tonumber(StringSplit)
                    
                    while MobHealth ~= 0 and Configs["EnableNameFarm"] do
                        MobHealth = tonumber(string.split(Enemy:WaitForChild("HealthBar").Main.Bar.Amount.Text, " ")[1])
                        
                        task.wait(0.1)
                    end

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

HighestLevelFarm = function()
    while Configs["EnableLevelFarm"] and task.wait() do
        local HighestLevel = 0
        local HighestLevelMob = nil

        for Index, Child in pairs(GameItems["Enemies"]:GetDescendants()) do
            if Child:IsA("TextLabel") and Child.Name == "LevelText" and tonumber(Child.Text) > HighestLevel then
                local SorryForThisShitThisIsNotCleanCodeAtAllBruhISwearImBetterThenThisManTsIsJustFuckedUp = Child:FindFirstAncestorOfClass("Model")
                local HealthAmount = string.split(SorryForThisShitThisIsNotCleanCodeAtAllBruhISwearImBetterThenThisManTsIsJustFuckedUp:WaitForChild("HealthBar").Main.Bar.Amount.Text, " ", "")[1]
                local MobHealth = ReturnRealNumber(HealthAmount)

                if MobHealth > 0 then
                    HighestLevelMob = Child:FindFirstAncestorOfClass("Model")
                    HighestLevel = tonumber(Child.Text)
                end
            end
        end
        print'got pot mob'
        if HighestLevelMob then
            local LocalRoot = ReturnLocalRoot()
            local QueueFunc = ReturnQueueFunc()

            local MobRoot = HighestLevelMob:WaitForChild("HumanoidRootPart")
            local HealthAmount = string.split(HighestLevelMob:WaitForChild("HealthBar").Main.Bar.Amount.Text, " ", "")[1]
            local MobHealth = ReturnRealNumber(HealthAmount)

            if not MobRoot then
                HighestLevelMob = nil
            end
            if MobHealth <= 0 then
                print'exiting loop'
                HighestLevelMob = nil
            end

            local CreatedTween = TweenService:Create(LocalRoot, TweenInfo.new(1), {CFrame = CFrame.new(MobRoot.Position - Vector3.new(-2, 0, 0))})
            CreatedTween:Play()
            CreatedTween.Completed:Wait(0.5)

            MergedAuras(HighestLevelMob, LocalRoot, QueueFunc)
            task.wait()
            
            while MobHealth ~= 0 and Configs["EnableLevelFarm"] do
                local UpdatedHpAmount = string.split(HighestLevelMob:WaitForChild("HealthBar").Main.Bar.Amount.Text, " ", "")[1]
                MobHealth = ReturnRealNumber(UpdatedHpAmount)
    
                task.wait()
            end

            task.wait(0.1)

            if ProxPrompts["AutoArise"] then
                AutoArise(MobRoot)
            elseif ProxPrompts["AutoDestroy"] then
                AutoDestroy(MobRoot)
            end
            HighestLevelMob = nil
        end
    end
end

EquipBestPet = function()       
    local Children = PetsFolder:GetChildren()
    local BestPets = {}
    local PotentialPets = {}
    local BestPetsToSend = {
        [1] = {
            [1] = {
                ["Event"] = "EquipBest",
                ["Pets"] = nil
            },
            [2] = "\t"
        }
    }

    for Index, Pet in pairs(Children) do
        insert(PotentialPets, Pet.Name)
    end
    for i = #PotentialPets - 3, #PotentialPets do
        insert(BestPets, PotentialPets[i])
    end

    rawset(BestPetsToSend[1][1], "Pets", BestPets)
    dataRemoteEvent:FireServer(unpack(BestPetsToSend))
end

HighestLevelFarm()
