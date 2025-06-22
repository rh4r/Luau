--[[
    Steal a Labubu: https://www.roblox.com/games/119823419558973/Steal-a-Labubu
    Credits:
        rh4r - Script Writing
        Sirius - Rayfield UI Library

    Recent Update:
	--  Implemented "Troll" tab with following features:
		-- Automatically steal and sell all labubus with open bases
		-- Player selection to steal buy from, aslong as u have enough money they cannot play the game this way
	--  Implemented "Info" tab with following features:
		-- Display if base is "OPEN" or "LOCKED"
		-- Display the player with the best labubu in the server
		-- Display the best labubu in the server, and who owns it
	-- Implemented "Auto Steal Richest Player" inwhich does the following:
		-- Steals the most valuable labubu in the server, before moving onto the next and etc.
	-- Implemnented "Auto Collect" inwhich does:
		-- Automatically collects all the cash generated from the players labubu's
	-- Other misc bug fixes.
]]--


pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/rh4r/Luau/refs/heads/main/Enviroment%20Files/cyn.luau'))() end)

local cyn = getgenv()

cyn.Configs = {
    ["ToTroll"] = "",
    ["ElonMusk"] = "",
    ["StealingFrom"] = "",
    ["KeepOrSell"] = "Keep",
    ["TheirBest"] = nil,
    ["IsLockedOrNot"] = nil,
    ["ThanksWkd"] = false,
    ["CanTakeElon"] = false,
    ["ConstantSteal"] = false,
    ["IAmAnAnnoynace"] = false,
    ["EnableBaseLock"] = false,
    ["EnableAutoCollect"] = false,
    ["EnableAutoStealFromRichest"] = false,
}

local Configs = cyn.Configs

local sort = table.sort
local gsub = string.gsub
local clear = table.clear
local split = string.split
local match = string.match
local insert = table.insert
local PlayerFunctions = cyn.PlayerFunctions

ReturnLocalChar = PlayerFunctions.ReturnLocalChar
ReturnLocalRoot = PlayerFunctions.ReturnLocalRoot
ReturnLocalHumanoid = PlayerFunctions.ReturnLocalHumanoid

local LocalPlayer = PlayerFunctions:InitializeLocalPlayer()
local LocalName = LocalPlayer.Name

local Players = game:GetService("Players")

local Teleport = function(part_going_to)
    local LocalRoot = ReturnLocalRoot()

    if LocalRoot and part_going_to then
        LocalRoot.CFrame = part_going_to.CFrame
        task.wait()
    end
end

local FindBase = function(player)
    local NewName =  nil
    local DisplayName 

    pcall(function()
        if player.DisplayName then
            DisplayName = player.DisplayName
        else
            DisplayName = nil
        end
    end)

    local Username = tostring(player)


    for index, item in pairs(workspace.Map.Plots:GetDescendants()) do
        local HasAncestorPart = item:FindFirstAncestorOfClass("Part")

        if item:IsA("TextLabel") and HasAncestorPart and HasAncestorPart.Name == "NameBoard" then
            NewName = split(item.Text, "'s")[1]

            if NewName == Username or NewName == DisplayName then
                return item:FindFirstAncestorOfClass("Model")
            end
        end
    end
end

local CheckIfAvailable = function(base)
    local LockText = nil
    local LockButton = nil

    if base then
        for index, item in pairs(base:GetDescendants()) do 
            LockButton = item:FindFirstAncestorOfClass("Part")

            if item:IsA("TextLabel") and LockButton and LockButton.Name == "LockButton" then
                LockText = split(item.Text, " ")[1]
                if LockText ~= "LOCKED" then
                    return true
                else
                    return false
                end
            end
        end 
    end
end

--[[
local GotoBase = function(base)
    local LocalRoot = ReturnLocalRoot()
    local PartoGoingTo = nil

    if LocalRoot then
        for index, item in base:GetDescendants() do 
            if item:IsA("UnionOperation") then
                if item.BrickColor == BrickColor.new("Bright bluish violet") then 
                    PartoGoingTo = item
                    LocalRoot.CFrame = PartoGoingTo.CFrame
                end
            end
        end
    end
end
]]--

