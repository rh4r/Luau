-- // Credits & Description \\ -- 
--[[
    Description: 
        This is a private script for Jujutsu Infinite.
    Credits: 
        rh4r / oni - functionality
        library: https://brady-xyz.gitbook.io/maclib-ui-library
    Game Link:
        https://www.roblox.com/games/10450270085/Jujutsu-Infinite
    Last Update:
        7th Febuary @ nihil
    To-Do:
        ESP:
            + NPC ESP
            + Player ESP
            + Dropped item ESP
            + Cursed spirit ESP
        Autos:
            + Auto Use Skills (DONE)
            + Auto Farm Daily
            + Auto Collect Chests (DONE)
            + Auto Farm Calamity
            + Auto Collect Tailsmen (DONE)
            + Auto area quests (DONE)
            + Auto Kill Aura (DONE)
            + Auto story quests (ON-HOLD)
            + Auto perfect parry
            + Automatic boss farm
            + Automatic investigation farm (IN-PROGRESS)
            + Always hit blackflash (DONE)
            + Auto use items (DONE)
            + Auto collect items
            + Auto Sell items
        Misc Features:
            + Redeem all codes (DONE)
            + Build saving + loading
            + Server hop for dropped items
            + Cursed & Cash market displays (DONE)
            + Roll selected innate
            + Teleport to town
            + Teleport to portal
]]--

-- // User Configuration \\ -- 
local cyn = getgenv()

