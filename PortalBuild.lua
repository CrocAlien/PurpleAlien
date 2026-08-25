local PortalBuild = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

--==================================================
-- CONFIG
--==================================================

PortalBuild.Decals = {

	-- Temporary placeholders.
	-- Replace these with your own images later.

	Stage1 = "rbxassetid://2281286723",
	Stage2 = "rbxassetid://139404131810285",
	Stage3 = "rbxassetid://5367816732",

	-- Temporary ID portal image.
	RobloxLogo = "rbxassetid://2281286723"
}

-- Visual portal size
PortalBuild.PortalWidth = 5
PortalBuild.PortalHeight = 8

-- Invisible hitbox
PortalBuild.HitboxWidth = 5
PortalBuild.HitboxHeight = 8
PortalBuild.HitboxThickness = 0.15

-- Opening animation
PortalBuild.StageHoldTime = 0.5
PortalBuild.StageGrowTime = 0.5
PortalBuild.FinalHoldTime = 1
PortalBuild.WorldFadeTime = 2

--==================================================
-- SAFE WORLD VIEW SETTINGS
--==================================================

-- Maximum distance from the destination portal
-- that will be copied into the viewport.
PortalBuild.WorldCopyRadius = 40

-- Hard limit so a huge game cannot destroy performance.
PortalBuild.MaxCopiedParts = 150

-- How often the copied world is refreshed.
PortalBuild.WorldUpdateRate = 0.25

--==================================================
-- FOLDER
--==================================================

local PortalFolder = Instance.new("Folder")
PortalFolder.Name = "PurpleAlien_Portals"
PortalFolder.Parent = Workspace

--==================================================
-- CREATE PORTAL PART
--==================================================

local function createPortalPart(cframe)

	local part = Instance.new("Part")

	part.Name = "Portal"
	part.Size = Vector3.new(
		PortalBuild.PortalWidth,
		PortalBuild.PortalHeight,
		PortalBuild.HitboxThickness
	)

	part.CFrame = cframe

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	part.Transparency = 1

	part.Parent = PortalFolder

	return part
end

--==================================================
-- CREATE HITBOX
--==================================================

local function createHitbox(cframe)

	local hitbox = Instance.new("Part")

	hitbox.Name = "PortalHitbox"

	hitbox.Size = Vector3.new(
		PortalBuild.HitboxWidth,
		PortalBuild.HitboxHeight,
		PortalBuild.HitboxThickness
	)

	hitbox.CFrame = cframe

	hitbox.Anchored = true

	hitbox.CanCollide = false
	hitbox.CanTouch = true
	hitbox.CanQuery = true

	hitbox.Transparency = 1

	hitbox.Parent = PortalFolder

	return hitbox
end

--==================================================
-- CREATE DECAL
--==================================================

local function createDecal(parent, face)

	local decal = Instance.new("Decal")

	decal.Face = face
	decal.Transparency = 1

	decal.Parent = parent

	return decal
end

--==================================================
-- CREATE VIEWPORT
--==================================================

local function createViewport(portalPart, face)

	local surface = Instance.new("SurfaceGui")

	surface.Name = "PortalWorld_" .. face.Name
	surface.Face = face

	surface.AlwaysOnTop = true
	surface.LightInfluence = 0

	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 60

	surface.Parent = portalPart

	local viewport = Instance.new("ViewportFrame")

	viewport.Name = "WorldView"

	viewport.Size = UDim2.fromScale(1, 1)
	viewport.Position = UDim2.fromScale(0, 0)

	viewport.BackgroundTransparency = 1

	viewport.Ambient = Color3.fromRGB(200, 200, 200)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.LightDirection = Vector3.new(-1, -1, -1)

	viewport.Parent = surface

	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "PortalWorld"

	worldModel.Parent = viewport

	local camera = Instance.new("Camera")
	camera.Name = "PortalCamera"

	camera.Parent = viewport

	viewport.CurrentCamera = camera

	return surface, viewport, worldModel, camera
end

--==================================================
-- SAFE CLONE
--==================================================

