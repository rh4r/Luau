-- // Credits & Description \\ -- 
--[[
    Description: 
        This is a private script for Jujutsu Infinite.
    Credits: 
        rh4r - everything
    Game Link:
        https://www.roblox.com/games/10450270085/Jujutsu-Infinite
    Last Update:
        nihil @ nihil
    To-Do:
        ESP:
            + NPC ESP
            + Player ESP
            + Dropped item ESP
            + Cursed spirit ESP
        Autos:
            + Auto Collect Tailsmen (DONE)
            + Auto area quests (PARTLY DONE)
            + Auto story quests
            + Auto perfect parry
            + Automatic boss farm
            + Automatic investigation farm
            + Always hit blackflash / chant
        Misc Features:
            + Redeem all codes (DONE)
            + Build saving + loading
            + Server hop for dropped items
            + Cursed & Cash market displays
]]--

-- // User Configuration \\ -- 
local cyn = getgenv()

cyn.Configuration = {
    ["AutomaticFeatures"] = {
        ["AutoM1"] = false,
        ["Tailsmen"] = false,
        ["AreaQuest"] = false,
        ["StoryQuest"] = false,
        ["PerfectParry"] = false,
        ["BossFarm"] = false,
        ["InvestigationFarm"] = false,
        ["AlwaysHitFocusNeedle"] = false,
    },
    ["MiscFeatures"] = {
        nil,
    },
    ["ESPFeatures"] = {
        ["Player"] = false,
    }
}


-- // Initialization and User Inputs \\ -- 
repeat
    task.wait()
until game.Loaded

if not getgenv().OtherFunctions then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/rh4r/Luau/refs/heads/main/Enviroment%20Files/barebones_cyn.luau"))() -- Function Library
end

-- // Executor Enviroment & Functions \\ --
local OtherFunctions = cyn.OtherFunctions
local PlayerFunctions = cyn.PlayerFunctions
local AutomaticFeatures = cyn.Configuration.AutomaticFeatures
local MiscFeatures = cyn.Configuration.MiscFeatures
local ESPFeatures = cyn.Configuration.ESPFeatures

local floor = math.floor
local random = math.random
local foreach = table.foreach
local insert = table.insert
local sub = string.sub
local split = string.split
local len = string.len
local find = table.find
local remove = table.remove

local cloneref = cloneref or function(...) return ... end 

local ReturnLocalRoot = PlayerFunctions.ReturnLocalRoot
local ReturnLocalChar = PlayerFunctions.ReturnLocalChar
local ReturnLocalHumanoid = PlayerFunctions.ReturnLocalHumanoid

local Services = setmetatable({}, {
    __index = function(self, key)
        return cloneref(game:GetService(key)) -- Prevent Service Detection Methods
    end
})

local function FindFirstDescendantOf(ParentObject: any, ClassToFind: string)
    for _, temp in pairs(ParentObject:GetDescendants()) do
        if temp:IsA(ClassToFind) then
            return temp
        end
    end
end

local function FindFirstDescendantNamed(ParentObject: any, DescendantName: string)
    for _, finding_descendant in pairs(ParentObject:GetDescendants()) do
        if finding_descendant.Name == DescendantName then
            return finding_descendant
        end
    end
end

local function LOG(type_of_log: any, logging_text: string)
    type_of_log("[LOG] "..logging_text)
end

local function MONITOR_REMOTE_EVENT(PassedRemote: RemoteEvent)
    local old; old = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
        local Args = {...}

        if typeof(Self) == "Instance" and Self == PassedRemote and not checkcaller() then
            local ResponsibleScript = getcallingscript()

            warn("[METAMETHOD HOOK LOG] Remote called from script: ", ResponsibleScript, ResponsibleScript:GetFullName())
        end
        return old(Self, ...)
    end))
end

-- // Game Globals \\ -- 
local Players = cloneref(Services.Players)
local RunService = cloneref(Services.RunService)
local ReplicatedFirst = cloneref(Services.ReplicatedFirst)
local ReplicatedStorage = cloneref(Services.ReplicatedStorage)

local LocalPlayer = cloneref(Players.LocalPlayer)
local PlayerGui = LocalPlayer.PlayerGui
local Backpack = LocalPlayer.Backpack

local Camera = cloneref(workspace.CurrentCamera)
local PLAYER_ESP_OBJECTS = {}

