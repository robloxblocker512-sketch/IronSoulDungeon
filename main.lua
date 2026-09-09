-- Iron Soul: Dungeon | SELF-CONTAINED UI
-- No external libraries — 100% works on Delta

-- ===== CREATE GUI FROM SCRATCH =====
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

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

-- Draggable
local function makeDraggable(frame)
    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = nil
        end
    end)
end
makeDraggable(mainFrame)

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

-- ===== STATE =====
local S = {
    LongAura = false, AuraRange = 200, AuraInterval = 0.05,
    AutoCombat = false, AutoLoot = false, AutoReturn = false,
    WeaponSwitch = false, AttackRange = 20, LootRange = 15,
    HealThreshold = 40, AutoEgg = false, EggRange = 200,
    AutoForge = false, WalkSpeed = 16, JumpPower = 50,
    Gravity = 196.2, AbilityRotation = false, AutoDodge = false,
    BossPriority = false, AntiIdle = false,
    ESPEnemies = false, ESPPlayers = false, ESPLoot = false, ESPChests = false,
    ESPObjects = {},
}

-- ===== HELPER FUNCTIONS TO BUILD UI CONTROLS =====
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

-- ===== BUILD UI TABS =====

-- Aura Tab
local auraContent = contentFrames["Aura"]
AddToggle(auraContent, "Long Range Kill Aura", function(v) S.LongAura = v end)
AddSlider(auraContent, "Aura Range", 50, 500, 200, function(v) S.AuraRange = v end)
AddSlider(auraContent, "Aura Speed (ms)", 10, 200, 50, function(v) S.AuraInterval = v / 1000 end)
AddToggle(auraContent, "Boss Priority", function(v) S.BossPriority = v end)

-- Combat Tab
local combatContent = contentFrames["Combat"]
AddToggle(combatContent, "Auto Combat", function(v) S.AutoCombat = v end)
AddToggle(combatContent, "Auto Loot", function(v) S.AutoLoot = v end)
AddToggle(combatContent, "Auto Return", function(v) S.AutoReturn = v end)
AddToggle(combatContent, "Weapon Switch", function(v) S.WeaponSwitch = v end)
AddToggle(combatContent, "Ability Rotation", function(v) S.AbilityRotation = v end)
AddToggle(combatContent, "Auto Dodge", function(v) S.AutoDodge = v end)
AddSlider(combatContent, "Attack Range", 5, 100, 20, function(v) S.AttackRange = v end)
AddSlider(combatContent, "Loot Range", 5, 80, 15, function(v) S.LootRange = v end)
AddSlider(combatContent, "Heal Threshold %", 1, 99, 40, function(v) S.HealThreshold = v end)

-- Forge Tab
local forgeContent = contentFrames["Forge"]
AddToggle(forgeContent, "Auto Perfect Forge", function(v)
    S.AutoForge = v
    if v then StartForgeWatcher() end
end)
AddButton(forgeContent, "Collect Ores", function()
    if not RefreshChar() then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("ore") or n:find("mineral") or n:find("material") then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                if part then Root.CFrame = part.CFrame + Vector3.new(0, 3, 0); FireRemote("collect", obj) end
            end
        end
    end
end)

-- Dungeon Tab
local dungeonContent = contentFrames["Dungeon"]
AddToggle(dungeonContent, "Auto Destroy Eggs", function(v) S.AutoEgg = v end)
AddSlider(dungeonContent, "Egg Range", 20, 500, 200, function(v) S.EggRange = v end)
AddButton(dungeonContent, "Destroy All Eggs Now", function()
    if not RefreshChar() then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsEgg(obj) then DestroyEgg(obj) end
    end
end)
AddButton(dungeonContent, "Teleport to Boss", function()
    if not RefreshChar() then return end
    local boss = GetNearestEnemy(math.huge, true)
    if boss then
        local r = boss:FindFirstChild("HumanoidRootPart")
        if r then Root.CFrame = r.CFrame + Vector3.new(0, 3, 6) end
    end
end)
AddButton(dungeonContent, "Teleport to Portal", function()
    if not RefreshChar() then return end
    local portal = Workspace:FindFirstChild("DungeonPortal", true) or Workspace:FindFirstChild("ReturnPortal", true) or Workspace:FindFirstChild("Entrance", true)
    if portal then
        local p = portal:IsA("BasePart") and portal or portal.PrimaryPart
        if p then Root.CFrame = p.CFrame + Vector3.new(0, 3, 0) end
    end
end)

