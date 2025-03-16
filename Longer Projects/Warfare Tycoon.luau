for i = 1,100 do print('\n') end

-- Startup Begin --
local env = getgenv() or _G or getfenv(script)
local cloneref = env.cloneref or cloneref or function (obj) return obj end

env.Configs = {
    ["DeeperConfigs"] = {
        ["FirstArgumentRun"] = false,
        ["IsCapturingPoint"] = false,
    },

    ["AutoButtons"] = false,
    ["ChosenWeapon"] = nil,
    ["ChosenArgument"] = nil,
    ["SelectedVeichle"] = nil,
    ["ButtonWaitTimer"] = nil,
    ["NewArgumentValue"] = nil,
    ["EnableKillAura"] = false,
    ["AutoCapturePoint"] = false,
    ["KillAuraRadius"] = nil or 50,
    ["ChooseCollectAirdrops"] = nil,
}

local Configs = env.Configs

local sort = table.sort
local find = table.find
local clear = table.clear
local split = string.split
local lower = string.lower
local smatch = string.match
local insert = table.insert

-- Enviroment Created -- 

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = cloneref(Players.LocalPlayer)

local RequestPrestigeEvent = ReplicatedStorage:WaitForChild("RequestPrestigeEvent")
local RequestGroundVehicleEvent = ReplicatedStorage:WaitForChild("RequestGroundVehicleEvent")
local RequestVehiclePurchaseEvent = ReplicatedStorage:WaitForChild("RequestVehiclePurchaseEvent")

local MyTycoon

local GunsTable = {}
local ModChoice = {}
local HardPoints = {}
local VeichleTable = {}
local WeaponsTable = {}

-- Variables Initialized -- 

function ReturnChar(plr)
    return plr.Character
end

function ReturnRoot(plr)
    local char = ReturnChar(plr)

    return char.HumanoidRootPart
end


function FindTycoon()
    for a,b in pairs(workspace:GetDescendants()) do 
        if b:IsA("IntValue") and b.Name == "OwnerId" and b.Value == LocalPlayer.UserId then
            MyTycoon = b:FindFirstAncestorOfClass("Model")
        end
    end
end

function FindCashButton()
    if not MyTycoon then FindTycoon() end
    for a,b in pairs(MyTycoon:GetDescendants()) do 
        if b:IsA("Part") and b.Name == "CashCollectButton" then
            return b
        end
    end
end

function FindCapturePoints()
    for a,b in pairs(workspace.Hardpoints:GetChildren()) do 
        insert(HardPoints, b.Name)
    end
end

function LoadWeaponsTable()
    for a,b in LocalPlayer.Backpack:GetChildren() do insert(WeaponsTable, a, b.Name) end
    sort(WeaponsTable)
end

function CheckDistance(p1, p2)
    if (p1 - p2).Magnitude <= Configs["KillAuraRadius"] then
        return true
    end
end

function RequestBuyVeichle(veichle)
    if find(VeichleTable, veichle) then
        RequestVehiclePurchaseEvent:FireServer(veichle)    
    end
end

function RequestSpawnVeichle(veichle)
    if find(VeichleTable, veichle) then
        RequestGroundVehicleEvent:FireServer(veichle)
    end
end

function GotoHome()
    if not MyTycoon then FindTycoon() end

    for a,b in pairs(MyTycoon:GetChildren()) do 
        if b:IsA("Part") and b.Name == "Spawn" then
            local Spawn = b
            local LocalRoot = ReturnRoot(LocalPlayer)

            if LocalRoot and Spawn then
                pcall(function()
                    LocalRoot.CFrame = Spawn.CFrame
                end)
            end
        end
    end
end

function LoadGunsTable()
    for a,b in LocalPlayer.Backpack:GetChildren() do 
        local name = b.Name

        if smatch(name, "Knife") then 
            return
        else
            insert(GunsTable, a, name)
        end
    end
    sort(GunsTable)
end

