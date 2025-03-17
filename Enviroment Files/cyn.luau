local cyn = getgenv()

cyn.OtherFunctions = {}
cyn.PlayerFunctions = {}

local OtherFunctions = cyn.OtherFunctions
local PlayerFunctions = cyn.PlayerFunctions
local cloneref = cloneref or cyn.cloneref or function(...) return ... end

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

function OtherFunctions:ReturnClonedService(service: string)
    return cloneref(game:GetService(service))
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
