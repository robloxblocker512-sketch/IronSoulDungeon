-- Iron Soul Dungeon - Full Rayfield GUI (1000+ lines)
-- Delta compatible - Latest Rayfield syntax

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
local ESPTab = Window:CreateTab("ESP")
local ForgeTab = Window:CreateTab("Forge")

-- ===== COMBAT TAB =====
local CombatSection = CombatTab:CreateSection("Auto Combat")
CombatSection:CreateToggle("Auto Combat", false, function(v) _G.autoCombat = v end)
CombatSection:CreateToggle("Auto Loot", false, function(v) _G.autoLoot = v end)
CombatSection:CreateToggle("Auto Return", false, function(v) _G.autoReturn = v end)
CombatSection:CreateSlider("Attack Range", 5, 50, 15, function(v) _G.attackRange = v end)
CombatSection:CreateSlider("Loot Range", 10, 100, 30, function(v) _G.lootRange = v end)
CombatSection:CreateSlider("Combat Delay (ms)", 50, 500, 150, function(v) _G.combatDelay = v / 1000 end)

local CombatWeaponSection = CombatTab:CreateSection("Weapon Settings")
CombatWeaponSection:CreateToggle("Auto-Switch to Best Weapon", true, function(v) _G.autoSwitch = v end)
CombatWeaponSection:CreateDropdown("Preferred Weapon", {"Sword", "Axe", "Hammer", "Bow"}, function(v) _G.preferredWeapon = v end)
CombatWeaponSection:CreateSlider("Weapon Range Bonus", -5, 10, 0, function(v) _G.weaponRangeBonus = v end)

local CombatHealthSection = CombatTab:CreateSection("Health Management")
CombatHealthSection:CreateSlider("Auto-Heal Threshold %", 10, 80, 30, function(v) _G.healThreshold = v end)
CombatHealthSection:CreateToggle("Use Potions", true, function(v) _G.usePotions = v end)
CombatHealthSection:CreateToggle("Use Heal Abilities", true, function(v) _G.useHealAbilities = v end)

