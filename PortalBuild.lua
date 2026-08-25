local PortalBuild = {}

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--//==================================================
--// CONFIG
--//==================================================

PortalBuild.Decals = {

	-- Temporary testing images.
	-- Replace these with your own PNG asset IDs later.

	Stage1 = "rbxassetid://2281286723",
	Stage2 = "rbxassetid://139404131810285",
	Stage3 = "rbxassetid://8220913511",

	-- Used later for ID portals.
	RobloxLogo = "rbxassetid://2281286723"
}

--//==================================================
--// PORTAL SIZE
--//==================================================

PortalBuild.PortalWidth = 5
PortalBuild.PortalHeight = 8

--//==================================================
--// HITBOX
--//==================================================

PortalBuild.HitboxWidth = 5
PortalBuild.HitboxHeight = 8
PortalBuild.HitboxThickness = 0.15

--//==================================================
--// ANIMATION
--//==================================================

PortalBuild.StageHoldTime = 0.5
PortalBuild.StageGrowTime = 0.5
PortalBuild.FinalHoldTime = 1

-- How long the portal exists after being created.
PortalBuild.Lifetime = 20

-- One full rotation takes this many seconds.
PortalBuild.RotationTime = 8

--//==================================================
--// PORTAL FOLDER
--//==================================================

local PortalFolder = Instance.new("Folder")
PortalFolder.Name = "PurpleAlien_Portals"
PortalFolder.Parent = Workspace

--//==================================================
--// CREATE VISUAL PORTAL
--//==================================================

local function createPortalPart(cframe)

	local part = Instance.new("Part")

	part.Name = "PortalVisual"

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

	-- IMPORTANT:
	-- The Part itself must NOT be fully transparent,
	-- otherwise the Decals can disappear too.
	part.Transparency = 0

	-- The PNG/Decal provides the actual appearance.
	part.Color = Color3.fromRGB(255, 255, 255)
	part.Material = Enum.Material.SmoothPlastic

	part.Parent = PortalFolder

	return part
end

--//==================================================
--// CREATE INVISIBLE HITBOX
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

	--==================================================
	-- CREATE OBJECTS
	--==================================================

	local portal =
		createPortalPart(cframe)

	local hitbox =
		createHitbox(cframe)

	-- Front
	local front =
		createDecal(
			portal,
			Enum.NormalId.Front
		)

	-- Back
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

	local rotating = true

	task.spawn(function()

		while rotating and portal.Parent do

			local rotationTween =
				TweenService:Create(

					portal,

					TweenInfo.new(
						PortalBuild.RotationTime,
						Enum.EasingStyle.Linear,
						Enum.EasingDirection.InOut
					),

					{
						CFrame =
							portal.CFrame
							* CFrame.Angles(
								0,
								0,
								math.rad(360)
							)
					}
				)

			rotationTween:Play()
			rotationTween.Completed:Wait()

		end

	end)

	--==================================================
	-- 20 SECOND LIFETIME
	--==================================================

	task.delay(
		PortalBuild.Lifetime,
		function()

			rotating = false

			if portal and portal.Parent then
				portal:Destroy()
			end

			if hitbox and hitbox.Parent then
				hitbox:Destroy()
			end

		end
	)

	--==================================================
	-- RETURN PORTAL DATA
	--==================================================

	return {

		Portal = portal,

		Hitbox = hitbox,

		Front = front,

		Back = back,

		Destroy = function()

			rotating = false

			if portal and portal.Parent then
				portal:Destroy()
			end

			if hitbox and hitbox.Parent then
				hitbox:Destroy()
			end

		end
	}
end

return PortalBuild
