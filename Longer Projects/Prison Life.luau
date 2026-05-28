--[[
	Game: Prison Life
	Credits: rh4r
]]--

-- // Configurations \\ -- 
local config = {
    ["Main"] = {
        ["ESP"] = false
    },
    ["Blatant"] = {
        ["Aimlock"]
    },
    ["Misc"] = {},
    ["Settings"] = {},
}

-- // Initialization \\ -- 

repeat
    task.wait()
until game.Loaded

if not getgenv().OtherFunctions then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/rh4r/Luau/refs/heads/main/Enviroment%20Files/barebones_cyn.luau"))() -- Function Library
end

local cloneref = cloneref or getgenv().cloneref or function(...) return ... end 
local Services = {}
local cyn = getgenv()

setmetatable(Services, {
    __index = function(table, key)
        return cloneref(game:GetService(key))
    end
})

local PlayerFunctions = cyn.PlayerFunctions

local cMain = config.Main
local cBlatant = config.Blatant
local cMisc = config.Misc
local cSettings = config.Settings

local function ValidObject(object)
    if object and object.IsDescendantOf(workspace) then
       return true 
    end
end

-- // Shortens \\ -- 
local insert = table.insert
local clear = table.clear

-- // Variables \\ -- 

local Camera = workspace.CurrentCamera
local Players = Services.Players
local RunService = Services.RunService
local LocalPlayer = Players.LocalPlayer

local PlayerEntityList = {}
local DrawingObjects = {}

-- // Main Logic \\ -- 

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
        print("Destroyed: ", b[2])
    end
end

local function PLAYER_ESP()
    if not cMain.ESP then
        DESTROY_DRAWINGS()
    else
        for index, entity in pairs(Players:GetPlayers()) do
            if entity.Character and entity.Character.HumanoidRootPart then
                local NewSize, BoxPosition, Visible = RETURN_BOX_POS(entity)

                local PlrSquare = Drawing.new("Square")
                PlrSquare.Visible = true
                PlrSquare.Transparency = 0.5
                PlrSquare.Color = Color3.new(1,0,0)
                PlrSquare.Size = NewSize
                PlrSquare.Thickness = 2
                PlrSquare.Filled = false
                PlrSquare.Position = BoxPosition

                insert(DrawingObjects, {entity, PlrSquare}) 
            end
        end
        RunService.Heartbeat:Connect(function()
            if cMain.ESP then 
                for index, PassedTable in DrawingObjects do
                    local plrInstance = PassedTable[1]
                    local DrawingObject = PassedTable[2]

                    if plrInstance.Character and plrInstance.Character.HumanoidRootPart then
                        local NewSize, NewPosition, Visible = RETURN_BOX_POS(plrInstance)

                        DrawingObject.Size = NewSize
                        DrawingObject.Position = NewPosition
                        DrawingObject.Visible = true

                        if Visible then
                            DrawingObject.Visible = false
                        end
                    end
                end
            end
        end) 
    end
end


-- // User Interface Library \\ -- 
local function importRelease(owner, repo, version, file)
    local tag = (version == "latest" and "latest/download" or "download/"..version)

    return loadstring(game:HttpGetAsync(("https://github.com/%s/%s/releases/%s/%s"):format(owner, repo, tag, file)), file)()
end

local cascade = importRelease("cascadeui", "Cascade", "latest", "dist.luau")


local app = cascade.New({
    Theme = cascade.Themes.Dark,
    Accent = cascade.Accents.Blue, -- Optional, defaults to Blue
})

do
    local window = app:Window({
        Title = "My Window",
        Subtitle = "My window",
    })

    do 
        local MainSection = window:Section({ Title = "Main Features" })
		local BlatantSection = window:Section({ Title = "Blatant" })
		local MiscSection = window:Section({ Title = "Misc" })
		local SettingsSection = window:Section({ Title = "Settings" })

        do 
            local MainTab = MainSection:Tab({
                Selected = true,
                Title = "Main",
                Icon = cascade.Symbols.squareStack3dUp,
            })

            local BlatantTab = BlatantSection:Tab({
                Selected = true,
                Title = "Main",
                Icon = cascade.Symbols.squareStack3dUp,
            })

            do
                local MainForm = MainTab:Form()
                local BlatantSection = BlatantSection:Form()

                do 
                    -- // Main Form \\ -- 
                    local row = MainForm:Row()
                    local label = row:Left():Label({
                        Text = "Toggle Esp"
                    })

                    local toggle = row:Right():Toggle({
                        Value = false,
                        ValueChanged = function(self, value: boolean)
                            cMain.ESP = value
                            PLAYER_ESP()
                        end,
                    })


                    local row = MainForm:Row()
                    local label = row:Left():Label({
                        Text = "Toggle Aimlock"
                    })

                    local toggle = row:Right():Toggle({
                        Value = false,
                        ValueChanged = function(self, value: boolean)
                            print("i'm bisexual")
                        end,
                    })
                end
            end
        end
    end
end
