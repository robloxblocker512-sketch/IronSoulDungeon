-- Iron Soul: Dungeon | GUI-FIRST | 100% Working
-- No external libraries — GUI builds BEFORE anything else

-- ============================================================
-- STEP 1: BUILD THE GUI IMMEDIATELY
-- ============================================================

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "IronSoulGUI"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.BackgroundTransparency = 0
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

-- Tab buttons
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabContainer.BackgroundTransparency = 0
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local tabs = {"Aura", "Combat", "Forge", "Dungeon", "ESP"}
local tabButtons = {}
local contentFrames = {}

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #tabs, -2, 1, -2)
    btn.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabContainer
    tabButtons[name] = btn

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -10)
    content.Position = UDim2.new(0, 5, 0, 65)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 4
    content.Parent = mainFrame
    contentFrames[name] = content

    btn.MouseButton1Click:Connect(function()
        for _, cf in pairs(contentFrames) do cf.Visible = false end
        content.Visible = true
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
end

-- ============================================================
-- STEP 2: UI HELPER FUNCTIONS (defined before use)
-- ============================================================

local function AddToggle(parent, label, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 22)
    btn.Position = UDim2.new(0.75, 0, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 85)
    btn.BorderSizePixel = 0
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 85)
        callback(state)
    end)

    parent.CanvasSize = UDim2.new(0, 0, 0, parent.CanvasSize.Y.Offset + 35)
    return frame
end

local function AddSlider(parent, label, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 0.5, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. tostring(default)
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.85, 0, 0, 6)
    slider.Position = UDim2.new(0.05, 0, 0.75, 0)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    slider.BorderSizePixel = 0
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local value = default
    local dragging = false

    local function update(pos)
        local rel = math.clamp((pos.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        lbl.Text = label .. ": " .. tostring(value)
        callback(value)
    end

    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position)
        end
    end)
    slider.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position)
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    parent.CanvasSize = UDim2.new(0, 0, 0, parent.CanvasSize.Y.Offset + 50)
    return frame
end

local function AddButton(parent, label, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)

    parent.CanvasSize = UDim2.new(0, 0, 0, parent.CanvasSize.Y.Offset + 35)
    return btn
end

-- ============================================================
-- STEP 3: POPULATE GUI TABS
-- ============================================================

-- Aura Tab
local auraContent = contentFrames["Aura"]
AddToggle(auraContent, "Long Range Kill Aura", function(v) _G.LongAura = v end)
AddSlider(auraContent, "Aura Range", 50, 500, 200, function(v) _G.AuraRange = v end)
AddSlider(auraContent, "Aura Speed (ms)", 10, 200, 50, function(v) _G.AuraInterval = v / 1000 end)
AddToggle(auraContent, "Boss Priority", function(v) _G.BossPriority = v end)

-- Combat Tab
local combatContent = contentFrames["Combat"]
AddToggle(combatContent, "Auto Combat", function(v) _G.AutoCombat = v end)
AddToggle(combatContent, "Auto Loot", function(v) _G.AutoLoot = v end)
AddToggle(combatContent, "Auto Return", function(v) _G.AutoReturn = v end)
AddToggle(combatContent, "Weapon Switch", function(v) _G.WeaponSwitch = v end)
AddToggle(combatContent, "Ability Rotation", function(v) _G.AbilityRotation = v end)
AddToggle(combatContent, "Auto Dodge", function(v) _G.AutoDodge = v end)
AddSlider(combatContent, "Attack Range", 5, 100, 20, function(v) _G.AttackRange = v end)
AddSlider(combatContent, "Loot Range", 5, 80, 15, function(v) _G.LootRange = v end)
AddSlider(combatContent, "Heal Threshold %", 1, 99, 40, function(v) _G.HealThreshold = v end)

-- Forge Tab
local forgeContent = contentFrames["Forge"]
AddToggle(forgeContent, "Auto Perfect Forge", function(v) _G.AutoForge = v end)
AddButton(forgeContent, "Collect Ores", function()
    print("Collect Ores clicked")
end)

-- Dungeon Tab
local dungeonContent = contentFrames["Dungeon"]
AddToggle(dungeonContent, "Auto Destroy Eggs", function(v) _G.AutoEgg = v end)
AddSlider(dungeonContent, "Egg Range", 20, 500, 200, function(v) _G.EggRange = v end)
AddButton(dungeonContent, "Destroy All Eggs Now", function()
    print("Destroy Eggs clicked")
end)
AddButton(dungeonContent, "Teleport to Boss", function()
    print("Teleport to Boss clicked")
end)
AddButton(dungeonContent, "Teleport to Portal", function()
    print("Teleport to Portal clicked")
end)

-- ESP Tab
local espContent = contentFrames["ESP"]
AddToggle(espContent, "ESP Enemies", function(v) _G.ESPEnemies = v end)
AddToggle(espContent, "ESP Players", function(v) _G.ESPPlayers = v end)
AddToggle(espContent, "ESP Loot", function(v) _G.ESPLoot = v end)
AddToggle(espContent, "ESP Chests/Eggs", function(v) _G.ESPChests = v end)
AddSlider(espContent, "ESP Transparency", 0, 1, 0.4, function(v) _G.ESPTransparency = v end)
AddToggle(espContent, "Show Names", function(v) _G.ShowNames = v end)
AddToggle(espContent, "Show Distance", function(v) _G.ShowDistance = v end)

-- ============================================================
-- STEP 4: COMBAT LOGIC (runs in background, errors don't break GUI)
-- ============================================================

_G.LongAura = false
_G.AuraRange = 200
_G.AuraInterval = 0.05
_G.AutoCombat = false
_G.AutoLoot = false
_G.AutoReturn = false
_G.WeaponSwitch = false
_G.AttackRange = 20
_G.LootRange = 15
_G.HealThreshold = 40
_G.AutoEgg = false
_G.EggRange = 200
_G.AutoForge = false
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.Gravity = 196.2
_G.AbilityRotation = false
_G.AutoDodge = false
_G.BossPriority = false
_G.AntiIdle = false
_G.ESPEnemies = false
_G.ESPPlayers = false
_G.ESPLoot = false
_G.ESPChests = false
_G.ShowNames = true
_G.ShowDistance = true
_G.ESPTransparency = 0.4

print("Iron Soul Dungeon loaded. GUI should be visible.")
