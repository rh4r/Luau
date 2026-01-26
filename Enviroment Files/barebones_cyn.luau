--[[
	Name: Cyn (Cynthoni)
	Description: This is a easily implimentible library which is used in my scripts for calling certain functions,
		The main use of "Cyn" is to not have to constantly add return functions for instances like HumanoidRootPart and nil.Character
			But Cyn also has implimentation of other convient functions and potentially more in the future.
]]--
local cyn = getgenv()

cyn.OtherFunctions = {}
cyn.PlayerFunctions = {}

local OtherFunctions = cyn.OtherFunctions
local PlayerFunctions = cyn.PlayerFunctions
local cloneref = cloneref or function(...) return ... end

function PlayerFunctions:InitializeLocalPlayer()
    return cloneref(game:GetService("Players")).LocalPlayer
end

function PlayerFunctions:ReturnChar(plr: Player)
    return plr.Character
end

function PlayerFunctions:ReturnRoot(char: Model)
    return char.HumanoidRootPart or char.PrimaryPart
end

function PlayerFunctions:ReturnHumanoid(char: Model)
    return char.Humanoid or char:FindFirstAncestorOfClass("Humanoid")
end

function PlayerFunctions:ReturnLocalHumanoid()
    local LocalPlayer = PlayerFunctions:InitializeLocalPlayer()
    local LocalChar = PlayerFunctions:ReturnChar(LocalPlayer)
    local LocalHumanoid = PlayerFunctions:ReturnHumanoid(LocalChar)

    return LocalHumanoid
end

function PlayerFunctions:ReturnLocalChar()
    local LocalPlayer = PlayerFunctions:InitializeLocalPlayer()
    local LocalChar = PlayerFunctions:ReturnChar(LocalPlayer)
    
    return LocalChar
end

function PlayerFunctions:ReturnLocalRoot()
    local LocalPlayer = PlayerFunctions:InitializeLocalPlayer()
    local LocalChar = PlayerFunctions:ReturnChar(LocalPlayer)
    local LocalRoot = PlayerFunctions:ReturnRoot(LocalChar)
    return LocalRoot
end

function OtherFunctions:ReturnClonedService(service: string)
    local CreatedService = nil
    xpcall(function()
        CreatedService = cloneref(game:GetService(service))
    end,
    function()
        CreatedService = game:GetService(service)    
    end)
    return CreatedService
end
