local CustomSkin = {}

--==================================================
-- HUMANOID DESCRIPTION PROPERTIES
--==================================================

CustomSkin.Properties = {
	-- Accessories
	BackAccessory = "",
	FaceAccessory = "",
	FrontAccessory = "",
	HairAccessory = "",
	HatAccessory = "",
	NeckAccessory = "",
	ShouldersAccessory = "",
	WaistAccessory = "",

	-- Classic clothing
	Shirt = 0,
	Pants = 0,
	GraphicTShirt = 0,

	-- Body parts
	Face = 0,
	Head = 0,
	LeftArm = 0,
	LeftLeg = 0,
	RightArm = 0,
	RightLeg = 0,
	Torso = 0,

	-- Body colors
	HeadColor = Color3.fromRGB(255, 204, 153),
	LeftArmColor = Color3.fromRGB(255, 204, 153),
	LeftLegColor = Color3.fromRGB(255, 204, 153),
	RightArmColor = Color3.fromRGB(255, 204, 153),
	RightLegColor = Color3.fromRGB(255, 204, 153),
	TorsoColor = Color3.fromRGB(255, 204, 153),

	-- Body scales
	BodyTypeScale = 0,
	DepthScale = 1,
	HeadScale = 1,
	HeightScale = 1,
	ProportionScale = 0,
	WidthScale = 1,

	-- Animations
	ClimbAnimation = 0,
	FallAnimation = 0,
	IdleAnimation = 0,
	JumpAnimation = 0,
	RunAnimation = 0,
	SwimAnimation = 0,
	WalkAnimation = 0
}

--==================================================
-- CREATE DESCRIPTION
--==================================================

function CustomSkin.Create()
	local description = Instance.new("HumanoidDescription")

	for property, value in pairs(CustomSkin.Properties) do
		pcall(function()
			description[property] = value
		end)
	end

	return description
end

return CustomSkin