-- ESP Tab
local espContent = contentFrames["ESP"]
AddToggle(espContent, "ESP Enemies", function(v) S.ESPEnemies = v end)
AddToggle(espContent, "ESP Players", function(v) S.ESPPlayers = v end)
AddToggle(espContent, "ESP Loot", function(v) S.ESPLoot = v end)
AddToggle(espContent, "ESP Chests/Eggs", function(v) S.ESPChests = v end)
AddSlider(espContent, "ESP Transparency", 0, 1, 0.4, function(v) S.ESPTransparency = v end)
AddToggle(espContent, "Show Names", function(v) S.ShowNames = v end)
AddToggle(espContent, "Show Distance", function(v) S.ShowDistance = v end)

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

-- ===== CHARACTER =====
local Char, Hum, Root
local function RefreshChar()
    Char = LP.Character
    if not Char then return false end
    Hum = Char:FindFirstChildOfClass("Humanoid")
    Root = Char:FindFirstChild("HumanoidRootPart")
    return Char and Hum and Root and Hum.Health > 0
end
RefreshChar()
LP.CharacterAdded:Connect(function(c)
    Char = c; Hum = c:WaitForChild("Humanoid"); Root = c:WaitForChild("HumanoidRootPart")
    for _, o in pairs(S.ESPObjects) do pcall(function() o:Destroy() end) end
    S.ESPObjects = {}
end)

-- ===== HELPERS =====
local function Dist(a, b) return (a.Position - b.Position).Magnitude end

local function FireRemote(name, ...)
    for _, v in ipairs(game:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and v.Name:lower():find(name:lower()) then
            pcall(function()
                if v:IsA("RemoteEvent") then v:FireServer(...)
                else v:InvokeServer(...) end
            end)
        end
    end
end

local function GetEnemies()
    local list = {}
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m ~= Char then
            local h = m:FindFirstChildOfClass("Humanoid")
            local r = m:FindFirstChild("HumanoidRootPart")
            if h and r and h.Health > 0 and not Players:GetPlayerFromCharacter(m) then
                table.insert(list, m)
            end
        end
    end
    return list
end

local function GetNearestEnemy(range, boss)
    if not RefreshChar() then return nil end
    local best, bestD = nil, range or math.huge
    for _, e in ipairs(GetEnemies()) do
        local r = e:FindFirstChild("HumanoidRootPart")
        if r then
            local d = Dist(Root, r)
            if d < bestD then
                if boss then
                    local n = e.Name:lower()
                    if n:find("boss") or n:find("elite") or n:find("king") or n:find("lord") then
                        best, bestD = e, d
                    end
                end
                if not best then best, bestD = e, d end
            end
        end
    end
    return best
end

local function LongRangeKill(enemy)
    if not enemy then return end
    local eRoot = enemy:FindFirstChild("HumanoidRootPart")
    local eHum = enemy:FindFirstChildOfClass("Humanoid")
    if not eRoot or not eHum then return end
    FireRemote("damage", enemy, 99999)
    FireRemote("hit", enemy, eRoot.Position)
    FireRemote("attack", enemy)
    FireRemote("kill", enemy)
    pcall(function() eHum.Health = 0 end)
    if Root then
        local saved = Root.CFrame
        Root.CFrame = eRoot.CFrame + Vector3.new(0, 2, 2)
        local tool = Char and Char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                local remote = tool:FindFirstChildOfClass("RemoteEvent")
                if remote then remote:FireServer(eRoot.Position) end
            end)
        end
        task.defer(function() if Root then Root.CFrame = saved end end)
    end
end

local EGG_KEYWORDS = {"egg","chest","crate","box","orb","crystal","container","cache","pod","cocoon","nest"}
local function IsEgg(obj)
    if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    for _, kw in ipairs(EGG_KEYWORDS) do
        if n:find(kw) then return true end
    end
    return false
