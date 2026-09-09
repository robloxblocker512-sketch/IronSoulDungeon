-- Iron Soul Dungeon - Rayfield GUI
-- Kill Aura + ESP (Players & NPCs)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Iron Soul Dungeon",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by VANTA",
    Theme = "Dark",
})

-- ===== GLOBALS =====
_G.KillAura = false
_G.KillRange = 200
_G.ESP = false

-- ===== KILL AURA LOGIC =====
local function KillAuraLoop()
    while task.wait(0.1) do
        if not _G.KillAura then continue end
        local char = game.Players.LocalPlayer.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist <= _G.KillRange then
                        -- Check if it's an enemy (not a player)
                        if not game.Players:GetPlayerFromCharacter(obj) then
                            hum.Health = 0
                        end
                    end
                end
            end
        end
    end
end

-- ===== ESP LOGIC =====
local ESPObjects = {}

local function ClearESP()
    for _, v in pairs(ESPObjects) do
        pcall(function() v:Destroy() end)
    end
    ESPObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not _G.ESP then return end
    
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- ESP for NPCs (Enemies)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local isPlayer = game.Players:GetPlayerFromCharacter(obj)
                local color = isPlayer and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(255, 50, 50)
                
                -- Highlight
                local highlight = Instance.new("Highlight")
                highlight.Parent = obj
                highlight.FillColor = color
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = color
                highlight.OutlineTransparency = 0
                table.insert(ESPObjects, highlight)
            end
        end
    end
end

-- ===== GUI TABS =====
local MainTab = Window:CreateTab("Main")

MainTab:CreateToggle({
    Name = "Kill Aura",
    CurrentValue = false,
    Flag = "KillAura",
    Callback = function(v)
        _G.KillAura = v
        Rayfield:Notify({
            Title = "Kill Aura",
            Content = v and "ON" or "OFF",
            Duration = 2
        })
    end
})

MainTab:CreateSlider({
    Name = "Kill Range",
    Range = {50, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 200,
    Flag = "KillRange",
    Callback = function(v)
        _G.KillRange = v
    end
})

MainTab:CreateToggle({
    Name = "ESP (Players + NPCs)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(v)
        _G.ESP = v
        if v then
            UpdateESP()
        else
            ClearESP()
        end
        Rayfield:Notify({
            Title = "ESP",
            Content = v and "ON" or "OFF",
            Duration = 2
        })
    end
})

-- ===== ESP UPDATE LOOP =====
task.spawn(function()
    while task.wait(1) do
        if _G.ESP then
            pcall(UpdateESP)
        end
    end
end)

-- ===== START KILL AURA LOOP =====
task.spawn(KillAuraLoop)

-- ===== NOTIFICATION =====
Rayfield:Notify({
    Title = "Iron Soul Dungeon",
    Content = "GUI Loaded - Toggle Kill Aura or ESP",
    Duration = 3,
})

print("Iron Soul Dungeon GUI Loaded")