function BringVeichle(veichle)
    if not MyTycoon then FindTycoon() end
    for a,b in pairs(MyTycoon:GetDescendants()) do 
        if b.Name == veichle then
            local LocalRoot = ReturnRoot(LocalPlayer)
            local Humvee = b

            Humvee:SetPrimaryPartCFrame(LocalRoot.CFrame * CFrame.new(0, 0, -20)) -- Moves it in front of you
            break
        end
    end
end

function AppendArguments(weapon)
    if Configs["DeeperConfigs"]["FirstArgumentRun"] then clear(ModChoice) end

    local Settings = require(cloneref(weapon:WaitForChild("ACS_Settings")))

    for a,b in Settings do 
        if type(b) ~= "table" and string.len(a) > 1 then 
            insert(ModChoice, a .. " (Default Value: " .. tostring(b)..")")
        end
    end
    sort(ModChoice)
end

function ModifyArgument(weapon, argument, newvalue)
    local Settings = require(cloneref(weapon:WaitForChild("ACS_Settings")))

    for Index, Value in Settings do 
        if Index == argument then
            rawset(Settings, Index, newvalue)
        end
    end
end

function FindWeapon(weaponame)
    local HasFoundWeapon = nil

    for _, weapon in pairs(LocalPlayer.Backpack:GetChildren()) do 
        if weapon.Name == weaponame then
            HasFoundWeapon = weapon
        end
    end

    if HasFoundWeapon == nil then
        for _, child in pairs(ReturnChar(LocalPlayer):GetChildren()) do 
            if child:IsA("Tool") and child.Name == weaponame then
                HasFoundWeapon = child
            end
        end
    end

    if HasFoundWeapon then return HasFoundWeapon else return error("FAILED TO FIND WEAPON.") end
end

function CallPrestige()
    return
end

function UpdateVeichleList()
    local FirstTable
    local SecondTable

    for a,b in pairs(getgc(true)) do 
        if type(b) == "table" and rawlen(b) > 0 then
            if type(b[1]) == "string" and b[1] == "ATV" then
                FirstTable = b

            elseif type(b[1]) == "string" and b[1] == "MH-6 Little Bird" then
                SecondTable = b
            end
        end
    end
    for _, veichle in SecondTable do
        insert(FirstTable, veichle)
    end

    VeichleTable = FirstTable
end

function ReturnMeleeAttack()
    local LocalChar = ReturnChar(LocalPlayer)
    local Framework = getsenv(LocalChar.ACS_Client.ACS_Framework)

    local meleeCast
    local meleeAttack

    for a,b in Framework do 
        if type(b) == "function" then
             if a == "meleeAttack" then
                meleeAttack = b
             elseif a == "meleeCast" then
                meleeCast = b
             end
        end
    end
    if meleeAttack then
         return meleeAttack, meleeCast
    else 
        error("FAILED TO FIND MELEE ATTACK FUNCTION.")
     end
end

function CollectAirdrops()
    while Configs["ChooseCollectAirdrops"] do
        task.wait(10)

        for a,b in pairs(workspace.Airdrops:GetChildren()) do 
            if b then 
                local LocalRoot = ReturnChar(LocalPlayer)

                LocalRoot.CFrame = b.PrimaryPart
            end
        end

        workspace.Airdrops.ChildAdded:Connect(function(child)
            if child:IsA("Model") then 
                local LocalRoot = ReturnChar(LocalPlayer)

                LocalRoot.CFrame = child.PrimaryPart
            end
        end)
    end
end

function GotoSpecificPoint(chosen_point)
    local Team = LocalPlayer.Team

    chosen_point = workspace.Hardpoints:FindFirstChild(chosen_point)

    for a,b in pairs(chosen_point:GetDescendants()) do 
        if b:IsA("Part") and b.Name == "ColorPart" then
            local CyberiaLayer1 = tostring(b.BrickColor)
            local CyberiaLayer2 = split(CyberiaLayer1, " ")[2]
            Team = tostring(Team)

            local LocalRoot = ReturnRoot(LocalPlayer)
            local HitBox = b.Parent.Parent:FindFirstChild("TouchPart")

            LocalRoot.CFrame = HitBox.CFrame
        end
    end
end

