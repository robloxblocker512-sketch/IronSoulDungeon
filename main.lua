-- Iron Soul Dungeon - Kavo UI (Alternative)
-- Delta compatible

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/Kavo.lua"))()

local Window = Library.CreateLib("Iron Soul Dungeon", "DarkTheme")

local CombatTab = Window:NewTab("Combat")
local CombatSection = CombatTab:NewSection("Auto")
CombatSection:NewToggle("Auto Combat", "Toggle", function(v)
    _G.autoCombat = v
end)
CombatSection:NewToggle("Auto Loot", "Toggle", function(v)
    _G.autoLoot = v
end)
CombatSection:NewToggle("Auto Return", "Toggle", function(v)
    _G.autoReturn = v
end)
CombatSection:NewSlider("Attack Range", "studs", 5, 50, 15, function(v)
    _G.attackRange = v
end)
CombatSection:NewSlider("Loot Range", "studs", 10, 100, 30, function(v)
    _G.lootRange = v
end)

local MovementTab = Window:NewTab("Movement")
local MovementSection = MovementTab:NewSection("Stats")
MovementSection:NewSlider("Walk Speed", "speed", 16, 120, 16, function(v)
    _G.walkSpeed = v
end)
MovementSection:NewSlider("Jump Power", "jump", 50, 200, 50, function(v)
    _G.jumpPower = v
end)

local UtilityTab = Window:NewTab("Utility")
local UtilitySection = UtilityTab:NewSection("Tools")
UtilitySection:NewButton("Teleport to Lobby", "Go back", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end)
UtilitySection:NewButton("Kill Character", "Reset", function()
    game.Players.LocalPlayer.Character.Humanoid.Health = 0
end)

local CombatOverhaulTab = Window:NewTab("Combat Overhaul")
local COSection = CombatOverhaulTab:NewSection("Combat Overhaul")
COSection:NewToggle("Ability Rotation", "Toggle", function(v)
    _G.abilityRotation = v
end)
COSection:NewToggle("Kill Aura (Subtle)", "Toggle", function(v)
    _G.killAura = v
end)
COSection:NewSlider("Kill Aura Extra Range", "studs", 0.5, 8, 2.5, function(v)
    _G.killAuraRange = v
end)
COSection:NewToggle("Auto Dodge", "Toggle", function(v)
    _G.autoDodge = v
end)
COSection:NewToggle("Boss Priority", "Toggle", function(v)
    _G.bossPriority = v
end)
COSection:NewSlider("Heal Threshold %", "percent", 10, 80, 30, function(v)
    _G.healThreshold = v
end)

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

Player.CharacterAdded:Connect(function()
    task.wait(1)
    Char = Player.Character
    Root = Char:FindFirstChild("HumanoidRootPart")
    Hum = Char:FindFirstChild("Humanoid")
end)

task.spawn(mainLoop)
