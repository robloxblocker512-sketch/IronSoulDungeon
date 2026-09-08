-- Iron Soul Dungeon - Full Build (Checked & Fixed)
-- Delta + Rayfield

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

-- ===== GLOBALS =====
_G.autoCombat = false
_G.autoLoot = false
_G.autoReturn = false
_G.walkSpeed = 16
_G.jumpPower = 50
_G.attackRange = 15
_G.lootRange = 30
_G.abilityRotation = false
_G.autoDodge = true
_G.killAura = false
_G.killAuraRange = 2.5
_G.healThreshold = 30
_G.bossPriority = true
_G.aoeRadius = 12
_G.espEnabled = false
_G.espLoot = false
_G.antiIdle = false
_G.abilityCooldowns = {}
_G.lastAttackTime = 0
_G.attackCooldown = 0.35

-- ===== HELPERS (defined FIRST so ESP can use them) =====
local function getEnemies()
    local enemies = {}
    local workspace = game:GetService("Workspace")
    if workspace:FindFirstChild("Enemies") then
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                table.insert(enemies, v)
            end
        end
    end
    return enemies
end

local function getLoot()
    local loot = {}
    local workspace = game:GetService("Workspace")
    if workspace:FindFirstChild("Loot") then
        for _, v in pairs(workspace.Loot:GetChildren()) do
            if v:FindFirstChild("Handle") and v:FindFirstChild("TouchInterest") then
                table.insert(loot, v)
            end
        end
    end
    return loot
end

local function getClosestEnemy()
    local closest = nil
    local closestDist = math.huge
    for _, enemy in pairs(getEnemies()) do
        local dist = (enemy.HumanoidRootPart.Position - Root.Position).Magnitude
        if dist < closestDist then
            closest = enemy
            closestDist = dist
        end
    end
    return closest, closestDist
end

local function getClosestLoot()
    local closest = nil
    local closestDist = math.huge
    for _, item in pairs(getLoot()) do
        if item:FindFirstChild("Handle") then
            local dist = (item.Handle.Position - Root.Position).Magnitude
            if dist < closestDist then
                closest = item
                closestDist = dist
            end
        end
    end
    return closest, closestDist
end

local function getTool()
    local tool = Char:FindFirstChildWhichIsA("Tool")
    if not tool then
        tool = Player.Backpack:FindFirstChildWhichIsA("Tool")
    end
    return tool
end

local function getAbilities()
    local abilities = {}
    for _, v in pairs(Char:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("Ability") then
            table.insert(abilities, v)
        end
    end
    return abilities
end

local function getCooldown(ability)
    local cd = _G.abilityCooldowns[ability]
    if cd and tick() - cd < 2 then
        return true
    end
    return false
end

local function setCooldown(ability)
    _G.abilityCooldowns[ability] = tick()
end

local function getTargets()
    local targets = {}
    local enemies = getEnemies()
    if _G.bossPriority then
        for _, enemy in pairs(enemies) do
            if enemy:FindFirstChild("BossTag") or enemy.Name:find("Boss") then
                table.insert(targets, enemy)
            end
        end
    end
    if #targets == 0 then
        targets = enemies
    end
    return targets
end

-- ===== RAYFIELD UI =====
local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by VANTA",
    Theme = "Default"
})

local CombatTab = Window:CreateTab("Combat")
local MovementTab = Window:CreateTab("Movement")
local UtilityTab = Window:CreateTab("Utility")
local CombatOverhaulTab = Window:CreateTab("Combat Overhaul")

