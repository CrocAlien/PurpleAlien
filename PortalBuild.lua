local PortalBuild = {}

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--==================================================
-- CONFIG
--==================================================

PortalBuild.Images = {
	Stage1 = "rbxassetid://82149604426664",
	Stage2 = "rbxassetid://96231048684434",
	Stage3 = "rbxassetid://119880285735898"
}

-- Portal's final physical size
PortalBuild.PortalWidth = 5
PortalBuild.PortalHeight = 8

-- Invisible hitbox
PortalBuild.HitboxWidth = 5
PortalBuild.HitboxHeight = 8
PortalBuild.HitboxThickness = 0.15

-- Animation
PortalBuild.StageHoldTime = 0.5
PortalBuild.StageGrowTime = 0.5
PortalBuild.FinalHoldTime = 1

-- Lifetime AFTER the portal finishes opening
PortalBuild.Lifetime = 20

-- One complete rotation
PortalBuild.RotationTime = 8

--==================================================
-- FOLDER
--==================================================

local PortalFolder = Workspace:FindFirstChild("PurpleAlien_Portals")

if not PortalFolder then
	PortalFolder = Instance.new("Folder")
	PortalFolder.Name = "PurpleAlien_Portals"
	PortalFolder.Parent = Workspace
end

--==================================================
-- CREATE VISUAL PART
--==================================================

local function createPortalPart(cframe)

	local part = Instance.new("Part")

	part.Name = "PortalVisual"

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

	-- Completely invisible.
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
-- CREATE IMAGE SURFACE
--==================================================

local function createImageSurface(portal, face)

	local surface = Instance.new("SurfaceGui")

	surface.Name = "PortalSurface"

	surface.Face = face

	surface.AlwaysOnTop = true

	surface.LightInfluence = 0

	surface.SizingMode =
		Enum.SurfaceGuiSizingMode.PixelsPerStud

	surface.PixelsPerStud = 100

	surface.Parent = portal

	local image = Instance.new("ImageLabel")

	image.Name = "PortalImage"

	image.BackgroundTransparency = 1

	image.Size = UDim2.fromScale(1, 1)

	image.Position = UDim2.fromScale(0, 0)

	image.AnchorPoint = Vector2.new(0, 0)

	image.ScaleType = Enum.ScaleType.Stretch

	image.ImageTransparency = 0

	image.Parent = surface

	return surface, image
end

--==================================================
-- SET IMAGE
--==================================================

local function setImage(frontImage, backImage, asset)

	frontImage.Image = asset
	backImage.Image = asset

end

--==================================================
-- CREATE PORTAL
--==================================================

function PortalBuild.Create(cframe, portalType)

	portalType = portalType or "Position"

	--==================================================
	-- CREATE
	--==================================================

	local portal =
		createPortalPart(cframe)

	local hitbox =
		createHitbox(cframe)

	local frontSurface, frontImage =
		createImageSurface(
			portal,
			Enum.NormalId.Front
		)

	local backSurface, backImage =
		createImageSurface(
			portal,
			Enum.NormalId.Back
		)

	--==================================================
	-- START SMALL
	--==================================================

	portal.Size = Vector3.new(
		0.5,
		0.5,
		0.05
	)

	setImage(
		frontImage,
		backImage,
		PortalBuild.Images.Stage1
	)

	frontImage.ImageTransparency = 0
	backImage.ImageTransparency = 0

	--==================================================
	-- STAGE 1
	--==================================================

	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 2
	--==================================================

	setImage(
		frontImage,
		backImage,
		PortalBuild.Images.Stage2
	)

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
					0.05
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

	setImage(
		frontImage,
		backImage,
		PortalBuild.Images.Stage3
	)

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
					0.05
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

		Front = frontImage,
		Back = backImage,

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
