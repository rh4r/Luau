--[[
    Steal a Labubu: https://www.roblox.com/games/119823419558973/Steal-a-Labubu
    Credits:
        rh4r - Script Writing
        Sirius - Rayfield UI Library
]]--

pcall(function() loadstring(game:HttpGet('https://raw.githubusercontent.com/rh4r/Luau/refs/heads/main/Enviroment%20Files/cyn.luau'))() end)

local cyn = getgenv()

cyn.Configs = {
    ["StealingFrom"] = "",
    ["ConstantSteal"] = false,
    ["KeepOrSell"] = "Keep",
    ["IsLockedOrNot"] = nil,
    ["EnableBaseLock"] = false,
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

local PersonToStealFrom = Players:FindFirstChild(Configs.StealingFrom)

local Teleport = function(part_going_to)
    local LocalRoot = ReturnLocalRoot()

    if LocalRoot then
        LocalRoot.CFrame = part_going_to.CFrame
        task.wait()
    end
end

local FindBase = function(player)
    local NewName =  nil
    local DisplayName = player.DisplayName
    local Username = tostring(player)


    for index, item in pairs(workspace.Map.Plots:GetDescendants()) do
        local HasAncestorPart = item:FindFirstAncestorOfClass("Part")

        if item:IsA("TextLabel") and HasAncestorPart and HasAncestorPart.Name == "NameBoard" then
            NewName = split(item.Text, "'s")[1]

            if NewName == DisplayName or NewName == Username then
                return item:FindFirstAncestorOfClass("Model")
            end
        end
    end
end

local CheckIfAvailable = function(base)
    local LockText = nil
    local LockButton = nil

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
                    if pet_item:IsA("ProximityPrompt") and pet_item.Name == "StealProx" then
                        StealPetProximityPrompt = pet_item

                        fireproximityprompt(StealPetProximityPrompt, LocalRoot, 0)
                        task.wait()
                        fireproximityprompt(StealPetProximityPrompt, LocalRoot, 1)
                        print("Successfully taken pet: ", tostring(pet))
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

local SellAllPets = function()
    while cyn.Configs.KeepOrSell == "Sell" do
        local LocalRoot = ReturnLocalRoot()
        local Localbase = FindBase(LocalName)

        for index, item in pairs(Localbase:GetDescendants()) do
            if item:IsA("ProximityPrompt") and item.Name == "SellProx" then
                local PetToSell = item.Parent

                Teleport(PetToSell)
                
                fireproximityprompt(item, LocalRoot, 0)
                task.wait()
                fireproximityprompt(item, LocalRoot, 1)
                task.wait(0.1)
            end
        end 
        task.wait()
    end
end

local ReturnBestPet = function(base)
    local HighestCash = 0
    local BestPetToGrab = nil

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
    return BestPetToGrab
end

local StealPetFrom = function(player)
    while cyn.Configs.ConstantSteal do
       local Base = FindBase(player)
        local BestPet = ReturnBestPet(Base)

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
        task.wait(0.1)
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
local MiscFeatures = Window:CreateTab("Misc Features", 4483362458) -- Title, Image
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

 local MiscSection = MiscFeatures:CreateSection("Script Status (DEBUG)")

local Paragraph = MiscFeatures:CreateParagraph({Title = "STATUS IS: ", Content = "..."})

local Button = MiscFeatures:CreateButton({
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
    print(Configs.StealingFrom)
   end,
})

local Button = Tab:CreateButton({
   Name = "Refresh Players List",
   Callback = function()
        clear(PlrsTbl)

        for a,b in Players:GetPlayers() do 
            if b ~= LocalPlayer then
                insert(PlrsTbl, tostring(b))
            end
        end
   end,
})

local Section = Tab:CreateSection("Main")

local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Steal",
   CurrentValue = false,
   Callback = function(Value)
    Configs.ConstantSteal = Value
    
    StealPetFrom(Configs.StealingFrom)
   end,
})

local Toggle = Tab:CreateToggle({
   Name = "Enable Auto Sell",
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
