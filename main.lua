-- IRON SOUL DUNGEON - FULL WORKING GUI
-- Rayfield - Delta Compatible

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Iron Soul Dungeon",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by VANTA",
   Theme = "Default",
})

-- ===== TABS =====
local CombatTab = Window:CreateTab("Combat")
local MovementTab = Window:CreateTab("Movement")
local UtilityTab = Window:CreateTab("Utility")
local OverhaulTab = Window:CreateTab("Overhaul")
local ESPTab = Window:CreateTab("ESP")

-- ===== COMBAT TAB =====
local CombatSection = CombatTab:CreateSection("Auto Combat")
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

local WeaponSection = CombatTab:CreateSection("Weapons")
WeaponSection:CreateToggle({
   Name = "Auto Switch Weapon",
   CurrentValue = true,
   Flag = "AutoSwitch",
   Callback = function(v) _G.autoSwitch = v end
})
WeaponSection:CreateDropdown({
   Name = "Preferred Weapon",
   Options = {"Sword", "Axe", "Hammer", "Bow"},
   CurrentOption = "Sword",
   Flag = "PreferredWeapon",
   Callback = function(v) _G.preferredWeapon = v end
})

local HealSection = CombatTab:CreateSection("Healing")
HealSection:CreateSlider({
   Name = "Heal Threshold %",
   Range = {10, 80},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 30,
   Flag = "HealThreshold",
   Callback = function(v) _G.healThreshold = v end
})
HealSection:CreateToggle({
   Name = "Use Potions",
   CurrentValue = true,
   Flag = "UsePotions",
   Callback = function(v) _G.usePotions = v end
})

