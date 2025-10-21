local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local originalSize = UDim2.new(0, 220, 0, 150)
local minimizedSize = UDim2.new(0, 220, 0, 30)
local isMinimized = false

-- Generate cumulative EXP tables
local function generateExpTable(baseExp)
    local t = {}
    local cum = 0
    for i = 1, 50 do
        cum = cum + baseExp * i
        table.insert(t, cum)
    end
    return t
end

local petExpTables = {
    OMEGA = generateExpTable(10000),
    UNIQUE = generateExpTable(5000),
    EPIC = generateExpTable(4000),
    RARE = generateExpTable(3000),
    ADVANCE = generateExpTable(2000),
    BASIC = generateExpTable(1000)
}

local function createUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PetGlitchUI"
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = originalSize
    MainFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame

    -- Title Bar (for dragging)
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "Pet Glitch Calc"
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 30, 1, 0)
    MinBtn.Position = UDim2.new(1, -60, 0, 0)
    MinBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.AutoButtonColor = false
    MinBtn.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = TitleBar

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -10, 1, -40)
    Content.Position = UDim2.new(0, 5, 0, 30)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- Rebirth Input
    local rebirthInput = Instance.new("TextBox")
    rebirthInput.PlaceholderText = "Rebirth"
    rebirthInput.Text = "0"
    rebirthInput.Size = UDim2.new(0.45, 0, 0, 25)
    rebirthInput.Position = UDim2.new(0, 0, 0, 5)
    rebirthInput.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    rebirthInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    rebirthInput.Font = Enum.Font.Gotham
    rebirthInput.TextSize = 14
    rebirthInput.ClearTextOnFocus = false
    rebirthInput.Parent = Content

    -- Rarity Dropdown Button
    local rarityDropdown = Instance.new("TextButton")
    rarityDropdown.Text = "OMEGA"
    rarityDropdown.Size = UDim2.new(0.5, 0, 0, 25)
    rarityDropdown.Position = UDim2.new(0.5, 5, 0, 5)
    rarityDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    rarityDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    rarityDropdown.Font = Enum.Font.Gotham
    rarityDropdown.TextSize = 14
    rarityDropdown.AutoButtonColor = false
    rarityDropdown.Parent = Content

    -- Dropdown Frame
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(0.5, 0, 0, 120)
    dropdownFrame.Position = UDim2.new(0.5, 5, 0, 30)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    dropdownFrame.Visible = false
    dropdownFrame.ZIndex = 10
    dropdownFrame.Parent = MainFrame

    local Corner2 = Instance.new("UICorner")
    Corner2.CornerRadius = UDim.new(0, 5)
    Corner2.Parent = dropdownFrame

    local rarities = {"OMEGA", "UNIQUE", "EPIC", "RARE", "ADVANCE", "BASIC"}
    for i, name in ipairs(rarities) do
        local btn = Instance.new("TextButton")
        btn.Text = name
        btn.Size = UDim2.new(1, 0, 0, 20)
        btn.Position = UDim2.new(0, 0, 0, (i - 1) * 20)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.AutoButtonColor = false
        btn.ZIndex = 10
        btn.Parent = dropdownFrame
        btn.MouseButton1Click:Connect(function()
            rarityDropdown.Text = name
            dropdownFrame.Visible = false
        end)
    end

    rarityDropdown.MouseButton1Click:Connect(function()
        dropdownFrame.Visible = not dropdownFrame.Visible
    end)

    -- Calculate Button
    local calcBtn = Instance.new("TextButton")
    calcBtn.Text = "Calculate First Glitch Level"
    calcBtn.Size = UDim2.new(1, 0, 0, 25)
    calcBtn.Position = UDim2.new(0, 0, 0, 160)
    calcBtn.BackgroundColor3 = Color3.fromRGB(60, 150, 60)
    calcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    calcBtn.Font = Enum.Font.GothamBold
    calcBtn.TextSize = 14
    calcBtn.AutoButtonColor = false
    calcBtn.Parent = MainFrame

    -- Result Notification
    local resultNotif = Instance.new("TextLabel")
    resultNotif.Size = UDim2.new(1, 0, 0, 25)
    resultNotif.Position = UDim2.new(0, 0, 0, 190)
    resultNotif.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    resultNotif.TextColor3 = Color3.fromRGB(255, 255, 255)
    resultNotif.Font = Enum.Font.GothamBold
    resultNotif.TextSize = 14
    resultNotif.Text = ""
    resultNotif.Visible = false
    resultNotif.Parent = MainFrame

    -- Calculate Logic
    calcBtn.MouseButton1Click:Connect(function()
        local rebirth = tonumber(rebirthInput.Text) or 0
        if rebirth < 0 then rebirth = 0 end

        local rarity = rarityDropdown.Text
        local expTable = petExpTables[rarity]
        if not expTable then
            resultNotif.Text = "Invalid rarity"
            resultNotif.Visible = true
            task.delay(3, function()
                if resultNotif and resultNotif.Parent then resultNotif.Visible = false end
            end)
            return
        end

        local orbExp = 15 * (rebirth + 1)
        local firstLevel = nil

        for lvl = 1, 50 do
            if expTable[lvl] % orbExp == 0 then
                firstLevel = lvl
                break
            end
        end

        if firstLevel then
            resultNotif.Text = "First Glitch Level: " .. firstLevel .. " 🔔"
        else
            resultNotif.Text = "No glitchable level ❌"
        end
        resultNotif.Visible = true
        task.delay(5, function()
            if resultNotif and resultNotif.Parent then
                resultNotif.Visible = false
            end
        end)
    end)

    -- Draggable (mouse + touch)
    local dragging = false
    local dragStart, startPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Minimize / Close
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            MainFrame.Size = minimizedSize
            Content.Visible = false
            calcBtn.Visible = false
            resultNotif.Visible = false
            MinBtn.Text = "+"
        else
            MainFrame.Size = originalSize
            Content.Visible = true
            calcBtn.Visible = true
            MinBtn.Text = "-"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end

-- Run
if player then
    createUI()
end