local TakePet = function(pet, base)
    local StealPetProximityPrompt = nil

    local LocalRoot = ReturnLocalRoot()
    local CanSteal = CheckIfAvailable(base)

    if LocalRoot and CanSteal then
        for index, item in pairs(base:GetDescendants()) do 
            if item:IsA("Model") and item == pet then
                Teleport(item.PrimaryPart)
                task.wait(0.15)

                for index, pet_item in pairs(item:GetDescendants()) do
                    if pet_item:IsA("ProximityPrompt") and pet_item.Name == "BuyProx" then
                        task.wait()
                        break
                    end
                    if pet_item:IsA("ProximityPrompt") and pet_item.Name == "StealProx" then
                        StealPetProximityPrompt = pet_item

                        fireproximityprompt(StealPetProximityPrompt, LocalRoot, 0)
                        task.wait()
                        fireproximityprompt(StealPetProximityPrompt, LocalRoot, 1)
                    end
                end
            end
        end 
    end
end


local CollectPetWhenStolen = function()
    local LocalBase = FindBase(LocalName)
    local CashPart = nil

    if LocalBase then
        for index, item in pairs(LocalBase:GetDescendants()) do
            if item:IsA("Part") and item.Name == "CashMultiDisplay" then
                CashPart = item
                
                Teleport(CashPart)
            end
        end 
    end
end

local LockOwnBase = function()
    while cyn.Configs.EnableBaseLock == true do
        local LocalBase = FindBase(LocalName)
        local LocalRoot = ReturnLocalRoot()

        if LocalBase then
            for index, item in pairs(LocalBase:GetDescendants()) do
                if item:IsA("Part") and item.Name == "LockButton" then
                    local LockButton = item
                    local OldCFrame = LocalRoot.CFrame

                    for index, child_item in LockButton:GetDescendants() do
                        if child_item:IsA("TextLabel") and child_item.Text == "Lock Base" then
                            Teleport(LockButton) 
                            task.wait(1)
                            LocalRoot.CFrame = OldCFrame
                        end
                    end
                end
            end
        end 
        task.wait(1)
    end
end

local ReturnBestPet = function(base)
    local HighestCash = 0
    local BestPetToGrab = nil

    if base then
       for index, pet_child in pairs(base:GetDescendants()) do
            if pet_child:IsA("TextLabel") and pet_child.Name == "CashPerSec" then
                local Pet = pet_child:FindFirstAncestorOfClass("Model")
                local Cash = pet_child.Text

                if Cash then
                    local FixedCash = split(Cash, "$")[2]
                    local TrueFixedCash = split(FixedCash, "/")[1]

                    if match(TrueFixedCash, "k") then
                        TrueFixedCash = gsub(TrueFixedCash, "k", "")
                        TrueFixedCash = tonumber(TrueFixedCash) * 1000
                    else
                        TrueFixedCash = tonumber(TrueFixedCash)
                    end

                    if TrueFixedCash and TrueFixedCash > HighestCash then
                        BestPetToGrab = Pet
                        HighestCash = TrueFixedCash
                    end
                end
            end
        end
        return BestPetToGrab, HighestCash 
    end
end

local ReturnCurrentServerwideBestWithPlayer = function()
        local CurrentBestPet = nil
        local CurrentHighestCash = 0
        local WhoOwnsThis = nil
        local PlayerOwning = nil

        for a,b in workspace:GetDescendants() do
            if b:IsA("TextLabel") and b.Name == "CashPerSec" then
                local Pet = b:FindFirstAncestorOfClass("Model")

                if Pet == cyn.Configs.TheirBest then
                    local Cash = b.Text

                    if Cash then
                        local FixedCash = split(Cash, "$")[2]
                        local TrueFixedCash = split(FixedCash, "/")[1]

                        if match(TrueFixedCash, "k") then
                            TrueFixedCash = gsub(TrueFixedCash, "k", "")
                            TrueFixedCash = tonumber(TrueFixedCash) * 1000
                        else
                            TrueFixedCash = tonumber(TrueFixedCash)
                        end

                        if TrueFixedCash and TrueFixedCash > CurrentHighestCash then
                            CurrentBestPet = Pet
                            CurrentHighestCash = TrueFixedCash
                        end
                    end
                end 
            end
        end

        for c,d in pairs(workspace.Map.Plots:GetChildren()) do
            for e,f in d:GetDescendants() do
                if f:IsA("Model") and f == CurrentBestPet then
                    WhoOwnsThis = tonumber(d:GetAttribute("OwnerId"))
                end
            end
        end

        if WhoOwnsThis then
            for index, player in pairs(Players:GetPlayers()) do
                print(player.UserId, type(player.UserId),"\n", WhoOwnsThis, type(WhoOwnsThis))
                if tonumber(player.UserId) == WhoOwnsThis then
                    PlayerOwning = player
                end
            end
        end

        task.wait()

        local StringToInput = "(".. tostring(CurrentBestPet) .. ")" .. " | Cash Per Second: " .. "(" .. tostring(CurrentHighestCash) .. ")"
        local Part2ToPrevious = "\nOwned By Player: " .. tostring(PlayerOwning)
        StringToInput = StringToInput .. Part2ToPrevious
    return StringToInput
