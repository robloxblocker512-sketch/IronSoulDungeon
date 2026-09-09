-- IRON SOUL DUNGEON - KILL AURA (NPC ONLY)
-- Follows and kills NPC enemies

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "IronSoulKillAura"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 160)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Kill Aura"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.2, 0, 1, 0)
ToggleBtn.Position = UDim2.new(0.6, 0, 0, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0.2, 0, 1, 0)
CloseBtn.Position = UDim2.new(0.8, 0, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = Header

local DistanceInput = Instance.new("TextBox")
DistanceInput.Size = UDim2.new(0.9, 0, 0, 30)
DistanceInput.Position = UDim2.new(0.05, 0, 0, 50)
DistanceInput.BackgroundColor3 = Color3.fromRGB(160, 160, 160)
DistanceInput.BorderSizePixel = 0
DistanceInput.Text = "15"
DistanceInput.TextColor3 = Color3.fromRGB(30, 30, 30)
DistanceInput.Font = Enum.Font.SourceSans
DistanceInput.TextSize = 14
DistanceInput.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 95)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- Logic
local IsActive = false
local SlowFlySpeed = 12

local function UseWeapon()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

local function GetNearestEnemy()
    local char = LocalPlayer.Character
    if not char then return nil, math.huge end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, math.huge end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if not Players:GetPlayerFromCharacter(obj) then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist < nearestDist then
                        nearest = obj
                        nearestDist = dist
                    end
                end
            end
        end
    end
    return nearest, nearestDist
end

local function StartKillAura()
    IsActive = true
    ToggleBtn.Text = "ON"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
    StatusLabel.Text = "Status: ACTIVE"
    
    task.spawn(function()
        while IsActive do
            task.wait(0.1)
            local char = LocalPlayer.Character
            if not char then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            local target, dist = GetNearestEnemy()
            
            if target then
                local hrp = target:FindFirstChild("HumanoidRootPart")
                local hum = target:FindFirstChildOfClass("Humanoid")
                
                if hrp and hum and hum.Health > 0 then
                    local range = tonumber(DistanceInput.Text) or 15
                    
                    if dist <= range then
                        root.CFrame = CFrame.new(root.Position, hrp.Position)
                        UseWeapon()
                        -- Fallback: direct kill
                        hum.Health = 0
                        StatusLabel.Text = "Attacking: " .. target.Name
                    else
                        -- Move toward enemy
                        local dir = (hrp.Position - root.Position).Unit
                        root.Velocity = dir * SlowFlySpeed
                        root.CFrame = CFrame.new(root.Position, hrp.Position)
                        StatusLabel.Text = "Chasing: " .. target.Name .. " (" .. math.floor(dist) .. "s)"
                    end
                end
            else
                StatusLabel.Text = "No enemies found"
            end
        end
    end)
end

local function StopKillAura()
    IsActive = false
    ToggleBtn.Text = "OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    StatusLabel.Text = "Status: OFF"
    
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, 0, 0)
        end
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    if IsActive then
        StopKillAura()
    else
        StartKillAura()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopKillAura()
    ScreenGui:Destroy()
end)

print("Iron Soul Kill Aura Loaded - Click ON to start killing NPCs")
