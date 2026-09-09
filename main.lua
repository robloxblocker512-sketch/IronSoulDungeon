-- IRON SOUL DUNGEON - GUI TEST
-- Only the GUI, no combat logic

local player = game.Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.Name = "IronSoulGUI_Test"

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.BackgroundTransparency = 0
title.BorderSizePixel = 0
title.Text = "Iron Soul Dungeon - TEST"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

-- Tab buttons
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 30)
tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
tabContainer.BackgroundTransparency = 0
tabContainer.BorderSizePixel = 0
tabContainer.Parent = mainFrame

local tabs = {"Aura", "Combat", "Forge", "Dungeon", "ESP"}
local tabButtons = {}
local contentFrames = {}

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1 / #tabs, -2, 1, -2)
    btn.Position = UDim2.new((i - 1) / #tabs, 1, 0, 1)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = tabContainer
    tabButtons[name] = btn

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -10)
    content.Position = UDim2.new(0, 5, 0, 65)
    content.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = (i == 1)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.ScrollBarThickness = 4
    content.Parent = mainFrame
    contentFrames[name] = content

    btn.MouseButton1Click:Connect(function()
        for _, cf in pairs(contentFrames) do cf.Visible = false end
        content.Visible = true
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
end

-- Add a simple toggle to Aura tab
local auraContent = contentFrames["Aura"]
local testToggle = Instance.new("TextButton")
testToggle.Size = UDim2.new(0.8, 0, 0, 40)
testToggle.Position = UDim2.new(0.1, 0, 0, 10)
testToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
testToggle.BorderSizePixel = 0
testToggle.Text = "GUI IS WORKING"
testToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
testToggle.TextSize = 16
testToggle.Font = Enum.Font.GothamBold
testToggle.Parent = auraContent
auraContent.CanvasSize = UDim2.new(0, 0, 0, 100)

print("GUI test loaded - you should see a window with tabs")
