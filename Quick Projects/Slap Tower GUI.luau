--[[
	Game link: https://www.roblox.com/games/95508886069297/Slap-Tower#ropro-quick-search

]]--

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SlapTowerTerminal"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "TerminalFrame"
frame.Size = UDim2.new(0, 500, 0, 255)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(190, 190, 190)
frameStroke.Parent = frame

-- Title & Status Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -50, 0, 30)
titleLabel.Position = UDim2.new(0, 15, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = ""
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.RichText = true
titleLabel.Parent = frame

-- Close Button (top-right corner)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextSize = 22
closeButton.Parent = frame
closeButton.AutoButtonColor = false

closeButton.MouseEnter:Connect(function()
	closeButton.TextColor3 = Color3.fromRGB(255, 120, 120)
end)
closeButton.MouseLeave:Connect(function()
	closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
end)

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Separator Line below title
local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, -30, 0, 2)
separator.Position = UDim2.new(0, 15, 0, 45)
separator.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
separator.BorderSizePixel = 0
separator.Parent = frame

-- Toggle Button (top)
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, -40, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 60)
toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 19
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Enable Script"
toggleButton.AutoButtonColor = false
toggleButton.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleButton

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(140, 140, 140)
toggleStroke.Parent = toggleButton

toggleButton.MouseEnter:Connect(function()
	toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
end)
toggleButton.MouseLeave:Connect(function()
	toggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
end)

-- Grant Button (below toggle)
local grantButton = Instance.new("TextButton")
grantButton.Name = "GrantButton"
grantButton.Size = UDim2.new(1, -40, 0, 50)
grantButton.Position = UDim2.new(0, 20, 0, 120)
grantButton.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
grantButton.Font = Enum.Font.GothamBold
grantButton.TextSize = 19
grantButton.TextColor3 = Color3.fromRGB(255, 255, 255)
grantButton.Text = "Grant All Slappers"
grantButton.AutoButtonColor = false
grantButton.Parent = frame

-- Player name input
local nameInput = Instance.new("TextBox")
nameInput.Name = "NameInput"
nameInput.Size = UDim2.new(1, -40, 0, 30)
nameInput.Position = UDim2.new(0, 20, 0, 180)
nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
nameInput.Font = Enum.Font.Gotham
nameInput.TextSize = 16
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.PlaceholderText = "Enter player's name or display name"
nameInput.ClearTextOnFocus = false
nameInput.Text = ""
nameInput.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = nameInput

-- Slap toggle button
local slapToggle = Instance.new("TextButton")
slapToggle.Name = "SlapToggle"
slapToggle.Size = UDim2.new(0.6, -25, 0, 30)
slapToggle.Position = UDim2.new(0, 20, 0, 215)
slapToggle.BackgroundColor3 = Color3.fromRGB(100, 70, 70)
slapToggle.Font = Enum.Font.GothamBold
slapToggle.TextSize = 16
slapToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
slapToggle.Text = "Start Targeted Slap"
slapToggle.AutoButtonColor = false
slapToggle.Parent = frame

local slapCorner = Instance.new("UICorner")
slapCorner.CornerRadius = UDim.new(0, 6)
slapCorner.Parent = slapToggle

local slapStroke = Instance.new("UIStroke")
slapStroke.Color = Color3.fromRGB(160, 120, 120)
slapStroke.Parent = slapToggle

-- Slap status label
local slapStatus = Instance.new("TextLabel")
slapStatus.Name = "SlapStatus"
slapStatus.Size = UDim2.new(0.4, -15, 0, 30)
slapStatus.Position = UDim2.new(0.6, 10, 0, 215)
slapStatus.BackgroundTransparency = 0
slapStatus.Font = Enum.Font.Gotham
slapStatus.TextSize = 16
slapStatus.Text = "TARGET: <font color='rgb(255,0,0)'>INVALID</font>"
slapStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
slapStatus.RichText = true
slapStatus.TextXAlignment = Enum.TextXAlignment.Left
slapStatus.Parent = frame


local grantCorner = Instance.new("UICorner")
grantCorner.CornerRadius = UDim.new(0, 6)
grantCorner.Parent = grantButton

local grantStroke = Instance.new("UIStroke")
grantStroke.Color = Color3.fromRGB(150, 150, 150)
grantStroke.Parent = grantButton

grantButton.MouseEnter:Connect(function()
	grantButton.BackgroundColor3 = Color3.fromRGB(115, 115, 115)
end)
grantButton.MouseLeave:Connect(function()
	grantButton.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
end)

