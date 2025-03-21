--[[
    Game link: https://www.roblox.com/games/4878988249/KIRYU-YOHEI-Mighty-Omega
    Description: Shows pseduo hitbox upon clicking
]]--

local cloneref = cloneref or function(...) return ... end
local UserInputService = cloneref(game:GetService("UserInputService")) or game:GetService("UserInputService")

function ReturnRoot()
    local success, result = pcall(function()
        return game.Players.LocalPlayer.Character.HumanoidRootPart
    end)

    if success and result then
        return result
    end
end

local function createEdge(parent, startPos, endPos)
    local edge = Instance.new("Part")
    edge.Parent = parent
    edge.Size = Vector3.new(0.2, 0.2, (startPos - endPos).Magnitude)
    edge.Position = (startPos + endPos) / 2
    edge.Anchored = true
    edge.CanCollide = false
    edge.Material = Enum.Material.Neon
    edge.Color = Color3.new(1, 0, 0)
    edge.Transparency = 0
    edge.CFrame = CFrame.lookAt(startPos, endPos) * CFrame.new(0, 0, -edge.Size.Z / 2)
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local LPRoot = ReturnRoot()

        if LPRoot then 
            local HitboxContainer = Instance.new("Model")
            HitboxContainer.Parent = workspace
            
            local CubeSize = Vector3.new(5, 7, 4)
            local rootCFrame = LPRoot.CFrame * CFrame.new(0, 0, -2) 
            local Half = CubeSize / 2
            
            local Corners = {
                rootCFrame.Position + rootCFrame.RightVector * -Half.X + rootCFrame.UpVector * -Half.Y + rootCFrame.LookVector * -Half.Z,
                rootCFrame.Position + rootCFrame.RightVector *  Half.X + rootCFrame.UpVector * -Half.Y + rootCFrame.LookVector * -Half.Z,
                rootCFrame.Position + rootCFrame.RightVector *  Half.X + rootCFrame.UpVector *  Half.Y + rootCFrame.LookVector * -Half.Z,
                rootCFrame.Position + rootCFrame.RightVector * -Half.X + rootCFrame.UpVector *  Half.Y + rootCFrame.LookVector * -Half.Z,
                rootCFrame.Position + rootCFrame.RightVector * -Half.X + rootCFrame.UpVector * -Half.Y + rootCFrame.LookVector *  Half.Z,
                rootCFrame.Position + rootCFrame.RightVector *  Half.X + rootCFrame.UpVector * -Half.Y + rootCFrame.LookVector *  Half.Z,
                rootCFrame.Position + rootCFrame.RightVector *  Half.X + rootCFrame.UpVector *  Half.Y + rootCFrame.LookVector *  Half.Z,
                rootCFrame.Position + rootCFrame.RightVector * -Half.X + rootCFrame.UpVector *  Half.Y + rootCFrame.LookVector *  Half.Z
            }

            local Edges = {
                {1, 2}, {2, 3}, {3, 4}, {4, 1},
                {5, 6}, {6, 7}, {7, 8}, {8, 5},
                {1, 5}, {2, 6}, {3, 7}, {4, 8} 
            }

            for _, edge in pairs(Edges) do
                createEdge(HitboxContainer, Corners[edge[1]], Corners[edge[2]])
            end
            task.wait(0.25)
            HitboxContainer:Destroy()
        end
    end
end)