cyn.Configuration = {
    ["AutomaticFeatures"] = {
        ["UseSkill"] = false,
        ["AutoM1"] = false,
        ["CollectChest"] = false,
        ["EnableKillAura"] = false,
        ["Tailsmen"] = false,
        ["AreaQuest"] = false,
        ["StoryQuest"] = false,
        ["PerfectParry"] = false,
        ["BossFarm"] = false,
        ["InvestigationFarm"] = false,
        ["AlwaysHitFocusNeedle"] = false,
        ["AutoBlackFlash"] = false,
    },
    ["MiscFeatures"] = {
        ["UseExpAndMasBuff"] = false,
        ["ConsumeItem"] = false
    },
    ["ESPFeatures"] = {
        ["Player"] = false,
        ["BetterGourd"] = false
    },
    ["BoolConfigNumbers"] = {
        ["KillAuraRadius"] = 100,
        ["KillAuraColor"] = Color3.fromRGB(147, 1, 0),
    },
    ["ScriptNotifiers"] = {
        ["InCombat"] = false,
        ["InInvestigation"] = false
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
local BoolsForConfig = cyn.Configuration.BoolConfigNumbers
local ScriptNotifiers = cyn.Configuration.ScriptNotifiers

local floor = math.floor
local random = math.random
local foreach = table.foreach
local insert = table.insert
local sub = string.sub
local split = string.split
local len = string.len
local sfind = string.find
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
local Players = Services.Players
local RunService = Services.RunService
local ReplicatedFirst = Services.ReplicatedFirst
local ReplicatedStorage = Services.ReplicatedStorage

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

-- // UI Functionality Variables \\ -- 
local SelectedArea = nil
local SelectedItems = {}
local SelectedSpecificItem = nil
local SelectedInterval = nil

 -- // Functions & Remote Events \\ -- 
local Objects = workspace.Objects
local MobPath = Objects.Mobs

local ControlsTable = ReplicatedFirst.Dependencies.Controls

local ServerEvents = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Server")

local DataEvent = ServerEvents:WaitForChild("Data")
local Combat = ServerEvents:WaitForChild("Combat")

local Skydive = Combat:WaitForChild("Skydive")
local M1 = Combat:WaitForChild("M1")
local M2 = Combat:WaitForChild("M2")
local Skill = Combat:WaitForChild("Skill")
local ApplyBlackFlashToNextHitbox = Combat:WaitForChild("ApplyBlackFlashToNextHitbox")

local RedeemFunc = DataEvent:WaitForChild("RedeemCode")
local EquipItem = DataEvent:WaitForChild("EquipItem")
local ClaimFunc = DataEvent:WaitForChild("ClaimQuest")
local RerollMissions = DataEvent:WaitForChild("RerollMissions")

local ReplicatedTempData = LocalPlayer:WaitForChild("ReplicatedTempData")
local inventory = LocalPlayer.ReplicatedData.inventory
local techniques = LocalPlayer.ReplicatedData.techniques

local GetResponse = ServerEvents:WaitForChild("Dialogue"):WaitForChild("GetResponse")


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
        "WINTER_END",
        "1M_LIKES",
        "96_PERCENT",
        "2M_FAVS"
    }
    local redeem_remote = cloneref(RedeemFunc)

    for _, code in pairs(code_list) do
        CodeButton.Text = code
        task.wait(0.5)

        redeem_remote:InvokeServer(code)
        warn(
            "Redeemed code: ", code
        )
        task.wait(3)
    end
    return
end

local function COLLECT_ALL_TAILSMEN()
    while AutomaticFeatures.Tailsmen and task.wait() do
        local TailsmenLocation = Objects.Drops

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
    TELEPORT(Objects.Portals.Missions)
    task.wait(2)

    local PriorityQueue = {
        ["Exorcise"] = 1,
        ["Defeat"] = 2,
        ["Defeat a band"] = 2,
        ["Capture"] = 99
    }

    local CurrentQuests = {}
    local HighestPrio = 999

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
        local QuestText = quest_value[1]; warn("Quest Text: ", QuestText)
        local QuestPrio = PriorityQueue[QuestText]; warn("Quest Priority: ", QuestPrio)

        if QuestPrio <= HighestPrio and quest_value[2]:FindFirstChild("Info") and not sfind(quest_value[1], "Capture") then
            ChosenQuest = quest_value[2]; warn("Chosen Quest: ", ChosenQuest)
            HighestPrio = QuestPrio; warn("New Highest Priority: ", HighestPrio)
        end
    end

    if ChosenQuest == nil then
        print("L capture blud rerolling...")

        table.clear(CurrentQuests)

        RerollMissions:InvokeServer(SelectedArea)
        task.wait(3)

        RETURN_HIGHEST_QUEST_PRIORITY()
    else
        print("Suitable Quest!")

        return ChosenQuest
    end
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
        ScriptNotifiers.InCombat = true

        if not string.find(MobObject.Name, "Curse") then
            TELEPORT_WITH_OFFSET(PrimaryPart, 0, 3, 2)    
        else
            TELEPORT_WITH_OFFSET(PrimaryPart, 0, 0, 2)
        end
    end
end

local function CLAIM_AREA_QUEST(CurrentArea: string)
    local PlayerMissions = ReplicatedStorage:WaitForChild("Missions"):WaitForChild(LocalPlayer.Name)

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

local function ONLY_CLOSE_MOBS(distance_to_check: number)
    local ClosestDist = distance_to_check or 1000
    local LocalRoot = ReturnLocalRoot()
    local MobsInRange = {}
    local BlacklistedMobs = {"Egg Jaw"}

    for close_index, close_instance in pairs(MobPath:GetChildren()) do
        if close_instance and close_instance.PrimaryPart and not find(BlacklistedMobs, close_instance.Name) then
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
        if not AutomaticFeatures.AreaQuest then break end
        CLAIM_AREA_QUEST(SelectedArea)
        task.wait(0.5)

        SKYDIVE()

        local MobsToAttack = ONLY_CLOSE_MOBS()

        for index, enemy_npc in pairs(MobsToAttack) do
            while AutomaticFeatures.AreaQuest and MOB_HAS_HEALTH_OBJECT(enemy_npc) do
                if not AutomaticFeatures.AreaQuest then break end

                task.spawn(function()
                    TRAIL_MOB(enemy_npc)
                end)

                AUTO_M1()
                task.wait(0.3)
            end 
        end
        ScriptNotifiers.InCombat = false
    end
end

local function KILL_AURA()
    local KillAuraRadius = cyn.Configuration.BoolConfigNumbers.KillAuraRadius
    local KillAuraPart = Instance.new("Part", workspace)
    KillAuraPart.Transparency = 0.8
    KillAuraPart.CanCollide = false
    KillAuraPart.Material = Enum.Material.Neon
    KillAuraPart.Size = Vector3.new(KillAuraRadius, 0.1, KillAuraRadius)

    print("PART CREATED AT: ", KillAuraPart:GetFullName())

    while AutomaticFeatures.EnableKillAura and task.wait() do 
        local CloseMobs = ONLY_CLOSE_MOBS(KillAuraRadius)
        local LocalRoot = ReturnLocalRoot()
        local NewPos = Vector3.new(LocalRoot.Position.X, LocalRoot.Position.Y - 2.5, LocalRoot.Position.Z)
        KillAuraPart.Position = NewPos
        KillAuraPart.Color = BoolsForConfig.KillAuraColor

        for _, MobInstance in pairs(CloseMobs) do
            while MOB_HAS_HEALTH_OBJECT(MobInstance) do
                ScriptNotifiers.InCombat = true

                TRAIL_MOB(MobInstance)
                AUTO_M1()
                task.wait(0.3) 
            end
        end 
        ScriptNotifiers.InCombat = false
    end
end

local function RETURN_STORYLINE_NPC()
    local NPC_Folder = Objects.NPCs:GetDescendants()
    local StorylineNPCRoot = PlayerGui.StorylineMarker.Adornee:GetFullName()

    for _, ChildName in pairs(NPC_Folder) do
        if ChildName:IsA("Part") and ChildName:GetFullName() == StorylineNPCRoot then
            return ChildName:FindFirstAncestorOfClass("Model")
        end
    end
end

local function RETURN_STORYLINE_ARGS()
    local FoundValues = nil

    for i, CurrentTable in pairs(getgc(true)) do
        if type(CurrentTable) == "table" and #CurrentTable > 1 then
            for i, CurrentValue in CurrentTable do
                if type(CurrentValue) == "string" and string.find(CurrentValue, "Accept/NS_") then
                    FoundValues = CurrentValue
                end
            end
        end
    end

    return FoundValues
end

local function AUTO_STORYLINE()
    --[[
local args = {
	"Clan Head",
	"Accept/NS_Q1_BanditOutpost_Start"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Server"):WaitForChild("Dialogue"):WaitForChild("GetResponse"):InvokeServer(unpack(args))

    ]]

    local AcceptableResponse = RETURN_STORYLINE_ARGS()
    local CurrentStoryNpc = RETURN_STORYLINE_NPC()
    local Primary = CurrentStoryNpc.PrimaryPart
    local DialogueInteract = CurrentStoryNpc.DialogueInteract

    TELEPORT(Primary)
    task.wait(1)

    fireproximityprompt(DialogueInteract)
    task.wait(2)

    warn(AcceptableResponse)

    local SendingArgs = {
        "Clan Head",
        AcceptableResponse
    }

    GetResponse:InvokeServer(unpack(SendingArgs)) 
    print("Attempted arg: ", AcceptableResponse)
    task.wait(0.5)
    
    task.spawn(function()
        for i, ProxPrompt in pairs(workspace.Objects.MissionItems:GetDescendants()) do
            if ProxPrompt:IsA("ProximityPrompt") then
                TELEPORT(ProxPrompt.Parent)
                task.wait(0.25)
                fireproximityprompt(ProxPrompt)
            end
        end
    end)
end

local function CLOSE_COLLECT_MENU()
    local v_u_18 = require(game:GetService("ReplicatedStorage").Dependencies.Global)

    PlayerGui.Loot.Results.Visible = true
    PlayerGui.Loot.Results.Visible = false

    v_u_18.tweenWait(PlayerGui.Loot.Results, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        ["Size"] = UDim2.new(0, 0, 0, 0)
    })
    v_u_18.clearJunk(PlayerGui.Loot.Results.Main.ScrollingFrame)

    PlayerGui.Loot.Enabled = false
    PlayerGui.Main.Enabled = true

    v_u_18.fx(PlayerGui.UI.Unlock)
    warn("Closed Collect Menu!")
end


local function COLLECT_CHESTS()
    while AutomaticFeatures.CollectChest and task.wait() do
        for _, ChestFound in pairs(Objects.Drops:GetDescendants()) do
            if ChestFound:IsA("ProximityPrompt") and ChestFound:FindFirstAncestorOfClass("Model").Name == "Chest" then
                task.spawn(function()
                    fireproximityprompt(ChestFound)
                    task.wait(2)
                    CLOSE_COLLECT_MENU()
                end)
            end
        end
    end
end

local function REFRESH_SELECTED_ITEMS()
    for i, ChildItem in pairs(inventory:GetChildren()) do
        insert(SelectedItems, ChildItem.Name)
    end
end

local function USE_SELECTED_ITEM(item_to_use: string)
    EquipItem:InvokeServer(item_to_use)
end

local function AUTO_DO_EXP_AND_MAS_BUFF()
    while MiscFeatures.UseExpAndMasBuff do
        for i = 1,3 do 
            USE_SELECTED_ITEM("Takoyaki")
            print("done one")
            task.wait(0.25)
            USE_SELECTED_ITEM("Dorayaki")
            print("done two")
        end 
        task.wait(600)
    end
end

local function DO_BETTER_AUTO_GOURD()
    while MiscFeatures.BetterGourd do
        local Gourds = {
            "Focus Gourd",
            "Damage Gourd",
            "Agility Vial"
        }

        for i, gourd in pairs(Gourds) do
            USE_SELECTED_ITEM(gourd)
        end
        task.wait(120)
    end
end

local function AUTO_BLACKFLASH()
    while AutomaticFeatures.AutoBlackFlash do
        if not AutomaticFeatures.AutoBlackFlash then break end
        if ScriptNotifiers.InCombat then
            task.spawn(function()
                ApplyBlackFlashToNextHitbox:FireServer(3)
                M2:FireServer(2)
            end)
            task.wait(0.4)
        else
            task.wait(0.05)
        end
    end
end

local function DO_ALL_SKILLS()
    while AutomaticFeatures.UseSkill do
        local SkillNames = {}

        for i, technique in pairs(techniques.innates:GetChildren()) do
            insert(SkillNames, technique.Value)    
        end
        for i, innate_skill in pairs(SkillNames) do
            task.spawn(function()
                Skill:FireServer(innate_skill)
            end)
            task.wait(0.25) 
        end 
        task.wait(3)
    end
end

local function COLLECT_CURSED_ITEMS()
    local MissionItems = Objects.MissionItems

    for i, CursedObject in pairs(MissionItems:GetChildren()) do
        if CursedObject.Name ~= "Civillian" then
            TELEPORT(CursedObject)
            task.wait(0.25)
            fireproximityprompt(CursedObject.Collect)
            task.wait() 
        end
    end
end

local function KILL_INVES_BOSS()
    local Mobs = Objects.Mobs
    local FoundBoss = false

    for a, MobObj in pairs(Mobs:GetChildren()) do
        if not sfind(MobObj.Name, "Curse") then
            FoundBoss = true
            while MOB_HAS_HEALTH_OBJECT(MobObj) do
                TRAIL_MOB(MobObj) 
                AUTO_M1()
                task.wait(0.3)
            end
        end
    end 

    if not FoundBoss then
        for a, CurseMobObj in pairs(Mobs:GetChildren()) do
            while MOB_HAS_HEALTH_OBJECT(CurseMobObj) do
                TRAIL_MOB(CurseMobObj) 
                AUTO_M1()
                task.wait(0.3)
            end
        end
    end
    task.wait()
end

local function RESCUE_NPCS()
    local MissionItems = Objects.MissionItems
    local GateLocations = {
        ["Inves1"] = CFrame.new(-4368, -331, 3573)
    }
    local CurrentInvestigation = "Inves1"
    local LocalRoot = ReturnLocalRoot()

    for i, CivillianToCarry in pairs (MissionItems:GetChildren()) do
        if CivillianToCarry.Name == "Civillian" then
            TELEPORT(CivillianToCarry)
            task.wait(0.25)
            fireproximityprompt(CivillianToCarry.Pickup)
            task.wait(0.1)
            LocalRoot.CFrame = GateLocations[CurrentInvestigation]
            task.wait(0.1)
        end
    end
end

local function GOTO_INVESTIGATIONS()
    return
end

local function AUTO_INVESTIGATION()
    while AutomaticFeatures.InvestigationFarm do
        if #Objects.MissionItems:GetChildren() > 0 then
            COLLECT_CURSED_ITEMS()
        end
        if #Objects.Mobs:GetChildren() > 0 then
            KILL_INVES_BOSS()
        end 
        if Objects.MissionItems:FindFirstChild("Civillian") then
            RESCUE_NPCS()
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
 



-- // User Interface \\ -- 

local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
    Title = "Followers Of Rher",
    Subtitle = "Developed by | rh4r / oni",
    Size = UDim2.fromOffset(868, 650),
    DragStyle = 1,
    DisabledWindowControls = {},
    ShowUserInfo = true,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
})

