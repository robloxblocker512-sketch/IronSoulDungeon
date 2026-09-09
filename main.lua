-- Iron Soul Dungeon | Delta Executor Script
-- Rayfield UI | Full Feature Build

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Iron Soul Dungeon",
    LoadingSubtitle = "by spinach",
    Theme = "Dark",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

-- ═══════════════════════════════════════════
-- SERVICES & CORE
-- ═══════════════════════════════════════════

local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local Workspace     = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer   = Players.LocalPlayer
local Character     = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid      = Character:WaitForChild("Humanoid")
local RootPart      = Character:WaitForChild("HumanoidRootPart")
local Camera        = Workspace.CurrentCamera

-- ═══════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════

local State = {
    AutoCombat     = false,
    AutoLoot       = false,
    AutoReturn     = false,
    WeaponSwitch   = false,
    AntiIdle       = false,
    KillAura       = false,
    AbilityRotation= false,
    AutoDodge      = false,
    BossPriority   = false,
    ESPEnemies     = false,
    ESPPlayers     = false,
    ESPLoot        = false,
    ESPChests      = false,
    ShowNames      = true,
    ShowDistance   = true,

    AttackRange    = 20,
    LootRange      = 15,
    WalkSpeed      = 16,
    JumpPower      = 50,
    Gravity        = 196.2,
    HealThreshold  = 40,
    KillAuraRange  = 25,
    ESPTransparency= 0.5,

    ESPColor       = Color3.fromRGB(255, 50, 50),
    PlayerESPColor = Color3.fromRGB(50, 150, 255),
    LootESPColor   = Color3.fromRGB(255, 215, 0),
    ChestESPColor  = Color3.fromRGB(0, 255, 100),

    ESPObjects     = {},
    AbilityIndex   = 1,
}

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════

local function GetCharacter()
    Character  = LocalPlayer.Character
    if not Character then return false end
    Humanoid   = Character:FindFirstChildOfClass("Humanoid")
    RootPart   = Character:FindFirstChild("HumanoidRootPart")
    return Character and Humanoid and RootPart and Humanoid.Health > 0
end

local function Distance(a, b)
    return (a.Position - b.Position).Magnitude
end

local function GetEnemies()
    local enemies = {}
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= Character then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local root = model:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 and not Players:GetPlayerFromCharacter(model) then
                table.insert(enemies, model)
            end
        end
    end
    return enemies
end

local function GetNearestEnemy(range, prioritizeBoss)
    if not GetCharacter() then return nil end
    local nearest, nearestDist = nil, range or math.huge
    for _, enemy in ipairs(GetEnemies()) do
        local root = enemy:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = Distance(RootPart, root)
            if dist < nearestDist then
                if prioritizeBoss then
                    local name = enemy.Name:lower()
                    if name:find("boss") or name:find("elite") or name:find("king") then
                        nearest = enemy
                        nearestDist = dist
                    end
                end
                if not nearest then
                    nearest = enemy
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

local function FireRemote(path, ...)
    local remote = ReplicatedStorage:FindFirstChild(path, true)
        or Workspace:FindFirstChild(path, true)
    if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        else
            return remote:InvokeServer(...)
        end
    end
end

local function Attack(enemy)
    if not enemy then return end
    local root = enemy:FindFirstChild("HumanoidRootPart")
    if not root then return end
    FireRemote("Attack", enemy)
    FireRemote("DamageEnemy", enemy)
    FireRemote("HitEnemy", enemy, root.Position)
    local tool = Character:FindFirstChildOfClass("Tool")
    if tool then
        local activate = tool:FindFirstChild("Activate") or tool:FindFirstChildOfClass("RemoteEvent")
        if activate then pcall(function() activate:FireServer(enemy) end) end
    end
end

local function Loot(item)
    FireRemote("Loot", item)
    FireRemote("PickupItem", item)
    FireRemote("CollectDrop", item)
    local root = item:FindFirstChild("HumanoidRootPart") or item:FindFirstChild("Handle") or item.PrimaryPart
    if root and RootPart then
        RootPart.CFrame = root.CFrame + Vector3.new(0, 2, 0)
    end
end

-- ═══════════════════════════════════════════
-- ESP
-- ═══════════════════════════════════════════

local function ClearESP()
    for _, obj in pairs(State.ESPObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    State.ESPObjects = {}
end

local function CreateESPBox(target, color, label)
    if not target.PrimaryPart and not target:FindFirstChild("HumanoidRootPart") then return end
    local highlight = Instance.new("SelectionBox")
    highlight.Color3 = color
    highlight.LineThickness = 0.05
    highlight.SurfaceTransparency = State.ESPTransparency
    highlight.SurfaceColor3 = color
    highlight.Adornee = target
    highlight.Parent = Camera

    local billboard
    if State.ShowNames or State.ShowDistance then
        billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 120, 0, 40)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Adornee = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart
        billboard.Parent = Camera

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = label or target.Name
        lbl.Parent = billboard
    end

    table.insert(State.ESPObjects, highlight)
    if billboard then table.insert(State.ESPObjects, billboard) end
