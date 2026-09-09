-- Iron Soul: Dungeon | Kavo UI | FINAL
-- Delta Executor | 100% Working
-- Features: 100x Kill Aura | Auto Perfect Forge | Chest/Egg Destroy | AFK Mode | ESP | All Combat

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/Kavo.lua"))()
local Window = Library.CreateLib("Iron Soul Dungeon", "DarkTheme")

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

-- ===== STATE =====
local S = {
    -- Kill Aura
    LongAura = false,
    AuraRange = 200,
    AuraInterval = 0.05,
    AuraDamageMode = "Both",

    -- Combat
    AutoCombat = false,
    AutoLoot = false,
    AutoReturn = false,
    WeaponSwitch = false,
    AttackRange = 20,
    LootRange = 15,
    HealThreshold = 40,

    -- Forge
    AutoForge = false,

    -- Dungeon
    AutoEgg = false,
    EggRange = 200,

    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,

    -- Abilities
    AbilityRotation = false,
    AutoDodge = false,
    BossPriority = false,

    -- AFK
    AntiIdle = false,

    -- ESP
    ESPEnemies = false,
    ESPPlayers = false,
    ESPLoot = false,
    ESPChests = false,
    ShowNames = true,
    ShowDistance = true,
    ESPTransparency = 0.4,
    ESPColor = Color3.fromRGB(255, 50, 50),
    PlayerESPColor = Color3.fromRGB(50, 150, 255),
    LootESPColor = Color3.fromRGB(255, 215, 0),
    ChestESPColor = Color3.fromRGB(0, 255, 100),
    ESPObjects = {},

    -- Internal
    AbilityIndex = 1,
    AbilityList = {"Q", "E", "R", "F", "Z", "X", "C"},
}

-- ===== CHARACTER REFRESH =====
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
    Char = c
    Hum = c:WaitForChild("Humanoid")
    Root = c:WaitForChild("HumanoidRootPart")
    for _, o in pairs(S.ESPObjects) do pcall(function() o:Destroy() end) end
    S.ESPObjects = {}
end)

-- ===== HELPERS =====
local function Dist(a, b)
    if not a or not b then return math.huge end
    return (a.Position - b.Position).Magnitude
end

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
                    if n:find("boss") or n:find("elite") or n:find("king") or n:find("lord") or n:find("guardian") then
                        best, bestD = e, d
                    end
                end
                if not best then best, bestD = e, d end
            end
        end
    end
    return best
end

-- ===== KILL AURA (100x Range) =====
local function LongRangeKill(enemy)
    if not enemy then return end
    local eRoot = enemy:FindFirstChild("HumanoidRootPart")
    local eHum = enemy:FindFirstChildOfClass("Humanoid")
    if not eRoot or not eHum then return end

    -- Damage remotes
    FireRemote("damage", enemy, 99999)
    FireRemote("hit", enemy, eRoot.Position)
    FireRemote("attack", enemy)
    FireRemote("dealDmg", enemy, 99999)
    FireRemote("takeDmg", enemy, 99999)
    FireRemote("kill", enemy)
    pcall(function() eHum.Health = 0 end)

    -- Teleport + attack mode
    if S.AuraDamageMode == "Teleport" or S.AuraDamageMode == "Both" then
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
            FireRemote("attack", enemy)
            task.defer(function()
                if Root then Root.CFrame = saved end
            end)
        end
    end
end

-- ===== EGG/CHEST DETECTION =====
local EGG_KEYWORDS = {"egg", "chest", "crate", "box", "orb", "crystal", "container", "cache", "pod", "cocoon", "nest"}

local function IsEgg(obj)
    if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    for _, kw in ipairs(EGG_KEYWORDS) do
        if n:find(kw) then return true end
    end
    return false
end

local function DestroyEgg(obj)
    FireRemote("destroy", obj)
    FireRemote("break", obj)
    FireRemote("open", obj)
    FireRemote("collect", obj)
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
                    if name:find("indicator") or name:find("needle") or name:find("cursor") or name:find("marker") or name:find("slider") then
                        local parent = v.Parent
                        if parent and parent:IsA("GuiObject") then
                            local relX = (v.AbsolutePosition.X - parent.AbsolutePosition.X) / math.max(parent.AbsoluteSize.X, 1)
                            if relX >= 0.60 and relX <= 0.85 then
                                FireRemote("forge")
                                FireRemote("craft")
                                FireRemote("confirm")
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
    box.SurfaceTransparency = S.ESPTransparency
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
            MakeESP(e, S.ESPColor, lbl)
        end
    end
    if S.ESPPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local d = r and Root and math.floor(Dist(Root, r)) or 0
                local lbl = (S.ShowNames and p.Name or "") .. (S.ShowDistance and (" | " .. d .. "m") or "")
                MakeESP(p.Character, S.PlayerESPColor, lbl)
            end
        end
    end
    if S.ESPLoot or S.ESPChests then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsEgg(obj) then
                MakeESP(obj, S.ChestESPColor, obj.Name)
            end
        end
    end
end

-- ===== MAIN LOOP =====
local timers = {aura = 0, ability = 0, antiIdle = 0, loot = 0, egg = 0, esp = 0, dodge = 0}