local TabGroup = Window:TabGroup()

local AutoTab = TabGroup:Tab({
  Name = "Main Functions",
})

local MoreMain = TabGroup:Tab({
  Name = "More Main Functions",
})

local ESPTab = TabGroup:Tab({
  Name = "ESP Functions",
})

local MiscTab = TabGroup:Tab({
  Name = "Misc Functions",
})


-- // Automatic Features In UI \\ -- 

local MainTab = AutoTab:Section({
  Side = "Left"
})

MainTab:Header({
  Text = "Auto Complete Quests In Selected Area"
})

MainTab:Dropdown({
	Name = "Chosen Location",
	Search = true,
	Multi = false,
	Required = false,
	Options = {"Shijo Town Set", "Umi Village Set", "Numa Temple Set", "Kura Camp Set", "Yuki Fortress Set"},
	Default = {"Shijo Town Set"},
	Callback = function(Value)
        SelectedArea = Value
	end,
})


MainTab:Toggle({
	Name = "Complete Quests In Area",
	Default = false,
	Callback = function(value)
        cyn.Configuration.AutomaticFeatures.AutoM1 = value
        cyn.Configuration.AutomaticFeatures.AreaQuest = value

        AREA_QUESTS()
	end,
})

local BossTab = AutoTab:Section({
  Side = "Right"
})