-- ===== COMBAT TAB =====
local CombatSection = CombatTab:CreateSection("Auto")
CombatSection:CreateToggle({
    Name = "Auto Combat",
    CurrentValue = false,
    Flag = "AutoCombat",
    Callback = function(v) _G.autoCombat = v end
})
CombatSection:CreateToggle({
    Name = "Auto Loot",
    CurrentValue = false,
    Flag = "AutoLoot",
    Callback = function(v) _G.autoLoot = v end
})
CombatSection:CreateToggle({
    Name = "Auto Return to Dungeon",
    CurrentValue = false,
    Flag = "AutoReturn",
    Callback = function(v) _G.autoReturn = v end
})
CombatSection:CreateSlider({
    Name = "Attack Range",
    Range = {5, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 15,
    Flag = "AttackRange",
    Callback = function(v) _G.attackRange = v end
})
CombatSection:CreateSlider({
    Name = "Loot Range",
    Range = {10, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 30,
    Flag = "LootRange",
    Callback = function(v) _G.lootRange = v end
})

-- ===== MOVEMENT TAB =====
local MovementSection = MovementTab:CreateSection("Stats")
MovementSection:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 120},
    Increment = 1,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        _G.walkSpeed = v
        if Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.WalkSpeed = v
        end
    end
})
MovementSection:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = "jump",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v)
        _G.jumpPower = v
        if Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.JumpPower = v
        end
    end
})

-- ===== UTILITY TAB =====
local UtilitySection = UtilityTab:CreateSection("Tools")
UtilitySection:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
    end
})
UtilitySection:CreateButton({
    Name = "Kill Character",
    Callback = function()
        if Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.Health = 0
        end
    end
})
UtilitySection:CreateButton({
    Name = "Reset GUI",
    Callback = function()
        Rayfield:Destroy()
        _G.autoCombat = false
        _G.autoLoot = false
        _G.autoReturn = false
        _G.abilityRotation = false
        _G.killAura = false
        _G.espEnabled = false
        _G.espLoot = false
        _G.antiIdle = false
    end
})

-- ===== TELEPORTS =====
local TeleportSection = UtilityTab:CreateSection("Teleports")
TeleportSection:CreateButton({
    Name = "Teleport to Nearest Chest",
    Callback = function()
        pcall(function()
            local chests = game:GetService("Workspace"):FindFirstChild("Chests")
            if not chests then return end
            local closest = nil
            local dist = math.huge
            for _, v in pairs(chests:GetChildren()) do
                if v:FindFirstChild("Handle") then
                    local mag = (v.Handle.Position - Root.Position).Magnitude
                    if mag < dist then
                        closest = v
                        dist = mag
                    end
                end
            end
            if closest and closest:FindFirstChild("Handle") then
                Root.CFrame = closest.Handle.CFrame
            end
        end)
    end
})

-- ===== FORGE =====
local ForgeSection = UtilityTab:CreateSection("Forge")
ForgeSection:CreateButton({
    Name = "Auto-Forge (Craft All)",
    Callback = function()
        pcall(function()
            local forge = game:GetService("Workspace"):FindFirstChild("Forge")
            if not forge then return end
            Root.CFrame = forge.CFrame
            task.wait(0.5)
            local gui = Player.PlayerGui:FindFirstChild("ForgeUI")
            if gui then
                local craftBtn = gui:FindFirstChild("CraftAllButton")
                if craftBtn then
                    craftBtn:Click()
                end
            end
        end)
    end
})

-- ===== ESP =====
local ESPSection = UtilityTab:CreateSection("ESP")
ESPSection:CreateToggle({
    Name = "ESP (Enemies)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v)
        _G.espEnabled = v
        if v then
            for _, enemy in pairs(getEnemies()) do
                local highlight = Instance.new("Highlight")
                highlight.Parent = enemy
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.FillTransparency = 0.4
                enemy:SetAttribute("Highlight", highlight)
            end
        else
            for _, enemy in pairs(getEnemies()) do
                local h = enemy:GetAttribute("Highlight")
                if h then h:Destroy() end
            end
        end
    end
})
ESPSection:CreateToggle({
    Name = "ESP (Loot)",
    CurrentValue = false,
    Flag = "ESPLoot",
    Callback = function(v)
        _G.espLoot = v
        if v then
            for _, item in pairs(getLoot()) do
                if item:FindFirstChild("Handle") then
                    local highlight = Instance.new("Highlight")
                    highlight.Parent = item
                    highlight.FillColor = Color3.new(0, 1, 0)
                    highlight.FillTransparency = 0.3
                    item:SetAttribute("LootHighlight", highlight)
                end
            end
        else
            for _, item in pairs(getLoot()) do
                local h = item:GetAttribute("LootHighlight")
                if h then h:Destroy() end
            end
        end
    end
})

