--[[
	Game: Prison Life
	Credits: rh4r
    Update Schedule:
        28/05/2026 - Begin script, add ESP functionality
        29/05/2026 - Begin work on Aimlock and Modifying ESP
        30/05/2026 - List of features implimented:
                                                    + Entirely fixed aimlock
                                                    + Select Aimlock Part
                                                    + Enable Auto-Sprint
                                                    + Auto collect
                                                    + Item Giver
                                                    + Pickup Team Weapons
                                                    + Selectable Teams
                                                        + Instant Criminal Method
                                                    + Auto Reload
                                                    + Auto Fire
                                                    + Auto Swap
                                                    + Gun Modding
                                                        + FireRate
                                                        + Automatic
                                                    + Server hop 
                                                    + Rejoin
                                                    + Fix destroy leaving parts
        31/05/2026 - List of features implimented:
                                                    + Instance phase
                                                    + Jumpheight keybind
                                                    + Ragebot
                                                    + Config saving
                                            
]]--

-- // Initialization \\ -- 

repeat
    task.wait()
until game.Loaded

local config
local cloneref = cloneref or getgenv().cloneref or function(...) return ... end 
local Services = {}

setmetatable(Services, {
    __index = function(table, key)
        return cloneref(game:GetService(key))
    end
})

local function RETURN_CONFIG_TBL()
    local Success, Result = pcall(function()
        return loadstring("return " .. readfile("PrisonConfig.lua"))()
    end)

    if Success then
        config = Result
    else
        warn("Errored with:", Result)
    end
end

if readfile then
    RETURN_CONFIG_TBL()

    if not config then
        config = {
            ["Main"] = {
                ["ESP"] = false,
                ["ESP_Config"] = {
                    ["Team"] = "All"
                },
                ["Sprint"] = false,
                ["Reload"] = false,
                ["Swap"] = false
            },
            ["Blatant"] = {
                ["Aimlock"] = {
                    ["Toggle"] = false,
                    ["AimLockPart"] = "Head",
                    ["AimlockKeybind"] = Enum.KeyCode.E
                },
                ["Mods"] = {
                    ["Enabled"] = false,
                    ["Weapon"] = "",
                    ["FireRate"] = 0.1,
                    ["Automatic"] = false,
                    ["Spread"] = false,
                    ["Range"] = false,
                },
                ["AutoFiring"] = false,
                ["RageBot"] = {
                    ["Enabled"] = false,
                    ["AutofireEnabled"] = false
                }
            },
            ["Misc"] = {
                ["Pickup"] = false,
                ["GunPickup"] = false,
                ["PhaseKey"] = Enum.KeyCode.Q,
                ["HighJumpKey"] = Enum.KeyCode.N,
                ["HighHeightValue"] = 60,
                ["IsPhasing"] = false,
                ["TeamChange"] = ""
            },
            ["Settings"] = {},
        }
    end
end


local cMain = config.Main
local cBlatant = config.Blatant
local cMisc = config.Misc
local cSettings = config.Settings

local function VALIDATE_OBJECT(ObjectChecking)
    if ObjectChecking then
        return ObjectChecking:IsDescendantOf(workspace) 
    end
end

local function RETURN_CHARACTER(PlayerInstance)
    if PlayerInstance then
        return PlayerInstance.Character  
    end
end

local function RETURN_TARGET_PART(PlayerInstance, NameOfPart)
    if PlayerInstance then
        local PlayerCharacter = RETURN_CHARACTER(PlayerInstance)

        if not PlayerCharacter then
            return 
        else
            if PlayerCharacter:FindFirstChild(NameOfPart) and PlayerCharacter:FindFirstChild(NameOfPart):IsA("BasePart") then
                return PlayerCharacter:FindFirstChild(NameOfPart)
            end 
        end
    end
end

-- // Shortens \\ -- 
local insert = table.insert
local find = table.find
local clear = table.clear

-- // Variables \\ -- 
local Players = Services.Players or game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = Services.RunService or game:GetService("RunService")
local ReplicatedStorage = Services.ReplicatedStorage or game:GetService("ReplicatedStorage")
local Teams = Services.Teams or game:GetService("ReplicatedStorage")
local TeleportService = Services.TeleportService or game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

local PrisonItemsGiver = workspace:WaitForChild("Prison_ITEMS"):WaitForChild("giver")

local RemotesFolder = ReplicatedStorage.Remotes
local GunRemotes = ReplicatedStorage.GunRemotes

local CollectRemote = RemotesFolder:WaitForChild("GiverPressed")
local InteractWithItem = RemotesFolder:WaitForChild("InteractWithItem")
local RequestTeamChange = RemotesFolder:WaitForChild("RequestTeamChange")
local ShootEvent = GunRemotes:WaitForChild("ShootEvent")

local ReloadFunc 
local ShootFunction


local AcceptedDropNames = {
    "Key card",
    "M9"
}

local WeaponNames = {
    "M9",
    "Remington 870",
    "AK-47",
    "M700",
    "Revolver",
    "M4A1",
    "FAL",
    "MP5"
}

local Spoof = {
    ["UserInputState"] = Enum.UserInputState.Begin,
    ["UserInputType"] = Enum.UserInputType.Touch,
    ["Position"] = {
        ["X"] = 0,
        ["Y"] = 0,
    }
}

local CurrentGuns = {}
local DrawingObjects = {}

-- // Main Logic \\ -- 

--[[
UserInputService.InputBegan:Connect(function(UserInput, GameProccess)
    if UserInput.KeyCode == cBlatant.AimlockKeybind then
        if cBlatant.Aimlock then
            cBlatant.Aimlock = false
        else
            cBlatant.Aimlock = true
        end
    end
end)
]]--

local function UPDATE_GUNS()
    local LocalChar = RETURN_CHARACTER(LocalPlayer)
    local LocalBackpack = LocalPlayer.Backpack
    
    for index, CharV in pairs(LocalChar:GetChildren()) do
        if find(WeaponNames, CharV.Name) and not find(CurrentGuns, CharV.Name) then
            insert(CurrentGuns, CharV.Name)
        end
    end
    for index, BackV in pairs(LocalBackpack:GetChildren()) do
        if find(WeaponNames, BackV.Name) and not find(CurrentGuns, BackV.Name) then
            insert(CurrentGuns, BackV.Name)
        end
    end
end

task.spawn(function()
    UPDATE_GUNS()
end)

local function RETURN_BOX_POS(entity)
    local HeadOffset = Vector3.new(0, 0.5, 0)
    local FeetOffset = Vector3.new(0, 3, 0)

    local EntityChar = entity.Character
    local EntityHumanoidRootPart = EntityChar:FindFirstChild("HumanoidRootPart")
    local EntityHead = EntityChar:FindFirstChild("Head")
    local PassingOnScreenValue = false

    if not EntityHumanoidRootPart or not EntityHead then
        return
    end

    local HeadPos, visible1 = Camera:WorldToViewportPoint(EntityHead.Position + HeadOffset)
    local RootPos, visible2 = Camera:WorldToViewportPoint(EntityHumanoidRootPart.Position)
    local FeetPos, visible3 = Camera:WorldToViewportPoint(EntityHumanoidRootPart.Position - FeetOffset)

    if not (visible1 and visible2 and visible3) then
        PassingOnScreenValue = true
    end

    local BoxHeight = math.abs(HeadPos.Y - FeetPos.Y)
    local BoxWidth = BoxHeight / 1.6

    local BoxPosition = Vector2.new(
        RootPos.X - BoxWidth / 2,
        RootPos.Y - BoxHeight / 2
    )

    return Vector2.new(BoxWidth, BoxHeight), BoxPosition, PassingOnScreenValue
