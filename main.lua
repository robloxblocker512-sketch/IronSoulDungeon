-- Iron Soul Dungeon - CUSTOM GUI
-- 100% Working on Delta | Kill Aura + ESP

local player = game.Players.LocalPlayer

-- ===== CREATE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "IronSoulGUI"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 200)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.BorderSizePixel = 0
title.Text = "Iron Soul Dungeon"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ===== KILL AURA TOGGLE =====
local killFrame = Instance.new("Frame")
killFrame.Size = UDim2.new(1, -20, 0, 35)
killFrame.Position = UDim2.new(0, 10, 0, 40)
killFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
killFrame.BorderSizePixel = 0
killFrame.Parent = mainFrame

local killLabel = Instance.new("TextLabel")
killLabel.Size = UDim2.new(0.6, 0, 1, 0)
killLabel.BackgroundTransparency = 1
killLabel.Text = "Kill Aura"
killLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
killLabel.TextSize = 14
killLabel.TextXAlignment = Enum.TextXAlignment.Left
killLabel.Font = Enum.Font.GothamBold
killLabel.Parent = killFrame

local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(0, 60, 0, 25)
killBtn.Position = UDim2.new(0.7, 0, 0.5, -12)
killBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
killBtn.BorderSizePixel = 0
killBtn.Text = "OFF"
killBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
killBtn.TextSize = 12
killBtn.Font = Enum.Font.GothamBold
killBtn.Parent = killFrame

local killState = false
killBtn.MouseButton1Click:Connect(function()
    killState = not killState
    killBtn.Text = killState and "ON" or "OFF"
    killBtn.BackgroundColor3 = killState and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 85)
    print("Kill Aura:", killState)
end)

-- ===== ESP TOGGLE =====
local espFrame = Instance.new("Frame")
espFrame.Size = UDim2.new(1, -20, 0, 35)
espFrame.Position = UDim2.new(0, 10, 0, 85)
espFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
espFrame.BorderSizePixel = 0
espFrame.Parent = mainFrame

local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0.6, 0, 1, 0)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP (Players + NPCs)"
espLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
espLabel.TextSize = 14
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Font = Enum.Font.GothamBold
espLabel.Parent = espFrame

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0, 60, 0, 25)
espBtn.Position = UDim2.new(0.7, 0, 0.5, -12)
espBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
espBtn.BorderSizePixel = 0
espBtn.Text = "OFF"
espBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
espBtn.TextSize = 12
espBtn.Font = Enum.Font.GothamBold
espBtn.Parent = espFrame

local espState = false
espBtn.MouseButton1Click:Connect(function()
    espState = not espState
    espBtn.Text = espState and "ON" or "OFF"
    espBtn.BackgroundColor3 = espState and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 85)
    print("ESP:", espState)
end)

-- ===== STATUS LABEL =====
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 130)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- ============================================================
-- KILL AURA LOGIC
-- ============================================================

local function GetEnemies()
    local enemies = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if not game.Players:GetPlayerFromCharacter(obj) then
                    table.insert(enemies, obj)
                end
            end
        end
    end
    return enemies
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not killState then continue end
        
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        for _, enemy in ipairs(GetEnemies()) do
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist <= 200 then
                    local hum = enemy:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.Health = 0
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- ESP LOGIC
-- ============================================================

local ESPObjects = {}

local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        pcall(function() obj:Destroy() end)
    end
    ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not espState then return end
    
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
                highlight.OutlineColor = color
                highlight.OutlineTransparency = 0
                table.insert(ESPObjects, highlight)
            end
        end
    end
end

-- ESP update loop
task.spawn(function()
    while true do
        task.wait(1)
        if espState then
            pcall(UpdateESP)
        else
            ClearESP()
        end
    end
end)

-- ============================================================
-- STATUS UPDATE
-- ============================================================

task.spawn(function()
    while true do
        task.wait(1)
        local status = ""
        if killState then status = status .. "Kill Aura ON " end
        if espState then status = status .. "ESP ON " end
        if status == "" then status = "All OFF" end
        statusLabel.Text = "Status: " .. status
    end
end)

print("Iron Soul Dungeon GUI Loaded - Click buttons to toggle")