-- ===== MOVEMENT TAB =====
local StatsSection = MovementTab:CreateSection("Stats")
StatsSection:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 200},
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
StatsSection:CreateSlider({
   Name = "Jump Power",
   Range = {50, 300},
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
StatsSection:CreateSlider({
   Name = "Gravity",
   Range = {0, 196.2},
   Increment = 0.1,
   Suffix = "gravity",
   CurrentValue = 196.2,
   Flag = "Gravity",
   Callback = function(v)
      _G.gravity = v
      game:GetService("Workspace").Gravity = v
   end
})

local TeleportSection = MovementTab:CreateSection("Teleports")
TeleportSection:CreateButton({
   Name = "Teleport to Lobby",
   Callback = function()
      game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
   end
})
TeleportSection:CreateButton({
   Name = "Teleport to Dungeon",
   Callback = function()
      local spawn = game:GetService("Workspace"):FindFirstChild("DungeonSpawn")
      if spawn then
         game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame
      end
   end
})

-- ===== UTILITY TAB =====
local ToolsSection = UtilityTab:CreateSection("Tools")
ToolsSection:CreateButton({
   Name = "Kill Character",
   Callback = function()
      if game.Players.LocalPlayer.Character then
         game.Players.LocalPlayer.Character.Humanoid.Health = 0
      end
   end
})
ToolsSection:CreateButton({
   Name = "Reset GUI",
   Callback = function()
      Rayfield:Destroy()
      _G.autoCombat = false
      _G.autoLoot = false
      _G.autoReturn = false
      _G.killAura = false
      _G.espEnabled = false
   end
})
ToolsSection:CreateToggle({
   Name = "Anti-Idle",
   CurrentValue = false,
   Flag = "AntiIdle",
   Callback = function(v) _G.antiIdle = v end
})

-- ===== OVERHAUL TAB (KILL AURA + ABILITIES) =====
local OverhaulSection = OverhaulTab:CreateSection("Combat Overhaul")
OverhaulSection:CreateToggle({
   Name = "Kill Aura",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(v) _G.killAura = v end
})
OverhaulSection:CreateSlider({
   Name = "Kill Aura Range",
   Range = {0.5, 10},
   Increment = 0.5,
   Suffix = "studs",
   CurrentValue = 2.5,
   Flag = "KillAuraRange",
   Callback = function(v) _G.killAuraRange = v end
})
OverhaulSection:CreateSlider({
   Name = "Kill Aura Hit Chance %",
   Range = {50, 100},
   Increment = 5,
   Suffix = "%",
   CurrentValue = 85,
   Flag = "KillAuraAccuracy",
   Callback = function(v) _G.killAuraAccuracy = v / 100 end
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

-- ===== ESP TAB =====
local ESPSection = ESPTab:CreateSection("ESP Settings")
ESPSection:CreateToggle({
   Name = "ESP Enemies",
   CurrentValue = false,
   Flag = "ESPEnabled",
   Callback = function(v) _G.espEnabled = v end
})
ESPSection:CreateToggle({
   Name = "ESP Players",
   CurrentValue = false,
   Flag = "ESPPlayers",
   Callback = function(v) _G.espPlayers = v end
})
ESPSection:CreateToggle({
   Name = "ESP Loot",
   CurrentValue = false,
   Flag = "ESPLoot",
   Callback = function(v) _G.espLoot = v end
})
ESPSection:CreateToggle({
   Name = "ESP Chests",
   CurrentValue = false,
   Flag = "ESPChests",
   Callback = function(v) _G.espChests = v end
})
ESPSection:CreateColorPicker({
   Name = "Enemy ESP Color",
   CurrentValue = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColor",
   Callback = function(v) _G.espColor = v end
})
ESPSection:CreateColorPicker({
   Name = "Player ESP Color",
   CurrentValue = Color3.fromRGB(0, 100, 255),
   Flag = "ESPPlayerColor",
   Callback = function(v) _G.espPlayerColor = v end
})
ESPSection:CreateSlider({
   Name = "ESP Transparency",
   Range = {0, 1},
   Increment = 0.05,
   Suffix = "alpha",
   CurrentValue = 0.4,
   Flag = "ESPTransparency",
   Callback = function(v) _G.espTransparency = v end
})
ESPSection:CreateToggle({
   Name = "ESP Show Names",
   CurrentValue = true,
   Flag = "ESPShowNames",
   Callback = function(v) _G.espShowNames = v end
})
ESPSection:CreateToggle({
   Name = "ESP Show Distance",
   CurrentValue = true,
   Flag = "ESPShowDistance",
   Callback = function(v) _G.espShowDistance = v end
})

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
_G.killAuraAccuracy = 0.85
_G.abilityRotation = false
_G.autoDodge = true
_G.bossPriority = true
_G.espEnabled = false
_G.espPlayers = false
_G.espLoot = false
_G.espChests = false
_G.espColor = Color3.fromRGB(255, 0, 0)
_G.espPlayerColor = Color3.fromRGB(0, 100, 255)
_G.espTransparency = 0.4
_G.espShowNames = true
_G.espShowDistance = true
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

local function getPlayers()
   local players = {}
   for _, v in pairs(game:GetService("Players"):GetPlayers()) do
      if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
         table.insert(players, v.Character)
      end
   end
   return players
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

-- ===== KILL AURA =====
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
      if math.random() < _G.killAuraAccuracy then
         tool:Activate()
         _G.lastAttackTime = tick()
      end
   end)
end

-- ===== ESP =====
local function updateESP()
   pcall(function()
      -- Enemy ESP
      if _G.espEnabled then
         for _, enemy in pairs(getEnemies()) do
            if not enemy:GetAttribute("ESP_Enemy") then
               local h = Instance.new("Highlight")
               h.Parent = enemy
               h.FillColor = _G.espColor
               h.FillTransparency = _G.espTransparency
               enemy:SetAttribute("ESP_Enemy", h)
               
               if _G.espShowNames then
                  local bill = Instance.new("BillboardGui")
                  bill.Parent = enemy.HumanoidRootPart
                  bill.Size = UDim2.new(0, 100, 0, 30)
                  bill.StudsOffset = Vector3.new(0, 3, 0)
                  local label = Instance.new("TextLabel")
                  label.Parent = bill
                  label.Size = UDim2.new(1, 0, 1, 0)
                  label.BackgroundTransparency = 1
                  label.TextColor3 = Color3.fromRGB(255, 255, 255)
                  label.TextStrokeTransparency = 0
                  label.Text = enemy.Name
                  if _G.espShowDistance then
                     local d = (enemy.HumanoidRootPart.Position - Root.Position).Magnitude
                     label.Text = enemy.Name .. " [" .. math.floor(d) .. "s]"
                  end
                  enemy:SetAttribute("ESP_Bill", bill)
               end
            end
         end
      else
         for _, enemy in pairs(getEnemies()) do
            local h = enemy:GetAttribute("ESP_Enemy")
            if h then h:Destroy() end
            local b = enemy:GetAttribute("ESP_Bill")
            if b then b:Destroy() end
            enemy:SetAttribute("ESP_Enemy", nil)
            enemy:SetAttribute("ESP_Bill", nil)
         end
      end
      
      -- Player ESP
      if _G.espPlayers then
         for _, p in pairs(getPlayers()) do
            if p and p:FindFirstChild("HumanoidRootPart") then
               if not p:GetAttribute("ESP_Player") then
                  local h = Instance.new("Highlight")
                  h.Parent = p
                  h.FillColor = _G.espPlayerColor
                  h.FillTransparency = _G.espTransparency
                  p:SetAttribute("ESP_Player", h)
               end
            end
         end
      else
         for _, p in pairs(getPlayers()) do
            local h = p:GetAttribute("ESP_Player")
            if h then h:Destroy() end
            p:SetAttribute("ESP_Player", nil)
         end
      end
      
      -- Loot ESP
      if _G.espLoot then
         for _, item in pairs(getLoot()) do
            if item:FindFirstChild("Handle") and not item:GetAttribute("ESP_Loot") then
               local h = Instance.new("Highlight")
               h.Parent = item
               h.FillColor = Color3.fromRGB(0, 255, 0)
               h.FillTransparency = _G.espTransparency
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
      
      -- Chest ESP
      if _G.espChests then
         for _, chest in pairs(getChests()) do
            if chest:FindFirstChild("Handle") and not chest:GetAttribute("ESP_Chest") then
               local h = Instance.new("Highlight")
               h.Parent = chest
               h.FillColor = Color3.fromRGB(255, 255, 0)
               h.FillTransparency = _G.espTransparency
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
            if _G.espEnabled or _G.espPlayers or _G.espLoot or _G.espChests then
               updateESP()
            end
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
   Title = "Iron Soul Dungeon",
   Content = "Full GUI Loaded - All Features Ready",
   Duration = 3,
})
