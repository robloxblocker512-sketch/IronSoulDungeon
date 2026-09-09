-- Iron Soul Dungeon - Rayfield UI
-- Full Combat Logic | Delta Executor

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by VANTA",
    Theme = "Dark",
})

-- ===== TABS =====
local AuraTab = Window:CreateTab("Aura")
local CombatTab = Window:CreateTab("Combat")
local ForgeTab = Window:CreateTab("Forge")
local DungeonTab = Window:CreateTab("Dungeon")
local ESPTab = Window:CreateTab("ESP")

-- ===== AURA TAB =====
local AuraSection = AuraTab:CreateSection("Long Range Kill Aura")
AuraSection:CreateToggle({
    Name = "Enable Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v) _G.KillAura = v end
})
AuraSection:CreateSlider({
    Name = "Aura Range",
    Range = {50, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 200,
    Flag = "AuraRange",
    Callback = function(v) _G.AuraRange = v end
})
AuraSection:CreateSlider({
    Name = "Aura Speed (ms)",
    Range = {10, 200},
    Increment = 5,
    Suffix = "ms",
    CurrentValue = 50,
    Flag = "AuraSpeed",
    Callback = function(v) _G.AuraInterval = v / 1000 end
})
AuraSection:CreateToggle({
    Name = "Boss Priority",
    CurrentValue = false,
    Flag = "BossPriority",
    Callback = function(v) _G.BossPriority = v end
})

-- ===== COMBAT TAB =====
local CombatSection = CombatTab:CreateSection("Auto Combat")
CombatSection:CreateToggle({
    Name = "Auto Combat",
    CurrentValue = false,
    Flag = "AutoCombat",
    Callback = function(v) _G.AutoCombat = v end
})
CombatSection:CreateToggle({
    Name = "Auto Loot",
    CurrentValue = false,
    Flag = "AutoLoot",
    Callback = function(v) _G.AutoLoot = v end
})
CombatSection:CreateToggle({
    Name = "Auto Return",
    CurrentValue = false,
    Flag = "AutoReturn",
    Callback = function(v) _G.AutoReturn = v end
})
CombatSection:CreateToggle({
    Name = "Weapon Switch",
    CurrentValue = false,
    Flag = "WeaponSwitch",
    Callback = function(v) _G.WeaponSwitch = v end
})
CombatSection:CreateToggle({
    Name = "Ability Rotation",
    CurrentValue = false,
    Flag = "AbilityRotation",
    Callback = function(v) _G.AbilityRotation = v end
})
CombatSection:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = false,
    Flag = "AutoDodge",
    Callback = function(v) _G.AutoDodge = v end
})
CombatSection:CreateSlider({
    Name = "Attack Range",
    Range = {5, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 20,
    Flag = "AttackRange",
    Callback = function(v) _G.AttackRange = v end
})
CombatSection:CreateSlider({
    Name = "Loot Range",
    Range = {5, 80},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 15,
    Flag = "LootRange",
    Callback = function(v) _G.LootRange = v end
})
CombatSection:CreateSlider({
    Name = "Heal Threshold %",
    Range = {1, 99},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 40,
    Flag = "HealThreshold",
    Callback = function(v) _G.HealThreshold = v end
})

-- ===== FORGE TAB =====
local ForgeSection = ForgeTab:CreateSection("Auto Forge")
ForgeSection:CreateToggle({
    Name = "Auto Perfect Forge",
    CurrentValue = false,
    Flag = "AutoForge",
    Callback = function(v) _G.AutoForge = v end
})
ForgeSection:CreateButton({
    Name = "Collect Ores",
    Callback = function()
        if not _G.RefreshChar then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("ore") or n:find("mineral") or n:find("material") then
                    local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                    if part and _G.Root then
                        _G.Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                        _G.FireRemote("collect", obj)
                    end
                end
            end
        end
    end
})

-- ===== DUNGEON TAB =====
local DungeonSection = DungeonTab:CreateSection("Chest Egg Destroyer")
DungeonSection:CreateToggle({
    Name = "Auto Destroy Eggs",
    CurrentValue = false,
    Flag = "AutoEgg",
    Callback = function(v) _G.AutoEgg = v end
})
DungeonSection:CreateSlider({
    Name = "Egg Range",
    Range = {20, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 200,
    Flag = "EggRange",
    Callback = function(v) _G.EggRange = v end
})
DungeonSection:CreateButton({
    Name = "Destroy All Eggs Now",
    Callback = function()
        if not _G.RefreshChar then return end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if _G.IsEgg and _G.IsEgg(obj) then
                _G.DestroyEgg(obj)
            end
        end
    end
})
DungeonSection:CreateButton({
    Name = "Teleport to Boss",
    Callback = function()
        if not _G.RefreshChar then return end
        local boss = _G.GetNearestEnemy and _G.GetNearestEnemy(math.huge, true)
        if boss then
            local r = boss:FindFirstChild("HumanoidRootPart")
            if r and _G.Root then _G.Root.CFrame = r.CFrame + Vector3.new(0, 3, 6) end
        end
    end
})
DungeonSection:CreateButton({
    Name = "Teleport to Portal",
    Callback = function()
        if not _G.RefreshChar then return end
        local portal = workspace:FindFirstChild("DungeonPortal", true) or workspace:FindFirstChild("ReturnPortal", true) or workspace:FindFirstChild("Entrance", true)
        if portal then
            local p = portal:IsA("BasePart") and portal or portal.PrimaryPart
            if p and _G.Root then _G.Root.CFrame = p.CFrame + Vector3.new(0, 3, 0) end
        end
    end
})

-- ===== ESP TAB =====
local ESPSection = ESPTab:CreateSection("ESP Settings")
ESPSection:CreateToggle({
    Name = "ESP Enemies",
    CurrentValue = false,
    Flag = "ESPEnemies",
    Callback = function(v) _G.ESPEnemies = v end
})
ESPSection:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESPPlayers",
    Callback = function(v) _G.ESPPlayers = v end
})
ESPSection:CreateToggle({
    Name = "ESP Loot",
    CurrentValue = false,
    Flag = "ESPLoot",
    Callback = function(v) _G.ESPLoot = v end
})
ESPSection:CreateToggle({
    Name = "ESP Chests/Eggs",
    CurrentValue = false,
    Flag = "ESPChests",
    Callback = function(v) _G.ESPChests = v end
})
ESPSection:CreateSlider({
    Name = "ESP Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.4,
    Flag = "ESPTransparency",
    Callback = function(v) _G.ESPTransparency = v end
})
ESPSection:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(v) _G.ShowNames = v end
})
ESPSection:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(v) _G.ShowDistance = v end
})