end

local function DESTROY_DRAWINGS()
    for a,b in pairs(DrawingObjects) do
        local ToDestroy = b[2]

        ToDestroy.Visible = false
        ToDestroy:Destroy()
    end
end

local function ASSOCIATE_TEAM_TO_COLOR(PlayerInst)
    local Team = PlayerInst.Team.Name
    local ColorToTeam = {
        ["Criminals"] = BrickColor.new("Really red").Color,
        ["Inmates"] = BrickColor.new("Bright orange").Color,
        ["Guards"] = BrickColor.new("Bright blue").Color,
        ["Neutral"] = BrickColor.new("Grey").Color
    }

    return ColorToTeam[Team]
end

local function PLAYER_ESP()
    if not cMain.ESP then
        DESTROY_DRAWINGS()
    else
        for index, entity in pairs(Players:GetPlayers()) do
            if entity.Character and entity.Character.HumanoidRootPart then
                if cMain.ESP_Config.Team == "Others" then
                    if entity.Team ~= LocalPlayer.Team then
                        local NewSize, BoxPosition, Visible = RETURN_BOX_POS(entity)

                        local PlrSquare = Drawing.new("Square")
                        PlrSquare.Visible = true
                        PlrSquare.Transparency = 1
                        PlrSquare.Color = ASSOCIATE_TEAM_TO_COLOR(entity)
                        PlrSquare.Size = NewSize
                        PlrSquare.Thickness = 2
                        PlrSquare.Filled = false
                        PlrSquare.Position = BoxPosition

                        insert(DrawingObjects, {entity, PlrSquare}) 
                    end
                else
                    local NewSize, BoxPosition, Visible = RETURN_BOX_POS(entity)

                    local PlrSquare = Drawing.new("Square")
                    PlrSquare.Visible = true
                    PlrSquare.Transparency = 1
                    PlrSquare.Color = ASSOCIATE_TEAM_TO_COLOR(entity)
                    PlrSquare.Size = NewSize
                    PlrSquare.Thickness = 2
                    PlrSquare.Filled = false
                    PlrSquare.Position = BoxPosition

                    insert(DrawingObjects, {entity, PlrSquare}) 
                end

            end
        end
        RunService.Heartbeat:Connect(function()
            if cMain.ESP then 
                for index, PassedTable in DrawingObjects do
                    local plrInstance = PassedTable[1]
                    local DrawingObject = PassedTable[2]

                    pcall(function()
                        if plrInstance.Character and plrInstance.Character.HumanoidRootPart then
                            local NewSize, NewPosition, Visible = RETURN_BOX_POS(plrInstance)

                            DrawingObject.Size = NewSize
                            DrawingObject.Position = NewPosition
                            DrawingObject.Visible = true

                            if Visible then
                                DrawingObject.Visible = false
                                DrawingObject.Color = ASSOCIATE_TEAM_TO_COLOR(plrInstance)
                            end
                        end
                    end)
                end
            end
        end) 
    end
end

local function IS_ALIVE(PlayerInst)
    local PlayerChar = RETURN_CHARACTER(PlayerInst)

    if PlayerChar then
        local PlayerHumanoid = PlayerChar:FindFirstChildOfClass("Humanoid") 
        if PlayerHumanoid and PlayerHumanoid.Health > 0 and not PlayerChar:FindFirstChildOfClass("ForceField") then
            return true
        else
            return false
        end
    end
end

local function CAN_DAMAGE(PlayerInst: Player)
    local LocalTeam = LocalPlayer.Team
    local TheirTeam = PlayerInst.Team
    local InmateWeaponTable = {
        "M9", "Remington 870", "MP5"
    }

    if LocalTeam ~= TheirTeam then
        if LocalTeam.Name == "Guards" and TheirTeam.Name == "Criminals" then
            return true
        elseif LocalTeam.Name == "Inmates" and TheirTeam.Name == "Guards" then
            if #LocalPlayer.Backpack:GetChildren() > 0 then
                for a,b in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if find(InmateWeaponTable, b.Name) then
                        return true
                    end
                end
            end
        elseif LocalTeam.Name == "Criminals" and TheirTeam.Name == "Guards" then
            return true
        elseif LocalTeam.Name == "Inmates" and TheirTeam.Name == "Criminals" then
            return true
        elseif LocalTeam.Name == "Guards" and TheirTeam.Name == "Inmates" then
            local TheirChar = RETURN_CHARACTER(PlayerInst)
            local Hostile = TheirChar:GetAttribute("Hostile")

            if Hostile then
                return true
            else
                return false
            end
        elseif LocalTeam.Name == "Criminals" and TheirTeam.Name == "Inmates" then
            local TheirChar = RETURN_CHARACTER(PlayerInst)
            local Hostile = TheirChar:GetAttribute("Hostile")

            if Hostile then
                return true
            else
                return false
            end
        end
    end
end

local function CHECK_AVAILABILITY_FOR_RAY(Closest_Player: Player)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local TargettingPart = RETURN_TARGET_PART(Closest_Player, cBlatant.Aimlock.AimLockPart)
    local TargettingCharacter = RETURN_CHARACTER(Closest_Player)

    if TargettingPart and TargettingCharacter then
        local rayResult

        task.spawn(function()
            local PartPosition, isOnScreen = Camera:WorldToViewportPoint(TargettingPart.Position)
            local screenWorldToRay = Camera:ViewportPointToRay(PartPosition.X, PartPosition.Y)
            raycastParams.FilterDescendantsInstances = {RETURN_CHARACTER(LocalPlayer)}

            rayResult = workspace:Raycast(
                screenWorldToRay.Origin,
                screenWorldToRay.Direction * 1000,
                raycastParams)
        end)
        
        if rayResult and rayResult.Instance then
            local RayResultInstance = rayResult.Instance

            if RayResultInstance:IsDescendantOf(TargettingCharacter) then
                return true
            end 
        end 
    end
end


local function RETURN_CLOSEST_PLAYER()
    local Closest
    local DistanceBetween = math.huge

    local Mouse = LocalPlayer:GetMouse()
    local MousePosition = Vector2.new(Mouse.X, Mouse.Y)

    for index, PlayerInst in pairs(Players:GetPlayers()) do
        if PlayerInst ~= LocalPlayer and VALIDATE_OBJECT(PlayerInst.Character) and VALIDATE_OBJECT(PlayerInst.Character:FindFirstChild(cBlatant.Aimlock.AimLockPart)) and PlayerInst.Team ~= LocalPlayer.Team then
            local ChosenPart = PlayerInst.Character:FindFirstChild(cBlatant.Aimlock.AimLockPart)
            local RootToViewpoint, CanSee = Camera:WorldToScreenPoint(ChosenPart.Position)
            local ViewportToVector = Vector2.new(RootToViewpoint.X, RootToViewpoint.Y)

            if CanSee and (MousePosition - ViewportToVector).Magnitude < DistanceBetween then
                Closest = PlayerInst
                DistanceBetween = (MousePosition - ViewportToVector).Magnitude
            end
        end
    end
    return Closest
