-- Iron Soul Dungeon - Rayfield UI
-- Delta Executor

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
    Callback = function(v)
        _G.KillAura = v
        print("Kill Aura:", v)
    end
})

AuraSection:CreateSlider({
    Name = "Aura Range",
    Range = {50, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 200,
    Flag = "AuraRange",
    Callback = function(v)
        _G.AuraRange = v
        print("Aura Range:", v)
    end
})

AuraSection:CreateSlider({
    Name = "Aura Speed (ms)",
    Range = {10, 200},
    Increment = 5,
    Suffix = "ms",
    CurrentValue = 50,
    Flag = "AuraSpeed",
    Callback = function(v)
        _G.AuraInterval = v / 1000
        print("Aura Speed:", v)
    end
})

AuraSection:CreateToggle({
    Name = "Boss Priority",
    CurrentValue = false,
    Flag = "BossPriority",
    Callback = function(v)
        _G.BossPriority = v
        print("Boss Priority:", v)
    end
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
        print("Collecting ores...")
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
        print("Destroying eggs...")
    end
})

DungeonSection:CreateButton({
    Name = "Teleport to Boss",
    Callback = function()
        print("Teleporting to boss...")
    end
})

DungeonSection:CreateButton({
    Name = "Teleport to Portal",
    Callback = function()
        print("Teleporting to portal...")
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

-- ===== INITIALIZE GLOBALS =====
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

print("Iron Soul Dungeon GUI Loaded")