end

local function UpdateESP()
    ClearESP()
    if State.ESPEnemies then
        for _, enemy in ipairs(GetEnemies()) do
            local root = enemy:FindFirstChild("HumanoidRootPart")
            local dist = root and RootPart and math.floor(Distance(RootPart, root)) or 0
            local lbl = ""
            if State.ShowNames then lbl = enemy.Name end
            if State.ShowDistance then lbl = lbl .. (lbl ~= "" and " | " or "") .. dist .. "m" end
            CreateESPBox(enemy, State.ESPColor, lbl)
        end
    end
    if State.ESPPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local dist = root and RootPart and math.floor(Distance(RootPart, root)) or 0
                local lbl = ""
                if State.ShowNames then lbl = plr.Name end
                if State.ShowDistance then lbl = lbl .. (lbl ~= "" and " | " or "") .. dist .. "m" end
                CreateESPBox(plr.Character, State.PlayerESPColor, lbl)
            end
        end
    end
    if State.ESPLoot then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("drop") or obj.Name:lower():find("loot") or obj.Name:lower():find("item")) then
                CreateESPBox(obj, State.LootESPColor, obj.Name)
            end
        end
    end
    if State.ESPChests then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate") or obj.Name:lower():find("box")) then
                CreateESPBox(obj, State.ChestESPColor, obj.Name)
            end
        end
    end
end

-- ═══════════════════════════════════════════
-- MAIN LOOP
-- ═══════════════════════════════════════════

local lastESPUpdate  = 0
local lastAbility    = 0
local lastAntiIdle   = 0
local abilityList    = {"Q", "E", "R", "F", "Z", "X", "C"}

RunService.Heartbeat:Connect(function(dt)
    if not GetCharacter() then return end

    -- Anti-Idle
    if State.AntiIdle then
        lastAntiIdle = lastAntiIdle + dt
        if lastAntiIdle >= 60 then
            lastAntiIdle = 0
            FireRemote("AntiIdle")
            VirtualInputManager = game:GetService("VirtualInputManager")
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            end)
        end
    end

    -- Walk Speed / Jump Power / Gravity
    if Humanoid then
        Humanoid.WalkSpeed = State.WalkSpeed
        Humanoid.JumpPower = State.JumpPower
    end
    Workspace.Gravity = State.Gravity

    -- Auto Heal
    if Humanoid and Humanoid.MaxHealth > 0 then
        local pct = (Humanoid.Health / Humanoid.MaxHealth) * 100
        if pct < State.HealThreshold then
            FireRemote("Heal")
            FireRemote("UsePotion")
        end
    end

    -- Auto Combat
    if State.AutoCombat then
        local enemy = GetNearestEnemy(State.AttackRange, State.BossPriority)
        if enemy then
            Attack(enemy)
            -- Weapon Switch
            if State.WeaponSwitch then
                local tools = LocalPlayer.Backpack:GetChildren()
                if #tools > 1 then
                    local idx = (tick() % #tools) + 1
                    local tool = tools[math.floor(idx)]
                    if tool and tool:IsA("Tool") then
                        Humanoid:EquipTool(tool)
                    end
                end
            end
        end
    end

    -- Auto Loot
    if State.AutoLoot then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local name = obj.Name:lower()
                if name:find("drop") or name:find("loot") or name:find("item") or name:find("pickup") then
                    local part = obj:FindFirstChild("Handle") or obj.PrimaryPart
                    if part and Distance(RootPart, part) <= State.LootRange then
                        Loot(obj)
                    end
                end
            end
        end
    end

    -- Auto Return
    if State.AutoReturn then
        local portal = Workspace:FindFirstChild("DungeonPortal", true)
            or Workspace:FindFirstChild("ReturnPortal", true)
            or Workspace:FindFirstChild("Entrance", true)
        if portal then
            local part = portal:IsA("BasePart") and portal or portal.PrimaryPart
            if part and Distance(RootPart, part) > 8 then
                RootPart.CFrame = part.CFrame + Vector3.new(0, 3, 0)
            else
                FireRemote("ReturnDungeon")
                FireRemote("EnterDungeon")
            end
        end
    end

    -- Kill Aura
    if State.KillAura then
        for _, enemy in ipairs(GetEnemies()) do
            local root = enemy:FindFirstChild("HumanoidRootPart")
            if root and Distance(RootPart, root) <= State.KillAuraRange then
                Attack(enemy)
            end
        end
    end

    -- Ability Rotation
    if State.AbilityRotation then
        lastAbility = lastAbility + dt
        if lastAbility >= 0.8 then
            lastAbility = 0
            local key = abilityList[State.AbilityIndex]
            State.AbilityIndex = (State.AbilityIndex % #abilityList) + 1
            pcall(function()
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[key], false, game)
                task.wait(0.05)
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode[key], false, game)
            end)
        end
    end

    -- Auto Dodge
    if State.AutoDodge then
        for _, enemy in ipairs(GetEnemies()) do
            local root = enemy:FindFirstChild("HumanoidRootPart")
            if root and Distance(RootPart, root) <= 10 then
                local away = (RootPart.Position - root.Position).Unit
                RootPart.Velocity = away * 60
                break
            end
        end
    end

    -- ESP Update (every 0.5s to save perf)
    lastESPUpdate = lastESPUpdate + dt
    if lastESPUpdate >= 0.5 then
        lastESPUpdate = 0
        if State.ESPEnemies or State.ESPPlayers or State.ESPLoot or State.ESPChests then
            UpdateESP()
        end
    end