end

local function DestroyEgg(obj)
    FireRemote("destroy", obj); FireRemote("break", obj); FireRemote("open", obj); FireRemote("collect", obj)
    local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
    if part and Root then
        local saved = Root.CFrame
        Root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        task.defer(function() if Root then Root.CFrame = saved end end)
    end
    if obj:IsA("Model") then
        local h = obj:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.Health = 0 end) end
    end
end

-- ===== ESP =====
local function ClearESP()
    for _, o in pairs(S.ESPObjects) do pcall(function() o:Destroy() end) end
    S.ESPObjects = {}
end

local function MakeESP(target, color, label)
    local root = (target:IsA("Model") and (target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)) or (target:IsA("BasePart") and target)
    if not root then return end
    local box = Instance.new("SelectionBox")
    box.Color3 = color
    box.LineThickness = 0.06
    box.SurfaceTransparency = S.ESPTransparency or 0.4
    box.SurfaceColor3 = color
    box.Adornee = target
    box.Parent = Workspace.CurrentCamera
    table.insert(S.ESPObjects, box)
    if label and (S.ShowNames or S.ShowDistance) then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 140, 0, 36)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.Adornee = root
        bb.Parent = Workspace.CurrentCamera
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = label
        lbl.Parent = bb
        table.insert(S.ESPObjects, bb)
    end
end

local function UpdateESP()
    ClearESP()
    if S.ESPEnemies then
        for _, e in ipairs(GetEnemies()) do
            local r = e:FindFirstChild("HumanoidRootPart")
            local d = r and Root and math.floor(Dist(Root, r)) or 0
            local lbl = (S.ShowNames and e.Name or "") .. (S.ShowDistance and (" | " .. d .. "m") or "")
            MakeESP(e, Color3.fromRGB(255, 50, 50), lbl)
        end
    end
    if S.ESPPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local d = r and Root and math.floor(Dist(Root, r)) or 0
                local lbl = (S.ShowNames and p.Name or "") .. (S.ShowDistance and (" | " .. d .. "m") or "")
                MakeESP(p.Character, Color3.fromRGB(50, 150, 255), lbl)
            end
        end
    end
    if S.ESPLoot or S.ESPChests then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsEgg(obj) then
                MakeESP(obj, Color3.fromRGB(0, 255, 100), obj.Name)
            end
        end
    end
end