-- Acceptable CFrames for touch checking
local Acceptable = {
	CFrame.new(33.4529037, 165.803314, 33.7354202),
	CFrame.new(33.4529037, 165.803314, 46.7354202),
	CFrame.new(33.4529037, 165.803314, 59.7354202),
	CFrame.new(38.4866753, 167.326248, 86.7648621, 0, 0, -1, 1, 0, 0, 0, -1, 0)
}

local boundaryStart = CFrame.new(-36.5470963, 165.80336, 99.2354202)
local boundaryEnd = CFrame.new(22.4529037, 165.803314, 99.2354202)

local function IsBetween(pos, p1, p2)
	local minX, maxX = math.min(p1.X, p2.X), math.max(p1.X, p2.X)
	local minY, maxY = math.min(p1.Y, p2.Y), math.max(p1.Y, p2.Y)
	local minZ, maxZ = math.min(p1.Z, p2.Z), math.max(p1.Z, p2.Z)

	return pos.X >= minX and pos.X <= maxX
	   and pos.Y >= minY and pos.Y <= maxY
	   and pos.Z >= minZ and pos.Z <= maxZ
end

-- Running control
local running = false
local thread

local function updateStatus()
	local color = running and "rgb(0,255,0)" or "rgb(255,0,0)"
	local label = running and "ENABLED" or "DISABLED"
	titleLabel.Text = "Slap Tower Unplayable | STATUS: <font color='" .. color .. "'>" .. label .. "</font>"
end

-- Toggle button logic
toggleButton.MouseButton1Click:Connect(function()
	running = not running
	toggleButton.Text = running and "Disable Script" or "Enable Script"
	updateStatus()

	if running then
		thread = task.spawn(function()
			while running do
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if root then
					for _, obj in ipairs(workspace:GetChildren()) do
						if obj:IsA("Part") then
							if obj.Name == "사라지는 파트" and table.find(Acceptable, obj.CFrame) then
								firetouchinterest(root, obj, true)
								task.wait()
								firetouchinterest(root, obj, false)
							elseif IsBetween(obj.Position, boundaryStart.Position, boundaryEnd.Position) then
								firetouchinterest(root, obj, true)
								task.wait()
								firetouchinterest(root, obj, false)
							end
						end
					end
				end
				task.wait()
			end
		end)
	end
end)

local function GrantAllSlappers()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("TouchTransmitter") and obj.Parent.Name == "Giver" then
			firetouchinterest(root, obj.Parent, true)
			task.wait()
			firetouchinterest(root, obj.Parent, false)
		end
	end
end

grantButton.MouseButton1Click:Connect(function()
	GrantAllSlappers()
end)

local slapRunning = false
local slapThread

local function getTargetFromName(input)
	input = input:lower()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and (plr.Name:lower() == input or plr.DisplayName:lower() == input) then
			return plr
		end
	end
end

slapToggle.MouseButton1Click:Connect(function()
	slapRunning = not slapRunning
	slapToggle.Text = slapRunning and "Stop Targeted Slap" or "Start Targeted Slap"

	if slapRunning then
		slapThread = task.spawn(function()
			while slapRunning do
				local target = getTargetFromName(nameInput.Text)
				if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if root then
						slapStatus.Text = "TARGET: <font color='rgb(0,255,0)'>VALID</font>"
						for a,b in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
							if not target.Character and target.Character.HumanoidRootPart then return end
							root.CFrame = target.Character.HumanoidRootPart.CFrame
							b.Parent = game.Players.LocalPlayer.Character

							player.Character:WaitForChild(tostring(b)):WaitForChild("Event"):FireServer(
								"slash",
								target.Character,
								root.CFrame.LookVector * b:WaitForChild("Power").Value
							)
							task.wait(0.25)
							b.Parent = game.Players.LocalPlayer.Backpack
						end
					end
				else
					slapStatus.Text = "TARGET: <font color='rgb(255,0,0)'>INVALID</font>"
				end
				task.wait(0.5)
			end
		end)
	else
		slapStatus.Text = "TARGET: <font color='rgb(255,0,0)'>INVALID</font>"
	end
end)


updateStatus()

-- obviously not my GUI, only logic was mine. 
-- This is literally only for my use so yes, i asked chatgpt for a ui. 
-- I know, kill me! How dare I!
-- ( in the time taken to make the gui THEN gui2lua and IMPLIMENT the logic would be time i could've spent trolling)