end

local function RETURN_SHOOT_FUNC()
    if ShootFunction then
        return
    else
        for index, FoundFunction in pairs(getgc(false)) do
            if type(FoundFunction) == "function" and islclosure(FoundFunction) then
                local Source = debug.info(FoundFunction, "n")
                
                if Source and Source ~= "" and Source ~= "nil" and Source == "shoot" then
                    ShootFunction = FoundFunction
                end
            end
        end
    end
end

local function AIMLOCK()
    if LocalPlayer.CameraMode ~= Enum.CameraMode.LockFirstPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
    end
    RunService.RenderStepped:Connect(function()
        if not cBlatant.Aimlock.Toggle then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        else
            local Closest_Player = RETURN_CLOSEST_PLAYER()
            local NotBlockedByRay = CHECK_AVAILABILITY_FOR_RAY(Closest_Player)

            if Closest_Player and NotBlockedByRay then
                local Hostile = CAN_DAMAGE(Closest_Player)
                local LivingHumanoid = IS_ALIVE(Closest_Player)

                if Hostile and LivingHumanoid then
                    local ClosestPlayerCharacter = RETURN_CHARACTER(Closest_Player)
                    local PartToLock = ClosestPlayerCharacter:FindFirstChild(cBlatant.Aimlock.AimLockPart)
            
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, PartToLock.Position)  
                    
                    if cBlatant.AutoFiring then
                        if ShootFunction then
                            ShootFunction() 
                        else
                            RETURN_SHOOT_FUNC()
                        end
                    end
                    task.wait()
                end
            end
        end
    end)
end

local function AUTO_SPRINT()
    while cMain.Sprint do
        local LChar = RETURN_CHARACTER(LocalPlayer)
        
        if LChar and LChar:FindFirstChildOfClass("Humanoid") then
            LChar:FindFirstChildOfClass("Humanoid").WalkSpeed = 24
        end
        task.wait()
    end
end


local function GIVE_ITEM(ItemToGive)
    local ItemsHolder = ReplicatedStorage.Tools

    if ItemsHolder:FindFirstChild(ItemToGive) and LocalPlayer.Backpack then
        local ToolFound = ItemsHolder:FindFirstChild(ItemToGive)

        if ToolFound then
            ToolFound = ToolFound:Clone()
            ToolFound.Parent = LocalPlayer.Backpack
        end
    end
end 

local function AUTO_COLLECT()
    while cMisc.Pickup do
        task.wait()
        for index, InstanceObject in pairs(workspace:GetChildren()) do
            if find(AcceptedDropNames, InstanceObject.Name) then
                if not InstanceObject.PrimaryPart then
                    warn("Instance has no primary part??")
                else
                    local LocalRoot = RETURN_TARGET_PART(LocalPlayer, "HumanoidRootPart")
                    local ChildPart = InstanceObject.PrimaryPart

                    if ChildPart and LocalRoot then
                        local Distance = (ChildPart.Position - LocalRoot.Position).Magnitude

                        if Distance <= 20 then
                            CollectRemote:FireServer(workspace:WaitForChild(InstanceObject.Name)) 
                            task.wait(0.25)
                        end 
                    end
                end 
            end
        end
    end
end

local function INTERACT_WITH_TEAM_ITEM()
    task.spawn(function()
        for index, WeaponModel in pairs(PrisonItemsGiver:GetChildren()) do
            if WeaponModel.Name == "Remington 870" then
                if LocalPlayer.Team == Teams.Criminals then
                    if WeaponModel.WorldPivot == CFrame.new(-938.547058, 94.1033859, 2034.82556, -5.24520874e-06, 9.15527344e-05, -1, 1, 5.24520874e-06, -5.24520874e-06, 5.24520874e-06, -1, -9.15527344e-05) then
                        InteractWithItem:InvokeServer(WeaponModel:WaitForChild("Meshes/r870_2"))
                    end
                elseif LocalPlayer.Team == Teams.Guards then
                    if WeaponModel.WorldPivot == CFrame.new(820.236389, 101.698959, 2227.66772, -1.1920929e-07, -0, -1.00000012, 0, 1, -0, 1.00000012, 0, -1.1920929e-07) then
                        InteractWithItem:InvokeServer(WeaponModel:WaitForChild("Meshes/r870_2"))
                    end
                end
            end
        end
    end)

    task.wait(0.5)

    local TeamItems = {
        ["Criminals"] = PrisonItemsGiver:WaitForChild("AK-47"):WaitForChild("Meshes/AK47_7"),
        ["Guards"] = PrisonItemsGiver:WaitForChild("MP5"):WaitForChild("Meshes/MP5 (2)")
    }

    local LocalTeam = LocalPlayer.Team

    for index, CertainTeamWeapon in TeamItems do
        if index == LocalTeam.Name then
            InteractWithItem:InvokeServer(CertainTeamWeapon)
        end
    end
end

local function CHANGE_TEAM()
    RequestTeamChange:InvokeServer(Teams:WaitForChild("Neutral", 1))
    task.wait(1.5)

    if cMisc.TeamChange ~= "Criminals" then
        RequestTeamChange:InvokeServer(Teams:WaitForChild(cMisc.TeamChange), 1) 
    else
        RequestTeamChange:InvokeServer(Teams:WaitForChild("Inmates"), 1)
        task.wait(3)
         
        local LocalRoot = RETURN_TARGET_PART(LocalPlayer, "HumanoidRootPart")
        local LocalHuman = RETURN_CHARACTER(LocalPlayer):FindFirstChildOfClass("Humanoid")
        
        if LocalRoot then
            LocalRoot.CFrame = CFrame.new(812, 106, 2653)
            task.wait(1)
            LocalHuman.Health = 0
        end
    end
end

local function FIND_NEXT_GUN()
    local BackPack = LocalPlayer.Backpack

    if BackPack then
        for index, ToolInstance in pairs(BackPack:GetChildren()) do
            if find(WeaponNames, ToolInstance.Name) then
                return ToolInstance
            end
        end
    end
end

local function RETURN_CURRENT_WEAPON_TO_BACKPACK()
    local LocalChar = RETURN_CHARACTER(LocalPlayer)
    local LocalBackpack = LocalPlayer.Backpack

    if LocalChar and LocalChar:FindFirstChildOfClass("Tool") then
        local FoundTool = LocalChar:FindFirstChildOfClass("Tool") 

        if find(WeaponNames, FoundTool.Name) then
            FoundTool.Parent = LocalBackpack
        end
    end
end

local function FIND_CURRENT_WEAPON(PlayerCharacter)
    local Current 

    for index, Instance in pairs(PlayerCharacter:GetChildren()) do
        if Instance:IsA("Tool") and find(WeaponNames, Instance.Name) then
            Current = Instance
        end
    end
    return Current
end


