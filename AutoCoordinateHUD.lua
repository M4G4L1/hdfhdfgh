local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "YCoordinateHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,120,0,55)
frame.Position = UDim2.new(1,-130,0,10)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

-- Drag Bar
local dragBar = Instance.new("TextLabel")
dragBar.Size = UDim2.new(1,0,0,20)
dragBar.BackgroundColor3 = Color3.fromRGB(40,40,40)
dragBar.Text = "CoordinateHUD"
dragBar.TextColor3 = Color3.new(1,1,1)
dragBar.Font = Enum.Font.SourceSansBold
dragBar.TextSize = 16
dragBar.Parent = frame

Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0,8)

-- Y Label
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1,0,0,30)
label.Position = UDim2.new(0,0,0,22)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(0,255,255)
label.Font = Enum.Font.Code
label.TextSize = 18
label.Text = "Y: 0.0"
label.Parent = frame

-- Drag System
local dragging = false
local dragInput
local dragStart
local startPos

local function update(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

dragBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

dragBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		update(input)
	end
end)

-- Relative Y
local startY

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if not startY then
		startY = root.Position.Y
	end

	local y = root.Position.Y - startY
	label.Text = string.format("Y: %.1f", y)
end)