end)

-- ═══════════════════════════════════════════
-- TABS
-- ═══════════════════════════════════════════

-- ── COMBAT ──────────────────────────────────

local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "Auto Combat",
    CurrentValue = false,
    Flag = "AutoCombat",
    Callback = function(v) State.AutoCombat = v end,
})

CombatTab:CreateToggle({
    Name = "Auto Loot",
    CurrentValue = false,
    Flag = "AutoLoot",
    Callback = function(v) State.AutoLoot = v end,
})

CombatTab:CreateToggle({
    Name = "Auto Return",
    CurrentValue = false,
    Flag = "AutoReturn",
    Callback = function(v) State.AutoReturn = v end,
})

CombatTab:CreateToggle({
    Name = "Weapon Switch",
    CurrentValue = false,
    Flag = "WeaponSwitch",
    Callback = function(v) State.WeaponSwitch = v end,
})

CombatTab:CreateSlider({
    Name = "Attack Range",
    Range = {5, 100},
    Increment = 1,
    Suffix = "m",
    CurrentValue = 20,
    Flag = "AttackRange",
    Callback = function(v) State.AttackRange = v end,
})

CombatTab:CreateSlider({
    Name = "Loot Range",
    Range = {5, 80},
    Increment = 1,
    Suffix = "m",
    CurrentValue = 15,
    Flag = "LootRange",
    Callback = function(v) State.LootRange = v end,
})

CombatTab:CreateSlider({
    Name = "Heal Threshold",
    Range = {1, 99},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 40,
    Flag = "HealThreshold",
    Callback = function(v) State.HealThreshold = v end,
})

-- ── MOVEMENT ─────────────────────────────────

local MovementTab = Window:CreateTab("Movement", 4483362458)

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 300},
    Increment = 1,
    Suffix = "",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        State.WalkSpeed = v
        if Humanoid then Humanoid.WalkSpeed = v end
    end,
})

MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v)
        State.JumpPower = v
        if Humanoid then Humanoid.JumpPower = v end
    end,
})

MovementTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 400},
    Increment = 5,
    Suffix = "",
    CurrentValue = 196,
    Flag = "Gravity",
    Callback = function(v)
        State.Gravity = v
        Workspace.Gravity = v
    end,
})

MovementTab:CreateButton({
    Name = "Teleport to Nearest Enemy",
    Callback = function()
        if not GetCharacter() then return end
        local enemy = GetNearestEnemy(math.huge, false)
        if enemy then
            local root = enemy:FindFirstChild("HumanoidRootPart")
            if root then
                RootPart.CFrame = root.CFrame + Vector3.new(0, 3, 4)
            end
        else
            Rayfield:Notify({ Title = "Teleport", Content = "No enemies found.", Duration = 2 })
        end
    end,
})

MovementTab:CreateButton({
    Name = "Teleport to Nearest Chest",
    Callback = function()
        if not GetCharacter() then return end
        local nearest, nearestDist = nil, math.huge
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("crate")) then
                local part = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                if part then
                    local d = Distance(RootPart, part)
                    if d < nearestDist then nearest = part; nearestDist = d end
                end
            end
        end
        if nearest then
            RootPart.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
        else
            Rayfield:Notify({ Title = "Teleport", Content = "No chests found.", Duration = 2 })
        end
    end,
})

MovementTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        if not GetCharacter() then return end
        local spawn = Workspace:FindFirstChild("SpawnLocation")
            or Workspace:FindFirstChild("Spawn")
        if spawn then
            RootPart.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
        else
            RootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end,
})