local function clonePart(part)

	if not part:IsA("BasePart") then
		return nil
	end

	-- Do not copy the portal system itself.
	if part:IsDescendantOf(PortalFolder) then
		return nil
	end

	-- Don't copy characters.
	local model = part:FindFirstAncestorOfClass("Model")

	if model then

		local humanoid = model:FindFirstChildOfClass("Humanoid")

		if humanoid then
			return nil
		end
	end

	local success, clone = pcall(function()
		return part:Clone()
	end)

	if not success or not clone then
		return nil
	end

	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false

	return clone
end

--==================================================
-- COPY NEARBY WORLD
--==================================================

local function copyNearbyWorld(destinationCFrame, worldModel)

	-- Delete previous copy.
	for _, object in ipairs(worldModel:GetChildren()) do
		object:Destroy()
	end

	local parts = {}

	local success, result = pcall(function()

		return Workspace:GetPartBoundsInBox(
			CFrame.new(destinationCFrame.Position),
			Vector3.new(
				PortalBuild.WorldCopyRadius * 2,
				PortalBuild.WorldCopyRadius * 2,
				PortalBuild.WorldCopyRadius * 2
			)
		)

	end)

	if not success then
		return
	end

	parts = result

	local copied = 0

	for _, part in ipairs(parts) do

		if copied >= PortalBuild.MaxCopiedParts then
			break
		end

		if part:IsA("BasePart") then

			local distance =
				(part.Position - destinationCFrame.Position).Magnitude

			if distance <= PortalBuild.WorldCopyRadius then

				local clone = clonePart(part)

				if clone then
					clone.Parent = worldModel
					copied += 1
				end
			end
		end
	end
end

--==================================================
-- PORTAL CAMERA TRANSFORM
--==================================================

local function transformCamera(
	sourcePortal,
	destinationPortal,
	cameraCFrame
)

	-- Position relative to source portal.
	local relativePosition =
		sourcePortal.CFrame:ToObjectSpace(
			cameraCFrame
		)

	-- Move that position through the portal.
	local destinationCFrame =
		destinationPortal.CFrame
		* relativePosition

	-- Flip the camera so it looks out
	-- of the opposite side of the destination portal.
	local flip =
		CFrame.Angles(
			0,
			math.rad(180),
			0
		)

	return destinationCFrame * flip
end

--==================================================
-- UPDATE VIEWPORT CAMERA
--==================================================

local function updateViewport(
	camera,
	sourcePortal,
	destinationPortal
)

	local playerCamera = Workspace.CurrentCamera

	if not playerCamera then
		return
	end

	local newCameraCFrame =
		transformCamera(
			sourcePortal,
			destinationPortal,
			playerCamera.CFrame
		)

	camera.CFrame = newCameraCFrame

	camera.FieldOfView =
		playerCamera.FieldOfView
end

--==================================================
-- CREATE LIVE SIDE
--==================================================

local function createLiveSide(
	portalPart,
	face,
	destinationPortal
)

	local surface,
		viewport,
		worldModel,
		camera =
		createViewport(
			portalPart,
			face
		)

	copyNearbyWorld(
		destinationPortal.CFrame,
		worldModel
	)

	return {
		Surface = surface,
		Viewport = viewport,
		WorldModel = worldModel,
		Camera = camera,
		Destination = destinationPortal
	}
end

--==================================================
-- PORTAL CREATION
--==================================================

