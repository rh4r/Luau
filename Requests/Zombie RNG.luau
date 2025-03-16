--[[
    Game link: https://www.roblox.com/games/73801682582529/Zombies-RNG
    Description: Auto farm zombies, Auto collect power ups and Auto buy potions!

    >! Auto Farm Zombies !<
        When loaded into a game, please WAIT UNTIL THE GAME EQUIPS UR WEAPON!
            once loaded, you can execute the script.
]]--

local cyn = getgenv()

cyn.AutoKillEnabled = true -- Automatically Kill Zombies
cyn.AutoPowerUps = true -- Automatically Collect Powerups 
cyn.AutoPotions = false -- Automatically Buy Lobby Potions
cyn.AutoRoll = true -- Automatically Spin For New Guns

local PlayerMethods = {}
local OtherMethods = {}

function PlayerMethods:InitializeLocalPlayer()
    return cloneref(game:GetService("Players")).LocalPlayer
end

function PlayerMethods:ReturnChar(plr: Player)
    return plr.Character
end

function PlayerMethods:ReturnRoot(char: Model)
    return char.HumanoidRootPart or char.PrimaryPart
end

function PlayerMethods:ReturnHumanoid(char: Model)
    return char.Humanoid or char:FindFirstChildOfClass("Humanoid")
end

function OtherMethods:ReturnClonedService(service: string)
    return cloneref(game:GetService(service))
end

local TweenService = OtherMethods:ReturnClonedService("TweenService") or game:GetService("TweenService")
local ReplicatedStorage = OtherMethods:ReturnClonedService("ReplicatedStorage") or game:GetService("ReplicatedStorage")
local BuyPotion = cloneref(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("BuyPotion"))

AutoRollFunc = function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Functions"):WaitForChild("Roll"):InvokeServer()
end

AutoCollect = function()
    local Root = PlayerMethods:ReturnRoot(PlayerMethods:ReturnChar(PlayerMethods:InitializeLocalPlayer()))
    local OldRootPos = Root.Position    

    workspace.Game.Powerups.ChildAdded:Connect(function(child_added)
        if Root.Anchored then Root.Anchored = false task.wait() end

        for _, Transmitter in child_added:GetDescendants() do 
            if Transmitter:IsA("TouchTransmitter") then
                firetouchinterest(Root, Transmitter.Parent, 0)
            end
        end

        local WorkingTween = TweenService:Create(Root, TweenInfo.new(0), {CFrame = CFrame.new(OldRootPos)})
        WorkingTween:Play()
        WorkingTween.Completed:Wait(0.1)
        Root.Anchored = true
    end)
end

AutoBuyPotion = pcall(function()
    if cyn.AutoBuyPotion then 
        local Root = PlayerMethods:ReturnRoot(PlayerMethods:ReturnChar(PlayerMethods:InitializeLocalPlayer()))
        local Old = Root.Position
        task.wait(2)

        Root.Position = Vector3.new(-292, 41, -259)
        for i = 1,6 do
            BuyPotion:InvokeServer(i)
        end
        task.wait()

        Root.Position = Old
    end
end)

AutoZombieFarm = function()
    local LocalPlayer = PlayerMethods:InitializeLocalPlayer()
    local Char = PlayerMethods:ReturnChar(LocalPlayer)

    if Char then
        local Root = PlayerMethods:ReturnRoot(Char)
        local Humanoid = PlayerMethods:ReturnHumanoid(Char)
        if Root and Humanoid then
            local WorkingTween = TweenService:Create(Root, TweenInfo.new(0.5), {CFrame = CFrame.new(Root.CFrame.X, (Root.CFrame.Y + 50), Root.CFrame.Z)})
            WorkingTween:Play()
            WorkingTween.Completed:Wait()

            Root.Anchored = true

            pcall(function()
                if workspace.Game.Map.Spaceship then
                    workspace.Game.Map.Spaceship.Scene.Misc.Ceiling:Destroy()
                end
            end)

            task.delay(1, function()
                local ShootEvent = nil

                for index, Remote in getgc(false) do 
                    if typeof(Remote) == "Instance" and Remote:IsA("RemoteEvent") and Remote.Name then
                        if Remote.Name == "Event" then
                            ShootEvent = Remote
                            break
                        end
                    end 
                end

                if not ShootEvent then
                    for index, CharItem in Char:GetDescendants() do if CharItem:IsA("RemoteEvent") and CharItem.Name == "Event" then ShootEvent = CharItem end end
                end

                if not ShootEvent then 
                    for index, PlayerItem in LocalPlayer.Backpack:GetDescendants() do if PlayerItem:IsA("RemoteEvent") and PlayerItem.Name == "Event" then ShootEvent = PlayerItem end end
                end
                Char.ChildAdded:Connect(function(Child_Added)
                    if Child_Added:IsA("Tool") then
                        for a,b in Child_Added:GetDescendants() do
                            if b:IsA("RemoteEvent") and b.Name == "Event" then
                                ShootEvent = b
                            end
                        end
                    end
                end)

                if ShootEvent then 
                    while cyn.AutoKillEnabled and task.wait() do
                        ShootEvent:FireServer(Vector3.new(Root.Position.X, (Root.Position.Y - 50), Root.Position.Z))
                    end
                end
            end)
        end
    end
end

if cyn.AutoKillEnabled then 
    AutoZombieFarm()
end
if cyn.AutoBuyPotion then
    AutoBuyPotion()
end
if cyn.AutoPowerUps then
    AutoCollect()
end
if cyn.AutoRoll then
    AutoRollFunc()
end
