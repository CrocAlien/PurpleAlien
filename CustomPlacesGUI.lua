local CustomPlacesGUI = {}

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

function CustomPlacesGUI.Create(Places)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "CustomPlacesGUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.fromOffset(300, 380)
	MainFrame.Position = UDim2.new(0.5, -150, 0.5, -190)
	MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12)
	MainCorner.Parent = MainFrame

	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Size = UDim2.new(1, -50, 0, 45)
	Title.Position = UDim2.fromOffset(15, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "Places"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 22
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = MainFrame

	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "Close"
	CloseButton.Size = UDim2.fromOffset(35, 35)
	CloseButton.Position = UDim2.new(1, -42, 0, 5)
	CloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	CloseButton.BorderSizePixel = 0
	CloseButton.Text = "×"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextSize = 24
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = MainFrame

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 8)
	CloseCorner.Parent = CloseButton

	CloseButton.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local ScrollingFrame = Instance.new("ScrollingFrame")
	ScrollingFrame.Name = "Places"
	ScrollingFrame.Size = UDim2.new(1, -20, 1, -60)
	ScrollingFrame.Position = UDim2.fromOffset(10, 50)
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.ScrollBarThickness = 5
	ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollingFrame.Parent = MainFrame

	local ScrollCorner = Instance.new("UICorner")
	ScrollCorner.CornerRadius = UDim.new(0, 10)
	ScrollCorner.Parent = ScrollingFrame

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop = UDim.new(0, 8)
	Padding.PaddingBottom = UDim.new(0, 8)
	Padding.PaddingLeft = UDim.new(0, 8)
	Padding.PaddingRight = UDim.new(0, 8)
	Padding.Parent = ScrollingFrame

	local Layout = Instance.new("UIListLayout")
	Layout.Padding = UDim.new(0, 7)
	Layout.SortOrder = Enum.SortOrder.Name
	Layout.Parent = ScrollingFrame

	for PlaceName, PlaceId in pairs(Places) do
		local Button = Instance.new("TextButton")
		Button.Name = PlaceName
		Button.Size = UDim2.new(1, 0, 0, 45)
		Button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		Button.BorderSizePixel = 0
		Button.Text = PlaceName
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.TextSize = 16
		Button.Font = Enum.Font.GothamMedium
		Button.AutoButtonColor = false
		Button.Parent = ScrollingFrame

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 8)
		Corner.Parent = Button

		Button.MouseEnter:Connect(function()
			Button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		end)

		Button.MouseLeave:Connect(function()
			Button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		end)

		Button.MouseButton1Click:Connect(function()
			TeleportService:Teleport(PlaceId, Player)
		end)
	end

	local Dragging = false
	local DragStart
	local StartPosition

	Title.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = Input.Position
			StartPosition = MainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if not Dragging then
			return
		end

		if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end

		local Delta = Input.Position - DragStart

		MainFrame.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)

	return ScreenGui
end

return CustomPlacesGUI