function PortalBuild.CreatePair(
	portalACFrame,
	portalBCFrame
)

	local portalA =
		createPortalPart(
			portalACFrame
		)

	local portalB =
		createPortalPart(
			portalBCFrame
		)

	local hitboxA =
		createHitbox(
			portalACFrame
		)

	local hitboxB =
		createHitbox(
			portalBCFrame
		)

	--==================================================
	-- OPENING DECALS
	--==================================================

	local AFront =
		createDecal(
			portalA,
			Enum.NormalId.Front
		)

	local ABack =
		createDecal(
			portalA,
			Enum.NormalId.Back
		)

	local BFront =
		createDecal(
			portalB,
			Enum.NormalId.Front
		)

	local BBack =
		createDecal(
			portalB,
			Enum.NormalId.Back
		)

	--==================================================
	-- STAGE 1
	--==================================================

	AFront.Texture =
		PortalBuild.Decals.Stage1

	ABack.Texture =
		PortalBuild.Decals.Stage1

	BFront.Texture =
		PortalBuild.Decals.Stage1

	BBack.Texture =
		PortalBuild.Decals.Stage1

	AFront.Transparency = 0
	ABack.Transparency = 0

	BFront.Transparency = 0
	BBack.Transparency = 0

	portalA.Size =
		Vector3.new(
			0.5,
			0.5,
			PortalBuild.HitboxThickness
		)

	portalB.Size =
		Vector3.new(
			0.5,
			0.5,
			PortalBuild.HitboxThickness
		)

	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 2
	--==================================================

	AFront.Texture =
		PortalBuild.Decals.Stage2

	ABack.Texture =
		PortalBuild.Decals.Stage2

	BFront.Texture =
		PortalBuild.Decals.Stage2

	BBack.Texture =
		PortalBuild.Decals.Stage2

	local stage2Info =
		TweenInfo.new(
			PortalBuild.StageGrowTime,
			Enum.EasingStyle.Elastic,
			Enum.EasingDirection.Out
		)

	local stage2A =
		TweenService:Create(
			portalA,
			stage2Info,
			{
				Size = Vector3.new(
					PortalBuild.PortalWidth * 0.7,
					PortalBuild.PortalHeight * 0.7,
					PortalBuild.HitboxThickness
				)
			}
		)

	local stage2B =
		TweenService:Create(
			portalB,
			stage2Info,
			{
				Size = Vector3.new(
					PortalBuild.PortalWidth * 0.7,
					PortalBuild.PortalHeight * 0.7,
					PortalBuild.HitboxThickness
				)
			}
		)

	stage2A:Play()
	stage2B:Play()

	stage2A.Completed:Wait()

	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 3
	--==================================================

	AFront.Texture =
		PortalBuild.Decals.Stage3

	ABack.Texture =
		PortalBuild.Decals.Stage3

	BFront.Texture =
		PortalBuild.Decals.Stage3

	BBack.Texture =
		PortalBuild.Decals.Stage3

	local stage3Info =
		TweenInfo.new(
			PortalBuild.StageGrowTime,
			Enum.EasingStyle.Elastic,
			Enum.EasingDirection.Out
		)

	local stage3A =
		TweenService:Create(
			portalA,
			stage3Info,
			{
				Size = Vector3.new(
					PortalBuild.PortalWidth,
					PortalBuild.PortalHeight,
					PortalBuild.HitboxThickness
				)
			}
		)

	local stage3B =
		TweenService:Create(
			portalB,
			stage3Info,
			{
				Size = Vector3.new(
					PortalBuild.PortalWidth,
					PortalBuild.PortalHeight,
					PortalBuild.HitboxThickness
				)
			}
		)

	stage3A:Play()
	stage3B:Play()

	stage3A.Completed:Wait()

	--==================================================
	-- FINAL HOLD
	--==================================================

	task.wait(
		PortalBuild.FinalHoldTime
	)

	--==================================================
	-- CREATE WORLD VIEWS
	--==================================================

	local frontA =
		createLiveSide(
			portalA,
			Enum.NormalId.Front,
			portalB
		)

	local backA =
		createLiveSide(
			portalA,
			Enum.NormalId.Back,
			portalB
		)

	local frontB =
		createLiveSide(
			portalB,
			Enum.NormalId.Front,
			portalA
		)

	local backB =
		createLiveSide(
			portalB,
			Enum.NormalId.Back,
			portalA
		)

	--==================================================
	-- FADE OPENING DECALS
	--==================================================

	local fadeInfo =
		TweenInfo.new(
			PortalBuild.WorldFadeTime,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)

	TweenService:Create(
		AFront,
		fadeInfo,
		{
			Transparency = 1
		}
	):Play()

	TweenService:Create(
		ABack,
		fadeInfo,
		{
			Transparency = 1
		}
	):Play()

	TweenService:Create(
		BFront,
		fadeInfo,
		{
			Transparency = 1
		}
	):Play()

	TweenService:Create(
		BBack,
		fadeInfo,
		{
			Transparency = 1
		}
	):Play()

	--==================================================
	-- UPDATE LOOP
	--==================================================

	local running = true

	task.spawn(function()

		while running
			and portalA.Parent
			and portalB.Parent do

			updateViewport(
				frontA.Camera,
				portalA,
				portalB
			)

			updateViewport(
				backA.Camera,
				portalA,
				portalB
			)

			updateViewport(
				frontB.Camera,
				portalB,
				portalA
			)

			updateViewport(
				backB.Camera,
				portalB,
				portalA
			)

			-- Refresh only the nearby world.
			copyNearbyWorld(
				portalB.CFrame,
				frontA.WorldModel
			)

			copyNearbyWorld(
				portalB.CFrame,
				backA.WorldModel
			)

			copyNearbyWorld(
				portalA.CFrame,
				frontB.WorldModel
			)

			copyNearbyWorld(
				portalA.CFrame,
				backB.WorldModel
			)

			task.wait(
				PortalBuild.WorldUpdateRate
			)
		end
	end)

	--==================================================
	-- RETURN
	--==================================================

	local pair = {

		PortalA = portalA,
		PortalB = portalB,

		HitboxA = hitboxA,
		HitboxB = hitboxB,

		Type = "Position",

		Stop = function()

			running = false

			if portalA then
				portalA:Destroy()
			end

			if portalB then
				portalB:Destroy()
			end

			if hitboxA then
				hitboxA:Destroy()
			end

			if hitboxB then
				hitboxB:Destroy()
			end
		end
	}

	return pair
