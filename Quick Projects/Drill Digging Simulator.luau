local AutoGetCash = getgenv().AutoGetCash or true
local AutoGotoWin = getgenv().AutoGotoWin or true
local AutoBuyDrill = getgenv().AutoBuyDrill or true
local AutoBuyPets = getgenv().AutoBuyPets or false

if game.PlaceId ~= 125723653259639 then game:GetService("TeleportService"):Teleport(125723653259639) end

local FoundTable
local NewTable = {}
local EggsTable = {}

local LocalPlayer = game:GetService("Players").LocalPlayer
local GiveCash = game:GetService("ReplicatedStorage"):WaitForChild("GiveCash") -- event
local BuySkin = game:GetService("ReplicatedStorage"):WaitForChild("DrillShop"):WaitForChild("BuySkin") -- function
local EquipSkin = game:GetService("ReplicatedStorage"):WaitForChild("DrillShop"):WaitForChild("EquipSkin") -- function
local Hatch = game:GetService("ReplicatedStorage"):WaitForChild("KPets"):WaitForChild("Events"):WaitForChild("Hatch") -- event
local EquipBest = game:GetService("ReplicatedStorage"):WaitForChild("KPets"):WaitForChild("Events"):WaitForChild("EquipBest") -- event

task.spawn(function()
    for _, value in pairs(getgc(true)) do 
        if type(value) == "table" and rawget(value, "Steel") then
            FoundTable = value
        elseif type(value) == "table" and rawget(value, "Egg") then
            for _, EggName in value do
                if type(EggName) == "string" and string.match(EggName, "Egg") and not table.find(EggsTable, EggName) then
                    table.insert(EggsTable, EggName) 
                end
            end
        end
    end
    
    for name, _ in FoundTable do 
        table.insert(NewTable, name) 
    end
    
    if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then 
        local ChosenTool 

        for _, toolname in NewTable do 
            if LocalPlayer.Backpack:FindFirstChild(toolname) then
                ChosenTool = LocalPlayer.Backpack[toolname]
            end
        end
        ChosenTool.Parent = LocalPlayer.Character
    end
end)

function CallAutoCash()
    task.spawn(function()
        LocalPlayer.Backpack.ChildAdded:Connect(function(childAdded)
            if LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                local REMOVING = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                REMOVING.Parent = LocalPlayer.Backpack
                task.wait(0.5)
                childAdded.Parent = LocalPlayer.Character
            end
        end)

        pcall(function()
            local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")

            GiveCash:FireServer(Tool)
        end)
    end)
end

function CallAutoBuy()
    task.spawn(function()
        for _, drill in NewTable do
            if not LocalPlayer.Backpack:FindFirstChild(drill) and not LocalPlayer.Character:FindFirstChild(drill) then 
                BuySkin:InvokeServer(drill)
                task.wait(0.1)
                EquipSkin:InvokeServer(drill, true)
            end
        end
    end)
end

function AutoWin()
    task.spawn(function()
        pcall(function()
            if firetouchinterest then
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, workspace.Worlds.Frozen.EndZone.EndCircle.Part, 0)
                task.wait()
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, workspace.Worlds.Frozen.EndZone.EndCircle.Part, 1)
            else
                LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.Worlds.Frozen.EndZone.EndCircle.Part.CFrame
            end
        end)
    end)
end

function CallAutoBuyEggs()
    task.spawn(function()
        for _, EggName in EggsTable do 
            Hatch:FireServer(EggName, 1)
            task.wait()
            EquipBest:FireServer()
        end
    end)
end


while task.wait() do
    if AutoGotoWin then
        AutoWin()
    end
    if AutoGetCash then 
        CallAutoCash()
    end
    if AutoBuyDrill then 
        CallAutoBuy()
    end
    if AutoBuyPets then 
        CallAutoBuyEggs()
    end
end