-- ===== MOVEMENT TAB =====
local MovementStatsSection = MovementTab:CreateSection("Stats")
MovementStatsSection:CreateSlider("Walk Speed", 16, 200, 16, function(v) 
    _G.walkSpeed = v
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
MovementStatsSection:CreateSlider("Jump Power", 50, 300, 50, function(v) 
    _G.jumpPower = v
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)
MovementStatsSection:CreateSlider("Gravity", 0, 196.2, 196.2, function(v) 
    _G.gravity = v
    game:GetService("Workspace").Gravity = v
end)

local MovementTeleportSection = MovementTab:CreateSection("Teleport")
MovementTeleportSection:CreateButton("Teleport to Dungeon Entrance", function()
    local entrance = game:GetService("Workspace"):FindFirstChild("DungeonEntrance")
    if entrance then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = entrance.CFrame
    end
end)
MovementTeleportSection:CreateButton("Teleport to Boss Room", function()
    local bossRoom = game:GetService("Workspace"):FindFirstChild("BossRoom")
    if bossRoom then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = bossRoom.CFrame
    end
end)
MovementTeleportSection:CreateButton("Teleport to Lobby", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end)

-- ===== UTILITY TAB =====
local UtilityToolsSection = UtilityTab:CreateSection("Tools")
UtilityToolsSection:CreateButton("Kill Character", function()
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end
end)
UtilityToolsSection:CreateButton("Reset GUI", function()
    Rayfield:Destroy()
    _G.autoCombat = false
    _G.autoLoot = false
    _G.autoReturn = false
    _G.abilityRotation = false
    _G.killAura = false
    _G.espEnabled = false
    _G.espLoot = false
end)
UtilityToolsSection:CreateButton("Rejoin Game", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end)

local UtilityAntiSection = UtilityTab:CreateSection("Anti-Kick")
UtilityAntiSection:CreateToggle("Anti-Idle (Prevent Kick)", false, function(v) _G.antiIdle = v end)
UtilityAntiSection:CreateToggle("Anti-AFK Kick", false, function(v) _G.antiAFK = v end)

-- ===== OVERHAUL TAB =====
local OverhaulCombatSection = OverhaulTab:CreateSection("Combat Overhaul")
OverhaulCombatSection:CreateToggle("Kill Aura (Subtle)", false, function(v) _G.killAura = v end)
OverhaulCombatSection:CreateSlider("Kill Aura Extra Range", 0.5, 10, 2.5, function(v) _G.killAuraRange = v end)
OverhaulCombatSection:CreateSlider("Kill Aura Hit Chance %", 50, 100, 85, function(v) _G.killAuraAccuracy = v / 100 end)
OverhaulCombatSection:CreateToggle("Ability Rotation", false, function(v) _G.abilityRotation = v end)
OverhaulCombatSection:CreateToggle("Auto Dodge", true, function(v) _G.autoDodge = v end)
OverhaulCombatSection:CreateToggle("Boss Priority", true, function(v) _G.bossPriority = v end)
OverhaulCombatSection:CreateSlider("Dodge Distance", 10, 40, 20, function(v) _G.dodgeDistance = v end)

local OverhaulAbilitySection = OverhaulTab:CreateSection("Ability Settings")
OverhaulAbilitySection:CreateSlider("Ability Cooldown Buffer (s)", 0.5, 3, 1, function(v) _G.abilityBuffer = v end)
OverhaulAbilitySection:CreateDropdown("Ability Priority", {"Damage First", "Heal First", "Balance"}, function(v) _G.abilityPriority = v end)
OverhaulAbilitySection:CreateToggle("Use Ultimate Abilities", true, function(v) _G.useUltimates = v end)

-- ===== ESP TAB =====
local ESPSection = ESPTab:CreateSection("ESP Settings")
ESPSection:CreateToggle("ESP Enemies", false, function(v) _G.espEnabled = v end)
ESPSection:CreateToggle("ESP Loot", false, function(v) _G.espLoot = v end)
ESPSection:CreateToggle("ESP Chests", false, function(v) _G.espChests = v end)
ESPSection:CreateToggle("ESP Bosses", false, function(v) _G.espBosses = v end)
ESPSection:CreateColorPicker("Enemy ESP Color", Color3.fromRGB(255, 0, 0), function(v) _G.espEnemyColor = v end)
ESPSection:CreateColorPicker("Loot ESP Color", Color3.fromRGB(0, 255, 0), function(v) _G.espLootColor = v end)
ESPSection:CreateSlider("ESP Transparency", 0, 1, 0.4, function(v) _G.espTransparency = v end)
ESPSection:CreateToggle("ESP Show Names", true, function(v) _G.espShowNames = v end)
ESPSection:CreateToggle("ESP Show Distance", true, function(v) _G.espShowDistance = v end)

-- ===== FORGE TAB =====
local ForgeSection = ForgeTab:CreateSection("Auto Forge")
ForgeSection:CreateToggle("Auto-Forge", false, function(v) _G.autoForge = v end)
ForgeSection:CreateToggle("Auto-Craft Best Gear", false, function(v) _G.autoCraftBest = v end)
ForgeSection:CreateToggle("Auto-Salvage Junk", false, function(v) _G.autoSalvage = v end)
ForgeSection:CreateSlider("Forge Delay (s)", 0.5, 5, 1, function(v) _G.forgeDelay = v end)
ForgeSection:CreateDropdown("Crafting Priority", {"Weapons First", "Armor First", "Accessories First"}, function(v) _G.craftPriority = v end)
ForgeSection:CreateButton("Force Forge Now", function()
    pcall(function()
        local forge = game:GetService("Workspace"):FindFirstChild("Forge")
        if forge then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = forge.CFrame
            task.wait(0.5)
            local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ForgeUI")
            if gui then
                local craftBtn = gui:FindFirstChild("CraftAllButton")
                if craftBtn then craftBtn:Click() end
            end
        end
    end)
end)

-- ===== GLOBALS =====
_G.autoCombat = false
_G.autoLoot = false
_G.autoReturn = false
_G.walkSpeed = 16
_G.jumpPower = 50
_G.gravity = 196.2
_G.attackRange = 15
_G.lootRange = 30
_G.combatDelay = 0.15
_G.autoSwitch = true
_G.preferredWeapon = "Sword"
_G.weaponRangeBonus = 0
_G.healThreshold = 30
_G.usePotions = true
_G.useHealAbilities = true
_G.killAura = false
_G.killAuraRange = 2.5
_G.killAuraAccuracy = 0.85
_G.abilityRotation = false
_G.autoDodge = true
_G.bossPriority = true
_G.dodgeDistance = 20
_G.abilityBuffer = 1
_G.abilityPriority = "Damage First"
_G.useUltimates = true
_G.espEnabled = false
_G.espLoot = false
_G.espChests = false
_G.espBosses = false
_G.espEnemyColor = Color3.fromRGB(255, 0, 0)
_G.espLootColor = Color3.fromRGB(0, 255, 0)
_G.espTransparency = 0.4
_G.espShowNames = true
_G.espShowDistance = true
_G.autoForge = false
_G.autoCraftBest = false
_G.autoSalvage = false
_G.forgeDelay = 1
_G.craftPriority = "Weapons First"
_G.antiIdle = false
_G.antiAFK = false
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

local function getChests()
    local chests = {}
    local workspace = game:GetService("Workspace")
    if workspace:FindFirstChild("Chests") then
        for _, v in pairs(workspace.Chests:GetChildren()) do
            if v:FindFirstChild("Handle") then
                table.insert(chests, v)
            end
        end
    end
    return chests
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
    if cd and tick() - cd < _G.abilityBuffer then
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
        local dir = Root.CFrame.LookVector * -_G.dodgeDistance + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
        Root.CFrame = Root.CFrame + dir
        task.wait(0.1)
        Root.CFrame = Root.CFrame + Root.CFrame.LookVector * 5
    end)
