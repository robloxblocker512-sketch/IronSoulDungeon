-- Iron Soul Dungeon - Fixed Rayfield GUI
-- Delta compatible

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by VANTA",
    Theme = "Default"
})

-- ===== COMBAT TAB =====
local CombatTab = Window:CreateTab("Combat")

local CombatSection = CombatTab:CreateSection("Auto Combat")
CombatSection:CreateToggle("Auto Combat", false, function(v) _G.autoCombat = v end)
CombatSection:CreateToggle("Auto Loot", false, function(v) _G.autoLoot = v end)
CombatSection:CreateToggle("Auto Return", false, function(v) _G.autoReturn = v end)
CombatSection:CreateSlider("Attack Range", 5, 50, 15, function(v) _G.attackRange = v end)
CombatSection:CreateSlider("Loot Range", 10, 100, 30, function(v) _G.lootRange = v end)

local WeaponSection = CombatTab:CreateSection("Weapons")
WeaponSection:CreateToggle("Auto Switch Weapon", true, function(v) _G.autoSwitch = v end)
WeaponSection:CreateDropdown("Preferred Weapon", {"Sword", "Axe", "Hammer", "Bow"}, function(v) _G.preferredWeapon = v end)

local HealSection = CombatTab:CreateSection("Healing")
HealSection:CreateSlider("Heal Threshold %", 10, 80, 30, function(v) _G.healThreshold = v end)
HealSection:CreateToggle("Use Potions", true, function(v) _G.usePotions = v end)

-- ===== MOVEMENT TAB =====
local MovementTab = Window:CreateTab("Movement")

