-- Iron Soul Dungeon - Full Rayfield GUI
-- Delta compatible

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by VANTA",
    Theme = "Default"
})

-- ===== TABS =====
local CombatTab = Window:CreateTab("Combat")
local MovementTab = Window:CreateTab("Movement")
local UtilityTab = Window:CreateTab("Utility")
local OverhaulTab = Window:CreateTab("Overhaul")

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
    Name = "Auto Return",
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
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
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
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

-- ===== UTILITY TAB =====
local UtilitySection = UtilityTab:CreateSection("Tools")
UtilitySection:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
    end
})
UtilitySection:CreateButton({
    Name = "Kill Character",
    Callback = function()
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.Health = 0
        end
    end
})

-- ===== OVERHAUL TAB (Kill Aura, Abilities, Dodge, ESP) =====
local OverhaulSection = OverhaulTab:CreateSection("Combat Overhaul")
OverhaulSection:CreateToggle({
    Name = "Kill Aura (Subtle)",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v) _G.killAura = v end
})
OverhaulSection:CreateSlider({
    Name = "Kill Aura Range",
    Range = {0.5, 8},
    Increment = 0.5,
    Suffix = "studs",
    CurrentValue = 2.5,
    Flag = "KillAuraRange",
    Callback = function(v) _G.killAuraRange = v end
})
OverhaulSection:CreateToggle({
    Name = "Ability Rotation",
    CurrentValue = false,
    Flag = "AbilityRotation",
    Callback = function(v) _G.abilityRotation = v end
})
OverhaulSection:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = true,
    Flag = "AutoDodge",
    Callback = function(v) _G.autoDodge = v end
})
OverhaulSection:CreateToggle({
    Name = "Boss Priority",
    CurrentValue = true,
    Flag = "BossPriority",
    Callback = function(v) _G.bossPriority = v end
})
OverhaulSection:CreateSlider({
    Name = "Heal Threshold",
    Range = {10, 80},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 30,
    Flag = "HealThreshold",
    Callback = function(v) _G.healThreshold = v end
})
OverhaulSection:CreateToggle({
    Name = "ESP (Enemies)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v) _G.espEnabled = v end
})
OverhaulSection:CreateToggle({
    Name = "ESP (Loot)",
    CurrentValue = false,
    Flag = "ESPLoot",
    Callback = function(v) _G.espLoot = v end
})

-- ===== GLOBALS =====
_G.autoCombat = false
_G.autoLoot = false
_G.autoReturn = false
_G.walkSpeed = 16
_G.jumpPower = 50
_G.attackRange = 15
_G.lootRange = 30
_G.killAura = false
_G.killAuraRange = 2.5
_G.abilityRotation = false
_G.autoDodge = true
_G.bossPriority = true
_G.healThreshold = 30
_G.espEnabled = false
_G.espLoot = false
_G.abilityCooldowns = {}
_G.lastAttackTime = 0
_G.attackCooldown = 0.35

local Player = game.Players.LocalPlayer
local Char = Player.Character or Player.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")
local Hum = Char:WaitForChild("Humanoid")

-- ===== HELPERS =====
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

-- ===== ESP =====
local function updateESP()
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
    else
        for _, enemy in pairs(getEnemies()) do
            local h = enemy:GetAttribute("Highlight")
            if h then h:Destroy() end
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
    else
        for _, item in pairs(getLoot()) do
            local h = item:GetAttribute("LootHighlight")
            if h then h:Destroy() end
        end
    end
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
            
            -- ESP update (every 2 seconds)
            if _G.espEnabled or _G.espLoot then
                updateESP()
            end
        end)
    end
end

Player.CharacterAdded:Connect(function()
    task.wait(1)
    Char = Player.Character
    Root = Char:FindFirstChild("HumanoidRootPart")
    Hum = Char:FindFirstChild("Humanoid")
end)

task.spawn(mainLoop)
