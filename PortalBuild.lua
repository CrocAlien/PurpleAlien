local PortalBuild = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

--//==================================================
--// CONFIG
--//==================================================

PortalBuild.Decals = {
	Stage1 = "rbxassetid://STAGE_1_IMAGE_ID",
	Stage2 = "rbxassetid://STAGE_2_IMAGE_ID",
	Stage3 = "rbxassetid://STAGE_3_IMAGE_ID",

	RobloxLogo = "rbxassetid://ROBLOX_LOGO_IMAGE_ID"
}

PortalBuild.HitboxThickness = 0.15
PortalBuild.HitboxWidth = 5
PortalBuild.HitboxHeight = 8

PortalBuild.PortalWidth = 5
PortalBuild.PortalHeight = 8

--// Animation timing
PortalBuild.StageHoldTime = 0.5
PortalBuild.StageGrowTime = 0.5
PortalBuild.FinalHoldTime = 1
PortalBuild.WorldFadeTime = 2

--// How often the local world copy updates.
PortalBuild.WorldUpdateRate = 0.05

--//==================================================
--// PORTAL PART
--//==================================================

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

	part.Parent = Workspace

	return part
end

--//==================================================
--// HITBOX
--//==================================================

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

	hitbox.Parent = Workspace

	return hitbox
end

--//==================================================
--// DECAL
--//==================================================

local function createDecal(parent, face)
	local decal = Instance.new("Decal")

	decal.Face = face
	decal.Transparency = 1

	decal.Parent = parent

	return decal
end

--//==================================================
--// WORLD CLONING
--//==================================================

local function canClone(instance)
	if instance:IsA("Terrain") then
		return false
	end

	if instance:IsA("Camera") then
		return false
	end

	if instance:IsA("Script") then
		return false
	end

	if instance:IsA("LocalScript") then
		return false
	end

	if instance:IsA("ModuleScript") then
		return false
	end

	return instance:IsA("BasePart")
		or instance:IsA("Model")
		or instance:IsA("Folder")
end

local function cloneWorldPart(instance)
	if not canClone(instance) then
		return nil
	end

	local success, clone = pcall(function()
		return instance:Clone()
	end)

	if not success or not clone then
		return nil
	end

	-- Remove scripts from the clone.
	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Script")
			or descendant:IsA("LocalScript")
			or descendant:IsA("ModuleScript") then

			descendant:Destroy()
		end

		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		end
	end

	return clone
end

--//==================================================
--// VIEWPORT CREATION
--//==================================================

local function createViewport(portalPart)
	local surface = Instance.new("SurfaceGui")

	surface.Name = "PortalWorldSurface"
	surface.Face = Enum.NormalId.Front
	surface.AlwaysOnTop = true

	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 100

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

--//==================================================
--// COPY WORKSPACE
--//==================================================

local function copyWorkspace(worldModel)
	for _, child in ipairs(worldModel:GetChildren()) do
		child:Destroy()
	end

	for _, child in ipairs(Workspace:GetChildren()) do
		if child ~= Workspace.CurrentCamera then

			local clone = cloneWorldPart(child)

			if clone then
				clone.Parent = worldModel
			end
		end
	end
end

--//==================================================
--// UPDATE WORLD VIEW
--//==================================================

local function updateViewportCamera(camera, portalCFrame)
	-- Camera is placed slightly behind the portal.
	--
	-- The portal's front direction is its LookVector.
	--
	-- This gives the viewer a camera looking in the
	-- direction of the opposite side.

	camera.CFrame = portalCFrame
end

--//==================================================
--// ID IMAGE
--//==================================================

local function createIDImage(portalPart)
	local front = createDecal(portalPart, Enum.NormalId.Front)
	local back = createDecal(portalPart, Enum.NormalId.Back)

	front.Texture = PortalBuild.Decals.RobloxLogo
	back.Texture = PortalBuild.Decals.RobloxLogo

	front.Transparency = 1
	back.Transparency = 1

	return front, back
end

--//==================================================
--// PORTAL CREATION
--//==================================================