local function CALL_UPDATE_MODS()
    if cBlatant.Mods.Enabled then
        if ShootFunction then
            local ShootFuncUpvalues = debug.getupvalues(ShootFunction)

            for index, upvalue in pairs(ShootFuncUpvalues) do
                if type(upvalue) == "table" then
                    for tableindex, tablevalue in pairs(upvalue) do

                        if cBlatant.Mods.Automatic and not cBlatant.RageBot.AutofireEnabled then
                            if tableindex == "AutoFire" and not rawget(upvalue, tableindex) == true then
                                rawset(upvalue, tableindex, true)
                            end
                        end

                        if cBlatant.Mods.FireRate then
                            if tableindex == "FireRate" then
                                rawset(upvalue, tableindex, cBlatant.Mods.FireRate)
                            end
                        end

                        if cBlatant.Mods.Spread then
                            if tableindex == "SpreadRadius" then
                                rawset(upvalue, tablevalue, 0)
                            end
                        end
                    end
                end
            end
        end 
    end
end

local function SETUP_PREMOD()
    if cBlatant.Mods.Enabled then
        RETURN_SHOOT_FUNC()

        local ChosenWeapon = cBlatant.Mods.Weapon
        local LocalChar = RETURN_CHARACTER(LocalPlayer)
        local LocalBackpack = LocalPlayer.Backpack

        if LocalChar then
            if not find(LocalChar:GetChildren(), LocalChar:FindFirstChild(ChosenWeapon)) then
                if LocalChar:FindFirstChildOfClass("Tool") then
                    local FoundTool = LocalChar:FindFirstChildOfClass("Tool")
                    FoundTool.Parent = LocalBackpack
                    task.wait()
                end
                local FoundWeapon = LocalBackpack:FindFirstChild(ChosenWeapon)

                if FoundWeapon then
                    FoundWeapon.Parent = LocalChar
                end
            end
        end
        task.wait()
    end
end

local function CALL_RELOAD()
    if not ReloadFunc then
        for a,b in pairs(getgc(false)) do
            if type(b) == "function" and islclosure(b) then
                local Source = debug.info(b, "n")
                local ScriptSource = debug.info(b, "s")
                
                if Source and Source ~= "" and Source ~= "nil" and Source == "reload" then
                    ReloadFunc = b
                end
            end
        end
        ReloadFunc()
    else
        ReloadFunc()
    end
end

local function ENABLE_PHASE()
    while cMisc.IsPhasing do 
        task.wait()

        local LocalChar = RETURN_CHARACTER(LocalPlayer)

        if LocalChar then
            local LocalToHit = RETURN_TARGET_PART(LocalPlayer, "Head")
            local LocalRootHit = RETURN_TARGET_PART(LocalPlayer, "HumanoidRootPart")

            if LocalToHit then
                local CreatedDirectionHead = Vector3.new(LocalToHit.CFrame.LookVector.X, LocalToHit.CFrame.LookVector.Y + 2, LocalToHit.CFrame.LookVector.Z * 100)
                local CreatedDirectionRoot = Vector3.new(LocalRootHit.CFrame.LookVector.X, LocalRootHit.CFrame.LookVector.Y - 0.25, LocalRootHit.CFrame.LookVector.Z * 100)


                local FitlerParams = RaycastParams.new()
                FitlerParams.FilterType = Enum.RaycastFilterType.Exclude
                FitlerParams.FilterDescendantsInstances = {LocalChar}
                FitlerParams.RespectCanCollide = true

                local HeadNewRay = workspace:Raycast(
                    LocalToHit.Position,
                    CreatedDirectionHead,
                    FitlerParams
                )

                local RootNewRay = workspace:Raycast(
                    LocalRootHit.Position,
                    CreatedDirectionRoot,
                    FitlerParams
                )
                
                if HeadNewRay and HeadNewRay.Instance then

                    task.spawn(function()
                        HeadNewRay.Instance.CanCollide = false
                        task.delay(3, function()
                            HeadNewRay.Instance.CanCollide = true
                        end)
                    end)
                end
                if RootNewRay and RootNewRay.Instance then

                    task.spawn(function()
                        RootNewRay.Instance.CanCollide = false
                        task.delay(3, function()
                            RootNewRay.Instance.CanCollide = true
                        end)
                    end)
                end
            end 
        end 
    end
end

local function ENABLE_HIGHJUMP()
    local LocalChar = RETURN_CHARACTER(LocalPlayer)

    if LocalChar then
        local LocalHumanoid = LocalChar:FindFirstChildOfClass("Humanoid")

        if LocalHumanoid then
            LocalHumanoid.JumpHeight = 50

            task.delay(5, function()
                LocalHumanoid.JumpHeight = 5.5
            end)
        end
    end
end

local function EQUIP_RANDOM_WEAPON()
    if cMain.Swap then
        return
    elseif not cMain.Swap or cMain.Swap and not RETURN_CHARACTER(LocalPlayer):FindFirstChildOfClass("Tool") then
        local LocalChar = RETURN_CHARACTER(LocalPlayer)
        local LocalBackpack = LocalPlayer.Backpack

        if LocalChar then
            if LocalChar:FindFirstChildOfClass("Tool") and not find(WeaponNames, LocalChar:FindFirstChildOfClass("Tool").Name) then
                LocalChar:FindFirstChildOfClass("Tool").Parent = LocalBackpack
            elseif LocalChar:FindFirstChildOfClass("Tool") and find(WeaponNames, LocalChar:FindFirstChildOfClass("Tool").Name) then
                return
            else
                if LocalBackpack then

                    for index, CurrentWeapon in pairs(LocalBackpack:GetChildren()) do
                        if find(WeaponNames, CurrentWeapon.Name) then
                            CurrentWeapon.Parent = LocalChar
                        end
                    end
                end
            end
        end
    end
end


local function RETURN_SENT_RAY(Instance1, Instance2, FilterInstance)
    local _, CanBeSeen = Camera:WorldToViewportPoint(Instance1.Position)
    local RayDistance = (Instance1.Position - Instance2.Position)
    local BlacklistParams = RaycastParams.new()
    BlacklistParams.FilterDescendantsInstances = {FilterInstance}
    BlacklistParams.FilterType = Enum.RaycastFilterType.Exclude
    
    if CanBeSeen and Instance1 and Instance2 then
        local CanDetect = workspace:Raycast(
            Instance2.Position,
            RayDistance * 1000,
            BlacklistParams
        )

        if CanDetect then
            return CanDetect
        end
    end
end

