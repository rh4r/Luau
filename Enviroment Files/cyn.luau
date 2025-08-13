--[[
	Name: Cyn (Cynthoni)
	Description: This is a easily implimentible library which is used in my scripts for calling certain functions,
		The main use of "Cyn" is to not have to constantly add return functions for instances like HumanoidRootPart and nil.Character
			But Cyn also has implimentation of other convient functions and potentially more in the future.
]]--
local cyn = getgenv()

cyn.OtherFunctions = {}
cyn.PlayerFunctions = {}
cyn.InstanceFunctions = {}
cyn.EnviromentFunctions = {}

local OtherFunctions = cyn.OtherFunctions
local PlayerFunctions = cyn.PlayerFunctions
local InstanceFunctions = cyn.InstanceFunctions
local EnviromentFunctions = cyn.EnviromentFunctions
local cloneref = cloneref or function(object) return object end

function PlayerFunctions:InitializeLocalPlayer()
    return cloneref(game:GetService("Players")).LocalPlayer
end

function PlayerFunctions:ReturnChar(plr)
    return plr.Character
end

function PlayerFunctions:ReturnRoot(char)
    return char.HumanoidRootPart or char.PrimaryPart
end

function PlayerFunctions:ReturnHumanoid(char)
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

function OtherFunctions:ReturnClonedService(service)
    local CreatedService = nil
    xpcall(function()
        CreatedService = cloneref(game:GetService(service))
    end,
    function()
        CreatedService = game:GetService(service)    
    end)
    return CreatedService
end

function InstanceFunctions:FindFirstDescendantOf(Instance, Class)
    local Found = nil

    for Index, ChildInstance in pairs(Instance:GetDescendants()) do
        if ChildInstance:IsA(Class) and ChildInstance.ClassName == Class then
            Found = ChildInstance
        end
    end

    if Found then
        return Found
    end
end

function InstanceFunctions:LoopToFind(ToLoop, ToFind)
    for Index, Instance in pairs(ToLoop) do
        if Instance == ToFind then
            return Instance
        end
    end
end

function EnviromentFunctions:CheckUpvalues(PassedFunc, item)
    if type(PassedFunc) == "function" and islclosure(PassedFunc) and not isexecutorclosure(PassedFunc) then
        warn(" | Cyn Check Upvalues Run  |")

        local Upvalues = debug.getupvalues(PassedFunc)

        if #Upvalues > 0 then
            table.foreach(Upvalues, function(_, ValueFound)
                if ValueFound == item then
                    warn("Is within upvalues (NON-STRING)")
                elseif tostring(ValueFound) == item then
                    warn("Is within upvalues (TOSTRINGGED UPVALUE)")
                end
            end)

        warn(" | Cyn Check Upvalues Run  |")
        else
            print("No Constants Found")
        end
    end
end

function EnviromentFunctions:CheckConstants(PassedFunc, item)
    if type(PassedFunc) == "function" and islclosure(PassedFunc) and not isexecutorclosure(PassedFunc) then
        warn(" | Cyn Check Constants Run  |")

        local Constants = debug.getconstants(PassedFunc)
        
        if #Constants > 0 then
            table.foreach(Constants, function(_, ValueFound)
                if ValueFound == item then
                    warn("Is within constants (NON-STRING)")
                elseif tostring(ValueFound) == item then
                    warn("Is within constants (TOSTRINGGED COSNTANT)")
                end
            end)

        warn(" | Cyn Check Constants Run  |")
        else
            print("No Constants Found")
        end
    end
end

function EnviromentFunctions:CompareEnv(PassedFunc, Enviroment1)
    local FuncEnviroment = getfenv(PassedFunc)

    if FuncEnviroment == Enviroment1 then
        return true
    else
        return false
    end
end

function EnviromentFunctions:DebugOutputFunction(PassedFunc)
    local ginfo = debug.getinfo
    local info = ginfo(PassedFunc)

    local ginfoChecks = {
        ["FUNCTION ITSELF: "]             = info.func,
        ["FUNCTION NAME: "]               = info.name,
        ["FUNCTION SOURCE: "]             = info.source,
        ["FUNCTION UPVALUES: "]           = info.nups,
        ["FUNCTION CONSTANTS: "]          = #debug.getconstants(PassedFunc),
        ["FUNCTION LINE DEFINED: "]       = info.linedefined,
        ["FUNCTION LANGUAGE DEFINED IN:"] = info.what,
    }

    local order = {
        "FUNCTION ITSELF: ",
        "FUNCTION NAME: ",
        "FUNCTION SOURCE: ",
        "FUNCTION UPVALUES: ",
        "FUNCTION CONSTANTS: ",
        "FUNCTION LINE DEFINED: ",
        "FUNCTION LANGUAGE DEFINED IN:",
    }

    warn(" | Cyn Function  Information Return |")

    for _, key in ipairs(order) do
        print(key, ginfoChecks[key])
    end

    warn("| Cyn Function  Information Return |")
end

cyn.clear_output = function()
    cloneref(game:GetService("LogService")):ClearOutput()
end

cyn.check_alive = function(plr)
    local PlrChar = PlayerFunctions:ReturnChar(plr)
    local PlrHumanoid = PlayerFunctions:ReturnHumanoid(PlrChar)

    if PlrChar and PlrHumanoid then
        if PlrChar.IsDescendantOf(workspace) and PlrHumanoid.Health > 0 then
            return true
        end
    end
end

cyn.kick = function(message)
    PlayerFunctions:InitializeLocalPlayer():Kick(message)
end

cyn.copy_position = function(root, keybind)
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
