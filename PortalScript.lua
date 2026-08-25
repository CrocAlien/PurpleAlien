return function(Places)
	local Players = game:GetService("Players")
	local Player = Players.LocalPlayer

	--==================================================
	-- LOAD GUI SCRIPTS
	--==================================================

	local PortalMakerGUI = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/PortalMakerGUI.lua"
	))()

	local CustomPlacesGUI = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/CustomPlacesGUI.lua"
	))()

	--==================================================
	-- CREATE GUIS
	--==================================================

	local PortalMaker = PortalMakerGUI.Create()

	local PlacesGUI = CustomPlacesGUI.Create(
		Places or {}
	)

	--==================================================
	-- GET GUI OBJECTS
	--==================================================

	local PortalMakerFrame =
		PortalMaker:WaitForChild("MainFrame")

	local ButtonsFrame =
		PortalMakerFrame:WaitForChild("Buttons")

	local PositionButton =
		ButtonsFrame:WaitForChild("Position")

	local PlayerButton =
		ButtonsFrame:WaitForChild("Player")

	local PlacesButton =
		ButtonsFrame:WaitForChild("Places")

	local PlayerTextBox =
		PortalMakerFrame:WaitForChild("PlayerName")

	--==================================================
	-- GUI ONLY
	--==================================================

	local PortalType = "Position"

	local function SetType(Type)
		PortalType = Type

		print(
			"[PortalScript] Portal type:",
			PortalType
		)
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

	PlayerTextBox.FocusLost:Connect(function()
		print(
			"[PortalScript] Player:",
			PlayerTextBox.Text
		)
	end)

	print("[PortalScript] Successfully loaded.")
	print("[PortalScript] Current type:", PortalType)
end