BossTab:Header({
  Text = "Auto Boss"
})

BossTab:Dropdown({
	Name = "Chosen Boss",
	Search = true,
	Multi = false,
	Required = false,
	Options = {"nil"},
	Default = {"nil"},
	Callback = function(Value)
        SelectedArea = Value
	end,
})

BossTab:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        return
	end,
})

local KillAura = AutoTab:Section({
  Side = "Right"
})

KillAura:Header({
  Text = "Auto Kill Aura"
})

KillAura:Slider({
	Name = "Distance",
	Default = 100,
	Minimum = 0,
	Maximum = 1000,
	DisplayMethod = "Round",
	Callback = function(Value)
		BoolsForConfig.KillAuraRadius = Value
	end,
})

KillAura:Colorpicker({
	Name = "Display Color",
	Default = Color3.fromRGB(147, 1, 0),
	Alpha = 0,
	Callback = function(color, alpha)
		local r, g, b = math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255)

		BoolsForConfig.KillAuraColor = Color3.fromRGB(r,g,b)
        print(BoolsForConfig.KillAuraColor)
	end,
})

KillAura:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        cyn.Configuration.AutomaticFeatures.EnableKillAura = value

        KILL_AURA()
	end,
})

local InvestigationTab = AutoTab:Section({
  Side = "Left"
})