function CapturePoints()
    while Configs["AutoCapturePoint"] do 
        local Team = LocalPlayer.Team
        local OldPOS = ReturnRoot(LocalPlayer).CFrame

        for a,b in pairs(workspace.Hardpoints:GetDescendants()) do 
            if not Configs["AutoCapturePoint"] then break end
            if Configs["DeeperConfigs"]["IsCapturingPoint"] then break end

            if b:IsA("Part") and b.Name == "ColorPart" then
                local CyberiaLayer1 = tostring(b.BrickColor)
                local CyberiaLayer2 = split(CyberiaLayer1, " ")[2]

                local LocalRoot = ReturnRoot(LocalPlayer)
                local HitBox = b.Parent.Parent:FindFirstChild("TouchPart")

                Team = tostring(Team)

                if Team == "Mercenaries" and lower(CyberiaLayer2) == "blue" then
                    Configs["DeeperConfigs"]["IsCapturingPoint"] = true

                    while LocalRoot and b.BrickColor == BrickColor.new("Really blue") and Configs["AutoCapturePoint"] do 
                        LocalRoot.CFrame = HitBox.CFrame
                        task.wait()
                    end
                elseif Team == "Task Force" and lower(CyberiaLayer2) == "red" then
                    Configs["DeeperConfigs"]["IsCapturingPoint"] = true

                    while LocalRoot and b.BrickColor == BrickColor.new("Really red") and Configs["AutoCapturePoint"] do
                        LocalRoot.CFrame = HitBox.CFrame
                        task.wait()
                    end
                elseif LocalRoot and b.BrickColor == BrickColor.new("Institutional white") then
                    while LocalRoot and b.BrickColor == BrickColor.new("Institutional white") and Configs["AutoCapturePoint"] do
                        LocalRoot.CFrame = HitBox.CFrame
                        task.wait()    
                    end
                end                    
                Configs["DeeperConfigs"]["IsCapturingPoint"] = false
            end
        end

        ReturnRoot(LocalPlayer).CFrame = CFrame.new(OldPOS)
        task.wait()
    end
end

function BuyButtons()
    while Configs["AutoButtons"] do 
        local CashButton = FindCashButton()
        local LocalRoot = ReturnRoot(LocalPlayer)

        if LocalRoot then LocalRoot.CFrame = CashButton.CFrame task.wait(3) end
        local Buttons = {}
        local ButtonCFrames = {}
        
        for a,b in pairs(MyTycoon["BuyButtons"]:GetDescendants()) do
            print("BEGININNG BUY!")

            if not Configs["AutoButtons"] then break end
            if b:IsA("TextLabel") and b.Name == "Cost" then
                local Parent = b.Parent.Parent
                local TextToNumber = string.gsub(b.Text, "$$", "")
                local LayerTwo = string.gsub(TextToNumber, ",", "")
                local LayerToNumber = tonumber(LayerTwo)

                Buttons[Parent.Parent.Name] = LayerToNumber
                ButtonCFrames[Parent.Parent.Name] = Parent.CFrame
            end
        end
        sort(Buttons)
        print("TABLE FOUND AND SORTED!")

        for name, price in Buttons do 
            if not Configs["AutoButtons"] then break end
            print("GOING THRU BUTTONS!")
            local CashRoot = ReturnRoot(LocalPlayer)
            local Cash = LocalPlayer.leaderstats.Money.Value

            if Cash >= price then 
                print("FOUND ELIGIBLE BUTTON!")
                CashRoot.CFrame = ButtonCFrames[name]

                task.wait(1)
            end
        end
        task.wait(Configs["ButtonWaitTimer"])
    end
end

--[[
function ModWeapon(weaponame)
    EquipWeapon(weaponame)

    local LocalChar = ReturnChar(LocalPlayer)
    local Settings = require(LocalChar.weaponame.ACS_Settings)

    rawset(Settings, "Ammo", math.huge)
    rawset(Settings, "StoredAmmo", math.huge)

    rawset(Settings, "ShootRate", math.huge)

    rawset(Settings["FireModes"], "Auto", true)

    rawset(Settings, "MinSpead", 0)
    rawset(Settings, "MaxSpread", 0)

    rawset(Settings, "BulletDrop", 0)
    rawset(Settings, "RainbowMode", true)

    for a,b in Settings do 
        if type(a) == "string" and smatch(a, "Recoil") then
            rawset(Settings, b, 0)
        elseif type(b) == "table" then
            for c,d in b do 
                if type(d) == "table" then
                    for e,f in d do 
                        if smatch(e, "Recoil") then
                            rawset(Settings, b, 0)
                        end
                    end
                end
            end
        end
    end
end
]]--

