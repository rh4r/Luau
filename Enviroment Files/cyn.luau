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

cyn.clear_output = function()
    cloneref(game:GetService("LogService")):ClearOutput()
end

cyn.check_alive = function(plr: Player)
    local PlrChar = PlayerFunctions:ReturnChar(plr)
    local PlrHumanoid = PlayerFunctions:ReturnHumanoid(PlrChar)

    if PlrChar and PlrHumanoid then
        if PlrChar.IsDescendantOf(workspace) and PlrHumanoid.Health > 0 then
            return true
        end
    end
end

cyn.kick = function(message: string)
    PlayerFunctions:InitializeLocalPlayer():Kick(message)
end

cyn.copy_position = function(root: Part, keybind: Enum.KeyCode)
    if root and not keybind then
        setclipboard(root.Position)
    end

    if keybind then
        local UserInputSevice = OtherFunctions:ReturnClonedService("UserInputService")

        UserInputSevice.InputBegan:Connect(function(gameEvent, UserInputted)
            if UserInputted.KeyCode == Enum.KeyCode[keybind] then
                setclipboard(root.Position)
            end
        end)
    end
end

cyn.dex = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
end

cyn.simplespy = function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end

cyn.IY = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end

cyn.saveinstance = function()
    local Params = {
        RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
        SSI = "saveinstance",
    }
    
    local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
    
    local CustomOptions = { SafeMode = true, timeout = 15, SaveBytecode = true }
    
    synsaveinstance(CustomOptions)
end

cyn.decompile = function(scriptpath)
    local body = getgenv().decompile(scriptpath)

    if type(body) == "string" then
        print(body)
    end
end