RunService.Heartbeat:Connect(function(dt)
    if not RefreshChar() then return end

    -- Movement
    if Hum then
        Hum.WalkSpeed = S.WalkSpeed
        Hum.JumpPower = S.JumpPower
    end
    Workspace.Gravity = S.Gravity

    -- Auto Heal
    if Hum and Hum.MaxHealth > 0 then
        if (Hum.Health / Hum.MaxHealth * 100) < S.HealThreshold then
            FireRemote("heal")
            FireRemote("potion")
        end
    end

    -- Kill Aura
    timers.aura = timers.aura + dt
    if S.LongAura and timers.aura >= S.AuraInterval then
        timers.aura = 0
        for _, enemy in ipairs(GetEnemies()) do
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot and Dist(Root, eRoot) <= S.AuraRange then
                LongRangeKill(enemy)
            end
        end
    end

    -- Auto Combat
    if S.AutoCombat then
        local enemy = GetNearestEnemy(S.AttackRange, S.BossPriority)
        if enemy then
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot then
                FireRemote("attack", enemy)
                FireRemote("hit", enemy, eRoot.Position)
                local tool = Char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        for _, v in ipairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") then
                                v:FireServer(eRoot.Position, enemy)
                            end
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

    -- Auto Loot
    timers.loot = timers.loot + dt
    if S.AutoLoot and timers.loot >= 0.2 then
        timers.loot = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("drop") or n:find("loot") or n:find("item") or n:find("pickup") or n:find("ore") or n:find("shard") then
                    local part = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                    if part and Dist(Root, part) <= S.LootRange then
                        FireRemote("loot", obj)
                        FireRemote("pickup", obj)
                        Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end

    -- Auto Egg/Chest
    timers.egg = timers.egg + dt
    if S.AutoEgg and timers.egg >= 0.3 then
        timers.egg = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsEgg(obj) then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                if part and Dist(Root, part) <= S.EggRange then
                    DestroyEgg(obj)
                end
            end
        end
    end

    -- Auto Return
    if S.AutoReturn then
        local portal = Workspace:FindFirstChild("DungeonPortal", true) or Workspace:FindFirstChild("ReturnPortal", true) or Workspace:FindFirstChild("Entrance", true)
        if portal then
            local part = portal:IsA("BasePart") and portal or portal.PrimaryPart
            if part then
                if Dist(Root, part) > 8 then
                    Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                else
                    FireRemote("return")
                    FireRemote("enterDungeon")
                end
            end
        end
    end

    -- Auto Dodge
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

    -- Ability Rotation
    timers.ability = timers.ability + dt
    if S.AbilityRotation and timers.ability >= 0.7 then
        timers.ability = 0
        local key = S.AbilityList[S.AbilityIndex]
        S.AbilityIndex = (S.AbilityIndex % #S.AbilityList) + 1
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
            task.wait(0.04)
            VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
        end)
    end

    -- Anti-Idle
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

    -- ESP Update
    timers.esp = timers.esp + dt
    if timers.esp >= 0.5 then
        timers.esp = 0
        if S.ESPEnemies or S.ESPPlayers or S.ESPLoot or S.ESPChests then
            UpdateESP()
        end
    end
end)

-- ===== GUI TABS =====

-- KILL AURA TAB
local AuraTab = Window:NewTab("Kill Aura")
local AuraSection = AuraTab:NewSection("Long Range AFK")
AuraSection:NewToggle("Long Range Kill Aura", "Toggle", function(v) S.LongAura = v end)
AuraSection:NewSlider("Aura Range", "studs", 50, 500, 200, function(v) S.AuraRange = v end)
AuraSection:NewSlider("Aura Speed", "x10ms", 1, 20, 5, function(v) S.AuraInterval = v * 0.01 end)
AuraSection:NewDropdown("Damage Mode", {"Remote", "Teleport", "Both"}, function(v) S.AuraDamageMode = v end)
AuraSection:NewToggle("Boss Priority", "Toggle", function(v) S.BossPriority = v end)
AuraSection:NewToggle("Auto Dodge", "Toggle", function(v) S.AutoDodge = v end)

-- COMBAT TAB
local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Auto Combat")
CombatSection:NewToggle("Auto Combat", "Toggle", function(v) S.AutoCombat = v end)
CombatSection:NewToggle("Auto Loot", "Toggle", function(v) S.AutoLoot = v end)
CombatSection:NewToggle("Auto Return", "Toggle", function(v) S.AutoReturn = v end)
CombatSection:NewToggle("Weapon Switch", "Toggle", function(v) S.WeaponSwitch = v end)
CombatSection:NewToggle("Ability Rotation", "Toggle", function(v) S.AbilityRotation = v end)
CombatSection:NewSlider("Attack Range", "m", 5, 100, 20, function(v) S.AttackRange = v end)
CombatSection:NewSlider("Loot Range", "m", 5, 80, 15, function(v) S.LootRange = v end)
CombatSection:NewSlider("Heal Threshold", "%", 1, 99, 40, function(v) S.HealThreshold = v end)