function KnifeAura()
    while Configs["EnableKillAura"] do
        pcall(function()
            local Knife = FindWeapon("Knife")

            if Knife then
                if Knife.Parent ~= ReturnChar(LocalPlayer) then Knife.Parent = ReturnChar(LocalPlayer) end
                local AttackFunction, AttackCast = ReturnMeleeAttack()

                for a,b in pairs(Players:GetPlayers()) do
                    if b ~= LocalPlayer and b.Team ~= LocalPlayer.Team and Configs["EnableKillAura"] then 
                        local PlayerChar = ReturnChar(b) 
                        local PlayerRoot = ReturnRoot(b)
        
                        local LocalChar = ReturnChar(LocalPlayer)
                        local LocalRoot = ReturnRoot(LocalPlayer)
        
                        if PlayerRoot and LocalRoot and CheckDistance(PlayerRoot.Position, LocalRoot.Position) and Configs["EnableKillAura"] then
                            while PlayerRoot and PlayerChar.Humanoid.Health > 0 and LocalRoot and LocalChar.Humanoid.Health > 0 and Configs["EnableKillAura"] do
                                pcall(function()
                                    local CorrectedCFrame = PlayerRoot.CFrame.Position - (PlayerRoot.CFrame.LookVector * 0.1)
                                
                                    LocalRoot.CFrame = CFrame.new(CorrectedCFrame) * CFrame.Angles(0, math.rad(180), 0)          
                                    AttackCast()                 
                                    AttackFunction()
                                    task.wait(0000000000000000000000000000000000000000000000000.1)
                                end)
                            end
                        end
                    end
                end
            end      
        end)
        task.wait()
    end
end

pcall(task.spawn(function() LoadGunsTable() LoadWeaponsTable() UpdateVeichleList() FindCapturePoints() ReturnChar(LocalPlayer).Humanoid.Health = 0 end))

-- Functions Created --     

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

if not workspace:FindFirstChild("SulfurSounds") then 
    local SoundFolder = Instance.new("Folder", workspace)
    SoundFolder.Name = "SulfurSounds"
end

if not workspace:WaitForChild("SulfurSounds"):FindFirstChildOfClass("Sound") then 
    local Sound = Instance.new("Sound")
    Sound.Name = tostring(math.random(-9e9, 9e9)) .. "PNG !{} JPEG"
    Sound.Parent = workspace:FindFirstChild("SulfurSounds")
    Sound.Volume = 100
    Sound.SoundId = "rbxassetid://130780676" 
    Sound:Play()
else
    local Sound = workspace:WaitForChild("SulfurSounds"):FindFirstChildOfClass("Sound")
    Sound:Play()
end

local RayfieldThemes = {"Default","Amber Glow","Amethyst","Bloom","Dark Blue","Green","Light","Ocean","Serenity"}; sort(RayfieldThemes)