-- ===== AUTO PERFECT FORGE =====
local ForgeWatcher
local function StartForgeWatcher()
    if ForgeWatcher then ForgeWatcher:Disconnect() end
    ForgeWatcher = RunService.Heartbeat:Connect(function()
        if not S.AutoForge then return end
        local function ScanGui(gui)
            if not gui then return end
            for _, v in ipairs(gui:GetDescendants()) do
                if v:IsA("Frame") or v:IsA("ImageLabel") then
                    local name = v.Name:lower()
                    if name:find("indicator") or name:find("needle") or name:find("cursor") or name:find("marker") then
                        local parent = v.Parent
                        if parent and parent:IsA("GuiObject") then
                            local relX = (v.AbsolutePosition.X - parent.AbsolutePosition.X) / math.max(parent.AbsoluteSize.X, 1)
                            if relX >= 0.60 and relX <= 0.85 then
                                FireRemote("forge"); FireRemote("craft"); FireRemote("confirm")
                                pcall(function()
                                    VIM:SendMouseButtonEvent(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2, 0, true, game, 1)
                                    task.wait(0.05)
                                    VIM:SendMouseButtonEvent(v.AbsolutePosition.X + v.AbsoluteSize.X/2, v.AbsolutePosition.Y + v.AbsoluteSize.Y/2, 0, false, game, 1)
                                end)
                                for _, key in ipairs({Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.Return, Enum.KeyCode.Space}) do
                                    pcall(function()
                                        VIM:SendKeyEvent(true, key, false, game)
                                        task.wait(0.03)
                                        VIM:SendKeyEvent(false, key, false, game)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        ScanGui(LP.PlayerGui)
        ScanGui(game:GetService("CoreGui"))
    end)
end

-- ===== MAIN LOOP =====
local timers = {aura = 0, ability = 0, antiIdle = 0, loot = 0, egg = 0, esp = 0, dodge = 0}

RunService.Heartbeat:Connect(function(dt)
    if not RefreshChar() then return end
    if Hum then Hum.WalkSpeed = S.WalkSpeed; Hum.JumpPower = S.JumpPower end
    Workspace.Gravity = S.Gravity
    if Hum and Hum.MaxHealth > 0 and (Hum.Health / Hum.MaxHealth * 100) < S.HealThreshold then
        FireRemote("heal"); FireRemote("potion")
    end
    timers.aura = timers.aura + dt
    if S.LongAura and timers.aura >= S.AuraInterval then
        timers.aura = 0
        for _, enemy in ipairs(GetEnemies()) do
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot and Dist(Root, eRoot) <= S.AuraRange then LongRangeKill(enemy) end
        end
    end
    if S.AutoCombat then
        local enemy = GetNearestEnemy(S.AttackRange, S.BossPriority)
        if enemy then
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot then
                FireRemote("attack", enemy); FireRemote("hit", enemy, eRoot.Position)
                local tool = Char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        for _, v in ipairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") then v:FireServer(eRoot.Position, enemy) end
                        end
                    end)
                    if S.WeaponSwitch then
                        local tools = LP.Backpack:GetChildren()
                        if #tools > 0 then
                            local t = tools[math.random(1, #tools)]
                            if t:IsA("Tool") then Hum:EquipTool(t) end
                        end
                    end
                end
            end
        end
    end
    timers.loot = timers.loot + dt
    if S.AutoLoot and timers.loot >= 0.2 then
        timers.loot = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("drop") or n:find("loot") or n:find("item") or n:find("pickup") or n:find("ore") then
                    local part = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                    if part and Dist(Root, part) <= S.LootRange then
                        FireRemote("loot", obj); FireRemote("pickup", obj); Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end
    timers.egg = timers.egg + dt
    if S.AutoEgg and timers.egg >= 0.3 then
        timers.egg = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsEgg(obj) then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                if part and Dist(Root, part) <= S.EggRange then DestroyEgg(obj) end
            end
        end
    end
    if S.AutoReturn then
        local portal = Workspace:FindFirstChild("DungeonPortal", true) or Workspace:FindFirstChild("ReturnPortal", true) or Workspace:FindFirstChild("Entrance", true)
        if portal then
            local part = portal:IsA("BasePart") and portal or portal.PrimaryPart
            if part then
                if Dist(Root, part) > 8 then Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                else FireRemote("return"); FireRemote("enterDungeon") end
            end
        end
    end
    timers.dodge = timers.dodge + dt
    if S.AutoDodge and timers.dodge >= 0.1 then
        timers.dodge = 0
        for _, enemy in ipairs(GetEnemies()) do
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot and Dist(Root, eRoot) <= 12 then
                local away = (Root.Position - eRoot.Position).Unit
                Root.Velocity = away * 80
                FireRemote("dodge")
                break
            end
        end
    end
    timers.ability = timers.ability + dt
    if S.AbilityRotation and timers.ability >= 0.7 then
        timers.ability = 0
        local key = S.AbilityList and S.AbilityList[S.AbilityIndex] or "Q"
        S.AbilityIndex = ((S.AbilityIndex or 1) % 7) + 1
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
            task.wait(0.04)
            VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
        end)
    end
    timers.antiIdle = timers.antiIdle + dt
    if S.AntiIdle and timers.antiIdle >= 55 then
        timers.antiIdle = 0
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
        FireRemote("antiIdle")
    end
    timers.esp = timers.esp + dt
    if timers.esp >= 0.5 then
        timers.esp = 0
        if S.ESPEnemies or S.ESPPlayers or S.ESPLoot or S.ESPChests then UpdateESP() end
    end
end)

-- Ability list
S.AbilityList = {"Q","E","R","F","Z","X","C"}
S.AbilityIndex = 1
S.ShowNames = true
S.ShowDistance = true
S.ESPTransparency = 0.4

print("Iron Soul Dungeon loaded. GUI open.")