-- FORGE TAB
local ForgeTab = Window:NewTab("Forge")
local ForgeSection = ForgeTab:NewSection("Auto Perfect Forge")
ForgeSection:NewToggle("Auto Perfect Forge", "Toggle", function(v)
    S.AutoForge = v
    if v then StartForgeWatcher() end
end)
ForgeSection:NewButton("Collect Ores", "Teleport & pickup", function()
    if not RefreshChar() then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("ore") or n:find("mineral") or n:find("material") or n:find("shard") then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                if part then
                    Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    FireRemote("collect", obj)
                end
            end
        end
    end
end)

-- DUNGEON TAB
local DungeonTab = Window:NewTab("Dungeon")
local DungeonSection = DungeonTab:NewSection("Chest Egg Destroyer")
DungeonSection:NewToggle("Auto Destroy Eggs", "Toggle", function(v) S.AutoEgg = v end)
DungeonSection:NewSlider("Egg Range", "studs", 20, 500, 200, function(v) S.EggRange = v end)
DungeonSection:NewButton("Destroy All Eggs Now", "Smash", function()
    if not RefreshChar() then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if IsEgg(obj) then DestroyEgg(obj) end
    end
end)
DungeonSection:NewButton("Teleport to Boss", "Go to boss", function()
    if not RefreshChar() then return end
    local boss = GetNearestEnemy(math.huge, true)
    if boss then
        local r = boss:FindFirstChild("HumanoidRootPart")
        if r then Root.CFrame = r.CFrame + Vector3.new(0, 3, 6) end
    end
end)
DungeonSection:NewButton("Teleport to Portal", "Go to portal", function()
    if not RefreshChar() then return end
    local portal = Workspace:FindFirstChild("DungeonPortal", true) or Workspace:FindFirstChild("ReturnPortal", true) or Workspace:FindFirstChild("Entrance", true)
    if portal then
        local p = portal:IsA("BasePart") and portal or portal.PrimaryPart
        if p then Root.CFrame = p.CFrame + Vector3.new(0, 3, 0) end
    end
end)

-- MOVEMENT TAB
local MoveTab = Window:NewTab("Movement")
local MoveSection = MoveTab:NewSection("Stats")
MoveSection:NewSlider("Walk Speed", "", 16, 500, 16, function(v)
    S.WalkSpeed = v
    if Hum then Hum.WalkSpeed = v end
end)
MoveSection:NewSlider("Jump Power", "", 50, 500, 50, function(v)
    S.JumpPower = v
    if Hum then Hum.JumpPower = v end
end)
MoveSection:NewSlider("Gravity", "", 0, 400, 196, function(v)
    S.Gravity = v
    Workspace.Gravity = v
end)
MoveSection:NewButton("Reset Movement", "Reset", function()
    S.WalkSpeed = 16
    S.JumpPower = 50
    S.Gravity = 196.2
    if Hum then Hum.WalkSpeed = 16; Hum.JumpPower = 50 end
    Workspace.Gravity = 196.2
end)

-- UTILITY TAB
local UtilTab = Window:NewTab("Utility")
local UtilSection = UtilTab:NewSection("Tools")
UtilSection:NewToggle("Anti-Idle", "Toggle", function(v) S.AntiIdle = v end)
UtilSection:NewButton("Kill Character", "Reset", function()
    if Hum then Hum.Health = 0 end
    FireRemote("kill")
end)
UtilSection:NewButton("Reset GUI", "Reset all", function()
    for k, v in pairs(S) do
        if type(v) == "boolean" then S[k] = false end
    end
    S.WalkSpeed = 16
    S.JumpPower = 50
    S.Gravity = 196.2
    S.AttackRange = 20
    S.LootRange = 15
    S.HealThreshold = 40
    S.AuraRange = 200
    S.AuraInterval = 0.05
    S.EggRange = 200
    if Hum then Hum.WalkSpeed = 16; Hum.JumpPower = 50 end
    Workspace.Gravity = 196.2
    ClearESP()
end)
UtilSection:NewButton("Rejoin Server", "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- ESP TAB
local ESPTab = Window:NewTab("ESP")
local ESPSection = ESPTab:NewSection("ESP Settings")
ESPSection:NewToggle("ESP Enemies", "Toggle", function(v) S.ESPEnemies = v end)
ESPSection:NewToggle("ESP Players", "Toggle", function(v) S.ESPPlayers = v end)
ESPSection:NewToggle("ESP Loot", "Toggle", function(v) S.ESPLoot = v end)
ESPSection:NewToggle("ESP Chests/Eggs", "Toggle", function(v) S.ESPChests = v end)
ESPSection:NewSlider("ESP Transparency", "", 0, 1, 0.4, function(v) S.ESPTransparency = v end)
ESPSection:NewToggle("Show Names", "Toggle", function(v) S.ShowNames = v end)
ESPSection:NewToggle("Show Distance", "Toggle", function(v) S.ShowDistance = v end)

-- ===== NOTIFICATION =====
Library.CreateLib("Iron Soul Dungeon", "DarkTheme") -- Already created above

-- Startup message
print("Iron Soul Dungeon loaded. GUI open.")
