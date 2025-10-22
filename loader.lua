local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local originalSize = UDim2.new(0, 220, 0, 220)
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
	if player.PlayerGui:FindFirstChild("PetGlitchUI") then
		player.PlayerGui.PetGlitchUI:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "PetGlitchUI"
	ScreenGui.Parent = player:WaitForChild("PlayerGui")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = originalSize
	MainFrame.Position = UDim2.new(0.5, -110, 0.5, -110)
	MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = false
	MainFrame.Parent = ScreenGui

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 10)
	Corner.Parent = MainFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 1.5
	Stroke.Color = Color3.fromRGB(80, 80, 120)
	Stroke.Parent = MainFrame

	-- Title Bar
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

	local function addHoverEffect(button, defaultColor, hoverColor)
		button.MouseEnter:Connect(function()
			button.BackgroundColor3 = hoverColor
		end)
		button.MouseLeave:Connect(function()
			button.BackgroundColor3 = defaultColor
		end)
	end

	addHoverEffect(MinBtn, Color3.fromRGB(80, 80, 100), Color3.fromRGB(100, 100, 120))
	addHoverEffect(CloseBtn, Color3.fromRGB(200, 60, 60), Color3.fromRGB(230, 80, 80))

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -10, 1, -40)
	Content.Position = UDim2.new(0, 5, 0, 30)
	Content.BackgroundTransparency = 1
	Content.Parent = MainFrame

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

	local rebirthLabel = Instance.new("TextLabel")
	rebirthLabel.Size = UDim2.new(1, 0, 0, 25)
	rebirthLabel.Position = UDim2.new(0, 0, 0, 40)
	rebirthLabel.BackgroundTransparency = 1
	rebirthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	rebirthLabel.Font = Enum.Font.Gotham
	rebirthLabel.TextSize = 12
	rebirthLabel.Text = "Detecting Rebirth..."
	rebirthLabel.Parent = Content

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

	local function calculateGlitch(rebirth, rarity)
		local expTable = petExpTables[rarity]
		local orbExp = 15 * (rebirth + 1)
		for lvl = 1, 50 do
			if expTable[lvl] % orbExp == 0 then
				return lvl
			end
		end
		return nil
	end

	calcBtn.MouseButton1Click:Connect(function()
		local rebirth = tonumber(rebirthInput.Text) or 0
		local rarity = rarityDropdown.Text
		local firstLevel = calculateGlitch(rebirth, rarity)
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

	-- Rebirth detection & auto check
	task.defer(function()
		local function findRebirthValue()
			local possibleNames = {"Rebirth", "Rebirths", "RebirthCount", "RebirthStat"}
			local ls = player:FindFirstChild("leaderstats")
			if ls then
				for _, child in ipairs(ls:GetChildren()) do
					for _, name in ipairs(possibleNames) do
						if string.find(string.lower(child.Name), string.lower(name)) then
							return tonumber(child.Value) or 0
						end
					end
				end
			end
			for _, child in ipairs(player:GetChildren()) do
				for _, name in ipairs(possibleNames) do
					if string.find(string.lower(child.Name), string.lower(name)) then
						return tonumber(child.Value) or 0
					end
				end
			end
			return nil
		end

		local rebirthValue = findRebirthValue()
		if rebirthValue then
			rebirthInput.Text = tostring(rebirthValue)
			rebirthLabel.Text = "Current Rebirth: " .. rebirthValue
		else
			rebirthLabel.Text = "No Rebirth stat found"
			rebirthValue = 0
		end

		local glitchable = {}
		for rarity,_ in pairs(petExpTables) do
			if calculateGlitch(rebirthValue, rarity) then
				table.insert(glitchable, rarity)
			end
		end
		if #glitchable > 0 then
			resultNotif.Text = "Glitch possible for: " .. table.concat(glitchable, ", ")
		else
			resultNotif.Text = "No pets glitchable at this rebirth"
		end
		resultNotif.Visible = true
		task.delay(5,function()
			if resultNotif and resultNotif.Parent then resultNotif.Visible = false end
		end)
	end)

	-- Dragging
	local dragging, dragStart, startPos
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
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
		local targetSize = isMinimized and minimizedSize or originalSize
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
		Content.Visible = not isMinimized
		calcBtn.Visible = not isMinimized
		resultNotif.Visible = not isMinimized
		MinBtn.Text = isMinimized and "+" or "-"
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)
end

-- Run
if player then
	createUI()
end
