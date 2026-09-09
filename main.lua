-- Iron Soul Dungeon - Rayfield Minimal
-- Delta compatible

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by VANTA",
    Theme = "Default"
})

local CombatTab = Window:CreateTab("Combat")
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

local MovementTab = Window:CreateTab("Movement")
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

local UtilityTab = Window:CreateTab("Utility")
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

-- ===== GLOBALS =====
_G.autoCombat = false
_G.autoLoot = false
_G.autoReturn = false
_G.walkSpeed = 16
_G.jumpPower = 50
_G.attackRange = 15
_G.lootRange = 30

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

-- ===== MAIN LOOP =====
local function mainLoop()
    while task.wait(0.1) do
        pcall(function()
            Char = Player.Character or Player.CharacterAdded:Wait()
            if not Char then return end
            Root = Char:FindFirstChild("HumanoidRootPart")
            Hum = Char:FindFirstChild("Humanoid")
            if not Root or not Hum then return end

            if _G.autoCombat then
                local target, dist = getClosestEnemy()
                if target and dist < _G.attackRange then
                    Root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                    local tool = getTool()
                    if tool then
                        tool:Activate()
                    end
                elseif target then
                    Root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, _G.attackRange - 2)
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
                    if lobby then
                        Root.CFrame = lobby.CFrame
                    end
                end
            end

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