function PortalBuild.Create(cframe, portalType)
	portalType = portalType or "Position"

	local portalPart = createPortalPart(cframe)
	local hitbox = createHitbox(cframe)

	local frontDecal = createDecal(
		portalPart,
		Enum.NormalId.Front
	)

	local backDecal = createDecal(
		portalPart,
		Enum.NormalId.Back
	)

	--==================================================
	-- STAGE 1
	--==================================================

	frontDecal.Texture = PortalBuild.Decals.Stage1
	backDecal.Texture = PortalBuild.Decals.Stage1

	frontDecal.Transparency = 0
	backDecal.Transparency = 0

	portalPart.Size = Vector3.new(
		0.5,
		0.5,
		PortalBuild.HitboxThickness
	)

	task.wait(PortalBuild.StageHoldTime)

	--==================================================
	-- STAGE 2
	--==================================================

	frontDecal.Texture = PortalBuild.Decals.Stage2
	backDecal.Texture = PortalBuild.Decals.Stage2

	local stage2Tween = TweenService:Create(
		portalPart,

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

	stage2Tween:Play()
	stage2Tween.Completed:Wait()

	task.wait(PortalBuild.StageHoldTime)

	--==================================================
	-- STAGE 3
	--==================================================

	frontDecal.Texture = PortalBuild.Decals.Stage3
	backDecal.Texture = PortalBuild.Decals.Stage3

	local stage3Tween = TweenService:Create(
		portalPart,

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

	stage3Tween:Play()
	stage3Tween.Completed:Wait()

	--==================================================
	-- FINAL HOLD
	--==================================================

	task.wait(PortalBuild.FinalHoldTime)

	--==================================================
	-- ID PORTAL
	--==================================================

	if portalType == "ID" then

		frontDecal.Transparency = 1
		backDecal.Transparency = 1

		local frontLogo, backLogo = createIDImage(portalPart)

		local fadeInfo = TweenInfo.new(
			PortalBuild.WorldFadeTime,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut
		)

		TweenService:Create(
			frontLogo,
			fadeInfo,
			{Transparency = 0}
		):Play()

		TweenService:Create(
			backLogo,
			fadeInfo,
			{Transparency = 0}
		):Play()

		return {
			Portal = portalPart,
			Hitbox = hitbox,
			Type = portalType,
			Front = frontLogo,
			Back = backLogo
		}
	end

	--==================================================
	-- LIVE WORLD PORTAL
	--==================================================

	local frontSurface,
		frontViewport,
		frontWorld,
		frontCamera =
		createViewport(portalPart)

	-- Create second side.
	local backSurface = frontSurface:Clone()
	backSurface.Name = "PortalWorldSurfaceBack"
	backSurface.Face = Enum.NormalId.Back

	backSurface.Parent = portalPart

	local backViewport =
		backSurface:FindFirstChild("WorldView")

	local backWorld =
		backViewport:FindFirstChild("PortalWorld")

	local backCamera =
		backViewport:FindFirstChild("PortalCamera")

	backViewport.CurrentCamera = backCamera

	-- Copy current workspace.
	copyWorkspace(frontWorld)
	copyWorkspace(backWorld)

	-- Put both portal cameras on the portal.
	updateViewportCamera(
		frontCamera,
		cframe
	)

	updateViewportCamera(
		backCamera,
		cframe
	)

	-- Hide opening decals.
	local fadeInfo = TweenInfo.new(
		PortalBuild.WorldFadeTime,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.InOut
	)

	local frontFade = TweenService:Create(
		frontDecal,
		fadeInfo,
		{
			Transparency = 1
		}
	)

	local backFade = TweenService:Create(
		backDecal,
		fadeInfo,
		{
			Transparency = 1
		}
	)

	frontFade:Play()
	backFade:Play()

	--==================================================
	-- WORLD UPDATE LOOP
	--==================================================

	local running = true

	task.spawn(function()

		while running and portalPart.Parent do

			copyWorkspace(frontWorld)
			copyWorkspace(backWorld)

			updateViewportCamera(
				frontCamera,
				portalPart.CFrame
			)

			updateViewportCamera(
				backCamera,
				portalPart.CFrame
			)

			task.wait(
				PortalBuild.WorldUpdateRate
			)
		end

	end)

	return {
		Portal = portalPart,
		Hitbox = hitbox,
		Type = portalType,

		FrontViewport = frontViewport,
		BackViewport = backViewport,

		StopWorldUpdate = function()
			running = false
		end
	}
end

--//==================================================
--// DESTROY
--//==================================================

function PortalBuild.Destroy(portal)

	if not portal then
		return
	end

	if portal.StopWorldUpdate then
		portal.StopWorldUpdate()
	end

	if portal.Portal then
		portal.Portal:Destroy()
	end

	if portal.Hitbox then
		portal.Hitbox:Destroy()
	end
end

return PortalBuild