local function DO_RAGEBOT()
    local FirstRay = nil
    local PlayerTargetting = nil
    local LocalChar 
    local PlayerChar
    local LocalRoot
    local PlayerRoot

    while cBlatant.RageBot.Enabled do
        task.wait()

        if PlayerTargetting == nil and FirstRay == nil then
            for index, PlayerInstance in pairs(Players:GetPlayers()) do
                if PlayerInstance ~= LocalPlayer then
                    PlayerChar = RETURN_CHARACTER(PlayerInstance)
                    LocalChar = RETURN_CHARACTER(LocalPlayer)

                    if PlayerChar and LocalChar and IS_ALIVE(PlayerInstance) and CAN_DAMAGE(PlayerInstance) then
                        LocalRoot = RETURN_TARGET_PART(LocalPlayer, "Head")
                        PlayerRoot = RETURN_TARGET_PART(PlayerInstance, cBlatant.Aimlock.AimLockPart)

                        if PlayerRoot and LocalRoot then
                                FirstRay = RETURN_SENT_RAY(PlayerRoot, LocalRoot, LocalChar)

                                if FirstRay and FirstRay.Instance and FirstRay.Instance:IsDescendantOf(PlayerChar) then
                                    PlayerTargetting = PlayerInstance
                                    break
                                end
                            end
                        end
                    end
                end
        else
            local TheirRoot = RETURN_TARGET_PART(PlayerTargetting, cBlatant.Aimlock.AimLockPart)
            local LocalRoot = RETURN_TARGET_PART(LocalPlayer, "Head")

            if IS_ALIVE(PlayerTargetting) and IS_ALIVE(LocalPlayer) and TheirRoot and LocalRoot and FirstRay and FirstRay.Instance and FirstRay.Instance:IsDescendantOf(PlayerChar) then
                if cBlatant.Mods.Automatic then
                    cBlatant.RageBot.AutofireEnabled = true
                end

                EQUIP_RANDOM_WEAPON()

                local LocalChar = RETURN_CHARACTER(LocalPlayer)
                TheirRoot = RETURN_TARGET_PART(PlayerTargetting, "HumanoidRootPart")
                LocalRoot = RETURN_TARGET_PART(LocalPlayer, "HumanoidRootPart")

                if not ShootFunction then
                    RETURN_SHOOT_FUNC()
                else
                    local TheirLocation = Camera:WorldToScreenPoint(TheirRoot.Position)
                    local SpoofPos = Spoof["Position"]

                    SpoofPos.X = TheirLocation.X
                    SpoofPos.Y = TheirLocation.Y

                    task.spawn(function()
                        ShootFunction(Spoof)
                    end)
                    task.wait(cBlatant.Mods.FireRate)
                end
                if TheirRoot and LocalRoot and LocalChar then
                    FirstRay = RETURN_SENT_RAY(TheirRoot, LocalRoot, LocalChar) 
                else
                    FirstRay = nil
                end
            elseif not FirstRay or not IS_ALIVE(PlayerTargetting) then
                PlayerTargetting = nil
                FirstRay = nil
            elseif not IS_ALIVE(PlayerTargetting) or not IS_ALIVE(LocalPlayer) then
                cBlatant.RageBot.AutofireEnabled = false
            else
                PlayerTargetting = nil
                FirstRay = nil
            end
        end
    end
end

-- Gun Functions -- 
task.spawn(function()
    while task.wait() do
        if cBlatant.Mods.Enabled then
            CALL_UPDATE_MODS()
        end

        local LocalChar = RETURN_CHARACTER(LocalPlayer)

        if LocalChar then
            local CurrentWeapon = FIND_CURRENT_WEAPON(LocalChar)

            if CurrentWeapon then
                local CurrentAmmo = CurrentWeapon:GetAttribute("Local_CurrentAmmo")

                if CurrentAmmo and CurrentAmmo <= 0 then
                    if cMain.Reload then
                        task.spawn(function()
                            CALL_RELOAD()
                        end)
                    end
                    if cMain.Swap then
                        local NextWeapon = FIND_NEXT_GUN()
                        local CurrentWeapon = LocalChar:FindFirstChildOfClass("Tool")

                        if CurrentWeapon and CurrentWeapon:GetAttribute("Local_CurrentAmmo") == 0 then
                            RETURN_CURRENT_WEAPON_TO_BACKPACK()
                            task.wait()
                            NextWeapon.Parent = LocalChar 
                        end
                    end
                end
            end
        end
    end
end)

-- Remove Left Player Drawing Esp -- 
Players.PlayerRemoving:Connect(function(RemovingPlayer)
    for index, PlrESPTable in pairs(DrawingObjects) do
        if find(PlrESPTable, RemovingPlayer) then
            local DrawingObject = PlrESPTable[2]

            DrawingObject.Visible = false
            DrawingObject:Destroy()
        end
    end
end)

-- Auto Gun Pickup -- 
LocalPlayer.CharacterAdded:Connect(function()
    if cMisc.GunPickup then
        task.wait(1)
        local ItemLocations = {
            ["Guards"] = CFrame.new(819, 100, 2233),
            ["Criminals"] = CFrame.new(-935, 94, 2039)
        }

        local LocalTeam = LocalPlayer.Team
        local LocalRoot = RETURN_TARGET_PART(LocalPlayer, "HumanoidRootPart")

        if LocalRoot then
            local OldRootCFrame = LocalRoot.CFrame

            LocalRoot.CFrame = ItemLocations[LocalTeam.Name]
            task.wait(0.75)
            INTERACT_WITH_TEAM_ITEM() 
            LocalRoot.CFrame = OldRootCFrame
        end
    end
    clear(CurrentGuns)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == cMisc.PhaseKey then
        if cMisc.IsPhasing then
            cMisc.IsPhasing = false
        else
            cMisc.IsPhasing = true
            ENABLE_PHASE()
        end
    end
    if input.KeyCode == cMisc.HighJumpKey then
        ENABLE_HIGHJUMP()
    end
end)


-- // User Interface Library \\ -- 
local function importRelease(owner, repo, version, file)
    local tag = (version == "latest" and "latest/download" or "download/"..version)

    return loadstring(game:HttpGetAsync(("https://github.com/%s/%s/releases/%s/%s"):format(owner, repo, tag, file)), file)()
end

local function importRelease(owner, repo, version, file)
    local tag = (version == "latest" and "latest/download" or "download/"..version)

    return loadstring(game:HttpGetAsync(("https://github.com/%s/%s/releases/%s/%s"):format(owner, repo, tag, file)), file)()
end

local cascade = importRelease("cascadeui", "Cascade", "latest", "dist.luau")

local app = cascade.New({
    Theme = cascade.Themes.Dark,
    Accent = cascade.Accents.Blue, 
})

