local PortalBuild = {}

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--//==================================================
--// CONFIG
--//==================================================

PortalBuild.Decals = {
	-- Temporary images for testing.
	-- Replace these with your own asset IDs later.

	Stage1 = "rbxassetid://2281286723",
	Stage2 = "rbxassetid://139404131810285",
	Stage3 = "rbxassetid://5367816732",

	-- Used later for ID portals if needed.
	RobloxLogo = "rbxassetid://2281286723"
}

--// Portal size
PortalBuild.PortalWidth = 5
PortalBuild.PortalHeight = 8

--// Invisible hitbox
PortalBuild.HitboxWidth = 5
PortalBuild.HitboxHeight = 8
PortalBuild.HitboxThickness = 0.15

--// Opening animation
PortalBuild.StageHoldTime = 0.5
PortalBuild.StageGrowTime = 0.5

--// Wait after Stage 3 finishes opening
PortalBuild.FinalHoldTime = 1

--// How long the portal exists
PortalBuild.Lifetime = 20

--// Rotation speed
PortalBuild.RotationTime = 8

--//==================================================
--// PORTAL FOLDER
--//==================================================

local PortalFolder = Instance.new("Folder")
PortalFolder.Name = "PurpleAlien_Portals"
PortalFolder.Parent = Workspace

--//==================================================
--// CREATE PORTAL PART
--//==================================================

local function createPortalPart(cframe)

	local part = Instance.new("Part")

	part.Name = "Portal"

	part.Size = Vector3.new(
		0.5,
		0.5,
		PortalBuild.HitboxThickness
	)

	part.CFrame = cframe

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	-- Invisible because only the decals should be visible.
	part.Transparency = 1

	part.Parent = PortalFolder

	return part
end

--//==================================================
--// CREATE HITBOX
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

	hitbox.Parent = PortalFolder

	return hitbox
end

--//==================================================
--// CREATE DECAL
--//==================================================

local function createDecal(parent, face)

	local decal = Instance.new("Decal")

	decal.Face = face
	decal.Transparency = 0

	decal.Parent = parent

	return decal
end

--//==================================================
--// CREATE PORTAL
--//==================================================

function PortalBuild.Create(cframe, portalType)

	portalType = portalType or "Position"

	local portal =
		createPortalPart(cframe)

	local hitbox =
		createHitbox(cframe)

	-- Front and back
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

	--==================================================
	-- STAGE 1
	--==================================================

	front.Texture =
		PortalBuild.Decals.Stage1

	back.Texture =
		PortalBuild.Decals.Stage1

	portal.Size = Vector3.new(
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

	front.Texture =
		PortalBuild.Decals.Stage2

	back.Texture =
		PortalBuild.Decals.Stage2

	local stage2Tween =
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

	stage2Tween:Play()

	stage2Tween.Completed:Wait()

	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 3
	--==================================================

	front.Texture =
		PortalBuild.Decals.Stage3

	back.Texture =
		PortalBuild.Decals.Stage3

	local stage3Tween =
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

	stage3Tween:Play()

	stage3Tween.Completed:Wait()

	--==================================================
	-- FINAL HOLD
	--==================================================

	task.wait(
		PortalBuild.FinalHoldTime
	)

	--==================================================
	-- SLOW ROTATION
	--==================================================

	local rotationTween =
		TweenService:Create(

			portal,

			TweenInfo.new(

				PortalBuild.RotationTime,

				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut,

				-1,

				false
			),

			{
				CFrame =
					portal.CFrame
					* CFrame.Angles(
						0,
						math.rad(360),
						0
					)
			}
		)

	rotationTween:Play()

	--==================================================
	-- LIFETIME
	--==================================================

	task.delay(
		PortalBuild.Lifetime,
		function()

			if rotationTween then
				rotationTween:Cancel()
			end

			if portal then
				portal:Destroy()
			end

			if hitbox then
				hitbox:Destroy()
			end

		end
	)

	return {
		Portal = portal,
		Hitbox = hitbox,
		Front = front,
		Back = back,

		Destroy = function()

			if rotationTween then
				rotationTween:Cancel()
			end

			if portal then
				portal:Destroy()
			end

			if hitbox then
				hitbox:Destroy()
			end

		end
	}
end

return PortalBuild
