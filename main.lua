-- Iron Soul: Dungeon | FULL REBUILD v2
-- Delta Executor | Rayfield UI
-- Long-Range Kill Aura | AFK Farm | Auto Perfect Forge | Chest Egg Destroyer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local VIM              = game:GetService("VirtualInputManager")

local LP               = Players.LocalPlayer
local S = {
    LongAura        = false,
    AuraRange       = 150,
    AuraDamageMode  = "Both",
    AuraInterval    = 0.05,
    AutoCombat      = false,
    AutoLoot        = false,
    AutoReturn      = false,
    WeaponSwitch    = false,
    AttackRange     = 20,
    LootRange       = 15,
    HealThreshold   = 40,
    AutoEgg         = false,
    EggRange        = 200,
    AutoForge       = false,
    WalkSpeed       = 16,
    JumpPower       = 50,
    Gravity         = 196.2,
    AbilityRotation = false,
    AutoDodge       = false,
    BossPriority    = false,
    AntiIdle        = false,
    ESPEnemies      = false,
    ESPPlayers      = false,
    ESPLoot         = false,
    ESPChests       = false,
    ShowNames       = true,
    ShowDistance    = true,
    ESPTransparency = 0.4,
    ESPColor        = Color3.fromRGB(255, 50,  50),
    PlayerESPColor  = Color3.fromRGB(50,  150, 255),
    LootESPColor    = Color3.fromRGB(255, 215, 0),
    ChestESPColor   = Color3.fromRGB(0,   255, 100),
    ESPObjects      = {},
    AbilityIndex    = 1,
    AbilityList     = {"Q","E","R","F","Z","X","C"},
}

local Char, Hum, Root

local function RefreshChar()
    Char = LP.Character
    if not Char then return false end
    Hum  = Char:FindFirstChildOfClass("Humanoid")
    Root = Char:FindFirstChild("HumanoidRootPart")
    return Char and Hum and Root and Hum.Health > 0
end

RefreshChar()
LP.CharacterAdded:Connect(function(c)
    Char = c
    Hum  = c:WaitForChild("Humanoid")
    Root = c:WaitForChild("HumanoidRootPart")
    for _, o in pairs(S.ESPObjects) do pcall(function() o:Destroy() end) end
    S.ESPObjects = {}
end)

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

local function LongRangeKill(enemy)
    if not enemy then return end
    local eRoot = enemy:FindFirstChild("HumanoidRootPart")
    local eHum  = enemy:FindFirstChildOfClass("Humanoid")
    if not eRoot or not eHum then return end
    FireRemote("damage",  enemy, 99999)
    FireRemote("hit",     enemy, eRoot.Position)
    FireRemote("attack",  enemy)
    FireRemote("dealDmg", enemy, 99999)
    FireRemote("takeDmg", enemy, 99999)
    FireRemote("onHit",   enemy, eRoot.Position, 99999)
    FireRemote("combat",  enemy)
    FireRemote("kill",    enemy)
    FireRemote("death",   enemy)
    pcall(function() eHum.Health = 0 end)
    if S.AuraDamageMode == "Teleport" or S.AuraDamageMode == "Both" then
        if Root then
            local savedCF = Root.CFrame
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
                if Root then Root.CFrame = savedCF end
            end)
        end
    end
    if Char then
        local tool = Char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        v:FireServer(eRoot.Position, enemy)
                    end
                end
            end)
        end
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
    FireRemote("destroy",  obj)
    FireRemote("break",    obj)
    FireRemote("open",     obj)
    FireRemote("interact", obj)
    FireRemote("collect",  obj)
    FireRemote("loot",     obj)
    FireRemote("smash",    obj)
    local part = obj:IsA("BasePart") and obj
        or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
    if part and Root then
        local saved = Root.CFrame
        Root.CFrame = part.CFrame + Vector3.new(0, 2, 0)
        task.defer(function()
            if Root then Root.CFrame = saved end
        end)
    end
    if obj:IsA("Model") then
        local h = obj:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.Health = 0 end) end
    end