end

--==================================================
-- ID PORTAL
--==================================================

function PortalBuild.CreateIDPortal(cframe)

	local portal =
		createPortalPart(cframe)

	local hitbox =
		createHitbox(cframe)

	local front =
		createDecal(
			portal,
			Enum.NormalId.Front
		)

	local back =
		createDecal(
			portal,
			Enum.NormalId.Back
		)

	-- Stage 1
	front.Texture =
		PortalBuild.Decals.Stage1

	back.Texture =
		PortalBuild.Decals.Stage1

	front.Transparency = 0
	back.Transparency = 0

	portal.Size =
		Vector3.new(
			0.5,
			0.5,
			PortalBuild.HitboxThickness
		)

	task.wait(
		PortalBuild.StageHoldTime
	)

	-- Stage 2
	front.Texture =
		PortalBuild.Decals.Stage2

	back.Texture =
		PortalBuild.Decals.Stage2

	local stage2 =
		TweenService:Create(
			portal,

			TweenInfo.new(
				PortalBuild.StageGrowTime,
				Enum.EasingStyle.Elastic,
				Enum.EasingDirection.Out
			),

			{
				Size = Vector3.new(
					PortalBuild.PortalWidth * 0.7,
					PortalBuild.PortalHeight * 0.7,
					PortalBuild.HitboxThickness
				)
			}
		)

	stage2:Play()
	stage2.Completed:Wait()

	task.wait(
		PortalBuild.StageHoldTime
	)

	-- Stage 3
	front.Texture =
		PortalBuild.Decals.Stage3

	back.Texture =
		PortalBuild.Decals.Stage3

	local stage3 =
		TweenService:Create(
			portal,

			TweenInfo.new(
				PortalBuild.StageGrowTime,
				Enum.EasingStyle.Elastic,
				Enum.EasingDirection.Out
			),

			{
				Size = Vector3.new(
					PortalBuild.PortalWidth,
					PortalBuild.PortalHeight,
					PortalBuild.HitboxThickness
				)
			}
		)

	stage3:Play()
	stage3.Completed:Wait()

	task.wait(
		PortalBuild.FinalHoldTime
	)

	-- Roblox logo
	front.Texture =
		PortalBuild.Decals.RobloxLogo

	back.Texture =
		PortalBuild.Decals.RobloxLogo

	TweenService:Create(
		front,

		TweenInfo.new(
			PortalBuild.WorldFadeTime,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		),

		{
			Transparency = 0
		}
	):Play()

	TweenService:Create(
		back,

		TweenInfo.new(
			PortalBuild.WorldFadeTime,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		),

		{
			Transparency = 0
		}
	):Play()

	return {

		Portal = portal,
		Hitbox = hitbox,

		Stop = function()

			portal:Destroy()
			hitbox:Destroy()

		end
	}
end

return PortalBuild
