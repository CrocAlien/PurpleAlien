local PortalMakerGUI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

function PortalMakerGUI.Create()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "PortalMakerGUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.fromOffset(360, 300)
	MainFrame.Position = UDim2.new(0.5, -180, 0.5, -150)
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
	Title.Text = "Portal Type"
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

	local ButtonsFrame = Instance.new("Frame")
	ButtonsFrame.Name = "Buttons"
	ButtonsFrame.Size = UDim2.new(1, -20, 0, 45)
	ButtonsFrame.Position = UDim2.fromOffset(10, 50)
	ButtonsFrame.BackgroundTransparency = 1
	ButtonsFrame.Parent = MainFrame

	local ButtonLayout = Instance.new("UIListLayout")
	ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
	ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ButtonLayout.Padding = UDim.new(0, 7)
	ButtonLayout.Parent = ButtonsFrame

	local PositionButton = Instance.new("TextButton")
	PositionButton.Name = "Position"
	PositionButton.Size = UDim2.fromOffset(105, 45)
	PositionButton.BackgroundColor3 = Color3.fromRGB(90, 150, 255)
	PositionButton.BorderSizePixel = 0
	PositionButton.Text = "Position"
	PositionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	PositionButton.TextSize = 15
	PositionButton.Font = Enum.Font.GothamBold
	PositionButton.Parent = ButtonsFrame

	local PlayerButton = Instance.new("TextButton")
	PlayerButton.Name = "Player"
	PlayerButton.Size = UDim2.fromOffset(105, 45)
	PlayerButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	PlayerButton.BorderSizePixel = 0
	PlayerButton.Text = "Player"
	PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	PlayerButton.TextSize = 15
	PlayerButton.Font = Enum.Font.GothamBold
	PlayerButton.Parent = ButtonsFrame

	local PlacesButton = Instance.new("TextButton")
	PlacesButton.Name = "Places"
	PlacesButton.Size = UDim2.fromOffset(105, 45)
	PlacesButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
	PlacesButton.BorderSizePixel = 0
	PlacesButton.Text = "Places"
	PlacesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	PlacesButton.TextSize = 15
	PlacesButton.Font = Enum.Font.GothamBold
	PlacesButton.Parent = ButtonsFrame

	for _, Button in ipairs({
		PositionButton,
		PlayerButton,
		PlacesButton
	}) do
		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 8)
		Corner.Parent = Button
	end

	local PlayerTextBox = Instance.new("TextBox")
	PlayerTextBox.Name = "PlayerName"
	PlayerTextBox.Size = UDim2.new(1, -20, 0, 40)
	PlayerTextBox.Position = UDim2.fromOffset(10, 105)
	PlayerTextBox.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
	PlayerTextBox.BorderSizePixel = 0
	PlayerTextBox.PlaceholderText = "Enter player name..."
	PlayerTextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 155)
	PlayerTextBox.Text = ""
	PlayerTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	PlayerTextBox.TextSize = 15
	PlayerTextBox.Font = Enum.Font.Gotham
	PlayerTextBox.Visible = false
	PlayerTextBox.ClearTextOnFocus = false
	PlayerTextBox.Parent = MainFrame

	local TextBoxCorner = Instance.new("UICorner")
	TextBoxCorner.CornerRadius = UDim.new(0, 8)
	TextBoxCorner.Parent = PlayerTextBox

	local Description = Instance.new("TextLabel")
	Description.Name = "Description"
	Description.Size = UDim2.new(1, -20, 0, 110)
	Description.Position = UDim2.fromOffset(10, 155)
	Description.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	Description.BorderSizePixel = 0
	Description.Text = "Position portals connect two positions in the world. Walking into one portal teleports you to the other portal's position."
	Description.TextColor3 = Color3.fromRGB(220, 220, 225)
	Description.TextSize = 15
	Description.Font = Enum.Font.Gotham
	Description.TextWrapped = true
	Description.TextXAlignment = Enum.TextXAlignment.Left
	Description.TextYAlignment = Enum.TextYAlignment.Top
	Description.Parent = MainFrame

	local DescriptionPadding = Instance.new("UIPadding")
	DescriptionPadding.PaddingTop = UDim.new(0, 10)
	DescriptionPadding.PaddingBottom = UDim.new(0, 10)
	DescriptionPadding.PaddingLeft = UDim.new(0, 10)
	DescriptionPadding.PaddingRight = UDim.new(0, 10)
	DescriptionPadding.Parent = Description

	local DescriptionCorner = Instance.new("UICorner")
	DescriptionCorner.CornerRadius = UDim.new(0, 8)
	DescriptionCorner.Parent = Description

	local CurrentType = "Position"

	local function SetType(Type)
		CurrentType = Type

		PositionButton.BackgroundColor3 =
			Type == "Position"
			and Color3.fromRGB(90, 150, 255)
			or Color3.fromRGB(45, 45, 52)

		PlayerButton.BackgroundColor3 =
			Type == "Player"
			and Color3.fromRGB(90, 150, 255)
			or Color3.fromRGB(45, 45, 52)

		PlacesButton.BackgroundColor3 =
			Type == "Places"
			and Color3.fromRGB(90, 150, 255)
			or Color3.fromRGB(45, 45, 52)

		PlayerTextBox.Visible = Type == "Player"

		if Type == "Position" then
			Description.Text =
				"Position portals connect two positions in the world. Walking into one portal teleports you to the other portal's position."
		elseif Type == "Player" then
			Description.Text =
				"Player portals connect you to another player. Enter a player's name in the textbox above to select who the portal should connect to."
		elseif Type == "Places" then
			Description.Text =
				"Places portals connect to Roblox places. A portal can be configured to send you to another place when you enter it."
		end
	end

	PositionButton.MouseButton1Click:Connect(function()
		SetType("Position")
	end)

	PlayerButton.MouseButton1Click:Connect(function()
		SetType("Player")
	end)

	PlacesButton.MouseButton1Click:Connect(function()
		SetType("Places")
	end)

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

return PortalMakerGUI