InvestigationTab:Header({
  Text = "Auto Investigation Farm"
})

InvestigationTab:Dropdown({
	Name = "Chosen Investigation",
	Search = true,
	Multi = false,
	Required = false,
	Options = {"nil"},
	Default = {"nil"},
	Callback = function(Value)
        SelectedArea = Value
	end,
})

InvestigationTab:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        AutomaticFeatures.InvestigationFarm = value

        AUTO_INVESTIGATION()
	end,
})

local ChestCollectTab = AutoTab:Section({
  Side = "Right"
})

ChestCollectTab:Header({
  Text = "Auto Collect Chests"
})

ChestCollectTab:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        cyn.Configuration.AutomaticFeatures.CollectChest = value

        COLLECT_CHESTS()
	end,
})


local TailsmenTab = AutoTab:Section({
  Side = "Left"
})

TailsmenTab:Header({
  Text = "Auto Collect Tailsmen"
})

TailsmenTab:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        cyn.Configuration.AutomaticFeatures.Tailsmen = value

        COLLECT_ALL_TAILSMEN()
	end,
})


local StoryTab = AutoTab:Section({
  Side = "Left"
})

StoryTab:Header({
  Text = "Auto Story Quest"
})

StoryTab:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        AUTO_STORYLINE()
	end,
})



-- // More Main \\ -- 

local UseSkill = MoreMain:Section({
  Side = "Left"
})

UseSkill:Header({
  Text = "Auto Use Skills"
})

UseSkill:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        AutomaticFeatures.UseSkill = value

        DO_ALL_SKILLS()
	end,
})

