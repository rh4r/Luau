local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VerboseTerminal"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local terminalFrame = Instance.new("Frame")
terminalFrame.Name = "TerminalFrame"
terminalFrame.Size = UDim2.new(0, 400, 0, 300)
terminalFrame.Position = UDim2.new(0, 50, 0, 50)
terminalFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45) 
terminalFrame.BorderSizePixel = 0
terminalFrame.Active = true
terminalFrame.Draggable = true
terminalFrame.Parent = screenGui

Instance.new("UICorner", terminalFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", terminalFrame).Color = Color3.fromRGB(200, 200, 200)

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -40, 0, 30)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Steal A Labubu (Verbose Terminal)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 17
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = terminalFrame

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundTransparency = 1
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextSize = 20
closeButton.Parent = terminalFrame

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local logFrame = Instance.new("ScrollingFrame")
logFrame.Name = "LogFrame"
logFrame.Size = UDim2.new(1, -10, 1, -40)
logFrame.Position = UDim2.new(0, 5, 0, 35)
logFrame.BackgroundTransparency = 1
logFrame.BorderSizePixel = 0
logFrame.ScrollBarThickness = 6
logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
logFrame.Parent = terminalFrame

local layout = Instance.new("UIListLayout", logFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 2)

local Verbose = {}
Verbose.MaxLogs = 100

function Verbose:Log(message)
	local logLine = Instance.new("TextLabel")
	logLine.Size = UDim2.new(1, 0, 0, 20)
	logLine.BackgroundTransparency = 1
	logLine.TextXAlignment = Enum.TextXAlignment.Left
	logLine.Font = Enum.Font.Code
	logLine.TextSize = 14
	logLine.TextColor3 = Color3.fromRGB(180, 255, 180)
	logLine.Text = "[+] " .. message
	logLine.Parent = logFrame

	logFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)

	local count = 0
	for _, child in ipairs(logFrame:GetChildren()) do
		if child:IsA("TextLabel") then
			count += 1
		end
	end
	if count > self.MaxLogs then
		for _, child in ipairs(logFrame:GetChildren()) do
			if child:IsA("TextLabel") then
				child:Destroy()
				break
			end
		end
	end
end


task.wait(1)
Verbose:Log("Booting Labubu acquisition module...")
task.wait(0.5)
Verbose:Log("Running encrypted bypass subroutine...")
task.wait(0.5)
Verbose:Log("Target Labubu acquired.")
task.wait(0.5)
Verbose:Log("Extraction initiated...")
task.wait(1)
Verbose:Log("✅ Labubu successfully stolen.")
