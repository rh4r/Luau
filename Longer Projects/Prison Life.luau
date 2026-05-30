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
                                            
]]--

-- // Configurations \\ -- 
local config = {
    ["Main"] = {
        ["ESP"] = false,
        ["ESP_Config"] = {
            ["Team"] = "All"
        },
        ["Sprint"] = false,
    },
    ["Blatant"] = {
        ["Aimlock"] = {
            ["Toggle"] = false,
            ["AimLockPart"] = "Head",
            ["AimlockKeybind"] = Enum.KeyCode.E
        },
    },
    ["Misc"] = {
        ["Pickup"] = false,
        ["GunPickup"] = false,
        ["TeamChange"] = ""
    },
    ["Settings"] = {},
}

-- // Initialization \\ -- 

repeat
    task.wait()
until game.Loaded

local cloneref = cloneref or getgenv().cloneref or function(...) return ... end 
local Services = {}
local cyn = getgenv()

setmetatable(Services, {
    __index = function(table, key)
        return cloneref(game:GetService(key))
    end
})


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

-- // Variables \\ -- 

local Camera = workspace.CurrentCamera
local Players = Services.Players or game:GetService("Players")
local RunService = Services.RunService or game:GetService("RunService")
local ReplicatedStorage = Services.ReplicatedStorage or game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local TeleportService = Services.TeleportService or game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local RemotesFolder = ReplicatedStorage.Remotes
local CollectRemote = RemotesFolder:WaitForChild("GiverPressed")
local InteractWithItem = RemotesFolder:WaitForChild("InteractWithItem")
local PrisonItemsGiver = workspace:WaitForChild("Prison_ITEMS"):WaitForChild("giver")
local RequestTeamChange = RemotesFolder:WaitForChild("RequestTeamChange")

local AcceptedDropNames = {
    "Key card",
    "M9"
}

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
    local BoxWidth = BoxHeight / 2

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
                    task.wait()
                end
            end
        end
    end)
end

local function AUTO_SPRINT()
    while cMain.Sprint do
        local LChar = RETURN_CHARACTER(LocalPlayer)
        
        if LChar then
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

Players.PlayerRemoving:Connect(function(RemovingPlayer)
    for plrInstance, DrawingObject in DrawingObjects do
        if plrInstance == RemovingPlayer then
            DrawingObject.Visible = false
            DrawingObject:Destroy()
        end
    end
end)

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
                        Value = false,
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
                    local BasePartRow = AimlockForm:Row()
                    
                    -- // AIMLOCK FUNCTION \\ -- 
                    row:Left():TitleStack({
                        Title = "Toggle Aimlock",
                        Subtitle = "Automatically locks onto targets that can be killed",
                    })

                    row:Right():Toggle({
                        Value = false,
                        ValueChanged = function(self, value: boolean)
                            cBlatant.Aimlock.Toggle = value
                            AIMLOCK()
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

                    local MainFeatures = tab:PageSection({ Title = "Silent Aim Features" })

                    local MainFeatures = tab:PageSection({ Title = "Auto Shoot Features" })

                    local MainFeatures = tab:PageSection({ Title = "Ragebot Features" })

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
                        Value = false,
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
                        Value = false,
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
                        Value = false,
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
                end
            end
        end
    end
end
