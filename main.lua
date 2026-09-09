-- Iron Soul Dungeon - Rayfield FIXED
-- Controls render directly on tabs

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by VANTA",
    Theme = "Dark",
})

-- ===== AURA TAB =====
local AuraTab = Window:CreateTab("Aura")

AuraTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v) _G.KillAura = v end
})

AuraTab:CreateSlider({
    Name = "Aura Range",
    Range = {50, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 200,
    Flag = "AuraRange",
    Callback = function(v) _G.AuraRange = v end
})

AuraTab:CreateSlider({
    Name = "Aura Speed (ms)",
    Range = {10, 200},
    Increment = 5,
    Suffix = "ms",
    CurrentValue = 50,
    Flag = "AuraSpeed",
    Callback = function(v) _G.AuraInterval = v / 1000 end
})

AuraTab:CreateToggle({
    Name = "Boss Priority",
    CurrentValue = false,
    Flag = "BossPriority",
    Callback = function(v) _G.BossPriority = v end
})

-- ===== COMBAT TAB =====
local CombatTab = Window:CreateTab("Combat")

CombatTab:CreateToggle({
    Name = "Auto Combat",
    CurrentValue = false,
    Flag = "AutoCombat",
    Callback = function(v) _G.AutoCombat = v end
})

CombatTab:CreateToggle({
    Name = "Auto Loot",
    CurrentValue = false,
    Flag = "AutoLoot",
    Callback = function(v) _G.AutoLoot = v end
})

CombatTab:CreateToggle({
    Name = "Auto Return",
    CurrentValue = false,
    Flag = "AutoReturn",
    Callback = function(v) _G.AutoReturn = v end
})

CombatTab:CreateToggle({
    Name = "Weapon Switch",
    CurrentValue = false,
    Flag = "WeaponSwitch",
    Callback = function(v) _G.WeaponSwitch = v end
})

CombatTab:CreateToggle({
    Name = "Ability Rotation",
    CurrentValue = false,
    Flag = "AbilityRotation",
    Callback = function(v) _G.AbilityRotation = v end
})

CombatTab:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = false,
    Flag = "AutoDodge",
    Callback = function(v) _G.AutoDodge = v end
})

CombatTab:CreateSlider({
    Name = "Attack Range",
    Range = {5, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 20,
    Flag = "AttackRange",
    Callback = function(v) _G.AttackRange = v end
})

CombatTab:CreateSlider({
    Name = "Loot Range",
    Range = {5, 80},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 15,
    Flag = "LootRange",
    Callback = function(v) _G.LootRange = v end
})

CombatTab:CreateSlider({
    Name = "Heal Threshold %",
    Range = {1, 99},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 40,
    Flag = "HealThreshold",
    Callback = function(v) _G.HealThreshold = v end
})

-- ===== FORGE TAB =====
local ForgeTab = Window:CreateTab("Forge")

ForgeTab:CreateToggle({
    Name = "Auto Perfect Forge",
    CurrentValue = false,
    Flag = "AutoForge",
    Callback = function(v) _G.AutoForge = v end
})

ForgeTab:CreateButton({
    Name = "Collect Ores",
    Callback = function()
        print("Collecting ores...")
    end
})

-- ===== DUNGEON TAB =====
local DungeonTab = Window:CreateTab("Dungeon")

DungeonTab:CreateToggle({
    Name = "Auto Destroy Eggs",
    CurrentValue = false,
    Flag = "AutoEgg",
    Callback = function(v) _G.AutoEgg = v end
})

DungeonTab:CreateSlider({
    Name = "Egg Range",
    Range = {20, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 200,
    Flag = "EggRange",
    Callback = function(v) _G.EggRange = v end
})

DungeonTab:CreateButton({
    Name = "Destroy All Eggs Now",
    Callback = function()
        print("Destroying eggs...")
    end
})

DungeonTab:CreateButton({
    Name = "Teleport to Boss",
    Callback = function()
        print("Teleporting to boss...")
    end
})

DungeonTab:CreateButton({
    Name = "Teleport to Portal",
    Callback = function()
        print("Teleporting to portal...")
    end
})

-- ===== ESP TAB =====
local ESPTab = Window:CreateTab("ESP")

ESPTab:CreateToggle({
    Name = "ESP Enemies",
    CurrentValue = false,
    Flag = "ESPEnemies",
    Callback = function(v) _G.ESPEnemies = v end
})

ESPTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESPPlayers",
    Callback = function(v) _G.ESPPlayers = v end
})

ESPTab:CreateToggle({
    Name = "ESP Loot",
    CurrentValue = false,
    Flag = "ESPLoot",
    Callback = function(v) _G.ESPLoot = v end
})

ESPTab:CreateToggle({
    Name = "ESP Chests/Eggs",
    CurrentValue = false,
    Flag = "ESPChests",
    Callback = function(v) _G.ESPChests = v end
})

ESPTab:CreateSlider({
    Name = "ESP Transparency",
    Range = {0, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = 0.4,
    Flag = "ESPTransparency",
    Callback = function(v) _G.ESPTransparency = v end
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ShowNames",
    Callback = function(v) _G.ShowNames = v end
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ShowDistance",
    Callback = function(v) _G.ShowDistance = v end
})

-- ===== GLOBALS =====
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

print("GUI Loaded - Controls should be visible")