-- ===== ANTI-IDLE =====
local AntiIdleSection = UtilityTab:CreateSection("Anti-Idle")
AntiIdleSection:CreateToggle({
    Name = "Anti-Idle (Prevent Kick)",
    CurrentValue = false,
    Flag = "AntiIdle",
    Callback = function(v) _G.antiIdle = v end
})

-- ===== COMBAT OVERHAUL TAB =====
local COSection = CombatOverhaulTab:CreateSection("Combat Overhaul")

COSection:CreateToggle({
    Name = "Ability Rotation",
    CurrentValue = false,
    Flag = "AbilityRotation",
    Callback = function(v) _G.abilityRotation = v end
})

COSection:CreateToggle({
    Name = "Kill Aura (Subtle)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v) _G.killAura = v end
})

COSection:CreateSlider({
    Name = "Kill Aura Extra Range",
    Range = {0.5, 8},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 2.5,
    Flag = "KillAuraRange",
    Callback = function(v) _G.killAuraRange = v end
})

COSection:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = true,
    Flag = "AutoDodge",
    Callback = function(v) _G.autoDodge = v end
})

COSection:CreateToggle({
    Name = "Boss Priority",
    CurrentValue = true,
    Flag = "BossPriority",
    Callback = function(v) _G.bossPriority = v end
})

COSection:CreateSlider({
    Name = "Heal Threshold %",
    Range = {10, 80},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 30,
    Flag = "HealThreshold",
    Callback = function(v) _G.healThreshold = v end
})

COSection:CreateSlider({
    Name = "AoE Radius",
    Range = {5, 25},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 12,
    Flag = "AoERadius",
    Callback = function(v) _G.aoeRadius = v end
})

-- ===== DODGE =====
local function dodge()
    pcall(function()
        local dir = Root.CFrame.LookVector * -20 + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
        Root.CFrame = Root.CFrame + dir
        task.wait(0.1)
        Root.CFrame = Root.CFrame + Root.CFrame.LookVector * 5
    end)
end

-- ===== HEAL =====
local function heal()
    pcall(function()
        if Hum.Health / Hum.MaxHealth * 100 < _G.healThreshold then
            local potion = Player.Backpack:FindFirstChild("HealthPotion") or Char:FindFirstChild("HealthPotion")
            if potion then
                potion:Activate()
                task.wait(0.3)
            end
        end
    end)
end

-- ===== ABILITY ROTATION =====
local function useAbilities(target)
    if not target then return end
    pcall(function()
        local abilities = getAbilities()
        local sorted = {}
        for _, ab in pairs(abilities) do
            local dmg = ab:GetAttribute("Damage") or 0
            local cd = getCooldown(ab)
            if not cd then
                table.insert(sorted, {ability = ab, damage = dmg})
            end
        end
        table.sort(sorted, function(a, b) return a.damage > b.damage end)
        
        for _, entry in ipairs(sorted) do
            local ab = entry.ability
            if ab:FindFirstChild("Handle") then
                ab.Handle.CFrame = target.HumanoidRootPart.CFrame
                ab:Activate()
                setCooldown(ab)
                task.wait(0.15)
            end
        end
    end)
end