MovementTab:CreateButton({
    Name = "Reset Speed & Gravity",
    Callback = function()
        State.WalkSpeed = 16
        State.JumpPower = 50
        State.Gravity   = 196.2
        if Humanoid then
            Humanoid.WalkSpeed = 16
            Humanoid.JumpPower = 50
        end
        Workspace.Gravity = 196.2
        Rayfield:Notify({ Title = "Movement", Content = "Reset to defaults.", Duration = 2 })
    end,
})

-- ── UTILITY ──────────────────────────────────

local UtilityTab = Window:CreateTab("Utility", 4483362458)

UtilityTab:CreateButton({
    Name = "Kill Character",
    Callback = function()
        if not GetCharacter() then return end
        Humanoid.Health = 0
        FireRemote("KillCharacter")
    end,
})

UtilityTab:CreateButton({
    Name = "Reset GUI",
    Callback = function()
        for k, _ in pairs(State) do
            if type(State[k]) == "boolean" then State[k] = false end
        end
        State.WalkSpeed = 16
        State.JumpPower = 50
        State.Gravity   = 196.2
        State.AttackRange = 20
        State.LootRange   = 15
        State.HealThreshold = 40
        State.KillAuraRange = 25
        State.ESPTransparency = 0.5
        if Humanoid then
            Humanoid.WalkSpeed = 16
            Humanoid.JumpPower = 50
        end
        Workspace.Gravity = 196.2
        ClearESP()
        Rayfield:Notify({ Title = "GUI", Content = "Reset complete.", Duration = 2 })
    end,
})

UtilityTab:CreateToggle({
    Name = "Anti-Idle",
    CurrentValue = false,
    Flag = "AntiIdle",
    Callback = function(v) State.AntiIdle = v end,
})

UtilityTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- ── OVERHAUL ─────────────────────────────────

local OverhaulTab = Window:CreateTab("Overhaul", 4483362458)

OverhaulTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v) State.KillAura = v end,
})

OverhaulTab:CreateSlider({
    Name = "Kill Aura Range",
    Range = {5, 150},
    Increment = 1,
    Suffix = "m",
    CurrentValue = 25,
    Flag = "KillAuraRange",
    Callback = function(v) State.KillAuraRange = v end,
})

OverhaulTab:CreateToggle({
    Name = "Ability Rotation",
    CurrentValue = false,
    Flag = "AbilityRotation",
    Callback = function(v) State.AbilityRotation = v end,
})

OverhaulTab:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = false,
    Flag = "AutoDodge",
    Callback = function(v) State.AutoDodge = v end,
})

OverhaulTab:CreateToggle({
    Name = "Boss Priority",
    CurrentValue = false,
    Flag = "BossPriority",
    Callback = function(v) State.BossPriority = v end,
})

-- ── ESP ──────────────────────────────────────

local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "ESP Enemies",
    CurrentValue = false,
    Flag = "ESPEnemies",
    Callback = function(v)
        State.ESPEnemies = v
        if not v then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESPPlayers",
    Callback = function(v)
        State.ESPPlayers = v
        if not v then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Loot",
    CurrentValue = false,
    Flag = "ESPLoot",
    Callback = function(v)
        State.ESPLoot = v
        if not v then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Chests",
    CurrentValue = false,
    Flag = "ESPChests",
    Callback = function(v)
        State.ESPChests = v
        if not v then ClearESP() end
    end,
})

ESPTab:CreateColorPicker({
    Name = "Enemy ESP Color",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "ESPEnemyColor",
    Callback = function(c) State.ESPColor = c end,
})

ESPTab:CreateColorPicker({
    Name = "Player ESP Color",
    Color = Color3.fromRGB(50, 150, 255),
    Flag = "ESPPlayerColor",
    Callback = function(c) State.PlayerESPColor = c end,
})

ESPTab:CreateColorPicker({
    Name = "Loot ESP Color",
    Color = Color3.fromRGB(255, 215, 0),
    Flag = "ESPLootColor",
    Callback = function(c) State.LootESPColor = c end,
})

ESPTab:CreateColorPicker({
    Name = "Chest ESP Color",
    Color = Color3.fromRGB(0, 255, 100),
    Flag = "ESPChestColor",
    Callback = function(c) State.ChestESPColor = c end,
})

ESPTab:CreateSlider({
    Name = "ESP Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.5,
    Flag = "ESPTransparency",
    Callback = function(v) State.ESPTransparency = v end,
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(v) State.ShowNames = v end,
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(v) State.ShowDistance = v end,
})

-- ═══════════════════════════════════════════
-- CHARACTER REFRESH
-- ═══════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    ClearESP()
end)

-- ═══════════════════════════════════════════
-- INIT NOTIFY
-- ═══════════════════════════════════════════

Rayfield:Notify({
    Title = "Iron Soul Dungeon",
    Content = "Loaded. All systems ready.",
    Duration = 3,
})