end

local StealOnce = function(player)
    local Base = FindBase(player)
    local BestPet = ReturnBestPet(Base)
    print'got base'
    print(player)

    if Base then
        local IsAvailable = CheckIfAvailable(Base)
        if IsAvailable then
            Configs.CanTakePets = true

            local CharacterPadsFolder = Base.CharacterPads

            for index, pet in pairs(CharacterPadsFolder:GetDescendants()) do
                if pet:IsA("Model") then
                    if pet == BestPet then
                        TakePet(BestPet, Base)
                        task.wait(0.1)
                        CollectPetWhenStolen()
                    end
                end
            end
        end
    end 
end

local SellAllOnce = function()
    local LocalRoot = ReturnLocalRoot()
    local Localbase = FindBase(LocalName)

    for index, item in pairs(Localbase:GetDescendants()) do
        if item:IsA("ProximityPrompt") and item.Name == "SellProx" then
            local PetToSell = item.Parent

            Teleport(PetToSell)
            
            fireproximityprompt(item, LocalRoot, 0)
            task.wait(0.1)
            fireproximityprompt(item, LocalRoot, 1)
            task.wait(0.1)
        end
    end 
    task.wait()
end

local SellAllPets = function()
    while cyn.Configs.KeepOrSell == "Sell" do
        SellAllOnce()
        task.wait()
    end
end

local SetServerwideBest = function()
    local PlayerToTakeIndex = 0
    local OverallHighestCash = 0
    local OverallBestPlr = nil
    local OverallBestPet = nil
    local BestPets = {}
    local PlayerAssociated = {}

    for current_index, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerBase = FindBase(player)

            if PlayerBase then
                local BestPet, PetCPS = ReturnBestPet(PlayerBase)

                if BestPet then
                    insert(BestPets, current_index, {BestPet, PetCPS})
                    insert(PlayerAssociated, current_index, player)
                end
            end 
        end
    end

    for plr_index, pet_values in BestPets do
        if pet_values[2] > OverallHighestCash then
            OverallHighestCash = pet_values[2]
            OverallBestPet = pet_values[1]
            PlayerToTakeIndex = plr_index
        end
    end
    OverallBestPlr = PlayerAssociated[PlayerToTakeIndex]
    cyn.Configs.ElonMusk = OverallBestPlr
    cyn.Configs.TheirBest = OverallBestPet
    task.wait(0.1)
end

local StealPetFrom = function(player)
    while cyn.Configs.ConstantSteal do
       StealOnce(player)
       task.wait()
    end
end

local AutoCollect = function()
    while cyn.Configs.EnableAutoCollect do
        local MyBase = FindBase(LocalName)

        if MyBase then
            local CharacterPads = MyBase.CharacterPads

            if CharacterPads then
                for _, hitbox in pairs(CharacterPads:GetDescendants()) do 
                    if hitbox:IsA("Part") and hitbox.Name == "Hitbox" then
                        Teleport(hitbox)
                        task.wait(0.25)
                    end
                end
                task.wait(1)
            end
        end
    end
end

local RobinHood = function()
    while cyn.Configs.EnableAutoStealFromRichest do
        if not cyn.Configs.EnableAutoStealFromRichest then break end
        local Richest = cyn.Configs.ElonMusk
        local Best = cyn.Configs.TheirBest

        if Richest ~= "" and Richest ~= nil then
            local BestBase = FindBase(Richest)
            local CanTakeFrom = CheckIfAvailable(BestBase)

            while not CanTakeFrom or not BestBase do
                if cyn.Configs.EnableAutoStealFromRichest ~= true then break end

                CanTakeFrom = CheckIfAvailable(BestBase)
                Best = ReturnBestPet(BestBase)
                task.wait()
            end
            Best = ReturnBestPet(BestBase)

            if Best ~= nil then
                TakePet(Best, BestBase)
                task.wait(0.1)
                CollectPetWhenStolen()
            end
            SetServerwideBest()
        else
            SetServerwideBest()
        end
        task.wait()
    end
end