end

local ForgeWatcher
local function StartForgeWatcher()
    if ForgeWatcher then ForgeWatcher:Disconnect() end
    ForgeWatcher = RunService.Heartbeat:Connect(function()
        if not S.AutoForge then return end
        local function ScanGui(gui)
            if not gui then return end
            for _, v in ipairs(gui:GetDescendants()) do
                local name = v.Name:lower()
                if v:IsA("Frame") or v:IsA("ImageLabel") then
                    if name:find("indicator") or name:find("needle") or name:find("cursor")
                    or name:find("arrow") or name:find("marker") or name:find("slider") then
                        local pos    = v.AbsolutePosition
                        local parent = v.Parent
                        if parent and parent:IsA("GuiObject") then
                            local pPos  = parent.AbsolutePosition
                            local pSize = parent.AbsoluteSize
                            local relX  = (pos.X - pPos.X) / math.max(pSize.X, 1)
                            if relX >= 0.60 and relX <= 0.85 then
                                FireRemote("forge")
                                FireRemote("craft")
                                FireRemote("confirm")
                                FireRemote("submit")
                                FireRemote("forgeConfirm")
                                FireRemote("craftItem")
                                FireRemote("forgeBar")
                                FireRemote("barHit")
                                pcall(function()
                                    VIM:SendMouseButtonEvent(
                                        pos.X + v.AbsoluteSize.X/2,
                                        pos.Y + v.AbsoluteSize.Y/2,
                                        0, true, game, 1)
                                    task.wait(0.05)
                                    VIM:SendMouseButtonEvent(
                                        pos.X + v.AbsoluteSize.X/2,
                                        pos.Y + v.AbsoluteSize.Y/2,
                                        0, false, game, 1)
                                end)
                                for _, key in ipairs({Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.Return, Enum.KeyCode.Space}) do
                                    pcall(function()
                                        VIM:SendKeyEvent(true,  key, false, game)
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

local function ClearESP()
    for _, o in pairs(S.ESPObjects) do pcall(function() o:Destroy() end) end
    S.ESPObjects = {}
end

local function MakeESP(target, color, label)
    local root = (target:IsA("Model") and (target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart))
        or (target:IsA("BasePart") and target)
    if not root then return end
    local box = Instance.new("SelectionBox")
    box.Color3              = color
    box.LineThickness       = 0.06
    box.SurfaceTransparency = S.ESPTransparency
    box.SurfaceColor3       = color
    box.Adornee             = target
    box.Parent              = Workspace.CurrentCamera
    table.insert(S.ESPObjects, box)
    if label and (S.ShowNames or S.ShowDistance) then
        local bb = Instance.new("BillboardGui")
        bb.Size        = UDim2.new(0, 140, 0, 36)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.Adornee     = root
        bb.Parent      = Workspace.CurrentCamera
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size                   = UDim2.new(1,0,1,0)
        lbl.TextColor3             = color
        lbl.TextStrokeTransparency = 0
        lbl.TextSize               = 13
        lbl.Font                   = Enum.Font.GothamBold
        lbl.Text                   = label
        lbl.Parent                 = bb
        table.insert(S.ESPObjects, bb)
    end
end

local function UpdateESP()
    ClearESP()
    if S.ESPEnemies then
        for _, e in ipairs(GetEnemies()) do
            local r = e:FindFirstChild("HumanoidRootPart")
            local d = r and Root and math.floor(Dist(Root,r)) or 0
            local lbl = (S.ShowNames and e.Name or "")..( S.ShowDistance and (" | "..d.."m") or "")
            MakeESP(e, S.ESPColor, lbl)
        end
    end
    if S.ESPPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                local d = r and Root and math.floor(Dist(Root,r)) or 0
                local lbl = (S.ShowNames and p.Name or "")..(S.ShowDistance and (" | "..d.."m") or "")
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

local timers = {aura=0, ability=0, antiIdle=0, loot=0, egg=0, esp=0, dodge=0}

RunService.Heartbeat:Connect(function(dt)
    if not RefreshChar() then return end
    if Hum then
        Hum.WalkSpeed = S.WalkSpeed
        Hum.JumpPower = S.JumpPower
    end
    Workspace.Gravity = S.Gravity
    if Hum and Hum.MaxHealth > 0 then
        if (Hum.Health / Hum.MaxHealth * 100) < S.HealThreshold then
            FireRemote("heal")
            FireRemote("potion")
            FireRemote("useItem")
        end
    end
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
    if S.AutoCombat then
        local enemy = GetNearestEnemy(S.AttackRange, S.BossPriority)
        if enemy then
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eRoot then
                FireRemote("attack", enemy)
                FireRemote("hit",    enemy, eRoot.Position)
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
                            local t = tools[math.random(1,#tools)]
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
                if n:find("drop") or n:find("loot") or n:find("item") or n:find("pickup") or n:find("ore") or n:find("shard") then
                    local part = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
                    if part and Dist(Root, part) <= S.LootRange then
                        FireRemote("loot",    obj)
                        FireRemote("pickup",  obj)
                        FireRemote("collect", obj)
                        Root.CFrame = part.CFrame + Vector3.new(0,3,0)
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
                local part = obj:IsA("BasePart") and obj
                    or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                if part and Dist(Root, part) <= S.EggRange then
                    DestroyEgg(obj)
                end
            end
        end
    end
    if S.AutoReturn then
        local portal = Workspace:FindFirstChild("DungeonPortal",true)
            or Workspace:FindFirstChild("ReturnPortal",true)
            or Workspace:FindFirstChild("Entrance",true)
            or Workspace:FindFirstChild("Exit",true)
        if portal then
            local part = portal:IsA("BasePart") and portal or portal.PrimaryPart
            if part then
                if Dist(Root, part) > 8 then
                    Root.CFrame = part.CFrame + Vector3.new(0,3,0)
                else
                    FireRemote("return")
                    FireRemote("enterDungeon")
                    FireRemote("returnDungeon")
                end
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
        local key = S.AbilityList[S.AbilityIndex]
        S.AbilityIndex = (S.AbilityIndex % #S.AbilityList) + 1
        pcall(function()
            VIM:SendKeyEvent(true,  Enum.KeyCode[key], false, game)
            task.wait(0.04)
            VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
        end)
    end
    timers.antiIdle = timers.antiIdle + dt
    if S.AntiIdle and timers.antiIdle >= 55 then
        timers.antiIdle = 0
        pcall(function()
            VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
        FireRemote("antiIdle")
        FireRemote("ping")
    end
    timers.esp = timers.esp + dt
    if timers.esp >= 0.5 then
        timers.esp = 0
        if S.ESPEnemies or S.ESPPlayers or S.ESPLoot or S.ESPChests then
            UpdateESP()
        end
    end
end)

local Win = Rayfield:CreateWindow({
    Name                    = "Iron Soul: Dungeon",
    LoadingTitle            = "Iron Soul: Dungeon",
    LoadingSubtitle         = "v2 — Long Range AFK Build",
    Theme                   = "Dark",
    DisableRayfieldPrompts  = true,
    DisableBuildWarnings    = true,
})

local AuraTab = Win:CreateTab("Kill Aura", 4483362458)
AuraTab:CreateSection("Long Range AFK — Stay Back, Everything Dies")
AuraTab:CreateToggle({
    Name="Long Range Kill Aura", CurrentValue=false, Flag="LongAura",
    Callback=function(v)
        S.LongAura = v
        Rayfield:Notify({Title="Kill Aura", Content=v and "ACTIVE — AFK on." or "OFF", Duration=2})
    end,
})
AuraTab:CreateSlider({
    Name="Aura Range", Range={50,500}, Increment=10, Suffix=" studs",
    CurrentValue=150, Flag="AuraRange",
    Callback=function(v) S.AuraRange=v end,
})
AuraTab:CreateSlider({
    Name="Aura Fire Rate (lower = faster)", Range={1,20}, Increment=1, Suffix=" x10ms",
    CurrentValue=5, Flag="AuraInterval",
    Callback=function(v) S.AuraInterval=v*0.01 end,
})
AuraTab:CreateDropdown({
    Name="Damage Mode", Options={"Remote","Teleport","Both"}, CurrentOption="Both", Flag="AuraDamageMode",
    Callback=function(v) S.AuraDamageMode=v end,
})
AuraTab:CreateToggle({
    Name="Boss Priority", CurrentValue=false, Flag="BossPriority",
    Callback=function(v) S.BossPriority=v end,
})
AuraTab:CreateToggle({
    Name="Auto Dodge", CurrentValue=false, Flag="AutoDodge",
    Callback=function(v) S.AutoDodge=v end,
})

local CombatTab = Win:CreateTab("Combat", 4483362458)
CombatTab:CreateSection("Close-Range Combat")
CombatTab:CreateToggle({
    Name="Auto Combat", CurrentValue=false, Flag="AutoCombat",
    Callback=function(v) S.AutoCombat=v end,
})
CombatTab:CreateToggle({
    Name="Auto Loot", CurrentValue=false, Flag="AutoLoot",
    Callback=function(v) S.AutoLoot=v end,
})
CombatTab:CreateToggle({
    Name="Auto Return to Dungeon", CurrentValue=false, Flag="AutoReturn",
    Callback=function(v) S.AutoReturn=v end,
})
CombatTab:CreateToggle({
    Name="Weapon Switch", CurrentValue=false, Flag="WeaponSwitch",
    Callback=function(v) S.WeaponSwitch=v end,
})
CombatTab:CreateToggle({
    Name="Ability Rotation", CurrentValue=false, Flag="AbilityRotation",
    Callback=function(v) S.AbilityRotation=v end,
})
CombatTab:CreateSlider({
    Name="Attack Range", Range={5,100}, Increment=1, Suffix="m",
    CurrentValue=20, Flag="AttackRange",
    Callback=function(v) S.AttackRange=v end,
})
CombatTab:CreateSlider({
    Name="Loot Range", Range={5,80}, Increment=1, Suffix="m",
    CurrentValue=15, Flag="LootRange",
    Callback=function(v) S.LootRange=v end,
})
CombatTab:CreateSlider({
    Name="Heal Threshold", Range={1,99}, Increment=1, Suffix="%",
    CurrentValue=40, Flag="HealThreshold",
    Callback=function(v) S.HealThreshold=v end,
})

local ForgeTab = Win:CreateTab("Forge", 4483362458)
ForgeTab:CreateSection("Auto Perfect Forge")
ForgeTab:CreateToggle({
    Name="Auto Perfect Forge", CurrentValue=false, Flag="AutoForge",
    Callback=function(v)
        S.AutoForge=v
        if v then StartForgeWatcher() end
        Rayfield:Notify({Title="Forge", Content=v and "Watching forge bar." or "OFF", Duration=2})
    end,
})
ForgeTab:CreateButton({
    Name="Fire Forge Remote (manual)",
    Callback=function()
        FireRemote("forge"); FireRemote("craft")
        FireRemote("craftItem"); FireRemote("confirm")
        Rayfield:Notify({Title="Forge", Content="Fired.", Duration=2})
    end,
})
ForgeTab:CreateButton({
    Name="Auto Collect Ores",
    Callback=function()
        if not RefreshChar() then return end
        local count=0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local n=obj.Name:lower()
                if n:find("ore") or n:find("mineral") or n:find("material") or n:find("shard") then
                    local part=obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")))
                    if part then
                        Root.CFrame=part.CFrame+Vector3.new(0,3,0)
                        FireRemote("collect",obj); FireRemote("pickup",obj); FireRemote("loot",obj)
                        count=count+1
                    end
                end
            end
        end
        Rayfield:Notify({Title="Ores", Content="Collected "..count.." objects.", Duration=3})
    end,
})

local DungeonTab = Win:CreateTab("Dungeon", 4483362458)
DungeonTab:CreateSection("Chest Egg Destroyer")
DungeonTab:CreateToggle({
    Name="Auto Destroy Chest Eggs", CurrentValue=false, Flag="AutoEgg",
    Callback=function(v) S.AutoEgg=v end,
})
DungeonTab:CreateSlider({
    Name="Egg Scan Range", Range={20,500}, Increment=10, Suffix=" studs",
    CurrentValue=200, Flag="EggRange",
    Callback=function(v) S.EggRange=v end,
})
DungeonTab:CreateButton({
    Name="Destroy ALL Eggs Now",
    Callback=function()
        if not RefreshChar() then return end
        local count=0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if IsEgg(obj) then DestroyEgg(obj); count=count+1 end
        end
        Rayfield:Notify({Title="Eggs", Content="Smashed "..count.." objects.", Duration=3})
    end,
})
DungeonTab:CreateSection("Navigation")
DungeonTab:CreateButton({
    Name="Teleport to Nearest Boss",
    Callback=function()
        if not RefreshChar() then return end
        local boss=GetNearestEnemy(math.huge,true)
        if boss then
            local r=boss:FindFirstChild("HumanoidRootPart")
            if r then Root.CFrame=r.CFrame+Vector3.new(0,3,6) end
        else
            Rayfield:Notify({Title="Boss TP", Content="No boss found.", Duration=2})
        end
    end,
})
DungeonTab:CreateButton({
    Name="Teleport to Dungeon Portal",
    Callback=function()
        if not RefreshChar() then return end
        local portal=Workspace:FindFirstChild("DungeonPortal",true)
            or Workspace:FindFirstChild("ReturnPortal",true)
            or Workspace:FindFirstChild("Entrance",true)
            or Workspace:FindFirstChild("Exit",true)
        if portal then
            local p=portal:IsA("BasePart") and portal or portal.PrimaryPart
            if p then Root.CFrame=p.CFrame+Vector3.new(0,3,0) end
        else
            Rayfield:Notify({Title="Portal", Content="No portal found.", Duration=2})
        end
    end,
})

local MoveTab = Win:CreateTab("Movement", 4483362458)
MoveTab:CreateSlider({
    Name="Walk Speed", Range={16,500}, Increment=1, Suffix="",
    CurrentValue=16, Flag="WalkSpeed",
    Callback=function(v) S.WalkSpeed=v; if Hum then Hum.WalkSpeed=v end end,
})
MoveTab:CreateSlider({
    Name="Jump Power", Range={50,500}, Increment=5, Suffix="",
    CurrentValue=50, Flag="JumpPower",
    Callback=function(v) S.JumpPower=v; if Hum then Hum.JumpPower=v end end,
})
MoveTab:CreateSlider({
    Name="Gravity", Range={0,400}, Increment=5, Suffix="",
    CurrentValue=196, Flag="Gravity",
    Callback=function(v) S.Gravity=v; Workspace.Gravity=v end,
})
MoveTab:CreateButton({
    Name="Reset Movement",
    Callback=function()
        S.WalkSpeed=16; S.JumpPower=50; S.Gravity=196.2
        if Hum then Hum.WalkSpeed=16; Hum.JumpPower=50 end
        Workspace.Gravity=196.2
    end,
})

local UtilTab = Win:CreateTab("Utility", 4483362458)
UtilTab:CreateToggle({
    Name="Anti-Idle", CurrentValue=false, Flag="AntiIdle",
    Callback=function(v) S.AntiIdle=v end,
})
UtilTab:CreateButton({
    Name="Kill Character",
    Callback=function()
        if Hum then Hum.Health=0 end
        FireRemote("kill")
    end,
})
UtilTab:CreateButton({
    Name="Dump All Remotes (console)",
    Callback=function()
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                print("[REMOTE]", v:GetFullName())
            end
        end
        Rayfield:Notify({Title="Remotes", Content="Check console.", Duration=3})
    end,
})
UtilTab:CreateButton({
    Name="Reset GUI",
    Callback=function()
        for k,v in pairs(S) do
            if type(v)=="boolean" then S[k]=false end
        end
        S.WalkSpeed=16; S.JumpPower=50; S.Gravity=196.2
        S.AttackRange=20; S.LootRange=15; S.HealThreshold=40
        S.AuraRange=150; S.AuraInterval=0.05; S.EggRange=200
        if Hum then Hum.WalkSpeed=16; Hum.JumpPower=50 end
        Workspace.Gravity=196.2
        ClearESP()
        Rayfield:Notify({Title="GUI", Content="Full reset.", Duration=2})
    end,
})
UtilTab:CreateButton({
    Name="Rejoin",
    Callback=function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
    end,
})

local ESPTab = Win:CreateTab("ESP", 4483362458)
ESPTab:CreateToggle({
    Name="ESP Enemies", CurrentValue=false, Flag="ESPEnemies",
    Callback=function(v) S.ESPEnemies=v; if not v then ClearESP() end end,
})
ESPTab:CreateToggle({
    Name="ESP Players", CurrentValue=false, Flag="ESPPlayers",
    Callback=function(v) S.ESPPlayers=v; if not v then ClearESP() end end,
})
ESPTab:CreateToggle({
    Name="ESP Loot", CurrentValue=false, Flag="ESPLoot",
    Callback=function(v) S.ESPLoot=v; if not v then ClearESP() end end,
})
ESPTab:CreateToggle({
    Name="ESP Chests/Eggs", CurrentValue=false, Flag="ESPChests",
    Callback=function(v) S.ESPChests=v; if not v then ClearESP() end end,
})
ESPTab:CreateColorPicker({
    Name="Enemy Color", Color=Color3.fromRGB(255,50,50), Flag="ESPEnemyColor",
    Callback=function(c) S.ESPColor=c end,
})
ESPTab:CreateColorPicker({
    Name="Player Color", Color=Color3.fromRGB(50,150,255), Flag="ESPPlayerColor",
    Callback=function(c) S.PlayerESPColor=c end,
})
ESPTab:CreateColorPicker({
    Name="Loot Color", Color=Color3.fromRGB(255,215,0), Flag="ESPLootColor",
    Callback=function(c) S.LootESPColor=c end,
})
ESPTab:CreateColorPicker({
    Name="Chest/Egg Color", Color=Color3.fromRGB(0,255,100), Flag="ESPChestColor",
    Callback=function(c) S.ChestESPColor=c end,
})
ESPTab:CreateSlider({
    Name="ESP Transparency", Range={0,1}, Increment=0.05, Suffix="",
    CurrentValue=0.4, Flag="ESPTransparency",
    Callback=function(v) S.ESPTransparency=v end,
})
ESPTab:CreateToggle({
    Name="Show Names", CurrentValue=true, Flag="ShowNames",
    Callback=function(v) S.ShowNames=v end,
})
ESPTab:CreateToggle({
    Name="Show Distance", CurrentValue=true, Flag="ShowDistance",
    Callback=function(v) S.ShowDistance=v end,
})

Rayfield:Notify({
    Title   = "Iron Soul: Dungeon v2",
    Content = "Loaded. Go to Kill Aura tab and enable.",
    Duration= 4,
})