-- ============================================================
-- COMBAT LOGIC
-- ============================================================

_G.KillAura = false
_G.AuraRange = 200
_G.AuraInterval = 0.05
_G.BossPriority = false
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
_G.AbilityRotation = false
_G.AutoDodge = false
_G.ESPEnemies = false
_G.ESPPlayers = false
_G.ESPLoot = false
_G.ESPChests = false
_G.ShowNames = true
_G.ShowDistance = true
_G.ESPTransparency = 0.4
_G.ESPObjects = {}
_G.AbilityIndex = 1
_G.AbilityList = {"Q","E","R","F","Z","X","C"}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local Char, Hum, Root

_G.RefreshChar = function()
    Char = LP.Character
    if not Char then return false end
    Hum = Char:FindFirstChildOfClass("Humanoid")
    Root = Char:FindFirstChild("HumanoidRootPart")
    _G.Char = Char
    _G.Hum = Hum
    _G.Root = Root
    return Char and Hum and Root and Hum.Health > 0
end

_G.RefreshChar()
LP.CharacterAdded:Connect(function(c)
    Char = c
    Hum = c:WaitForChild("Humanoid")
    Root = c:WaitForChild("HumanoidRootPart")
    _G.Char = Char
    _G.Hum = Hum
    _G.Root = Root
    for _, o in pairs(_G.ESPObjects) do pcall(function() o:Destroy() end) end
    _G.ESPObjects = {}
end)

local function Dist(a, b)
    return (a.Position - b.Position).Magnitude
end

_G.FireRemote = function(name, ...)
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

_G.GetNearestEnemy = function(range, boss)
    if not _G.RefreshChar() then return nil end
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
    _G.FireRemote("damage", enemy, 99999)
    _G.FireRemote("hit", enemy, eRoot.Position)
    _G.FireRemote("attack", enemy)
    _G.FireRemote("kill", enemy)
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

_G.IsEgg = function(obj)
    if not obj:IsA("Model") and not obj:IsA("BasePart") then return false end
    local n = obj.Name:lower()
    for _, kw in ipairs(EGG_KEYWORDS) do
        if n:find(kw) then return true end
    end
    return false
end

_G.DestroyEgg = function(obj)
    _G.FireRemote("destroy", obj)
    _G.FireRemote("break", obj)
    _G.FireRemote("open", obj)
    _G.FireRemote("collect", obj)
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
    for _, o in pairs(_G.ESPObjects) do pcall(function() o:Destroy() end) end
    _G.ESPObjects = {}
end

local function MakeESP(target, color, label)
    local root = (target:IsA("Model") and (target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart)) or (target:IsA("BasePart") and target)
    if not root then return end
    local box = Instance.new("SelectionBox")
    box.Color3 = color
    box.LineThickness = 0.06
    box.SurfaceTransparency = _G.ESPTransparency or 0.4
    box.SurfaceColor3 = color
    box.Adornee = target
    box.Parent = Workspace.CurrentCamera
    table.insert(_G.ESPObjects, box)
    if label and (_G.ShowNames or _G.ShowDistance) then
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
        table.insert(_G.ESPObjects, bb)
    end
end

