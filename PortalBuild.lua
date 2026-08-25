local PortalBuild = {}

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--==================================================
-- CONFIG
--==================================================

PortalBuild.Decals = {
	Stage1 = "rbxassetid://82149604426664",
	Stage2 = "rbxassetid://96231048684434",
	Stage3 = "rbxassetid://119880285735898"
}

-- Final visual size
PortalBuild.PortalWidth = 5
PortalBuild.PortalHeight = 8

-- Invisible hitbox
PortalBuild.HitboxWidth = 5
PortalBuild.HitboxHeight = 8
PortalBuild.HitboxThickness = 0.15

-- Opening animation
PortalBuild.StageHoldTime = 0.5
PortalBuild.StageGrowTime = 0.5

-- Wait after the final portal finishes opening
PortalBuild.FinalHoldTime = 1

-- Total lifetime AFTER creation
PortalBuild.Lifetime = 20

-- One complete rotation
PortalBuild.RotationTime = 8

--==================================================
-- FOLDER
--==================================================

local PortalFolder = Instance.new("Folder")
PortalFolder.Name = "PurpleAlien_Portals"
PortalFolder.Parent = Workspace

--==================================================
-- VISUAL PART
--==================================================

local function createPortalPart(cframe)

	local part = Instance.new("Part")

	part.Name = "PortalVisual"

	-- IMPORTANT:
	-- Keep the visual part at its FINAL size.
	part.Size = Vector3.new(
		PortalBuild.PortalWidth,
		PortalBuild.PortalHeight,
		0.05
	)

	part.CFrame = cframe

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	-- Make the actual Part invisible.
	-- The Decals are what we see.
	part.Transparency = 1

	part.Parent = PortalFolder

	return part
end

--==================================================
-- HITBOX
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
-- DECAL
--==================================================

local function createDecal(parent, face)

	local decal = Instance.new("Decal")

	decal.Face = face

	decal.Transparency = 0

	decal.Parent = parent

	return decal
end

--==================================================
-- SET IMAGE
--==================================================

local function setImage(front, back, image)

	front.Texture = image
	back.Texture = image

end

--==================================================
-- CREATE
--==================================================

function PortalBuild.Create(cframe, portalType)

	portalType = portalType or "Position"

	--==================================================
	-- CREATE PARTS
	--==================================================

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

	--==================================================
	-- START SMALL
	--==================================================

	setImage(
		front,
		back,
		PortalBuild.Decals.Stage1
	)

	-- Decal starts invisible.
	front.Transparency = 1
	back.Transparency = 1

	--==================================================
	-- STAGE 1 APPEAR
	--==================================================

	local appearInfo =
		TweenInfo.new(
			0.15,
			Enum.EasingStyle.Sine,
			Enum.EasingDirection.Out
		)

	local frontAppear =
		TweenService:Create(
			front,
			appearInfo,
			{
				Transparency = 0
			}
		)

	local backAppear =
		TweenService:Create(
			back,
			appearInfo,
			{
				Transparency = 0
			}
		)

	frontAppear:Play()
	backAppear:Play()

	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 2
	--==================================================

	setImage(
		front,
		back,
		PortalBuild.Decals.Stage2
	)

	-- Brief scale-like effect using transparency.
	front.Transparency = 0
	back.Transparency = 0

	-- Hold Stage 2
	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 3
	--==================================================

	setImage(
		front,
		back,
		PortalBuild.Decals.Stage3
	)

	front.Transparency = 0
	back.Transparency = 0

	--==================================================
	-- FINAL WAIT
	--==================================================

	task.wait(
		PortalBuild.FinalHoldTime
	)

	--==================================================
	-- ROTATION
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
	-- DESTROY AFTER 20 SECONDS
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
	-- RETURN
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