local CodeButton = PlayerGui.Customization.Frame.BottomRight.Codes
local CardsToFilter = PlayerGui.Missions.Frame.Main.Cards

local ChosenQuest = nil

local MeleeFunction = nil
local M1ArgumentsTable = {}

 -- // Functions & Remote Events \\ -- 
local MobPath = workspace.Objects.Mobs

local ControlsTable = ReplicatedFirst.Dependencies.Controls

local ServerEvents = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Server")
local PlayerMissions = ReplicatedStorage:WaitForChild("Missions"):WaitForChild("HollovvSquadd")

local DataEvent = ServerEvents:WaitForChild("Data")
local Combat = ServerEvents:WaitForChild("Combat")

local Skydive = Combat:WaitForChild("Skydive")
local M1 = Combat:WaitForChild("M1")

local RedeemFunc = DataEvent:WaitForChild("RedeemCode")
local ClaimFunc = DataEvent:WaitForChild("ClaimQuest")

local ReplicatedTempData = LocalPlayer:WaitForChild("ReplicatedTempData")
local Client = LocalPlayer.PlayerScripts:WaitForChild("Client")


-- // Game Functions \\ --
local function VALIDATE_OBJECT(ObjectChecking: any)
    return ObjectChecking and ObjectChecking:IsDescendantOf(workspace)
end


local function TELEPORT(TeleportingTo: Part)
    local LocalRoot = ReturnLocalRoot()

    if TeleportingTo and VALIDATE_OBJECT(LocalRoot) then
        LocalRoot.CFrame = TeleportingTo.CFrame
    end
end

local function TELEPORT_WITH_OFFSET(TP_Part: Part, X_OFFSET: number, Y_OFFSET: number, Z_OFFSET: number)
    local LocalRoot = ReturnLocalRoot()
    local NewCFrame = CFrame.new(
        TP_Part.CFrame.X - (X_OFFSET or 0),
        TP_Part.CFrame.Y - (Y_OFFSET or 0),
        TP_Part.CFrame.Z - (Z_OFFSET or 0)
    )

    if TP_Part and VALIDATE_OBJECT(LocalRoot) then
        LocalRoot.CFrame = NewCFrame
    end
end

local function REDEEM_CODES()
    local code_list = {
        "SHOWDOWN_SORRY!",
        "WINTER_EVENT_OUT",
        "WINTER_SOON",
        "SOUL_KING_OUT",
        "HAPPY_2026",
        "95_PERCENT",
        "EXCHANGE_OUT",
        "EXCHANGE_50"
    }
    local redeem_remote = cloneref(RedeemFunc)

    for _, code in pairs(code_list) do
        CodeButton.Text = code
        task.wait(0.25)

        redeem_remote:InvokeServer(code)
        warn(
            "Redeemed code: ", code
        )
        task.wait(1)
    end
    return
end


local function COLLECT_ALL_TAILSMEN()
    while AutomaticFeatures.Tailsmen and task.wait() do
        local TailsmenLocation = workspace.Objects.Drops

        for _, tailsmen in pairs(TailsmenLocation:GetChildren()) do
            if tailsmen.Name == "Talisman" then
                task.spawn(function()
                    local TailsmenProximityPrompt = tailsmen:WaitForChild("Collect")
            
                    TELEPORT(tailsmen.Root)

                    task.wait(0.5)
                    fireproximityprompt(TailsmenProximityPrompt)
                    task.wait(0.5) 
                end
                )
            end
        end 
    end
end