-- ===== SUBTLE KILL AURA =====
local function subtleKillAura()
    if not _G.killAura then return end
    pcall(function()
        local target, dist = getClosestEnemy()
        if not target then return end
        
        local extendedRange = _G.attackRange + _G.killAuraRange
        if dist > extendedRange then return end
        
        if tick() - _G.lastAttackTime < math.random(30, 60) / 100 then
            return
        end
        
        local tool = getTool()
        if not tool then return end
        
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if hrp then
            Root.CFrame = CFrame.new(Root.Position, hrp.Position)
        end
        
        if math.random() > 0.15 then
            tool:Activate()
            _G.lastAttackTime = tick()
        end
        
        if math.random() > 0.7 then
            Hum.Jump = true
        end
    end)
end

-- ===== MAIN LOOP =====
local function mainLoop()
    while task.wait(0.1) do
        pcall(function()
            Char = Player.Character or Player.CharacterAdded:Wait()
            if not Char then return end
            Root = Char:FindFirstChild("HumanoidRootPart")
            Hum = Char:FindFirstChild("Humanoid")
            if not Root or not Hum then return end

            -- Auto combat with overhaul
            if _G.autoCombat then
                local targets = getTargets()
                local target = targets[1]
                
                if target then
                    local dist = (target.HumanoidRootPart.Position - Root.Position).Magnitude
                    
                    if _G.autoDodge and target:FindFirstChild("WindUp") and target.WindUp.Value == true then
                        dodge()
                    end
                    
                    heal()
                    
                    if _G.abilityRotation then
                        useAbilities(target)
                    end
                    
                    if _G.killAura then
                        subtleKillAura()
                    end
                    
                    if dist < _G.attackRange then
                        Root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                        local tool = getTool()
                        if tool and tick() - _G.lastAttackTime > _G.attackCooldown then
                            tool:Activate()
                            _G.lastAttackTime = tick()
                        end
                    else
                        Root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.attackRange - 2)
                    end
                end
            end

            -- Auto loot
            if _G.autoLoot then
                local loot, dist = getClosestLoot()
                if loot and dist < _G.lootRange then
                    Root.CFrame = loot.Handle.CFrame
                    task.wait(0.2)
                end
            end

            -- Auto return
            if _G.autoReturn then
                local inDungeon = game:GetService("Workspace"):FindFirstChild("DungeonZone") ~= nil
                if not inDungeon then
                    local lobby = game:GetService("Workspace"):FindFirstChild("LobbySpawn")
                    if lobby then
                        Root.CFrame = lobby.CFrame
                    end
                end
            end

            -- Speed/jump sync
            if Hum.WalkSpeed ~= _G.walkSpeed then
                Hum.WalkSpeed = _G.walkSpeed
            end
            if Hum.JumpPower ~= _G.jumpPower then
                Hum.JumpPower = _G.jumpPower
            end
        end)
    end
end

-- ===== ANTI-IDLE LOOP =====
task.spawn(function()
    while true do
        task.wait(60)
        if _G.antiIdle then
            pcall(function()
                local v = game:GetService("VirtualUser")
                v:CaptureController()
                v:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ===== ESP UPDATE LOOP =====
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            if _G.espEnabled then
                for _, enemy in pairs(getEnemies()) do
                    if not enemy:GetAttribute("Highlight") then
                        local h = Instance.new("Highlight")
                        h.Parent = enemy
                        h.FillColor = Color3.new(1, 0, 0)
                        h.FillTransparency = 0.4
                        enemy:SetAttribute("Highlight", h)
                    end
                end
            end
            if _G.espLoot then
                for _, item in pairs(getLoot()) do
                    if item:FindFirstChild("Handle") and not item:GetAttribute("LootHighlight") then
                        local h = Instance.new("Highlight")
                        h.Parent = item
                        h.FillColor = Color3.new(0, 1, 0)
                        h.FillTransparency = 0.3
                        item:SetAttribute("LootHighlight", h)
                    end
                end
            end
        end)
    end
end)

-- ===== RESPAWN =====
Player.CharacterAdded:Connect(function()
    task.wait(1)
    Char = Player.Character
    Root = Char:FindFirstChild("HumanoidRootPart")
    Hum = Char:FindFirstChild("Humanoid")
end)

-- ===== START =====
task.spawn(mainLoop)