local DoM1 = MoreMain:Section({
  Side = "Right"
})

DoM1:Header({
  Text = "Auto M1"
})

DoM1:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        cyn.Configuration.AutomaticFeatures.AutoM1 = value

        AUTO_M1()
	end,
})

local AlwaysBlackFlash = MoreMain:Section({
  Side = "Left"
})

AlwaysBlackFlash:Header({
  Text = "Auto Black Flash"
})

AlwaysBlackFlash:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        cyn.Configuration.AutomaticFeatures.AutoBlackFlash = value

        AUTO_BLACKFLASH()
	end,
})

AlwaysBlackFlash:Label({
  Text = "RISK LEVEL: Medium"
})


local PerfectTab = MoreMain:Section({
  Side = "Right"
})

PerfectTab:Header({
  Text = "Auto Perfect Parry"
})

PerfectTab:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        return
	end,
})

local AutoConsume = MoreMain:Section({
  Side = "Left"
})

AutoConsume:Header({
  Text = "Auto Consume Items"
})

REFRESH_SELECTED_ITEMS()
AutoConsume:Dropdown({
	Name = "Select Items",
	Search = true,
	Multi = true,
	Required = false,
	Options = SelectedItems,
	Default = {""},
	Callback = function(Value)
        SelectedSpecificItem = SelectedItems[Value]
	end,
})

AutoConsume:Input({
	Name = "Interval Per Use (Seconds)",
	Placeholder = "60",
	AcceptedCharacters = "All",
	Callback = function(input)
        SelectedInterval = tonumber(input)
	end,
})

AutoConsume:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        MiscFeatures.ConsumeItem = value

        while MiscFeatures.ConsumeItem do
            USE_SELECTED_ITEM(SelectedSpecificItem)
            task.wait(SelectedInterval)
        end
	end,
})


local AutoMasAndExp = MoreMain:Section({
  Side = "Right"
})

AutoMasAndExp:Header({
  Text = "Auto Consume Master + EXP Buff"
})


AutoMasAndExp:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        MiscFeatures.UseExpAndMasBuff = value

        AUTO_DO_EXP_AND_MAS_BUFF()
	end,
})

local BetterAutoBuff = MoreMain:Section({
  Side = "Left"
})

BetterAutoBuff:Header({
  Text = "Better Auto Buff (Game one is buggy)"
})


BetterAutoBuff:Toggle({
	Name = "Enable",
	Default = false,
	Callback = function(value)
        MiscFeatures.BetterGourd = value

        DO_BETTER_AUTO_GOURD()
	end,
})


-- // ESP UI Functions \\ -- 

local MainTab = ESPTab:Section({
  Side = "Left"
})

MainTab:Header({
  Text = "NPC ESP"
})

MainTab:Button({
	Name = "Enable",
	Callback = function()
		return
	end,
})



-- // Misc UI Functions \\ -- 

local MainTab = MiscTab:Section({
  Side = "Left"
})

MainTab:Header({
  Text = "Auto Redeem All Codes"
})

MainTab:Button({
	Name = "Enable",
	Callback = function()
		REDEEM_CODES()
	end,
})

local DisplayTabs = MiscTab:Section({
  Side = "Right"
})

DisplayTabs:Header({
  Text = "Display Cursed Market"
})


DisplayTabs:Button({
	Name = "Refresh",
	Callback = function()
		fireproximityprompt(Objects.NPCs["Curse Market"].DialogueInteract)
	end,
})

local CashMarket = MiscTab:Section({
  Side = "Right"
})

CashMarket:Header({
  Text = "Display Cash Market"
})

CashMarket:Button({
	Name = "Refresh",
	Callback = function()
		fireproximityprompt(Objects.NPCs["Cash Market"].DialogueInteract)
	end,
})

local RefreshGlobals = MiscTab:Section({
  Side = "Left"
})

RefreshGlobals:Header({
  Text = "Refresh All Script Toggles (FIX)"
})

RefreshGlobals:Button({
	Name = "Refresh",
	Callback = function()
		foreach(cyn.Configuration, function(t,_)
            if type(t) == "table" then
                foreach(t, function(k,v)
                    if type(v) == "boolean" then
                        v = false
                    end
                end)
            end
        end)
	end,
})
