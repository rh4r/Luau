loadstring(game:HttpGet('https://raw.githubusercontent.com/rh4r/Luau/refs/heads/main/Enviroment%20Files/cyn.luau'))()

local cyn = getgenv()
local PlayerFunctions = cyn.PlayerFunctions

cyn.Configs = {
    ["EnableAura"] = true,
    ["ProxPrompts"] = {
        ["AutoArise"] = false,
        ["AutoDestroy"] = true
    }
}

ReturnLocalChar = PlayerFunctions.ReturnLocalChar
ReturnLocalRoot = PlayerFunctions.ReturnLocalRoot
ReturnLocalHumanoid = PlayerFunctions.ReturnLocalHumanoid

local Configs = cyn.Configs 
local ProxPrompts = Configs["ProxPrompts"]
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

ReturnQueueFunc = function(env: ModuleScript)
    for string_name, function_found in env do 
        if string_name == "addToQueue" then
            return function_found
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
        print'fired'
    end
end

AutoKillAura = function()
    local ModuleEnviroment = require(ReplicatedStorage.BridgeNet2.src.Client.ClientProcess)
    local QueueFunc = ReturnQueueFunc(ModuleEnviroment)

    while Configs["EnableAura"] and task.wait() do
        local ClosestMob = nil
        local ClosestRange = math.huge  -- Change to a number, not Vector3
        local PlayerRoot = ReturnLocalRoot()
    
        for _, Mob in pairs(workspace.__Main.__Enemies.Client:GetChildren()) do
            local MobRoot = Mob.HumanoidRootPart or Mob.PrimaryPart

            local MVPDistance = (MobRoot.Position - PlayerRoot.Position).Magnitude
            
            if MVPDistance <= ClosestRange then
                ClosestMob = Mob
                ClosestRange = MVPDistance 
            end
        end
    
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

AutoKillAura()
