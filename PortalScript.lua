return function(Places)
	local Players = game:GetService("Players")
	local TeleportService = game:GetService("TeleportService")

	local Player = Players.LocalPlayer
	local PlayerGui = Player:WaitForChild("PlayerGui")

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
	-- LOAD GUI SCRIPTS
	--==================================================

	local function LoadScript(URL, Name)
		local Success, Result = pcall(function()
			local Source = game:HttpGet(URL)
			local Function = loadstring(Source)

			if not Function then
				error("loadstring returned nil")
			end

			return Function()
		end)

		if not Success then
			warn("[PortalScript] Failed to load " .. Name .. ": " .. tostring(Result))
			return nil
		end

		print("[PortalScript] Loaded " .. Name)
		return Result
	end

	local PortalMakerGUI = LoadScript(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/PortalMakerGUI.lua",
		"PortalMakerGUI"
	)

	local CustomPlacesGUI = LoadScript(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/CustomPlacesGUI.lua",
		"CustomPlacesGUI"
	)

	--==================================================
	-- CREATE GUIS
	--==================================================

	if not PortalMakerGUI then
		warn("[PortalScript] PortalMakerGUI could not be loaded.")
		return
	end

	if not CustomPlacesGUI then
		warn("[PortalScript] CustomPlacesGUI could not be loaded.")
		return
	end

	local Success, PortalMaker = pcall(function()
		return PortalMakerGUI.Create()
	end)

	if not Success then
		warn("[PortalScript] PortalMakerGUI.Create failed: " .. tostring(PortalMaker))
		return
	end

	local Success2, PlacesGUI = pcall(function()
		return CustomPlacesGUI.Create(Places or {})
	end)

	if not Success2 then
		warn("[PortalScript] CustomPlacesGUI.Create failed: " .. tostring(PlacesGUI))
		return
	end

	print("[PortalScript] GUIs created successfully")

	--==================================================
	-- GET GUI OBJECTS
	--==================================================

	local PortalMakerFrame = PortalMaker:WaitForChild("MainFrame")
	local ButtonsFrame = PortalMakerFrame:WaitForChild("Buttons")

	local PositionButton = ButtonsFrame:WaitForChild("Position")
	local PlayerButton = ButtonsFrame:WaitForChild("Player")
	local PlacesButton = ButtonsFrame:WaitForChild("Places")

	local PlayerTextBox = PortalMakerFrame:WaitForChild("PlayerName")

	local PlacesMainFrame = PlacesGUI:WaitForChild("MainFrame")
	local PlacesScrollingFrame = PlacesMainFrame:WaitForChild("Places")

	--==================================================
	-- LOAD MAIN SYSTEM SCRIPTS
	--==================================================

	local PortalBuild = LoadScript(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/PortalBuild.lua",
		"PortalBuild"
	)

	local CustomSkin = LoadScript(
		"https://raw.githubusercontent.com/CrocAlien/PurpleAlien/Builds/CustomSkin.lua",
		"CustomSkin"
	)

	if not PortalBuild then
		warn("[PortalScript] PortalBuild failed to load.")
		return
	end

	if not CustomSkin then
		warn("[PortalScript] CustomSkin failed to load.")
		return
	end

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

		print("[PortalScript] Portal type:", Type)
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

	for PlaceName, PlaceId in pairs(Places or {}) do
		local Button = PlacesScrollingFrame:FindFirstChild(PlaceName)

		if Button then
			Button.MouseButton1Click:Connect(function()
				SelectedPlaceName = PlaceName
				SelectedPlaceId = PlaceId

				print(
					"[PortalScript] Selected place:",
					PlaceName,
					PlaceId
				)
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

		local Success, Description = pcall(function()
			return CustomSkin.Create()
		end)

		if not Success then
			warn(
				"[PortalScript] CustomSkin.Create failed:",
				Description
			)
			return
		end

		if not Description then
			warn("[PortalScript] CustomSkin returned no description.")
			return
		end

		local Applied, Error = pcall(function()
			Humanoid:ApplyDescription(Description)
		end)

		if not Applied then
			warn(
				"[PortalScript] Failed to apply CustomSkin:",
				Error
			)
		else
			print("[PortalScript] Custom skin applied")
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

	local function GetPortalPositions()
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
	-- FIND PLAYER
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
		local Front, Back = GetPortalPositions()

		local SuccessA, ResultA = pcall(function()
			return PortalBuild.Create(Front, "Position")
		end)

		if not SuccessA then
			warn("[PortalScript] Portal A failed:", ResultA)
			return false
		end

		PortalA = ResultA

		local SuccessB, ResultB = pcall(function()
			return PortalBuild.Create(Back, "Position")
		end)

		if not SuccessB then
			warn("[PortalScript] Portal B failed:", ResultB)
			return false
		end

		PortalB = ResultB

		return true
	end

	--==================================================
	-- CREATE PLAYER PORTALS
	--==================================================

	local function CreatePlayerPortals()
		local Target = FindPlayer()

		if not Target then
			warn("[PortalScript] Player not found:", TargetPlayerName)
			return false
		end

		local TargetCharacter = Target.Character

		if not TargetCharacter then
			warn("[PortalScript] Target has no character.")
			return false
		end

		local TargetRoot = TargetCharacter:FindFirstChild(
			"HumanoidRootPart"
		)

		if not TargetRoot then
			warn("[PortalScript] Target has no HumanoidRootPart.")
			return false
		end

		local Front = GetPortalPositions()

		local SuccessA, ResultA = pcall(function()
			return PortalBuild.Create(Front, "Player")
		end)

		if not SuccessA then
			warn("[PortalScript] Player portal A failed:", ResultA)
			return false
		end

		PortalA = ResultA

		local SuccessB, ResultB = pcall(function()
			return PortalBuild.Create(TargetRoot.CFrame, "Player")
		end)

		if not SuccessB then
			warn("[PortalScript] Player portal B failed:", ResultB)
			return false
		end

		PortalB = ResultB

		return true
	end

	--==================================================
	-- CREATE PLACE PORTALS
	--==================================================

	local function CreatePlacePortals()
		if not SelectedPlaceId then
			warn("[PortalScript] No place selected.")
			return false
		end

		local Front, Back = GetPortalPositions()

		local SuccessA, ResultA = pcall(function()
			return PortalBuild.Create(Front, "Places")
		end)

		if not SuccessA then
			warn("[PortalScript] Place portal A failed:", ResultA)
			return false
		end

		PortalA = ResultA

		local SuccessB, ResultB = pcall(function()
			return PortalBuild.Create(Back, "Places")
		end)

		if not SuccessB then
			warn("[PortalScript] Place portal B failed:", ResultB)
			return false
		end

		PortalB = ResultB

		return true
	end

	--==================================================
	-- TELEPORT
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
			if CreatePositionPortals() then
				ConnectPositionPortals()
			end
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

	print("[PortalScript] Starting")

	ApplyCustomSkin()

	task.wait(SkinDelay)

	UpdateCharacter()
	CreatePortals()

	print("[PortalScript] Ready")
end