local Annihilation = function()
    while cyn.Configs.IAmAnAnnoynace do
        for index, player in pairs(Players:GetPlayers()) do
            local CurrentBase = FindBase(player)

            if CurrentBase then
                local IsOpen = CheckIfAvailable(CurrentBase)

                if IsOpen then
                    StealOnce(player)
                    task.wait()
                    SellAllOnce()
                else
                    task.wait(0.05)
                end
            end
        end
        task.wait()
    end
end

local NoBuyingAnythingLol = function(player)
    while cyn.Configs.ThanksWkd do
        local PlrBase = FindBase(player)

        if PlrBase then
            for index, labubu in pairs(workspace.Map.Plots["New Plot"].CharacterPads:GetChildren()) do
                if not labubu:GetAttribute("Madeit") then
                    if labubu:FindFirstChildOfClass("Model") then
                        labubu = labubu:FindFirstChildOfClass("Model")

                        local TeleportPart = labubu.PrimaryPart or labubu.HumanoidRootPart

                        if TeleportPart then
                            for index, labubu_item in pairs(labubu:GetDescendants()) do
                                if labubu_item:IsA("ProximityPrompt") and labubu_item.Name == "BuyProx" then
                                    Teleport(TeleportPart)
                                    task.wait(0.1)
                                    fireproximityprompt(labubu_item)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait()
    end
end

-- GUI Lib

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local PlrsTbl = {}
local RayfieldThemes = {"Default","Amber Glow","Amethyst","Bloom","Dark Blue","Green","Light","Ocean","Serenity"}; sort(RayfieldThemes)

task.spawn(function()
    for a,b in Players:GetPlayers() do 
        if b ~= LocalPlayer then
            insert(PlrsTbl, tostring(b))
        end
    end
end)

local Window = Rayfield:CreateWindow({
   Name = "w1cked",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by Sirius",
   ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
})

local Tab = Window:CreateTab("Main Features", 4483362458) -- Title, Image
local TrollTab = Window:CreateTab("Trolling", 4483362458) -- Title, Image
local InfoTab = Window:CreateTab("Information", 4483362458) -- Title, Image
local MiscFeatures = Window:CreateTab("GUI Features", 4483362458) -- Title, Image
local MiscSection = MiscFeatures:CreateSection("Misc")

 local Dropdown = MiscFeatures:CreateDropdown({
	Name = "Select Theme",
	Options = RayfieldThemes,
	CurrentOption = RayfieldThemes["Ocean"],
	MultipleOptions = false,
	Callback = function(Option)
		local Choice = unpack(Option)
		local TrySub = string.gsub(Choice, " ", "")

		Window.ModifyTheme(TrySub)
	end,
 })

 local Button = MiscFeatures:CreateButton({
	Name = "Destroy GUI",
	Callback = function()
        clear(cyn.Configs)

		Rayfield:Destroy()
	end,
 })

 local InfoSec = InfoTab:CreateSection("Base Status Of Player Trying To Steal From:")

local Paragraph = InfoTab:CreateParagraph({Title = "STATUS IS: ", Content = "..."})

local Button = InfoTab:CreateButton({
   Name = "View Current Status",
   Callback = function()
        local CanStealPetsRN = CheckIfAvailable(FindBase(Configs.StealingFrom))

        if CanStealPetsRN == true then
            Configs.IsLockedOrNot = true
        else
            Configs.IsLockedOrNot = false
        end

        if Configs.IsLockedOrNot == true then
            Paragraph:Set({Title = "STATUS IS", Content = "! STEALING PETS !"})
        else
            Paragraph:Set({Title = "STATUS IS", Content = "! BASE IS LOCKED !"})
        end
   end,
})

 local InfoSec = InfoTab:CreateSection("Current Player With The Most Valuable Pets:")

local RichestPar = InfoTab:CreateParagraph({Title = "Richest Player Is: ", Content = "..."})

local Button = InfoTab:CreateButton({
   Name = "View Richest Player",
   Callback = function()
        SetServerwideBest()
        task.wait()
        RichestPar:Set({Title = "Richest Player Is: ", Content = tostring(cyn.Configs.ElonMusk)})
   end,
})

 local InfoSec = InfoTab:CreateSection("Most Valuable Pet In Server:")

local RichestPar = InfoTab:CreateParagraph({Title = "The Best Pet Is: ", Content = "..."})

local Button = InfoTab:CreateButton({
   Name = "Refresh Best Pet",
   Callback = function()
        SetServerwideBest()

        local Info = ReturnCurrentServerwideBestWithPlayer()

        RichestPar:Set({Title = "Best Pet Is: ", Content = Info})
   end,
})

