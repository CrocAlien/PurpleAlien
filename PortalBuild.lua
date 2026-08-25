local PortalBuild = {}

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--==================================================
-- IMAGES
--==================================================

PortalBuild.Images = {
	Stage1 = "rbxassetid://82149604426664",
	Stage2 = "rbxassetid://96231048684434",
	Stage3 = "rbxassetid://119880285735898"
}

--==================================================
-- SIZE
--==================================================

PortalBuild.PortalWidth = 5
PortalBuild.PortalHeight = 8

PortalBuild.HitboxWidth = 5
PortalBuild.HitboxHeight = 8
PortalBuild.HitboxThickness = 0.15

--==================================================
-- TIMING
--==================================================

-- Original was 0.5.
-- Everything involved in the opening is now 3x slower.

PortalBuild.StageHoldTime = 1.5
PortalBuild.StageGrowTime = 1.5
PortalBuild.FinalHoldTime = 3

-- How long the completed portal remains.
PortalBuild.Lifetime = 20

-- One complete rotation.
PortalBuild.RotationTime = 8

--==================================================
-- FOLDER
--==================================================

local PortalFolder =
	Workspace:FindFirstChild("PurpleAlien_Portals")

if not PortalFolder then

	PortalFolder = Instance.new("Folder")

	PortalFolder.Name =
		"PurpleAlien_Portals"

	PortalFolder.Parent =
		Workspace

end

--==================================================
-- VISUAL PART
--==================================================

local function createPortalPart(cframe)

	local part =
		Instance.new("Part")

	part.Name =
		"PortalVisual"

	-- Keep the Part at its final size.
	-- The IMAGE itself will be animated.
	part.Size =
		Vector3.new(
			PortalBuild.PortalWidth,
			PortalBuild.PortalHeight,
			0.05
		)

	part.CFrame =
		cframe

	part.Anchored =
		true

	part.CanCollide =
		false

	part.CanTouch =
		false

	part.CanQuery =
		false

	part.Transparency =
		1

	part.Parent =
		PortalFolder

	return part
end

--==================================================
-- HITBOX
--==================================================

local function createHitbox(cframe)

	local hitbox =
		Instance.new("Part")

	hitbox.Name =
		"PortalHitbox"

	hitbox.Size =
		Vector3.new(
			PortalBuild.HitboxWidth,
			PortalBuild.HitboxHeight,
			PortalBuild.HitboxThickness
		)

	hitbox.CFrame =
		cframe

	hitbox.Anchored =
		true

	hitbox.CanCollide =
		false

	hitbox.CanTouch =
		true

	hitbox.CanQuery =
		true

	hitbox.Transparency =
		1

	hitbox.Parent =
		PortalFolder

	return hitbox
end

--==================================================
-- IMAGE SURFACE
--==================================================

local function createImageSurface(
	portal,
	face
)

	local surface =
		Instance.new("SurfaceGui")

	surface.Name =
		"PortalSurface"

	surface.Face =
		face

	surface.AlwaysOnTop =
		true

	surface.LightInfluence =
		0

	surface.SizingMode =
		Enum.SurfaceGuiSizingMode.PixelsPerStud

	surface.PixelsPerStud =
		100

	surface.Parent =
		portal

	local image =
		Instance.new("ImageLabel")

	image.Name =
		"PortalImage"

	image.BackgroundTransparency =
		1

	image.AnchorPoint =
		Vector2.new(
			0.5,
			0.5
		)

	-- Start tiny.
	image.Position =
		UDim2.fromScale(
			0.5,
			0.5
		)

	image.Size =
		UDim2.fromScale(
			0.01,
			0.01
		)

	image.ScaleType =
		Enum.ScaleType.Stretch

	image.ImageTransparency =
		0

	image.Parent =
		surface

	return image
end

--==================================================
-- CHANGE IMAGE
--==================================================

local function setImage(
	front,
	back,
	image
)

	front.Image =
		image

	back.Image =
		image

end

--==================================================
-- TWEEN IMAGE SIZE
--==================================================

local function growImage(
	front,
	back,
	scale
)

	local info =
		TweenInfo.new(
			PortalBuild.StageGrowTime,

			Enum.EasingStyle.Elastic,

			Enum.EasingDirection.Out
		)

	local goal =
		UDim2.fromScale(
			scale,
			scale
		)

	local frontTween =
		TweenService:Create(
			front,
			info,
			{
				Size = goal
			}
		)

	local backTween =
		TweenService:Create(
			back,
			info,
			{
				Size = goal
			}
		)

	frontTween:Play()
	backTween:Play()

	frontTween.Completed:Wait()
end

--==================================================
-- CREATE PORTAL
--==================================================

function PortalBuild.Create(
	cframe,
	portalType
)

	portalType =
		portalType or "Position"

	--==================================================
	-- OBJECTS
	--==================================================

	local portal =
		createPortalPart(
			cframe
		)

	local hitbox =
		createHitbox(
			cframe
		)

	local front =
		createImageSurface(
			portal,
			Enum.NormalId.Front
		)

	local back =
		createImageSurface(
			portal,
			Enum.NormalId.Back
		)

	--==================================================
	-- STAGE 1
	--==================================================

	setImage(
		front,
		back,
		PortalBuild.Images.Stage1
	)

	-- Tiny crack
	front.Size =
		UDim2.fromScale(
			0.15,
			0.15
		)

	back.Size =
		UDim2.fromScale(
			0.15,
			0.15
		)

	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 2
	--==================================================

	setImage(
		front,
		back,
		PortalBuild.Images.Stage2
	)

	growImage(
		front,
		back,
		0.65
	)

	task.wait(
		PortalBuild.StageHoldTime
	)

	--==================================================
	-- STAGE 3
	--==================================================

	setImage(
		front,
		back,
		PortalBuild.Images.Stage3
	)

	growImage(
		front,
		back,
		1
	)

	--==================================================
	-- FINAL HOLD
	--==================================================

	task.wait(
		PortalBuild.FinalHoldTime
	)

	--==================================================
	-- ROTATION
	--==================================================

	local rotating =
		true

	task.spawn(function()

		while rotating
			and portal.Parent do

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

			rotating =
				false

			if portal
				and portal.Parent then

				portal:Destroy()

			end

			if hitbox
				and hitbox.Parent then

				hitbox:Destroy()

			end

		end
	)

	--==================================================
	-- RETURN
	--==================================================

	return {

		Portal =
			portal,

		Hitbox =
			hitbox,

		Front =
			front,

		Back =
			back,

		Destroy =
			function()

				rotating =
					false

				if portal
					and portal.Parent then

					portal:Destroy()

				end

				if hitbox
					and hitbox.Parent then

					hitbox:Destroy()

				end

			end
	}
end

return PortalBuild