local function UpdateESP()
    ClearESP()
    if _G.ESPEnemies then
        for _, e in ipairs(GetEnemies()) do
            local r = e:FindFirstChild("HumanoidRootPart")
            local d = r and Root and math.floor(Dist(Root, r)) or 0
            local lbl = (_G.ShowNames and e.Name or "") .. (_G.ShowDistance and (" | " .. d .. "m") or "")
            MakeESP(e, Color3.fromRGB(255, 50, 50), lbl)
        end
    end
    if _G.ESPPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local d = r and Root and math.floor(Dist(Root, r)) or 0
                local lbl = (_G.ShowNames and p.Name or "") .. (_G.ShowDistance and (" | " .. d .. "m") or "")
                MakeESP(p.Character, Color3.fromRGB(50, 150, 255), lbl)
            end
        end
    end
    if _G.ESPLoot or _G.ESPChests then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if _G.IsEgg(obj) then
                MakeESP(obj, Color3.fromRGB(0, 255, 100), obj.Name)
            end
        end
    end
end

-- ===== AUTO PERFECT FORGE =====
local ForgeWatcher
_G.StartForgeWatcher = function()
    if ForgeWatcher then ForgeWatcher:Disconnect() end
    ForgeWatcher = RunService.Heartbeat:Connect(function()
        if not _G.AutoForge then return end
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
                                _G.FireRemote("forge")
                                _G.FireRemote("craft")
                                _G.FireRemote("confirm")
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
    if not _G.RefreshChar() then return end

    if Hum then
        Hum.WalkSpeed = _G.WalkSpeed or 16
        Hum.JumpPower = _G.JumpPower or 50
    end
    Workspace.Gravity = _G.Gravity or 196.2

    if Hum and Hum.MaxHealth > 0 and (Hum.Health / Hum.MaxHealth * 100) < (_G.HealThreshold or 40) then
        _G.FireRemote("heal")
        _G.FireRemote("potion")
    end

    timers.aura = timers.aura + dt
    if _G.KillAura and timers.aura >= (_G.AuraInterval or 0.05) then
        timers.aura = 0
        for _, enemy in ipairs(GetEnemies()) do
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot and Dist(Root, eRoot) <= (_G.AuraRange or 200) then
                LongRangeKill(enemy)
            end
        end
    end

    if _G.AutoCombat then
        local enemy = _G.GetNearestEnemy(_G.AttackRange or 20, _G.BossPriority or false)
        if enemy then
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot then
                _G.FireRemote("attack", enemy)
                _G.FireRemote("hit", enemy, eRoot.Position)
                local tool = Char:FindFirstChildOfClass("Tool")
                if tool then
                    pcall(function()
                        for _, v in ipairs(tool:GetDescendants()) do
                            if v:IsA("RemoteEvent") then
                                v:FireServer(eRoot.Position, enemy)
                            end
                        end
                    end)
                    if _G.WeaponSwitch then
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
    if _G.AutoLoot and timers.loot >= 0.2 then
        timers.loot = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local n = obj.Name:lower()
                if n:find("drop") or n:find("loot") or n:find("item") or n:find("pickup") or n:find("ore") then
                    local part = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                    if part and Dist(Root, part) <= (_G.LootRange or 15) then
                        _G.FireRemote("loot", obj)
                        _G.FireRemote("pickup", obj)
                        Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                    end
                end
            end
        end
    end

    timers.egg = timers.egg + dt
    if _G.AutoEgg and timers.egg >= 0.3 then
        timers.egg = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if _G.IsEgg(obj) then
                local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                if part and Dist(Root, part) <= (_G.EggRange or 200) then
                    _G.DestroyEgg(obj)
                end
            end
        end
    end

    if _G.AutoReturn then
        local portal = Workspace:FindFirstChild("DungeonPortal", true) or Workspace:FindFirstChild("ReturnPortal", true) or Workspace:FindFirstChild("Entrance", true)
        if portal then
            local part = portal:IsA("BasePart") and portal or portal.PrimaryPart
            if part then
                if Dist(Root, part) > 8 then
                    Root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
                else
                    _G.FireRemote("return")
                    _G.FireRemote("enterDungeon")
                end
            end
        end
    end

    timers.dodge = timers.dodge + dt
    if _G.AutoDodge and timers.dodge >= 0.1 then
        timers.dodge = 0
        for _, enemy in ipairs(GetEnemies()) do
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot and Dist(Root, eRoot) <= 12 then
                local away = (Root.Position - eRoot.Position).Unit
                Root.Velocity = away * 80
                _G.FireRemote("dodge")
                break
            end
        end
    end

    timers.ability = timers.ability + dt
    if _G.AbilityRotation and timers.ability >= 0.7 then
        timers.ability = 0
        local key = _G.AbilityList[_G.AbilityIndex]
        _G.AbilityIndex = (_G.AbilityIndex % 7) + 1
        pcall(function()
            VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
            task.wait(0.04)
            VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
        end)
    end

    timers.esp = timers.esp + dt
    if timers.esp >= 0.5 then
        timers.esp = 0
        if _G.ESPEnemies or _G.ESPPlayers or _G.ESPLoot or _G.ESPChests then
            UpdateESP()
        end
    end
end)

-- AutoForge toggle handler (attached to the UI toggle)
-- The toggle in the UI sets _G.AutoForge, and the watcher checks it

print("Iron Soul Dungeon FULLY LOADED")
