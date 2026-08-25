return function(Places)
	local Players = game:GetService("Players")
	local TeleportService = game:GetService("TeleportService")

	local Player = Players.LocalPlayer

	--==================================================
	-- SETTINGS
	--==================================================

	local PortalType = "Position"
	local TargetPlayerName = ""
	local SelectedPlaceName = nil
	local SelectedPlaceId = nil

	local PortalDistance = 8
	local SkinDelay = 1
	local TeleportCooldown = false

	local PortalA = nil
	local PortalB = nil

	--==================================================
	-- LOAD SCRIPTS
	--==================================================

	local PortalBuild = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/PortalBuild.lua"
	))()

	local CustomSkin = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/CustomSkin.lua"
	))()

	local CustomPlacesGUI = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/CustomPlacesGUI.lua"
	))()

	local PortalMakerGUI = loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/PortalMakerGUI.lua"
	))()

	--==================================================
	-- CREATE GUIS
	--==================================================

	local PortalMaker = PortalMakerGUI.Create()
	local PlacesGUI = CustomPlacesGUI.Create(Places)

	local PortalMakerFrame = PortalMaker:WaitForChild("MainFrame")
	local ButtonsFrame = PortalMakerFrame:WaitForChild("Buttons")

	local PositionButton = ButtonsFrame:WaitForChild("Position")
	local PlayerButton = ButtonsFrame:WaitForChild("Player")
	local PlacesButton = ButtonsFrame:WaitForChild("Places")

	local PlayerTextBox = PortalMakerFrame:WaitForChild("PlayerName")

	local PlacesMainFrame = PlacesGUI:WaitForChild("MainFrame")
	local PlacesScrollingFrame = PlacesMainFrame:WaitForChild("Places")

	--==================================================
	-- PORTAL TYPE
	--==================================================

	local function SetPortalType(Type)
		PortalType = Type

		if Type ~= "Player" then
			TargetPlayerName = ""
			PlayerTextBox.Text = ""
		end

		if Type ~= "Places" then
			SelectedPlaceName = nil
			SelectedPlaceId = nil
		end
	end

	PositionButton.MouseButton1Click:Connect(function()
		SetPortalType("Position")
	end)

	PlayerButton.MouseButton1Click:Connect(function()
		SetPortalType("Player")
	end)

	PlacesButton.MouseButton1Click:Connect(function()
		SetPortalType("Places")
	end)

	--==================================================
	-- PLAYER INPUT
	--==================================================

	PlayerTextBox.FocusLost:Connect(function()
		TargetPlayerName = PlayerTextBox.Text
	end)

	--==================================================
	-- PLACE INPUT
	--==================================================

	for PlaceName, PlaceId in pairs(Places) do
		local Button = PlacesScrollingFrame:FindFirstChild(PlaceName)

		if Button then
			Button.MouseButton1Click:Connect(function()
				SelectedPlaceName = PlaceName
				SelectedPlaceId = PlaceId
			end)
		end
	end

	--==================================================
	-- CHARACTER
	--==================================================

	local Character
	local Humanoid
	local RootPart

	local function UpdateCharacter()
		Character = Player.Character or Player.CharacterAdded:Wait()
		Humanoid = Character:WaitForChild("Humanoid")
		RootPart = Character:WaitForChild("HumanoidRootPart")
	end

	UpdateCharacter()

	Player.CharacterAdded:Connect(function(NewCharacter)
		Character = NewCharacter
		Humanoid = NewCharacter:WaitForChild("Humanoid")
		RootPart = NewCharacter:WaitForChild("HumanoidRootPart")
	end)

	--==================================================
	-- CUSTOM SKIN
	--==================================================

	local function ApplyCustomSkin()
		UpdateCharacter()

		local Description = CustomSkin.Create()

		if Description then
			pcall(function()
				Humanoid:ApplyDescription(Description)
			end)
		end
	end

	--==================================================
	-- DESTROY PORTALS
	--==================================================

	local function DestroyPortals()
		if PortalA then
			PortalA:Destroy()
			PortalA = nil
		end

		if PortalB then
			PortalB:Destroy()
			PortalB = nil
		end
	end

	--==================================================
	-- PORTAL POSITIONS
	--==================================================

	local function GetPositionPortals()
		UpdateCharacter()

		local Front = RootPart.CFrame * CFrame.new(
			0,
			0,
			-PortalDistance
		)

		local Back = RootPart.CFrame * CFrame.new(
			0,
			0,
			PortalDistance
		)

		return Front, Back
	end

	--==================================================
	-- TARGET PLAYER
	--==================================================

	local function FindPlayer()
		if TargetPlayerName == "" then
			return nil
		end

		local Search = string.lower(TargetPlayerName)

		for _, Target in ipairs(Players:GetPlayers()) do
			if string.lower(Target.Name) == Search
				or string.lower(Target.DisplayName) == Search then
				return Target
			end
		end

		for _, Target in ipairs(Players:GetPlayers()) do
			if string.sub(
				string.lower(Target.Name),
				1,
				#Search
			) == Search then
				return Target
			end
		end

		return nil
	end

	--==================================================
	-- CREATE POSITION PORTALS
	--==================================================

	local function CreatePositionPortals()
		local Front, Back = GetPositionPortals()

		PortalA = PortalBuild.Create(
			Front,
			"Position"
		)

		PortalB = PortalBuild.Create(
			Back,
			"Position"
		)
	end

	--==================================================
	-- CREATE PLAYER PORTALS
	--==================================================

	local function CreatePlayerPortals()
		local Target = FindPlayer()

		if not Target then
			warn("PortalMaker: Player not found.")
			return false
		end

		local TargetCharacter = Target.Character

		if not TargetCharacter then
			warn("PortalMaker: Target has no character.")
			return false
		end

		local TargetRoot = TargetCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

		if not TargetRoot then
			warn("PortalMaker: Target has no HumanoidRootPart.")
			return false
		end

		local Front = GetPositionPortals()

		PortalA = PortalBuild.Create(
			Front,
			"Player"
		)

		PortalB = PortalBuild.Create(
			TargetRoot.CFrame,
			"Player"
		)

		return true
	end

	--==================================================
	-- CREATE PLACE PORTALS
	--==================================================

	local function CreatePlacePortals()
		if not SelectedPlaceId then
			warn("PortalMaker: No place selected.")
			return false
		end

		local Front, Back = GetPositionPortals()

		PortalA = PortalBuild.Create(
			Front,
			"Places"
		)

		PortalB = PortalBuild.Create(
			Back,
			"Places"
		)

		return true
	end

	--==================================================
	-- TELEPORT TO CFRAME
	--==================================================

	local function TeleportTo(CFrame)
		if TeleportCooldown then
			return
		end

		TeleportCooldown = true

		UpdateCharacter()

		RootPart.CFrame = CFrame

		task.delay(1, function()
			TeleportCooldown = false
		end)
	end

	--==================================================
	-- CONNECT POSITION PORTALS
	--==================================================

	local function ConnectPositionPortals()
		if not PortalA or not PortalB then
			return
		end

		local AHitbox = PortalA.Hitbox
		local BHitbox = PortalB.Hitbox

		AHitbox.Touched:Connect(function(Hit)
			if Character and Hit:IsDescendantOf(Character) then
				TeleportTo(BHitbox.CFrame)
			end
		end)

		BHitbox.Touched:Connect(function(Hit)
			if Character and Hit:IsDescendantOf(Character) then
				TeleportTo(AHitbox.CFrame)
			end
		end)
	end

	--==================================================
	-- CONNECT PLACE PORTAL
	--==================================================

	local function ConnectPlacePortal()
		if not PortalA then
			return
		end

		PortalA.Hitbox.Touched:Connect(function(Hit)
			if not Character then
				return
			end

			if not Hit:IsDescendantOf(Character) then
				return
			end

			if not SelectedPlaceId then
				return
			end

			if TeleportCooldown then
				return
			end

			TeleportCooldown = true

			TeleportService:Teleport(
				SelectedPlaceId,
				Player
			)
		end)
	end

	--==================================================
	-- CREATE PORTALS
	--==================================================

	local function CreatePortals()
		DestroyPortals()

		if PortalType == "Position" then
			CreatePositionPortals()
			ConnectPositionPortals()

		elseif PortalType == "Player" then
			if CreatePlayerPortals() then
				ConnectPositionPortals()
			end

		elseif PortalType == "Places" then
			if CreatePlacePortals() then
				ConnectPlacePortal()
			end
		end
	end

	--==================================================
	-- START
	--==================================================

	ApplyCustomSkin()

	task.wait(SkinDelay)

	UpdateCharacter()
	CreatePortals()
end
