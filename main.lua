-- IRON SOUL DUNGEON - REAL KILL AURA
-- Uses your weapon to attack enemies

local player = game.Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Name = "IronSoulGUI"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 80)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -40)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
title.BorderSizePixel = 0
title.Text = "Kill Aura"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(0.8, 0, 0, 30)
killBtn.Position = UDim2.new(0.1, 0, 0, 40)
killBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
killBtn.BorderSizePixel = 0
killBtn.Text = "Kill Aura: OFF"
killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
killBtn.TextSize = 14
killBtn.Font = Enum.Font.GothamBold
killBtn.Parent = mainFrame

local killAuraActive = false

killBtn.MouseButton1Click:Connect(function()
    killAuraActive = not killAuraActive
    killBtn.Text = killAuraActive and "Kill Aura: ON" or "Kill Aura: OFF"
    killBtn.BackgroundColor3 = killAuraActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
end)

-- ===== KILL AURA WITH WEAPON =====
task.spawn(function()
    while true do
        task.wait(0.2)
        if not killAuraActive then continue end
        
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        
        -- Get the weapon the player is holding
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then
            -- If no weapon in hand, try to equip one from backpack
            local backpack = player.Backpack
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    tool = item
                    break
                end
            end
        end
        
        if not tool then
            print("No weapon found")
            continue
        end
        
        -- Find nearest enemy
        local nearestEnemy = nil
        local nearestDist = math.huge
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then
                    if not game.Players:GetPlayerFromCharacter(obj) then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < nearestDist and dist <= 30 then
                            nearestEnemy = obj
                            nearestDist = dist
                        end
                    end
                end
            end
        end
        
        if nearestEnemy then
            local hrp = nearestEnemy:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Face the enemy
                root.CFrame = CFrame.new(root.Position, hrp.Position)
                -- Equip the tool if not already equipped
                if tool.Parent ~= char then
                    tool.Parent = char
                    task.wait(0.1)
                end
                -- Swing the weapon
                tool:Activate()
                -- Fire remote events if they exist
                pcall(function()
                    local remote = tool:FindFirstChildOfClass("RemoteEvent")
                    if remote then
                        remote:FireServer(nearestEnemy, hrp.Position)
                    end
                end)
                -- Try other common remote names
                pcall(function()
                    local attackRemote = tool:FindFirstChild("Attack")
                    if attackRemote and attackRemote:IsA("RemoteEvent") then
                        attackRemote:FireServer(nearestEnemy)
                    end
                end)
                print("Attacking:", nearestEnemy.Name)
                task.wait(0.3) -- Wait between attacks
            end
        end
    end
end)

print("Kill Aura loaded. Click the button to toggle.")