do -- Window Section
    local window = app:Window({
        Title = "Prison Life (0.0.1)",
        Subtitle = "Credits to rh4r",
    })

    do -- Start of tab section
        local section = window:Section({ Title = "--" })

        do -- Make our main tab
            local tab = section:Tab({
                Selected = true,
                Title = "Main Features",
                Icon = cascade.Symbols.squareStack3dUp,
            })

            local GunFeatures = section:Tab({
                Selected = true,
                Title = "Gun Features",
                Icon = cascade.Symbols.squareStack3dUp,
            })

            local QoLFeatures = section:Tab({
                Selected = true,
                Title = "QoL Settings",
                Icon = cascade.Symbols.squareStack3dUp,
            })

            local ScriptSettings = section:Tab({
                Selected = true,
                Title = "Script Settings",
                Icon = cascade.Symbols.squareStack3dUp,
            })

        do -- Settings Tab
            local tab = section:Tab({
                Title = "UI Settings",
                Icon = cascade.Symbols.squareStack3dUp,
            })

            do 
                local form = tab:PageSection({ Title = "Appearance" }):Form() -- 

                do 
                    local row = form:Row({
                        SearchIndex = "Dark mode",
                    })

                    row:Left():TitleStack({
                        Title = "Light mode",
                        Subtitle = "Light Mode is a application appearance setting that uses a Light color palette to provide a less comfortable viewing experience tailored for well lit environments.",
                    })

                    row:Right():Toggle({
                        Value = app.Theme == cascade.Themes.Light,
                        ValueChanged = function(self, value: boolean)
                            app.Theme = value and cascade.Themes.Light or cascade.Themes.Dark
                        end,
                    })
                end
            end

            do 
                local form = tab:PageSection({ Title = "Input" }):Form()

                do 
                    local row = form:Row({
                        SearchIndex = "Searchable",
                    })

                    row:Left():TitleStack({
                        Title = "Searchable",
                        Subtitle = "Allows pages to be searched using a text field in the title bar.",
                    })

                    row:Right():Toggle({
                        Value = window.Searching,
                        ValueChanged = function(self, value: boolean)
                            window.Searching = value
                        end,
                    })
                end

                do 
                    local row = form:Row({
                        SearchIndex = "Draggable",
                    })

                    row:Left():TitleStack({
                        Title = "Draggable",
                        Subtitle = "Allows users to move the window with a mouse or touch device.",
                    })

                    row:Right():Toggle({
                        Value = window.Draggable,
                        ValueChanged = function(self, value: boolean)
                            window.Draggable = value
                        end,
                    })
                end

                do 
                    local row = form:Row({
                        SearchIndex = "Resizable",
                    })

                    row:Left():TitleStack({
                        Title = "Resizable",
                        Subtitle = "Allows users to resize the window with a mouse or touch device.",
                    })

                    row:Right():Toggle({
                        Value = window.Resizable,
                        ValueChanged = function(self, value: boolean)
                            window.Resizable = value
                        end,
                    })
                end
            end

            do 
                local form = tab:PageSection({
                    Title = "Effects",
                    Subtitle = "These effects may be resource intensive across different systems.",
                }):Form()

                do
                    local row = form:Row({
                        SearchIndex = "Dropshadow",
                    })

                    row:Left():TitleStack({
                        Title = "Dropshadow",
                        Subtitle = "Enables a dropshadow effect on the window.",
                    })

                    row:Right():Toggle({
                        Value = window.Dropshadow,
                        ValueChanged = function(self, value: boolean)
                            window.Dropshadow = value
                        end,
                    })
                end

                do
                    local row = form:Row({
                        SearchIndex = "Background blur",
                    })

                    row:Left():TitleStack({
                        Title = "Background blur",
                        Subtitle = "Enables a UI background blur effect on the window. This can be detectable in some games.",
                    })

                    row:Right():Toggle({
                        Value = window.UIBlur,
                        ValueChanged = function(self, value: boolean)
                            window.UIBlur = value
                        end,
                    })
                end
            end
        end

            do
                local MainFeatures = tab:PageSection({ Title = "ESP Features" })
                local form = tab:Form()

                -- // MAIN FUNCTIONS \\ -- 

                do 
                    local ToggleRow = form:Row()
                    local PartRow = form:Row()
                    local NameTagRow = form:Row()
                    local SnapLineRow = form:Row()
                    local SkeletonRow = form:Row()

                    ToggleRow:Left():TitleStack({
                        Title = "Toggle ESP",
                        Subtitle = "Enables ESP",
                    })

                    ToggleRow:Right():Toggle({
                        Value = cMain.ESP,
                        ValueChanged = function(self, value: boolean)
                            cMain.ESP = value
                            PLAYER_ESP()
                        end 
                    })


                    -- // ESP CHOICES \\ --
                    do -- Team Esp Select
                        PartRow:Left():TitleStack({
                            Title = "Select Type of ESP",
                            Subtitle = "Select who to show in ESP",
                        })

                        local popUpButton = PartRow:Right():PopUpButton({
                        Options = {
                            "All Players",
                            "Other Teams",
                        },
                        ValueChanged = function(self, value: number)
                            if value == 1 then
                                cMain.ESP_Config.Team = "All"
                            elseif value == 2 then
                                cMain.ESP_Config.Team = "Others"
                            end
                            print(cMain.ESP_Config.Team, value)
                        end,
                    })
                    end

                    do  -- Nametags
                        NameTagRow:Left():TitleStack({
                            Title = "Toggle Nametags",
                            Subtitle = "Displays Usernames on ESP",
                        })

                        NameTagRow:Right():Toggle({
                            Value = false,
                            ValueChanged = function(self, value: boolean)
                                print("Done!")
                            end 
                        })
                    end

                    do  -- Snaplines
                        SnapLineRow:Left():TitleStack({
                            Title = "Toggle Snaplines",
                            Subtitle = "Displays lines from the top of your screen to players heads",
                        })

                        SnapLineRow:Right():Toggle({
                            Value = false,
                            ValueChanged = function(self, value: boolean)
                                print("Done!")
                            end 
                        })
                    end

                    do -- Skeletons
                        SkeletonRow:Left():TitleStack({
                            Title = "Toggle Skeletons",
                            Subtitle = "Displays lines to mimic player skeletons",
                        })

                        SkeletonRow:Right():Toggle({
                            Value = false,
                            ValueChanged = function(self, value: boolean)
                                print("Done!")
                            end 
                        })
                    end
                end
                    local MainFeatures = tab:PageSection({ Title = "Aimlock Features" })
                    local AimlockForm = MainFeatures:Form()
                    local row = AimlockForm:Row()
                    local AutoFireRow = AimlockForm:Row()
                    local BasePartRow = AimlockForm:Row()

                    
                    -- // AIMLOCK FUNCTION \\ -- 
                    row:Left():TitleStack({
                        Title = "Toggle Aimlock",
                        Subtitle = "Automatically locks onto targets that can be killed",
                    })

                    row:Right():Toggle({
                        Value = cBlatant.Aimlock.Toggle,
                        ValueChanged = function(self, value: boolean)
                            cBlatant.Aimlock.Toggle = value
                            AIMLOCK()
                        end 
                    })

                    -- // AUTO FIRING \\ --
                    AutoFireRow:Left():TitleStack({
                        Title = "Enable Auto Firing",
                        Subtitle = "Automatically shoots a player if detected on screen.",
                    })

                    AutoFireRow:Right():Toggle({
                        Value = cBlatant.AutoFiring,
                        ValueChanged = function(self, value: boolean)
                            cBlatant.AutoFiring = value
                        end 
                    })

                    local PartChoices = {}

                    task.spawn(function()
                        local LChar = RETURN_CHARACTER(LocalPlayer)
                        for a,b in pairs(LChar:GetChildren()) do
                            if b:IsA("BasePart") then
                                insert(PartChoices, b.Name)
                            end
                        end
                    end)

                    local popUpButton = BasePartRow:Right():PopUpButton({
                        Options = PartChoices,
                        ValueChanged = function(self, value: number)
                            cBlatant.Aimlock.AimLockPart = self.Options[value]
                        end,
                    })

                    BasePartRow:Left():TitleStack({
                        Title = "Select Aimlock Part",
                        Subtitle = "Select the BasePart that the script will target",
                    })

                    local RagebotTab = tab:PageSection({ Title = "Ragebot Features" })
                    local RageForm = RagebotTab:Form()
                    local RageRow = RageForm:Row()

                    -- // RAGEBOT TOGGLE \\ --

                    RageRow:Left():TitleStack({
                        Title = "Enable Ragebot",
                        Subtitle = "Automatically shoots at hostile targets",
                    })

                    RageRow:Right():Toggle({
                        Value = cBlatant.RageBot.Enabled,
                        ValueChanged = function(self, value: boolean)
                            cBlatant.RageBot.Enabled = value
                            DO_RAGEBOT()
                        end 
                    })


                    local MainFeatures = tab:PageSection({ Title = "Silent Aim Features" })
                
                do
                    local GunPage = GunFeatures:PageSection({ Title = "Gun Convience" })
                    local GunForm = GunPage:Form()
                    local AutoReloadGun = GunForm:Row()
                    local AutoSwapGun = GunForm:Row()

                    local GunModifiers = GunFeatures:PageSection({ Title = "Gun Select" })
                    local ModForm = GunModifiers:Form()
                    local EnableModdingRow = ModForm:Row()
                    local SelectedGunToModify = ModForm:Row()
                    local RefreshRow = ModForm:Row()

                    local RealModPage = GunFeatures:PageSection({ Title = "Choose Modifiers" })
                    local ModdingForm = RealModPage:Form()
                    local RefreshUpdateRow = ModdingForm:Row()
                    local AutomaticRow = ModdingForm:Row()
                    local SpreadRow = ModdingForm:Row()
                    local FirerateRow = ModdingForm:Row()

                    -- // AUTO RELOAD \\ -- 

                    AutoReloadGun:Left():TitleStack({
                        Title = "Enable Reload",
                        Subtitle = "Automatically reloads your current weapon",
                    })

                    AutoReloadGun:Right():Toggle({
                        Value = cMain.Reload,
                        ValueChanged = function(self, value: boolean)
                            cMain.Reload = value
                        end 
                    })

                    -- // SWAP GUN \\ -- 
                    AutoSwapGun:Left():TitleStack({
                        Title = "Enable Swap",
                        Subtitle = "Automatically swaps your current weapon whilst you have no ammo",
                    })

                    AutoSwapGun:Right():Toggle({
                        Value = cMain.Swap,
                        ValueChanged = function(self, value: boolean)
                            cMain.Swap = value
                        end 
                    })


                    -- // GUN MODS \\ -- 

                    EnableModdingRow:Left():TitleStack({
                        Title = "Allow Mods",
                        Subtitle = "Enables weapon modification",
                    })

                    EnableModdingRow:Right():Toggle({
                        Value = cBlatant.Mods.Enabled,
                        ValueChanged = function(self, value: boolean)
                            cBlatant.Mods.Enabled = value
                        end 
                    })

                    SelectedGunToModify:Left():TitleStack({
                        Title = "Choose a weapon to mod",
                        Subtitle = "Selects the weapon to make modifications to",
                    })


                    local ModDropdown = SelectedGunToModify:Right():PopUpButton({
                        Options = CurrentGuns,
                        ValueChanged = function(self, value: number)
                            cBlatant.Mods.Weapon = self.Options[value]
                            print(cBlatant.Mods.Weapon)
                        end,
                    })

                    
                    RefreshRow:Left():TitleStack({
                        Title = "Click to refresh available weapons",
                        Subtitle = "Refreshes the script, allowing you to choose weapons to mod.",
                    })

                    local RefreshButton = RefreshRow:Right():Button({
                        Label = "Refrersh",
                        State = "Primary",
                        Pushed = function(self)
                            UPDATE_GUNS()
                            ModDropdown.Options = CurrentGuns
                        end,
                    })


                    RefreshUpdateRow:Left():TitleStack({
                        Title = "Update weapon",
                        Subtitle = "Modifies the new weapon with the selected modifiers.",
                    })

                    local RefreshButton = RefreshUpdateRow:Right():Button({
                        Label = "Refrersh",
                        State = "Primary",
                        Pushed = function(self)
                            cBlatant.Mods.HasHooked = true
                            SETUP_PREMOD()
                            CALL_UPDATE_MODS()
                        end,
                    })

                    -- // ACTUAL GUN MODDING CHOICES \\ -- 

                    AutomaticRow:Left():TitleStack({
                        Title = "Set Automatic",
                        Subtitle = "Allows the weapon to Auto-Fire",
                    })

                    AutomaticRow:Right():Toggle({
                        Value = cBlatant.Mods.Automatic,
                        ValueChanged = function(self, value: boolean)
                            cBlatant.Mods.Automatic = value
                        end 
                    })

                    FirerateRow:Left():TitleStack({
                        Title = "Set FireRate",
                        Subtitle = "Enter new firerate (Lower = Faster)",
                    })

                    local FireRateTextEnter = FirerateRow:Right():TextField({
                        Value = "",
                        ValueChanged = function(self, value: string)
                            cBlatant.Mods.FireRate = tonumber(value)
                        end,
                        TextChanged = function(self, value: string)
                            print("Text changed:", value)
                        end,
                    })

                    -- // SPREAD \\ -- 

                    SpreadRow:Left():TitleStack({
                        Title = "Set No-Spread",
                        Subtitle = "Sets the SpreadRadius to 0",
                    })

                    SpreadRow:Right():Toggle({
                        Value = cBlatant.Mods.Spread,
                        ValueChanged = function(self, value: boolean)
                            cBlatant.Mods.Spread = value
                        end 
                    })

                end
                do
                    local QoLPpage = QoLFeatures:PageSection({ Title = "Player Advantages" })
                    local QolForm = QoLFeatures:Form()
                    local SprintRow = QolForm:Row()
                    local CollectRow = QolForm:Row()
                    local GunPickup = QolForm:Row()
                    local UseKeycard = QolForm:Row()

                     -- // SPRINT \\ -- 

                    SprintRow:Left():TitleStack({
                        Title = "Enable Auto-Sprint",
                        Subtitle = "Automatically sprints for you",
                    })

                    SprintRow:Right():Toggle({
                        Value = cMain.Sprint,
                        ValueChanged = function(self, value: boolean)
                            cMain.Sprint = value
                            AUTO_SPRINT()

                            if not value then
                                RETURN_CHARACTER(LocalPlayer).Humanoid.WalkSpeed = 16
                            end
                        end 
                    })

                    -- // AUTO COLLECT \\ -- 

                    CollectRow:Left():TitleStack({
                        Title = "Enable Collect",
                        Subtitle = "Automatically collects dropped items for you",
                    })

                    CollectRow:Right():Toggle({
                        Value = cMisc.Pickup ,
                        ValueChanged = function(self, value: boolean)
                            cMisc.Pickup = value
                            AUTO_COLLECT()
                        end 
                    })

                    -- // AUTO PICKUP \\ -- 

                    GunPickup:Left():TitleStack({
                        Title = "Enable Gun Pickup",
                        Subtitle = "Automatically grabs your teams associated weapons. (ON SPAWN)",
                    })

                    GunPickup:Right():Toggle({
                        Value = cMisc.GunPickup,
                        ValueChanged = function(self, value: boolean)
                            cMisc.GunPickup = value
                        end 
                    })

                    -- // AUTO KEYCARD \\ -- 

                    UseKeycard:Left():TitleStack({
                        Title = "Enable Auto Keycard",
                        Subtitle = "Automatically uses keycard on doors that require it",
                    })

                    UseKeycard:Right():Toggle({
                        Value = false,
                        ValueChanged = function(self, value: boolean)
                            print()
                        end 
                    })

                    local HumanoidPage = QoLFeatures:PageSection({ Title = "Humanoid Settings" })
                    local HumanoidForm = HumanoidPage:Form()
                    local PhaseRow = HumanoidForm:Row()
                    local HighJumpRow = HumanoidForm:Row()
                    local QoLPpage = QoLFeatures:PageSection({ Title = "Client Side Features" })
                    local ClientFeaturesForm = QoLPpage:Form()
                    local SpawnItemRow = ClientFeaturesForm:Row()

                    -- // GIVE ITEM \\ -- 
                    local ToolOptions = {}

                    task.spawn(function()
                        for a,b in pairs(ReplicatedStorage.Tools:GetChildren()) do
                            if b:IsA("Tool") then
                                insert(ToolOptions, b.Name)
                            end
                        end
                    end)

                    local popUpButton = SpawnItemRow:Right():PopUpButton({
                        Options = ToolOptions,
                        ValueChanged = function(self, value: number)
                            cMain.Pickup = self.Options[value]
                        end,
                    })

                    SpawnItemRow:Left():TitleStack({
                        Title = "(CLIENT) Give player item",
                        Subtitle = "Select the item to be given to you",
                    })

                    local button = SpawnItemRow:Right():Button({
                        Label = "Spawn",
                        State = "Primary",
                        Pushed = function(self)
                            GIVE_ITEM(cMain.Pickup)
                        end,
                    })
                    -- // PHASE \\ --

                    PhaseRow:Left():TitleStack({
                        Title = "Enter the keybind for phase",
                        Subtitle = "When this key is pressed, you will be able to phase through walls infront of you.",
                    })

                    local phaseKeybind = PhaseRow:Right():KeybindField({
                        ValueChanged = function(self, value: Enum.KeyCode)
                            cMisc.PhaseKey = value
                        end,
                    })

                    -- // HIGH JUMP \\ --

                    HighJumpRow:Left():TitleStack({
                        Title = "Enter the keybind for high jump",
                        Subtitle = "When this key is pressed, you will gain a temporary jump boost.",
                    })

                    local highjumpKeybind = HighJumpRow:Right():KeybindField({
                        ValueChanged = function(self, value: Enum.KeyCode)
                            cMisc.HighJumpKey = value
                        end,
                    })

                    local highJumpEnter = HighJumpRow:Right():TextField({
                        Value = "Enter Height Value",
                        ValueChanged = function(self, value: string)
                            cMisc.HighHeightValue = value
                        end,
                    })

                    -- // TEAM CHANGE \\ -- 

                    local TeamFeatures = QoLFeatures:PageSection({ Title = "Team Features" })
                    local TeamForm = TeamFeatures:Form()
                    local TeamRow = TeamForm:Row()

                    TeamRow:Left():TitleStack({
                        Title = "Team Change",
                        Subtitle = "Select the team to change to (DO NOT SPAM, CHANCE OF BAN)",
                    })

                    local popUpButton = TeamRow:Right():PopUpButton({
                        Options = {"Inmates", "Guards", "Criminals", "Neutral"},
                        ValueChanged = function(self, value: number)
                            cMisc.TeamChange = self.Options[value]
                        end,
                    })

                    local button = TeamRow:Right():Button({
                        Label = "Spawn",
                        State = "Primary",
                        Pushed = function(self)
                            CHANGE_TEAM()
                        end,
                    })
                end
                    -- // CLEAR DRAWINGS \\ -- 
                do
                    local ScriptPage = ScriptSettings:PageSection({ Title = "Debug/Fix Features" })
                    local ScriptSettingForm = ScriptSettings:Form()
                    local ScriptSettingRow = ScriptSettingForm:Row()
                    local ScriptSetRejoin = ScriptSettingForm:Row()
                    local ScriptServerhop = ScriptSettingForm:Row()
                    local SaveConfigRow = ScriptSettingForm:Row()

                    ScriptSettingRow:Left():TitleStack({
                        Title = "Clear all drawing objects",
                        Subtitle = "Destroys all currently existing drawing objects",
                    })


                    local button = ScriptSettingRow:Right():Button({
                        Label = "Clear Drawings",
                        State = "Primary",
                        Pushed = function(self)
                            DESTROY_DRAWINGS()
                        end,
                    })

                    
                    ScriptSetRejoin:Left():TitleStack({
                        Title = "Rejoin Server",
                        Subtitle = "Rejoins the current server",
                    })


                    local button = ScriptSetRejoin:Right():Button({
                        Label = "Rejoin",
                        State = "Primary",
                        Pushed = function(self)
                            Services.TeleportService:Teleport(game.PlaceId)
                        end,
                    })

                    -- // SERVERHOP BUTTON \\ -- 

                    ScriptServerhop:Left():TitleStack({
                        Title = "Serverhop To Another Server",
                        Subtitle = "Rejoins the current server",
                    })


                    local button = ScriptServerhop:Right():Button({
                        Label = "Hop",
                        State = "Primary",
                        Pushed = function(self)
                            local HttpService = Services.HttpService
                            local SentRequest = request({
                                Url = "https://games.roblox.com/v1/games/155615604/servers/Public?sortOrder=Asc&limit=100",
                                Method = "GET",
                            })

                            local JSONDecode = HttpService:JSONDecode(SentRequest.Body)
                            local NewJobID = JSONDecode.data[math.random(1, table.getn(JSONDecode.data))].id

                            TeleportService:TeleportToPlaceInstance(game.PlaceId, NewJobID)
                        end,
                    })

                    -- // SAVE CURRENT CONFIG \\ -- 
                    SaveConfigRow:Left():TitleStack({
                        Title = "Save Config",
                        Subtitle = "Stores your current choices and automatically enables them on execute",
                    })


                    local button = SaveConfigRow:Right():Button({
                        Label = "Save",
                        State = "Primary",
                        Pushed = function(self)
                            -- cba to make this, chatgpt did this admitidely

                            local function serialize(value, indent)
                                indent = indent or 0
                                local padding = string.rep("    ", indent)

                                if typeof(value) == "table" then
                                    local result = "{\n"

                                    for k, v in pairs(value) do
                                        local key

                                        if type(k) == "string" then
                                            key = string.format('["%s"]', k)
                                        else
                                            key = string.format("[%s]", tostring(k))
                                        end

                                        result ..= string.rep("    ", indent + 1)
                                            .. key
                                            .. " = "
                                            .. serialize(v, indent + 1)
                                            .. ",\n"
                                    end

                                    result ..= padding .. "}"
                                    return result

                                elseif typeof(value) == "EnumItem" then
                                    return tostring(value)

                                elseif type(value) == "string" then
                                    return string.format("%q", value)

                                elseif type(value) == "boolean" or type(value) == "number" then
                                    return tostring(value)

                                else
                                    return "nil"
                                end
                            end

                            local configString = serialize(config)

                            for index, File in listfiles("") do
                                if File == "PrisonConfig.lua" then
                                    delfile(File)
                                end
                            end

                            writefile("PrisonConfig.lua", configString)
                            print("Saved Config File!")
                        end,
                    })
                end
            end
        end
    end
end