end

-- ===== HEAL =====
local function heal()
    pcall(function()
        if Hum.Health / Hum.MaxHealth * 100 < _G.healThreshold then
            if _G.usePotions then
                local potion = Player.Backpack:FindFirstChild("HealthPotion") or Char:FindFirstChild("HealthPotion")
                if potion then
                    potion:Activate()
                    task.wait(0.3)
                    return
                end
            end
            if _G.useHealAbilities then
                local abilities = getAbilities()
                for _, ab in pairs(abilities) do
                    if ab:GetAttribute("Heal") and not getCooldown(ab) then
                        ab:Activate()
                        setCooldown(ab)
                        task.wait(0.3)
                        return
                    end
                end
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
            local heal = ab:GetAttribute("Heal") or 0
            local cd = getCooldown(ab)
            if not cd then
                local score = 0
                if _G.abilityPriority == "Damage First" then
                    score = dmg + heal * 0.5
                elseif _G.abilityPriority == "Heal First" then
                    score = heal * 2 + dmg * 0.5
                else
                    score = dmg + heal
                end
                if _G.useUltimates then
                    local isUlt = ab:GetAttribute("Ultimate") or false
                    if isUlt then score = score * 1.5 end
                end
                table.insert(sorted, {ability = ab, score = score})
            end
        end
        table.sort(sorted, function(a, b) return a.score > b.score end)
        
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
        
        if tick() - _G.lastAttackTime < _G.combatDelay then
            return
        end
        
        local tool = getTool()
        if not tool then return end
        
        local hrp = target:FindFirstChild("HumanoidRootPart")
        if hrp then
            Root.CFrame = CFrame.new(Root.Position, hrp.Position)
        end
        
        if math.random() < _G.killAuraAccuracy then
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
    pcall(function()
        local workspace = game:GetService("Workspace")
        
        -- Enemy ESP
        if _G.espEnabled then
            for _, enemy in pairs(getEnemies()) do
                if not enemy:GetAttribute("ESP_Highlight") then
                    local h = Instance.new("Highlight")
                    h.Parent = enemy
                    h.FillColor = _G.espEnemyColor or Color3.fromRGB(255, 0, 0)
                    h.FillTransparency = _G.espTransparency or 0.4
                    enemy:SetAttribute("ESP_Highlight", h)
                    
                    if _G.espShowNames then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Parent = enemy.HumanoidRootPart
                        billboard.Size = UDim2.new(0, 100, 0, 30)
                        billboard.StudsOffset = Vector3.new(0, 3, 0)
                        local label = Instance.new("TextLabel")
                        label.Parent = billboard
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.TextStrokeTransparency = 0
                        label.Text = enemy.Name
                        if _G.espShowDistance then
                            local dist = (enemy.HumanoidRootPart.Position - Root.Position).Magnitude
                            label.Text = enemy.Name .. " [" .. math.floor(dist) .. "s]"
                        end
                        enemy:SetAttribute("ESP_Billboard", billboard)
                    end
                end
            end
        else
            for _, enemy in pairs(getEnemies()) do
                local h = enemy:GetAttribute("ESP_Highlight")
                if h then h:Destroy() end
                local b = enemy:GetAttribute("ESP_Billboard")
                if b then b:Destroy() end
                enemy:SetAttribute("ESP_Highlight", nil)
                enemy:SetAttribute("ESP_Billboard", nil)
            end
        end
        
        -- Loot ESP
        if _G.espLoot then
            for _, item in pairs(getLoot()) do
                if item:FindFirstChild("Handle") and not item:GetAttribute("ESP_LootHighlight") then
                    local h = Instance.new("Highlight")
                    h.Parent = item
                    h.FillColor = _G.espLootColor or Color3.fromRGB(0, 255, 0)
                    h.FillTransparency = _G.espTransparency or 0.3
                    item:SetAttribute("ESP_LootHighlight", h)
                end
            end
        else
            for _, item in pairs(getLoot()) do
                local h = item:GetAttribute("ESP_LootHighlight")
                if h then h:Destroy() end
                item:SetAttribute("ESP_LootHighlight", nil)
            end
        end
        
        -- Chest ESP
        if _G.espChests then
            for _, chest in pairs(getChests()) do
                if chest:FindFirstChild("Handle") and not chest:GetAttribute("ESP_ChestHighlight") then
                    local h = Instance.new("Highlight")
                    h.Parent = chest
                    h.FillColor = Color3.fromRGB(255, 255, 0)
                    h.FillTransparency = _G.espTransparency or 0.3
                    chest:SetAttribute("ESP_ChestHighlight", h)
                end
            end
        else
            for _, chest in pairs(getChests()) do
                local h = chest:GetAttribute("ESP_ChestHighlight")
                if h then h:Destroy() end
                chest:SetAttribute("ESP_ChestHighlight", nil)
            end
        end
        
        -- Boss ESP
        if _G.espBosses then
            for _, enemy in pairs(getEnemies()) do
                if enemy:FindFirstChild("BossTag") or enemy.Name:find("Boss") then
                    if not enemy:GetAttribute("ESP_BossHighlight") then
                        local h = Instance.new("Highlight")
                        h.Parent = enemy
                        h.FillColor = Color3.fromRGB(255, 0, 255)
                        h.FillTransparency = 0.2
                        enemy:SetAttribute("ESP_BossHighlight", h)
                    end
                end
            end
        else
            for _, enemy in pairs(getEnemies()) do
                local h = enemy:GetAttribute("ESP_BossHighlight")
                if h then h:Destroy() end
                enemy:SetAttribute("ESP_BossHighlight", nil)
            end
        end
    end)
end

-- ===== AUTO FORGE =====
local function autoForgeLoop()
    if not _G.autoForge then return end
    pcall(function()
        local forge = game:GetService("Workspace"):FindFirstChild("Forge")
        if not forge then return end
        
        local inRange = (forge.Position - Root.Position).Magnitude < 20
        if not inRange then
            Root.CFrame = forge.CFrame
            task.wait(_G.forgeDelay)
        end
        
        local gui = Player.PlayerGui:FindFirstChild("ForgeUI")
        if gui then
            if _G.autoCraftBest then
                local craftBtn = gui:FindFirstChild("CraftBestButton")
                if craftBtn then craftBtn:Click() end
            end
            if _G.autoSalvage then
                local salvageBtn = gui:FindFirstChild("SalvageAllButton")
                if salvageBtn then salvageBtn:Click() end
            end
            task.wait(_G.forgeDelay)
        end
    end)
end

-- ===== ANTI-IDLE =====
local function antiIdleLoop()
    if _G.antiIdle or _G.antiAFK then
        pcall(function()
            local v = game:GetService("VirtualUser")
            v:CaptureController()
            v:ClickButton2(Vector2.new())
        end)
    end
end

-- ===== MAIN LOOP =====
local function mainLoop()
    local espTimer = 0
    local forgeTimer = 0
    local idleTimer = 0
    
    while task.wait(0.1) do
        espTimer = espTimer + 0.1
        forgeTimer = forgeTimer + 0.1
        idleTimer = idleTimer + 0.1
        
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
                    
                    if dist < _G.attackRange + _G.weaponRangeBonus then
                        Root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                        local tool = getTool()
                        if tool and tick() - _G.lastAttackTime > _G.combatDelay then
                            if _G.autoSwitch and _G.preferredWeapon then
                                local preferred = Player.Backpack:FindFirstChild(_G.preferredWeapon)
                                if preferred and preferred ~= tool then
                                    preferred.Parent = Char
                                    task.wait(0.1)
                                end
                            end
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

            -- Speed/jump/gravity sync
            if Hum.WalkSpeed ~= _G.walkSpeed then
                Hum.WalkSpeed = _G.walkSpeed
            end
            if Hum.JumpPower ~= _G.jumpPower then
                Hum.JumpPower = _G.jumpPower
            end
            if game:GetService("Workspace").Gravity ~= _G.gravity then
                game:GetService("Workspace").Gravity = _G.gravity
            end
            
            -- ESP update (every 2 seconds)
            if espTimer >= 2 then
                espTimer = 0
                if _G.espEnabled or _G.espLoot or _G.espChests or _G.espBosses then
                    updateESP()
                end
            end
            
            -- Auto forge (every 5 seconds)
            if forgeTimer >= 5 and _G.autoForge then
                forgeTimer = 0
                autoForgeLoop()
            end
            
            -- Anti-idle (every 60 seconds)
            if idleTimer >= 60 then
                idleTimer = 0
                antiIdleLoop()
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

-- ===== NOTIFICATION =====
Rayfield:Notify({
    Title = "Iron Soul Dungeon Loaded",
    Content = "All features ready. Use the tabs above.",
    Duration = 5
})
