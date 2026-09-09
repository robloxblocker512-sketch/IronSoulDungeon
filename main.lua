-- IRON SOUL DUNGEON - WORKING SCRIPT
-- Kill Aura + ESP + Auto Farm

local player = game.Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- ===== KILL AURA =====
local killAuraEnabled = false
local espEnabled = false
local espObjects = {}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Iron Soul Dungeon"
titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Kill Aura Button
local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(0.8, 0, 0, 30)
killBtn.Position = UDim2.new(0.1, 0, 0, 40)
killBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
killBtn.BorderSizePixel = 0
killBtn.Text = "Kill Aura: OFF"
killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killBtn.TextSize = 14
killBtn.Font = Enum.Font.GothamBold
killBtn.Parent = mainFrame

killBtn.MouseButton1Click:Connect(function()
    killAuraEnabled = not killAuraEnabled
    killBtn.Text = killAuraEnabled and "Kill Aura: ON" or "Kill Aura: OFF"
    killBtn.BackgroundColor3 = killAuraEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
end)

-- ESP Button
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0.8, 0, 0, 30)
espBtn.Position = UDim2.new(0.1, 0, 0, 80)
espBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
espBtn.BorderSizePixel = 0
espBtn.Text = "ESP: OFF"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 14
espBtn.Font = Enum.Font.GothamBold
espBtn.Parent = mainFrame

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
    if not espEnabled then
        for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
        espObjects = {}
    end
end)

-- ===== KILL AURA LOOP =====
task.spawn(function()
    while true do
        task.wait(0.1)
        if not killAuraEnabled then continue end
        
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    if not game.Players:GetPlayerFromCharacter(obj) then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist <= 200 then
                            hum.Health = 0
                        end
                    end
                end
            end
        end
    end
end)

-- ===== ESP LOOP =====
task.spawn(function()
    while true do
        task.wait(0.5)
        if not espEnabled then continue end
        
        -- Clear old ESP
        for _, obj in pairs(espObjects) do pcall(function() obj:Destroy() end) end
        espObjects = {}
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local isPlayer = game.Players:GetPlayerFromCharacter(obj)
                    local color = isPlayer and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(255, 50, 50)
                    
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = obj
                    highlight.FillColor = color
                    highlight.FillTransparency = 0.5
                    table.insert(espObjects, highlight)
                end
            end
        end
    end
end)

print("Script loaded! Click the buttons to toggle Kill Aura and ESP.")