local StatsSection = MovementTab:CreateSection("Stats")
StatsSection:CreateSlider("Walk Speed", 16, 200, 16, function(v)
    _G.walkSpeed = v
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
StatsSection:CreateSlider("Jump Power", 50, 300, 50, function(v)
    _G.jumpPower = v
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)
StatsSection:CreateSlider("Gravity", 0, 196.2, 196.2, function(v)
    _G.gravity = v
    game:GetService("Workspace").Gravity = v
end)

local TeleportSection = MovementTab:CreateSection("Teleports")
TeleportSection:CreateButton("Teleport to Lobby", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
end)
TeleportSection:CreateButton("Teleport to Dungeon", function()
    local spawn = game:GetService("Workspace"):FindFirstChild("DungeonSpawn")
    if spawn then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame
    end
end)

-- ===== UTILITY TAB =====
local UtilityTab = Window:CreateTab("Utility")

local ToolsSection = UtilityTab:CreateSection("Tools")
ToolsSection:CreateButton("Kill Character", function()
    if game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.Humanoid.Health = 0
    end
end)
ToolsSection:CreateButton("Reset GUI", function()
    Rayfield:Destroy()
    _G.autoCombat = false
    _G.autoLoot = false
    _G.autoReturn = false
    _G.killAura = false
    _G.espEnabled = false
end)
ToolsSection:CreateToggle("Anti-Idle", false, function(v) _G.antiIdle = v end)

-- ===== OVERHAUL TAB =====
local OverhaulTab = Window:CreateTab("Overhaul")

local OverhaulSection = OverhaulTab:CreateSection("Combat Overhaul")
OverhaulSection:CreateToggle("Kill Aura", false, function(v) _G.killAura = v end)
OverhaulSection:CreateSlider("Kill Aura Range", 0.5, 10, 2.5, function(v) _G.killAuraRange = v end)
OverhaulSection:CreateToggle("Ability Rotation", false, function(v) _G.abilityRotation = v end)
OverhaulSection:CreateToggle("Auto Dodge", true, function(v) _G.autoDodge = v end)
OverhaulSection:CreateToggle("Boss Priority", true, function(v) _G.bossPriority = v end)

-- ===== ESP TAB =====
local ESPTab = Window:CreateTab("ESP")

local ESPSection = ESPTab:CreateSection("ESP Settings")
ESPSection:CreateToggle("ESP Enemies", false, function(v) _G.espEnabled = v end)
ESPSection:CreateToggle("ESP Loot", false, function(v) _G.espLoot = v end)
ESPSection:CreateToggle("ESP Chests", false, function(v) _G.espChests = v end)
ESPSection:CreateColorPicker("Enemy Color", Color3.fromRGB(255, 0, 0), function(v) _G.espColor = v end)

-- ===== FORGE TAB =====
local ForgeTab = Window:CreateTab("Forge")

local ForgeSection = ForgeTab:CreateSection("Auto Forge")
ForgeSection:CreateToggle("Auto Forge", false, function(v) _G.autoForge = v end)
ForgeSection:CreateToggle("Auto Craft Best", false, function(v) _G.autoCraftBest = v end)
ForgeSection:CreateButton("Force Forge Now", function()
    local forge = game:GetService("Workspace"):FindFirstChild("Forge")
    if forge then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = forge.CFrame
        task.wait(0.5)
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ForgeUI")
        if gui then
            local btn = gui:FindFirstChild("CraftAllButton")
            if btn then btn:Click() end
        end
    end
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
_G.autoSwitch = true
_G.preferredWeapon = "Sword"
_G.healThreshold = 30
_G.usePotions = true
_G.killAura = false
_G.killAuraRange = 2.5
_G.abilityRotation = false
_G.autoDodge = true
_G.bossPriority = true
_G.espEnabled = false
_G.espLoot = false
_G.espChests = false
_G.espColor = Color3.fromRGB(255, 0, 0)
_G.autoForge = false
_G.autoCraftBest = false
_G.antiIdle = false
_G.abilityCooldowns = {}
_G.lastAttackTime = 0
_G.combatDelay = 0.15

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
    if cd and tick() - cd < 1.5 then return true end
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
    if #targets == 0 then targets = enemies end
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
            if _G.usePotions then
                local potion = Player.Backpack:FindFirstChild("HealthPotion") or Char:FindFirstChild("HealthPotion")
                if potion then
                    potion:Activate()
                    task.wait(0.3)
                    return
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
        for _, ab in pairs(abilities) do
            if not getCooldown(ab) then
                if ab:FindFirstChild("Handle") then
                    ab.Handle.CFrame = target.HumanoidRootPart.CFrame
                    ab:Activate()
                    setCooldown(ab)
                    task.wait(0.15)
                end
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
        if tick() - _G.lastAttackTime < _G.combatDelay then return end
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
    end)
end

-- ===== ESP =====
local function updateESP()
    pcall(function()
        if _G.espEnabled then
            for _, enemy in pairs(getEnemies()) do
                if not enemy:GetAttribute("ESP") then
                    local h = Instance.new("Highlight")
                    h.Parent = enemy
                    h.FillColor = _G.espColor
                    h.FillTransparency = 0.4
                    enemy:SetAttribute("ESP", h)
                end
            end
        else
            for _, enemy in pairs(getEnemies()) do
                local h = enemy:GetAttribute("ESP")
                if h then h:Destroy() end
                enemy:SetAttribute("ESP", nil)
            end
        end
        if _G.espLoot then
            for _, item in pairs(getLoot()) do
                if item:FindFirstChild("Handle") and not item:GetAttribute("ESP_Loot") then
                    local h = Instance.new("Highlight")
                    h.Parent = item
                    h.FillColor = Color3.fromRGB(0, 255, 0)
                    h.FillTransparency = 0.3
                    item:SetAttribute("ESP_Loot", h)
                end
            end
        else
            for _, item in pairs(getLoot()) do
                local h = item:GetAttribute("ESP_Loot")
                if h then h:Destroy() end
                item:SetAttribute("ESP_Loot", nil)
            end
        end
        if _G.espChests then
            for _, chest in pairs(getChests()) do
                if chest:FindFirstChild("Handle") and not chest:GetAttribute("ESP_Chest") then
                    local h = Instance.new("Highlight")
                    h.Parent = chest
                    h.FillColor = Color3.fromRGB(255, 255, 0)
                    h.FillTransparency = 0.3
                    chest:SetAttribute("ESP_Chest", h)
                end
            end
        else
            for _, chest in pairs(getChests()) do
                local h = chest:GetAttribute("ESP_Chest")
                if h then h:Destroy() end
                chest:SetAttribute("ESP_Chest", nil)
            end
        end
    end)
end

-- ===== MAIN LOOP =====
local function mainLoop()
    local espTimer = 0
    while task.wait(0.1) do
        espTimer = espTimer + 0.1
        pcall(function()
            Char = Player.Character or Player.CharacterAdded:Wait()
            if not Char then return end
            Root = Char:FindFirstChild("HumanoidRootPart")
            Hum = Char:FindFirstChild("Humanoid")
            if not Root or not Hum then return end

            if _G.autoCombat then
                local targets = getTargets()
                local target = targets[1]
                if target then
                    local dist = (target.HumanoidRootPart.Position - Root.Position).Magnitude
                    if _G.autoDodge and target:FindFirstChild("WindUp") and target.WindUp.Value == true then
                        dodge()
                    end
                    heal()
                    if _G.abilityRotation then useAbilities(target) end
                    if _G.killAura then subtleKillAura() end
                    if dist < _G.attackRange then
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

            if _G.autoLoot then
                local loot, dist = getClosestLoot()
                if loot and dist < _G.lootRange then
                    Root.CFrame = loot.Handle.CFrame
                    task.wait(0.2)
                end
            end

            if _G.autoReturn then
                local inDungeon = game:GetService("Workspace"):FindFirstChild("DungeonZone") ~= nil
                if not inDungeon then
                    local lobby = game:GetService("Workspace"):FindFirstChild("LobbySpawn")
                    if lobby then Root.CFrame = lobby.CFrame end
                end
            end

            if Hum.WalkSpeed ~= _G.walkSpeed then Hum.WalkSpeed = _G.walkSpeed end
            if Hum.JumpPower ~= _G.jumpPower then Hum.JumpPower = _G.jumpPower end
            if game:GetService("Workspace").Gravity ~= _G.gravity then
                game:GetService("Workspace").Gravity = _G.gravity
            end

            if espTimer >= 2 then
                espTimer = 0
                if _G.espEnabled or _G.espLoot or _G.espChests then updateESP() end
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