local Window = Rayfield:CreateWindow({
    Name = "Sulfur Pits",
    Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
    LoadingTitle = "Loading Sulfur Suite",
    LoadingSubtitle = "by Sulfu3r",
    Theme = "Ocean", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
 
    Discord = {
       Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })

 local Tab = Window:CreateTab("Main Features", 4483362458) -- Title, Image
 local GunTab = Window:CreateTab("Gun Features", 4483362458) -- Title, Image
 local Veichle = Window:CreateTab("Veichle Features", 4483362458) -- Title, Image
 local MiscFeatures = Window:CreateTab("Misc Features", 4483362458) -- Title, Image

 local MiscSection = MiscFeatures:CreateSection("Rayfield Settings")

 local Dropdown = MiscFeatures:CreateDropdown({
	Name = "Select Theme",
	Options = RayfieldThemes,
	CurrentOption = RayfieldThemes["Ocean"],
	MultipleOptions = false,
	Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
		local Choice = unpack(Option)
		local TrySub = string.gsub(Choice, " ", "")

		Window.ModifyTheme(TrySub)
	end,
 })

 local Button = MiscFeatures:CreateButton({
	Name = "Destroy GUI",
	Callback = function()
        clear(env.Configs)

		Rayfield:Destroy()
	end,
 })

 local Section = MiscFeatures:CreateSection("Script Fixes")

 local Button = MiscFeatures:CreateButton({
	Name = "Go To Tycoon",
	Callback = function()
        GotoHome()
	end,
 })


 local Button = MiscFeatures:CreateButton({
	Name = "Reset Character",
	Callback = function()
        ReturnChar(LocalPlayer).Humanoid.Health = 0
	end,
 })

 local Button = MiscFeatures:CreateButton({
	Name = "Re-execute Script",
	Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/sulfu3r/Newer-Pentest-Projects/refs/heads/main/Useable%20Projects/Warfare%20Tycoon.luau'))()
	end,
 })

 local Section = Tab:CreateSection("Buttons")

 local Toggle = Tab:CreateToggle({
	Name = "Enable Auto Buy Buttons",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(Value)
		Configs["AutoButtons"] = Value
		task.wait()

		BuyButtons()
        print'called'
	end,
 })

 local Slider = Tab:CreateSlider({
    Name = "Select Waiting Speed",
    Range = {0.001, 1000},
    Increment = 10,
    Suffix = "Seconds",
    CurrentValue = 10,
    Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        if type(Value) == "table" then Value = Value[1] end

        Configs["ButtonWaitTimer"] = tonumber(Value)
    end,
 })

 local Section = Tab:CreateSection("Knife Features")

 local Slider = Tab:CreateSlider({
    Name = "Select Aura Radius",
    Range = {10, 1000},
    Increment = 10,
    Suffix = "Studs",
    CurrentValue = 10,
    Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(Value)
        if type(Value) == "table" then Value = Value[1] end

        Configs["KillAuraRadius"] = tonumber(Value)
    end,
 })

 local Toggle = Tab:CreateToggle({
	Name = "Enable Knife Kill Aura",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(Value)
        if type(Value) == "table" then Value = Value[1] end
        Configs["EnableKillAura"] = Value

        KnifeAura()
	end,
})

 local Section = Tab:CreateSection("Drops")

 local Toggle = Tab:CreateToggle({
	Name = "Enable Auto Teleport To Airdrops",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(Value)
		Configs["ChooseCollectAirdrops"] = Value
		task.wait()

		CollectAirdrops()
	end,
 })

 local Section = Tab:CreateSection("Capture Points")

 local Dropdown = Tab:CreateDropdown({
    Name = "Choose Point To Goto",
    Options = HardPoints,
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(value)
        if type(value) == "table" then value = value[1] end 

        GotoSpecificPoint(value)
    end,
 })

 local Toggle = Tab:CreateToggle({
	Name = "Enable Auto Capture Point",
	CurrentValue = false,
	Flag = "Toggle1",
	Callback = function(Value)
        if type(Value) == "table" then Value = Value[1] end

        Configs["AutoCapturePoint"] = Value

        CapturePoints()
	end,
 })


 local Section = Veichle:CreateSection("Veichles")

 local Dropdown = Veichle:CreateDropdown({
    Name = "Select Veichle",
    Options = VeichleTable,
    CurrentOption = VeichleTable[1],
    MultipleOptions = false,
    Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
    Callback = function(value)
        if type(value) == "table" then value = value[1] end
        Configs["SelectedVeichle"] = value
    end,
 })

 local Button = Veichle:CreateButton({
	Name = "Buy Selected Veichle",
	Callback = function()
        RequestBuyVeichle(Configs["SelectedVeichle"])

        Rayfield:Notify({
            Title = "Successfully ran!",
            Content = "Ignore this message, just letting you know the command was a success.",
            Duration = 2,
            Image = 4483362458,
         })
	end,
 })

 local Button = Veichle:CreateButton({
	Name = "Spawn Selected Veichle",
	Callback = function()
        RequestSpawnVeichle(Configs["SelectedVeichle"])

        Rayfield:Notify({
            Title = "Successfully ran!",
            Content = "Ignore this message, just letting you know the command was a success.",
            Duration = 2,
            Image = 4483362458,
         })
	end,
 })

 local Button = Veichle:CreateButton({
	Name = "Bring Selected Veichle",
	Callback = function()
        BringVeichle(Configs["SelectedVeichle"])

        Rayfield:Notify({
            Title = "Successfully ran!",
            Content = "Ignore this message, just letting you know the command was a success.",
            Duration = 2,
            Image = 4483362458,
         })
	end,
 })

 local Section = GunTab:CreateSection("Explanation")

 local Paragraph = GunTab:CreateParagraph({Title = "How To Use:", Content = "First, press on 'Update Guns List' then select a gun. Then once the gun is selected you MUST press the 'Reveal Arguments' button or else this will NOT work. Then enter in the TextBox at the bottom the new value, press the 'Finalize Change' and enjoy."})

 local Section = GunTab:CreateSection("Gun Choice")

 local GunsListDropdown = GunTab:CreateDropdown({
	Name = "Select Gun To Modify",
	Options = {},
	CurrentOption = "",
	MultipleOptions = false,
	Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
		Configs["ChosenWeapon"] = unpack(Option)
        task.wait(0.5)

        local WeaponVariable = FindWeapon(Configs["ChosenWeapon"])

        AppendArguments(WeaponVariable)
	end,
 })

 local Button = GunTab:CreateButton({
	Name = "Update Guns List",
	Callback = function()
        table.clear(GunsTable)

        LoadGunsTable()
        task.wait(0.1)

		GunsListDropdown:Refresh(GunsTable)

        Rayfield:Notify({
            Title = "Successfully ran!",
            Content = "Ignore this message, just letting you know the command was a success.",
            Duration = 2,
            Image = 4483362458,
         })
	end,
 })

 local Section = GunTab:CreateSection("Arguments")

 local ArgumentDropdown = GunTab:CreateDropdown({
	Name = "Select Argument To Modify",
	Options = {},
	CurrentOption = "",
	MultipleOptions = false,
	Flag = "Dropdown1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Option)
        local TrueValue = split(Option[1], " (")[1]

        Configs["ChosenArgument"] = TrueValue
	end,
 })

 local Button = GunTab:CreateButton({
	Name = "Reveal Arguments (REQUIRED)",
	Callback = function()
		ArgumentDropdown:Refresh(ModChoice)

        if not Configs["DeeperConfigs"]["FirstArgumentRun"] then Configs["DeeperConfigs"]["FirstArgumentRun"] = true end

        Rayfield:Notify({
            Title = "Successfully ran!",
            Content = "Ignore this message, just letting you know the command was a success.",
            Duration = 2,
            Image = 4483362458,
         })
	end,
 })

 local Section = GunTab:CreateSection("User Argument Choice")

 local Input = GunTab:CreateInput({
    Name = "Please enter a new value: (Either BOOL or NUMBER)",
    CurrentValue = "",
    PlaceholderText = "0",
    RemoveTextAfterFocusLost = false,
    Flag = "Input1",
    Callback = function(Text)
        if lower(Text) == "true" then
             Configs["NewArgumentValue"] = true
        elseif lower(Text) == "false" then
            Configs["NewArgumentValue"] = false
        else
            Configs["NewArgumentValue"] = tonumber(Text)
        end
    end,
 })

 local Button = GunTab:CreateButton({
	Name = "Modify Selected Argument",
	Callback = function()
        local WeaponVariable = FindWeapon(Configs["ChosenWeapon"])

		ModifyArgument(WeaponVariable, Configs["ChosenArgument"], Configs["NewArgumentValue"])

        Rayfield:Notify({
            Title = "Successfully ran!",
            Content = "Ignore this message, just letting you know the command was a success.",
            Duration = 2,
            Image = 4483362458,
         })
	end,
 })
 -- End Of Script :) --