local TrollSec = TrollTab:CreateSection("Troll Features")

local Toggle = TrollTab:CreateToggle({
   Name = "Sell All Pets Of Open Bases",
   CurrentValue = false,
   Callback = function(Value)
    Configs.IAmAnAnnoynace = Value

    Annihilation()
   end,
})

local TrollSec = TrollTab:CreateSection("Troll Player")


local Dropdown = TrollTab:CreateDropdown({
   Name = "Select Player To Target",
   Options = PlrsTbl,
   CurrentOption = {},
   MultipleOptions = false,
   Callback = function(Options)
    local ChosenPlayer = Options[1]
    ChosenPlayer = Players:FindFirstChild(ChosenPlayer)

    Configs.ToTroll = ChosenPlayer
   end,
})

local Button = TrollTab:CreateButton({
   Name = "Refresh Players List",
   Callback = function()
        clear(PlrsTbl)

        for a,b in pairs(Players:GetPlayers()) do 
            if b ~= LocalPlayer then
                insert(PlrsTbl, b.Name)
            end
        end
        sort(PlrsTbl)
        Dropdown:Refresh(PlrsTbl)
   end,
})

local Button = TrollTab:CreateButton({
   Name = "Refresh Players List (DISPLAY NAMES)",
   Callback = function()
        clear(PlrsTbl)

        for a,b in pairs(Players:GetPlayers()) do 
            if b ~= LocalPlayer then
                if b.DisplayName then 
                    insert(PlrsTbl, b.DisplayName)
                else
                    insert(PlrsTbl, b.Name)
                end
            end
        end
        sort(PlrsTbl)
        Dropdown:Refresh(PlrsTbl)
   end,
})


local Toggle = TrollTab:CreateToggle({
   Name = "Steal Labubu Buy",
   CurrentValue = false,
   Callback = function(Value)
    Configs.ThanksWkd = Value

    NoBuyingAnythingLol(Configs.ToTroll)
   end,
})



local Section = Tab:CreateSection("Players")

local Dropdown = Tab:CreateDropdown({
   Name = "Select Player To Target",
   Options = PlrsTbl,
   CurrentOption = {},
   MultipleOptions = false,
   Callback = function(Options)
    local ChosenPlayer = Options[1]
    ChosenPlayer = Players:FindFirstChild(ChosenPlayer)

    Configs.StealingFrom = ChosenPlayer
   end,
})

local Button = Tab:CreateButton({
   Name = "Refresh Players List",
   Callback = function()
        clear(PlrsTbl)

        for a,b in pairs(Players:GetPlayers()) do 
            if b ~= LocalPlayer then
                insert(PlrsTbl, b.Name)
            end
        end
        sort(PlrsTbl)
        Dropdown:Refresh(PlrsTbl)
   end,
})

local Button = Tab:CreateButton({
   Name = "Refresh Players List (DISPLAY NAMES)",
   Callback = function()
        clear(PlrsTbl)

        for a,b in pairs(Players:GetPlayers()) do 
            if b ~= LocalPlayer then
                if b.DisplayName then 
                    insert(PlrsTbl, b.DisplayName)
                else
                    insert(PlrsTbl, b.Name)
                end
            end
        end
        sort(PlrsTbl)
        Dropdown:Refresh(PlrsTbl)
   end,
})

local Section = Tab:CreateSection("Steal Choices")

local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Steal (SELECTED PLAYER)",
   CurrentValue = false,
   Callback = function(Value)
    Configs.ConstantSteal = Value
    
    StealPetFrom(Configs.StealingFrom)
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Steal (RICHEST PLAYER)",
   CurrentValue = false,
   Callback = function(Value)
    Configs.EnableAutoStealFromRichest = Value
    
    RobinHood()
   end,
})

local Section = Tab:CreateSection("Base Choices")

local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Collect",
   CurrentValue = false,
   Callback = function(Value)
    cyn.Configs.EnableAutoCollect = Value
        AutoCollect()
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Sell All",
   CurrentValue = false,
   Callback = function(Value)
    if Value == true then
        cyn.Configs.KeepOrSell = "Sell" 
    else
        cyn.Configs.KeepOrSell = "Keep" 
    end
        SellAllPets()
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Lock Base",
   CurrentValue = false,
   Callback = function(Value)
    cyn.Configs.EnableBaseLock = Value
        LockOwnBase()
   end,
})