local function RETURN_HIGHEST_QUEST_PRIORITY()
    TELEPORT(workspace.Objects.Portals.Missions)
    task.wait(2)

    local PriorityQueue = {
        ["Exorcise"] = 1,
        ["Defeat"] = 2,
        ["Defeat a band"] = 2,
        ["Capture"] = 3
    }

    local CurrentQuests = {}

    for quest_index, quest in pairs(CardsToFilter:GetChildren()) do
        if quest:IsA("Frame") then
            for _, quest_text in pairs(quest:GetDescendants()) do
                if quest_text:IsA("TextLabel") and quest_text.Name == "Title" then
                    quest_index = quest_index - 1 

                    insert(CurrentQuests, quest_index, {quest_text.Text, quest})
                end
            end
        end
    end


    for quest_no, quest_value in pairs(CurrentQuests) do
        local HighestPrio = 999
        local QuestText = quest_value[1]; warn("Quest Text: ", QuestText)
        local QuestPrio = PriorityQueue[QuestText]; warn("Quest Priority: ", QuestPrio)

        if ChosenQuest == nil and QuestPrio < HighestPrio and quest_value[2]:FindFirstChild("Info") then
            ChosenQuest = quest_value[2]; warn("Chosen Quest: ", ChosenQuest)
            HighestPrio = QuestPrio; warn("New Highest Priority: ", HighestPrio)
        end
    end

    if ChosenQuest == nil then
        LOG(warn, "No chosen quest found, returning random.")

        ChosenQuest = CurrentQuests[random(1, #CurrentQuests)]
    end

    return ChosenQuest
end

local function GET_NUMBER_FROM_QUEST(QuestStr: string)
    local FinalChar = sub(QuestStr, len(QuestStr))
    return FinalChar
end

local function SKYDIVE()
    local ModuleScript = require(ControlsTable)
    local WarpFunction = ModuleScript.warp

    if WarpFunction then
        WarpFunction(ModuleScript)
        task.wait()
        Skydive:FireServer({ReplicatedTempData:WaitForChild("quest")})
    end
end

local function RETURN_MOB_LIST()
    local LocalRoot = ReturnLocalRoot()

    for _, MobInstance in pairs(MobPath:GetChildren()) do
        if MobInstance.PrimaryPart and MobInstance.Humanoid then
            if (LocalRoot.Position - MobInstance.PrimaryPart.Position).Magnitude <= 500 then
                insert(M1ArgumentsTable, MobInstance.Humanoid)
            end
        end
    end
    MobPath.ChildRemoved:Connect(function(LeavingChild: Instance)
        if LeavingChild.PrimaryPart and find(M1ArgumentsTable, LeavingChild.Humanoid) then
            remove(M1ArgumentsTable, LeavingChild.Humanoid)
        end
    end)
end

local function EQUIP_FISTS()
    pcall(function()
        local LocalCharacter = ReturnLocalChar()

        Backpack.Skills.Parent = LocalCharacter
    end)
end

local function AUTO_M1()
    if MeleeFunction then
        MeleeFunction(require(ControlsTable), nil)
    else
        local ControlHandler = require(ControlsTable)

        EQUIP_FISTS()

        for element_name, element_value in pairs(ControlHandler) do
            if element_name == "m1" then
                MeleeFunction = element_value
            end
        end
    end
end

local function RETURN_CLOSEST_MOB()
    local ClosestMob
    local ClosestDist = 500
    local LocalRoot = ReturnLocalRoot()

    for mob_index, mob_instance in pairs(MobPath:GetChildren()) do
        if mob_instance and mob_instance.PrimaryPart then
            local ComparePart = mob_instance.PrimaryPart
            local DistanceCheck = (LocalRoot.Position - ComparePart.Position).Magnitude

            if DistanceCheck < ClosestDist then
                ClosestMob = mob_instance
                ClosestDist = floor(DistanceCheck)
            end
        end
    end

    return ClosestMob
end

local function TRAIL_MOB(MobObject: Model)
    local PrimaryPart = MobObject.PrimaryPart
    local LocalRoot = ReturnLocalRoot()

    if VALIDATE_OBJECT(LocalRoot) and VALIDATE_OBJECT(PrimaryPart) then
        LocalRoot.Orientation = PrimaryPart.Orientation

        TELEPORT_WITH_OFFSET(PrimaryPart, 0, 0, 2)
    end
end

local function CLAIM_AREA_QUEST(CurrentArea: string)
    local HighestPrioQuest = RETURN_HIGHEST_QUEST_PRIORITY()     
    local QuestIndexToNumber = GET_NUMBER_FROM_QUEST(tostring(HighestPrioQuest))

    for key, value in pairs(CardsToFilter:GetChildren()) do
        if value == HighestPrioQuest then
            local NewQuestString = "Quest" .. QuestIndexToNumber
            local QuestParent = PlayerMissions[CurrentArea]
            local QuestArgument = QuestParent:WaitForChild(NewQuestString)

            ClaimFunc:InvokeServer(QuestArgument)
            print("Invoked quest: ", QuestArgument)
        end
    end
end

local function ONLY_CLOSE_MOBS()
    local ClosestDist = 1000
    local LocalRoot = ReturnLocalRoot()
    local MobsInRange = {}

    for close_index, close_instance in pairs(MobPath:GetChildren()) do
        if close_instance and close_instance.PrimaryPart then
            local ComparePart = close_instance.PrimaryPart
            local DistanceCheck = (LocalRoot.Position - ComparePart.Position).Magnitude

            if DistanceCheck < ClosestDist then
                insert(MobsInRange, close_instance)
            end
        end
    end
    return MobsInRange
end

local function MOB_HAS_HEALTH_OBJECT(MobObj: Model)
    local MobCurrentHumanoidRootPart = MobObj and MobObj:FindFirstChild("HumanoidRootPart")

    return MobCurrentHumanoidRootPart
        and MobCurrentHumanoidRootPart:IsDescendantOf(workspace)
        and MobCurrentHumanoidRootPart:FindFirstChild("Health")
end


local function AREA_QUESTS()
    while AutomaticFeatures.AreaQuest and task.wait() do
        CLAIM_AREA_QUEST("Shijo Town Set")
        task.wait(0.5)

        SKYDIVE()
        task.wait(5)

        local MobsToAttack = ONLY_CLOSE_MOBS()

        for index, enemy_npc in pairs(MobsToAttack) do
            while MOB_HAS_HEALTH_OBJECT(enemy_npc) do
                TRAIL_MOB(enemy_npc)   
                AUTO_M1()

                print("In loop...")
                task.wait(0.3)
            end 
        end
    end
end





-- // ESP Functions \\ -- 

local function RETURN_V2_POINT(Object: Instance)
    local Vector, OnScreen = Camera:WorldToViewportPoint(Vector3.new(Object.Position.X, Object.Position.Y, Object.Position.Z))
    local ScreenPoint = Vector2.new(Vector.X, Vector.Y)

    if OnScreen then
        return ScreenPoint
    end
end

local function SCALE_TO_DIST(InstancePosition: Vector3)
    local CameraPosition = Camera.Position
    local DistanceInMagnitude = (CameraPosition - InstancePosition).Magnitude
    local ClampedValue = math.clamp(1 / (DistanceInMagnitude / 25), 0.6, 3)

    return ClampedValue
end

local function CREATE_SQUARE_FOR_PLAYER(Player: Player)
    local PlrPart = Player.Character.Root

    if not PLAYER_ESP_OBJECTS[Player] then
        local PlrSquare = Drawing.new("Square")
        PlrSquare.Visible = true
        PlrSquare.Transparency = 0.5
        PlrSquare.Color = Color3.new(1,0,0)
        PlrSquare.Size = Vector2.new(50,50)
        PlrSquare.Thickness = 2
        PlrSquare.Filled = false

        PLAYER_ESP_OBJECTS[Player] = {Square = PlrSquare, PlayerPart = PlrPart}
      end
end


local function PLAYER_ESP()
    for _, player_instance in pairs(Players:GetPlayers()) do
        if player_instance ~= LocalPlayer and VALIDATE_OBJECT(player_instance.Character) then
            CREATE_SQUARE_FOR_PLAYER(player_instance)
        end
    end

    Players.PlayerAdded:Connect(function(AddedPlr)
        if VALIDATE_OBJECT(AddedPlr.Character) then
            CREATE_SQUARE_FOR_PLAYER(AddedPlr)
        end
    end) 


    RunService.RenderStepped:Connect(function()
        for player, info in pairs(PLAYER_ESP_OBJECTS) do
            if VALIDATE_OBJECT(info.PlayerPart) and RETURN_V2_POINT(info.PlayerPart) then
                local ESP_Part = info.PlayerPart
                local InstanceToV2Value = RETURN_V2_POINT(ESP_Part)
                
                info.Square.Visible = true
                info.Square.Position = Vector2.new(InstanceToV2Value.X, InstanceToV2Value.Y / 2)
            else
                info.Square.Visible = false
            end
        end
        if ESPFeatures.Player ~= true then 
            cyn.ESP_Loop:Disconnect()
        end
    end)
end

print("pre-test")


AutomaticFeatures.AutoM1 = true
AutomaticFeatures.AreaQuest = true

AREA_QUESTS()

print("post-test")

