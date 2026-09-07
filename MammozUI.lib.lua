--[[
	MammozUI - reusable sidebar UI library for Roblox Luau.
	Uses the MAMMOZ HUB blue dashboard design and compatibility contracts.

	API:
		local UI = loadstring(...)()
		local Window = UI:CreateWindow({ Title="My Hub", Accent=Color3..., Size=UDim2... })

		local Page = Window:CreatePage("Key System", "code")   -- icon: code|search|gear|user|shield|star
		local Card = Page:CreateCard("Verify Access")
		Card:AddLabel("text", true)                 -- note=true => dim small
		Card:AddButton("Verify Key", function() end)
		Card:AddInput({Placeholder="...", Masked=true}, function(text, focused) end)
		Card:AddToggle("Remember me", false, function(on) end)
		Card:AddSlider("Speed", 0, 100, 50, function(val) end)
		Card:AddDropdown("Mode", {"A","B","C"}, "A", function(val) end)

		Window:Notify("Title", "Body", "success"|"error"|"primary")
		Window:SelectPage(Page)
		Window:Destroy()

	Mobile: touch drag, auto-collapse sidebar, responsive scaling, larger tap targets.
	No key-gate / anti-tamper / payload logic — pure UI.
]]

local MammozUI = {}

-- ===== services =====
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

-- ===== theme =====
local DEFAULT_THEME = {
	Accent = Color3.fromRGB(39, 145, 255),
	AccentBright = Color3.fromRGB(83, 193, 255),
	Window = Color3.fromRGB(4, 12, 26),
	WindowBottom = Color3.fromRGB(1, 5, 14),
	Header = Color3.fromRGB(5, 15, 32),
	HeaderBottom = Color3.fromRGB(2, 8, 19),
	Sidebar = Color3.fromRGB(6, 20, 41),
	SidebarBottom = Color3.fromRGB(2, 10, 23),
	WindowLine = Color3.fromRGB(35, 113, 188),
	Divider = Color3.fromRGB(30, 81, 132),
	Card = Color3.fromRGB(11, 31, 56),
	CardBottom = Color3.fromRGB(5, 18, 35),
	CardLine = Color3.fromRGB(30, 81, 132),
	Element = Color3.fromRGB(10, 34, 62),
	ElementHover = Color3.fromRGB(16, 47, 82),
	ElementLine = Color3.fromRGB(30, 81, 132),
	Field = Color3.fromRGB(3, 13, 29),
	FieldRaised = Color3.fromRGB(10, 34, 62),
	NavActive = Color3.fromRGB(15, 45, 80),
	Title = Color3.fromRGB(235, 247, 255),
	Value = Color3.fromRGB(226, 243, 255),
	Label = Color3.fromRGB(180, 209, 232),
	NavIdle = Color3.fromRGB(190, 219, 242),
	Dim = Color3.fromRGB(105, 145, 179),
	Primary = Color3.fromRGB(83, 193, 255),
	Success = Color3.fromRGB(61, 224, 167),
	Error = Color3.fromRGB(255, 104, 119),
	Gold = Color3.fromRGB(247, 191, 72),
}

-- ===== tween infos =====
local TI_FAST = TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_MED = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_SMOOTH = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ===== icon geometry (14x14 grid) =====
local ICONS = {
	code = {
		{ "bar", -0.9, 4.2, 6.4, 1.4, -58 },
		{ "bar", -0.9, 8.4, 6.4, 1.4, 58 },
		{ "bar", 8.5, 4.2, 6.4, 1.4, 58 },
		{ "bar", 8.5, 8.4, 6.4, 1.4, -58 },
		{ "bar", 6.3, 1.4, 1.4, 11.2, 18 },
	},
	search = {
		{ "ring", 0.6, 0.6, 10.2 },
		{ "bar", 9.1, 9.1, 4.9, 1.5, 45 },
	},
	gear = {
		{ "ring", 4.2, 4.2, 6.4 },
		{ "bar", 6.3, 0.4, 1.4, 2.2, 0 },
		{ "bar", 6.3, 11.4, 1.4, 2.2, 0 },
		{ "bar", 0.4, 6.3, 2.2, 1.4, 0 },
		{ "bar", 11.4, 6.3, 2.2, 1.4, 0 },
	},
	user = {
		{ "ring", 4.2, 0.6, 4.2 },
		{ "ring", 1.4, 5.6, 11.2 },
	},
	shield = {
		{ "bar", 2.1, 1.4, 9.8, 1.4, 0 },
		{ "bar", 2.1, 1.4, 1.4, 9.8, 0 },
		{ "bar", 11.5, 1.4, 1.4, 9.8, 0 },
		{ "bar", 2.1, 11.2, 9.8, 1.4, 0 },
	},
	star = {
		{ "bar", 6.3, 1.0, 1.4, 5.0, 0 },
		{ "bar", 6.3, 1.0, 5.0, 1.4, 30 },
	},
	home = {
		{ "bar", 1.4, 4.5, 11.2, 1.4, 30 },
		{ "bar", 1.4, 4.5, 1.4, 7.0, 0 },
		{ "bar", 11.2, 4.5, 1.4, 7.0, 0 },
		{ "bar", 1.4, 11.2, 11.2, 1.4, 0 },
	},
}

-- ===== helpers =====
local function make(className, properties, parent)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function corner(object, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 7) }, object)
end

local function stroke(object, color, transparency, thickness)
	return make("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	}, object)
end

local function tween(object, info, properties)
	if not object then
		return nil
	end
	local ok, value = pcall(function()
		local animation = TweenService:Create(object, info, properties)
		animation:Play()
		return animation
	end)
	if not ok then
		-- Some executors fail to tween certain properties (e.g. CanvasGroup
		-- GroupTransparency). Falling back to a direct set keeps elements at
		-- their intended final state instead of getting stuck faded out.
		pcall(function()
			for property, finalValue in pairs(properties) do
				object[property] = finalValue
			end
		end)
	end
	return ok and value or nil
end

local function reportCallbackError(context, err)
	local environment = (getgenv and getgenv()) or _G
	local reporter = environment and environment.__MAMMOZ_REPORT_ERROR
	if type(reporter) == "function" then
		pcall(reporter, tostring(context or "Mammoz UI"), tostring(err or "Unknown error"))
	elseif type(warn) == "function" then
		warn(("[Mammoz] %s: %s"):format(tostring(context or "Mammoz UI"), tostring(err or "Unknown error")))
	end
end

local function invokeCallback(context, callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local args = table.pack(...)
	local ok, err = xpcall(function()
		callback(table.unpack(args, 1, args.n))
	end, function(message)
		return debug and debug.traceback and debug.traceback(tostring(message), 2) or tostring(message)
	end)
	if not ok then
		reportCallbackError(context, err)
	end
end

local function spawnCallback(context, callback, ...)
	local args = table.pack(...)
	task.spawn(function()
		invokeCallback(context, callback, table.unpack(args, 1, args.n))
	end)
end

local function spaceOut(text: string)
	local output = {}
	for index = 1, #text do
		output[#output + 1] = text:sub(index, index)
	end
	return table.concat(output, " ")
end

local function isTouchDevice()
	-- Roblox reports touch capability on phones/tablets
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local function viewport()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(1920, 1080)
end

-- ===== icon renderer =====
local function renderIcon(parent, name, size, color)
	local box = make("Frame", {
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		ZIndex = parent.ZIndex + 1,
	}, parent)
	local fills = {}
	local outlines = {}
	for _, partInfo in ipairs(ICONS[name] or ICONS.code) do
		local kind = partInfo[1]
		local outline = kind == "ring"
		local height = outline and partInfo[4] or partInfo[5]
		local part = make("Frame", {
			BackgroundColor3 = color,
			BackgroundTransparency = outline and 1 or 0,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(partInfo[2] / 14, partInfo[3] / 14),
			Size = UDim2.fromScale(partInfo[4] / 14, height / 14),
			Rotation = kind == "bar" and (partInfo[6] or 0) or 0,
			ZIndex = box.ZIndex,
		}, box)
		corner(part, outline and 999 or 1)
		if outline then
			outlines[#outlines + 1] = stroke(part, color, 0, math.max(1, 1.35 * size / 14))
		else
			fills[#fills + 1] = part
		end
	end
	local function setColor(nextColor, info)
		for _, part in ipairs(fills) do
			tween(part, info or TI_MED, { BackgroundColor3 = nextColor })
		end
		for _, line in ipairs(outlines) do
			tween(line, info or TI_MED, { Color = nextColor })
		end
	end
	return box, setColor
end

local function makeChevron(parent, width, color)
	local box = make("Frame", {
		Name = "Chevron",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(width, width * 0.62),
		ZIndex = parent.ZIndex + 1,
	}, parent)
	local bars = {}
	for index, rotation in ipairs({ 38, -38 }) do
		bars[index] = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(index == 1 and 0.29 or 0.71, 0.44),
			Size = UDim2.fromOffset(width * 0.6, 1.5),
			Rotation = rotation,
			ZIndex = box.ZIndex,
		}, box)
		corner(bars[index], 1)
	end
	local function setColor(nextColor)
		for _, bar in ipairs(bars) do
			tween(bar, TI_FAST, { BackgroundColor3 = nextColor })
		end
	end
	return box, setColor
end

local function drawElephantLogo(parent)
	local logo = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(7, 7),
		Size = UDim2.fromOffset(46, 42),
		ZIndex = parent.ZIndex + 1,
	}, parent)
	-- Accent halo behind the elephant so the blue body stands out against the
	-- dark chip background instead of blending into it.
	local halo = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.fromOffset(46, 46),
		BackgroundColor3 = Color3.fromRGB(120, 200, 255),
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0,
		ZIndex = logo.ZIndex - 1,
	}, logo)
	corner(halo, 999)
	local outline = Color3.fromRGB(219, 244, 255)
	local body = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(74, 174, 240),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(5, 14),
		Size = UDim2.fromOffset(28, 17),
		ZIndex = logo.ZIndex,
	}, logo)
	corner(body, 8)
	stroke(body, outline, 0, 1)
	local head = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(100, 200, 252),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(27, 9),
		Size = UDim2.fromOffset(17, 21),
		ZIndex = logo.ZIndex + 2,
	}, logo)
	corner(head, 9)
	stroke(head, outline, 0, 1)
	local ear = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(45, 124, 200),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(22, 12),
		Size = UDim2.fromOffset(14, 16),
		ZIndex = logo.ZIndex + 3,
	}, logo)
	corner(ear, 8)
	stroke(ear, outline, 0, 1)
	local trunk = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(40, 118, 190),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(38, 23),
		Size = UDim2.fromOffset(6, 11),
		ZIndex = logo.ZIndex + 2,
	}, logo)
	corner(trunk, 5)
	stroke(trunk, outline, 0, 1)
	local tusk = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(35, 24),
		Rotation = -16,
		Size = UDim2.fromOffset(10, 3),
		ZIndex = logo.ZIndex + 4,
	}, logo)
	corner(tusk, 3)
	local eye = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(2, 13, 26),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(37, 15),
		Size = UDim2.fromOffset(3, 3),
		ZIndex = logo.ZIndex + 4,
	}, logo)
	corner(eye, 3)
	for _, x in ipairs({ 10, 25 }) do
		local leg = make("Frame", {
			BackgroundColor3 = Color3.fromRGB(50, 140, 212),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, 27),
			Size = UDim2.fromOffset(5, 8),
			ZIndex = logo.ZIndex,
		}, logo)
		corner(leg, 3)
		stroke(leg, outline, 0, 1)
	end
	return logo
end

-- ===== window =====
local Window = {}
Window.__index = Window

-- forward declarations (assigned below) so Window methods can reference them
local Page, Card

-- Animated walking/jumping elephant scene, ported from Loader's
-- BuildElephantMascot so the restore chip shows the same mascot (trees, moon,
-- mud puddle, jump + landing dust) instead of a static logo. `window` is the
-- Window that owns the mascot (for theme + bind); `parent` is the container.
local function buildElephantMascot(window, parent, opts)
	opts = opts or {}
	local function uiMake(className, properties, par)
		return make(className, properties, par or parent)
	end
	local function uiCorner(obj, radius)
		return corner(obj, radius)
	end
	local function uiStroke(obj, color, thickness, transparency)
		-- MammozUI stroke() signature is (obj, color, transparency, thickness).
		return stroke(obj, color, transparency, thickness)
	end
	-- Adapter self so the ported body can reference self.Theme / self.TweenService
	-- / self:IsLowEffects() / self:HudEffectsAllowed() verbatim.
	local self = {
		TweenService = TweenService,
		Theme = {
			Root = window.theme.Window,
			Accent = window.theme.Accent,
			AccentHover = window.theme.AccentBright,
			StrokeSoft = window.theme.Divider,
			Success = window.theme.Success,
		},
		IsLowEffects = function()
			return false
		end,
		HudEffectsAllowed = function()
			return parent.Visible
		end,
	}
	local alwaysAnimate = opts.AlwaysAnimate == true
	local lowEffects = opts.LowEffects == true
	local animateAllowed = function()
		return alwaysAnimate or self:HudEffectsAllowed()
	end

	local mascotPanel = uiMake("Frame", {
		Name = opts.Name or "AnimatedMascot",
		AnchorPoint = opts.AnchorPoint or Vector2.new(0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = opts.Position or UDim2.new(0, 0, 0, 0),
		Size = opts.Size or UDim2.new(1, 0, 1, 0),
	}, parent)

	for index = 1, 7 do
		uiMake("Frame", {
			BackgroundColor3 = index % 2 == 0 and self.Theme.Accent or self.Theme.StrokeSoft,
			BackgroundTransparency = 0.88,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(10 + index * 22, 18 + ((index * 19) % 44)),
			Size = UDim2.fromOffset(10 + (index % 3) * 12, 1),
			ZIndex = mascotPanel.ZIndex + 1,
		}, mascotPanel)
	end

	local moon = uiMake("Frame", {
		Name = "CrescentMoon",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(116, 7),
		Size = UDim2.fromOffset(30, 30),
		ZIndex = mascotPanel.ZIndex + 1,
	}, mascotPanel)
	local moonGlow = uiMake("Frame", {
		BackgroundColor3 = Color3.fromRGB(112, 211, 255),
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(1, 1),
		Size = UDim2.fromOffset(24, 24),
		ZIndex = moon.ZIndex,
	}, moon)
	uiCorner(moonGlow, 999)
	local moonBody = uiMake("Frame", {
		BackgroundColor3 = Color3.fromRGB(219, 244, 255),
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(5, 4),
		Size = UDim2.fromOffset(18, 18),
		ZIndex = moon.ZIndex + 1,
	}, moon)
	uiCorner(moonBody, 999)
	local moonCut = uiMake("Frame", {
		BackgroundColor3 = self.Theme.Root,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(11, 2),
		Size = UDim2.fromOffset(18, 20),
		ZIndex = moon.ZIndex + 2,
	}, moon)
	uiCorner(moonCut, 999)
	if not lowEffects then
		task.spawn(function()
			while moonGlow.Parent do
				if animateAllowed() then
					self.TweenService:Create(moonGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						BackgroundTransparency = 0.58,
						Size = UDim2.fromOffset(28, 28),
					}):Play()
					task.wait(1.8)
					if not moonGlow.Parent then
						break
					end
					self.TweenService:Create(moonGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						BackgroundTransparency = 0.78,
						Size = UDim2.fromOffset(24, 24),
					}):Play()
					task.wait(1.8)
				else
					task.wait(0.25)
				end
			end
		end)
	end

	local shadow = uiMake("Frame", {
		Name = "ElephantShadow",
		BackgroundColor3 = self.Theme.Accent,
		BackgroundTransparency = 0.72,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(58, 90),
		Size = UDim2.fromOffset(86, 8),
		ZIndex = mascotPanel.ZIndex + 2,
	}, mascotPanel)
	uiCorner(shadow, 999)

	local mudPuddle = uiMake("Frame", {
		Name = "JumpMudPuddle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(68, 86),
		Size = UDim2.fromOffset(56, 18),
		ZIndex = mascotPanel.ZIndex + 1,
	}, mascotPanel)
	local mudDark = Color3.fromRGB(62, 43, 33)
	local mudMid = Color3.fromRGB(112, 75, 45)
	local mudLight = Color3.fromRGB(174, 119, 63)
	local function mudPixel(name, x, y, w, h, color, transparency, z)
		local patch = uiMake("Frame", {
			Name = name,
			BackgroundColor3 = color,
			BackgroundTransparency = transparency or 0,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			ZIndex = mudPuddle.ZIndex + (z or 1),
		}, mudPuddle)
		uiCorner(patch, 3)
		return patch
	end
	mudPixel("MudShadow", 5, 8, 46, 7, mudDark, 0.08, 1)
	mudPixel("MudBody", 0, 5, 56, 10, mudMid, 0.04, 2)
	mudPixel("MudLeft", 7, 2, 14, 6, mudMid, 0.12, 2)
	mudPixel("MudRight", 38, 3, 13, 6, mudMid, 0.16, 2)
	local mudShine = mudPixel("MudWetShine", 13, 7, 26, 2, mudLight, 0.34, 3)
	mudPixel("MudDropA", 2, 13, 4, 3, mudDark, 0.14, 1)
	mudPixel("MudDropB", 50, 12, 4, 3, mudDark, 0.18, 1)
	mudPixel("MudSplashA", 15, 0, 3, 2, mudLight, 0.18, 3)
	mudPixel("MudSplashB", 41, 1, 4, 2, mudLight, 0.22, 3)
	if not lowEffects then
		task.spawn(function()
			while mudPuddle.Parent and mudShine.Parent do
				if animateAllowed() then
					self.TweenService:Create(mudShine, TweenInfo.new(0.82, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						BackgroundTransparency = 0.16,
						Size = UDim2.fromOffset(32, 2),
					}):Play()
					task.wait(0.82)
					if not (mudPuddle.Parent and mudShine.Parent) then
						break
					end
					self.TweenService:Create(mudShine, TweenInfo.new(1.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						BackgroundTransparency = 0.46,
						Size = UDim2.fromOffset(22, 2),
					}):Play()
					task.wait(1.05)
				else
					task.wait(0.25)
				end
			end
		end)
	end

	local treeGreen = Color3.fromRGB(66, 218, 167)
	local treeGreenDark = Color3.fromRGB(25, 102, 85)
	local treeTrunk = Color3.fromRGB(113, 79, 48)
	local function treePixel(parentTree, x, y, w, h, color, z, transparency)
		local block = uiMake("Frame", {
			BackgroundColor3 = color,
			BackgroundTransparency = transparency or 0,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			ZIndex = z,
		}, parentTree)
		uiCorner(block, 2)
		return block
	end
	local function buildTree(name, x, scale, y, flatZ, transparency)
		local treeZ = flatZ or (mascotPanel.ZIndex + 6)
		local function treeZIndex(offset)
			if flatZ then
				return flatZ
			end
			return treeZ + offset
		end
		local tree = uiMake("Frame", {
			Name = name,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(x, y or 31),
			Size = UDim2.fromOffset(58 * scale, 76),
			ZIndex = treeZ,
		}, mascotPanel)
		treePixel(tree, 23 * scale, 40, 10 * scale, 30, treeTrunk, treeZIndex(1), transparency)
		treePixel(tree, 8 * scale, 34, 40 * scale, 14, treeGreenDark, treeZIndex(2), transparency)
		treePixel(tree, 2 * scale, 23, 52 * scale, 18, treeGreen, treeZIndex(3), transparency)
		treePixel(tree, 11 * scale, 11, 34 * scale, 18, treeGreen, treeZIndex(4), transparency)
		treePixel(tree, 21 * scale, 2, 16 * scale, 14, Color3.fromRGB(112, 238, 196), treeZIndex(5), transparency)
		treePixel(tree, 0, 68, 58 * scale, 5, treeGreenDark, treeZIndex(6), transparency)
		return tree
	end
	local leftTree = buildTree("LeftPixelTree", -4, 1)
	local rightTree = buildTree("RightPixelTree", 146, 1)
	local function animateTree(tree, firstPosition, secondPosition)
		if lowEffects then
			return
		end
		task.spawn(function()
			while tree.Parent do
				if animateAllowed() then
					self.TweenService:Create(tree, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Position = secondPosition,
					}):Play()
					task.wait(1.4)
					if not tree.Parent then
						break
					end
					self.TweenService:Create(tree, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Position = firstPosition,
					}):Play()
					task.wait(1.4)
				else
					task.wait(0.25)
				end
			end
		end)
	end
	animateTree(leftTree, UDim2.fromOffset(-4, 31), UDim2.fromOffset(-6, 29))
	animateTree(rightTree, UDim2.fromOffset(146, 31), UDim2.fromOffset(148, 33))

	local pet = uiMake("Frame", {
		Name = "PixelElephantPet",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(44, 20),
		Size = UDim2.fromOffset(104, 70),
		ZIndex = mascotPanel.ZIndex + 2,
	}, mascotPanel)

	local pixelBlue = Color3.fromRGB(91, 190, 255)
	local pixelBlueDark = Color3.fromRGB(31, 92, 150)
	local pixelPink = Color3.fromRGB(255, 172, 214)
	local trunkColor = Color3.fromRGB(129, 196, 236)
	local trunkShade = Color3.fromRGB(56, 121, 176)
	local rearShadeColor = Color3.fromRGB(49, 126, 190)
	local tailBaseColor = Color3.fromRGB(255, 116, 153)
	local tailColor = Color3.fromRGB(255, 174, 198)
	local tailTipColor = Color3.fromRGB(255, 224, 104)

	local function pixel(name, x, y, w, h, color, z)
		local block = uiMake("Frame", {
			Name = name,
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			ZIndex = pet.ZIndex + (z or 1),
		}, pet)
		uiCorner(block, 2)
		return block
	end

	local ivory = Color3.fromRGB(255, 245, 207)
	local rearCurve = pixel("RearCurve", 24, 31, 12, 20, pixelBlue, 0)
	local rearShade = pixel("RearShade", 24, 45, 7, 7, rearShadeColor, 1)
	rearShade.BackgroundTransparency = 0.12
	local body = pixel("Body", 31, 25, 42, 29, pixelBlue, 1)
	local head = pixel("Head", 64, 16, 27, 29, pixelBlue, 3)
	local leftEar = pixel("LeftEar", 20, 22, 20, 24, pixelBlueDark, 0)
	local rightEar = pixel("RightEar", 79, 18, 17, 23, pixelBlueDark, 2)
	local earInner = pixel("EarInner", 23, 29, 10, 10, pixelPink, 1)
	earInner.BackgroundTransparency = 0.18
	local trunkRoot = pixel("TrunkRoot", 87, 31, 8, 8, trunkColor, 9)
	local trunkTop = pixel("TrunkTop", 90, 38, 8, 12, trunkColor, 9)
	local trunkEnd = pixel("TrunkEnd", 89, 49, 9, 7, trunkColor, 9)
	local trunkTip = pixel("TrunkTip", 84, 54, 12, 5, trunkShade, 9)
	local tusk = pixel("Tusk", 86, 39, 14, 4, ivory, 12)
	local tuskHighlight = pixel("TuskHighlight", 88, 39, 9, 1, Color3.fromRGB(255, 255, 232), 13)
	local backLeg = pixel("BackLeg", 33, 52, 8, 12, pixelBlueDark, 0)
	local backLegAlt = pixel("BackLegAlt", 45, 52, 8, 12, pixelBlueDark, 0)
	local frontLeg = pixel("FrontLeg", 58, 52, 8, 12, pixelBlueDark, 0)
	local frontLegAlt = pixel("FrontLegAlt", 68, 52, 8, 12, pixelBlueDark, 0)
	local tailBase = pixel("TailBase", 22, 37, 5, 4, tailBaseColor, 4)
	local tail = pixel("Tail", 16, 38, 8, 3, tailColor, 4)
	local tailTip = pixel("TailTip", 12, 39, 4, 4, tailTipColor, 4)
	pixel("Eye", 76, 26, 4, 4, self.Theme.Root, 4)
	local cheek = pixel("Cheek", 82, 32, 5, 3, pixelPink, 4)
	cheek.BackgroundTransparency = 0.1
	local function tweenPart(part, duration, properties)
		if part and part.Parent then
			self.TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), properties):Play()
		end
	end

	local function walkPose(duration)
		duration = duration or 0.18
		tweenPart(rearCurve, duration, { Rotation = 0, Position = UDim2.fromOffset(24, 31) })
		tweenPart(rearShade, duration, { Rotation = 0, Position = UDim2.fromOffset(24, 45) })
		tweenPart(body, duration, { Rotation = 0, Position = UDim2.fromOffset(31, 25) })
		tweenPart(head, duration, { Rotation = 0, Position = UDim2.fromOffset(64, 16) })
		tweenPart(leftEar, duration, { Rotation = -4, Position = UDim2.fromOffset(20, 22) })
		tweenPart(rightEar, duration, { Rotation = 4, Position = UDim2.fromOffset(79, 18) })
		tweenPart(trunkRoot, duration, { Rotation = 0, Position = UDim2.fromOffset(87, 31) })
		tweenPart(trunkTop, duration, { Rotation = 0, Position = UDim2.fromOffset(90, 38) })
		tweenPart(trunkEnd, duration, { Rotation = 0, Position = UDim2.fromOffset(89, 49) })
		tweenPart(trunkTip, duration, { Rotation = 0, Position = UDim2.fromOffset(84, 54) })
		tweenPart(tusk, duration, { Rotation = 0, Position = UDim2.fromOffset(86, 39) })
		tweenPart(tuskHighlight, duration, { Rotation = 0, Position = UDim2.fromOffset(88, 39) })
		tweenPart(tailBase, duration, { Rotation = 0, Position = UDim2.fromOffset(22, 37) })
		tweenPart(tail, duration, { Rotation = 0, Position = UDim2.fromOffset(16, 38) })
		tweenPart(tailTip, duration, { Rotation = 0, Position = UDim2.fromOffset(12, 39) })
	end

	local function jumpPose()
		tweenPart(rearCurve, 0.14, { Rotation = -5, Position = UDim2.fromOffset(24, 28) })
		tweenPart(rearShade, 0.14, { Rotation = -5, Position = UDim2.fromOffset(24, 42) })
		tweenPart(body, 0.14, { Rotation = -5, Position = UDim2.fromOffset(31, 22) })
		tweenPart(head, 0.14, { Rotation = -7, Position = UDim2.fromOffset(63, 13) })
		tweenPart(leftEar, 0.14, { Rotation = -13, Position = UDim2.fromOffset(17, 22) })
		tweenPart(rightEar, 0.14, { Rotation = 12, Position = UDim2.fromOffset(82, 16) })
		tweenPart(trunkRoot, 0.14, { Rotation = -3, Position = UDim2.fromOffset(88, 28) })
		tweenPart(trunkTop, 0.14, { Rotation = -3, Position = UDim2.fromOffset(91, 35) })
		tweenPart(trunkEnd, 0.14, { Rotation = -5, Position = UDim2.fromOffset(90, 46) })
		tweenPart(trunkTip, 0.14, { Rotation = -8, Position = UDim2.fromOffset(84, 51) })
		tweenPart(tusk, 0.14, { Rotation = -5, Position = UDim2.fromOffset(87, 36) })
		tweenPart(tuskHighlight, 0.14, { Rotation = -5, Position = UDim2.fromOffset(89, 36) })
		tweenPart(tailBase, 0.14, { Rotation = -10, Position = UDim2.fromOffset(21, 34) })
		tweenPart(tail, 0.14, { Rotation = -16, Position = UDim2.fromOffset(15, 35) })
		tweenPart(tailTip, 0.14, { Rotation = -20, Position = UDim2.fromOffset(10, 37) })
	end

	local function setPart(part, properties)
		if part and part.Parent then
			for property, value in pairs(properties) do
				part[property] = value
			end
		end
	end

	local function holdJumpPose()
		setPart(pet, {
			Position = UDim2.fromOffset(50, 4),
		})
		setPart(shadow, {
			BackgroundTransparency = 0.93,
			Position = UDim2.fromOffset(76, 96),
			Size = UDim2.fromOffset(40, 4),
		})
		setPart(rearCurve, { Rotation = -5, Position = UDim2.fromOffset(24, 28) })
		setPart(rearShade, { Rotation = -5, Position = UDim2.fromOffset(24, 42) })
		setPart(body, { Rotation = -5, Position = UDim2.fromOffset(31, 22) })
		setPart(head, { Rotation = -7, Position = UDim2.fromOffset(63, 13) })
		setPart(leftEar, { Rotation = -13, Position = UDim2.fromOffset(17, 22) })
		setPart(rightEar, { Rotation = 12, Position = UDim2.fromOffset(82, 16) })
		setPart(trunkRoot, { Rotation = -3, Position = UDim2.fromOffset(88, 28) })
		setPart(trunkTop, { Rotation = -3, Position = UDim2.fromOffset(91, 35) })
		setPart(trunkEnd, { Rotation = -5, Position = UDim2.fromOffset(90, 46) })
		setPart(trunkTip, { Rotation = -8, Position = UDim2.fromOffset(84, 51) })
		setPart(tusk, { Rotation = -5, Position = UDim2.fromOffset(87, 36) })
		setPart(tuskHighlight, { Rotation = -5, Position = UDim2.fromOffset(89, 36) })
		setPart(backLeg, { Rotation = 16, Position = UDim2.fromOffset(33, 49) })
		setPart(backLegAlt, { Rotation = -14, Position = UDim2.fromOffset(46, 49) })
		setPart(frontLeg, { Rotation = -18, Position = UDim2.fromOffset(58, 49) })
		setPart(frontLegAlt, { Rotation = 14, Position = UDim2.fromOffset(69, 49) })
		setPart(tailBase, { Rotation = -10, Position = UDim2.fromOffset(21, 34) })
		setPart(tail, { Rotation = -16, Position = UDim2.fromOffset(15, 35) })
		setPart(tailTip, { Rotation = -20, Position = UDim2.fromOffset(10, 37) })
	end

	local function animateLeg(part, basePosition, baseRotation, activePosition, activeRotation)
		if lowEffects then
			return
		end
		task.spawn(function()
			while part.Parent do
				if animateAllowed() then
					self.TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Position = activePosition,
						Rotation = activeRotation,
					}):Play()
					task.wait(0.3)
					if not part.Parent then
						break
					end
					self.TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Position = basePosition,
						Rotation = baseRotation,
					}):Play()
					task.wait(0.3)
				else
					task.wait(0.25)
				end
			end
		end)
	end
	animateLeg(backLeg, UDim2.fromOffset(33, 52), 0, UDim2.fromOffset(31, 51), 12)
	animateLeg(backLegAlt, UDim2.fromOffset(45, 52), 0, UDim2.fromOffset(47, 54), -10)
	animateLeg(frontLeg, UDim2.fromOffset(58, 52), 0, UDim2.fromOffset(56, 54), -12)
	animateLeg(frontLegAlt, UDim2.fromOffset(68, 52), 0, UDim2.fromOffset(70, 51), 10)

	local function emitJumpSpeedLines(baseX, baseY)
		for index, data in ipairs({
			{ -18, 0, -34, -4, 28, 2 },
			{ -8, 12, -25, 9, 21, 2 },
			{ -24, 22, -42, 20, 16, 2 },
		}) do
			local line = uiMake("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = index == 1 and self.Theme.AccentHover or self.Theme.Accent,
				BackgroundTransparency = 0.18,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(baseX + data[1], baseY + data[2]),
				Size = UDim2.fromOffset(data[5], data[6]),
				ZIndex = pet.ZIndex - 1,
			}, mascotPanel)
			uiCorner(line, 999)
			self.TweenService:Create(line, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(baseX + data[3], baseY + data[4]),
				Size = UDim2.fromOffset(math.max(5, data[5] - 10), 1),
			}):Play()
			task.delay(0.28, function()
				if line.Parent then
					line:Destroy()
				end
			end)
		end
	end

	local function emitLandingDust(baseX, baseY)
		for index, data in ipairs({
			{ -22, 1, -35, -3, 5, 2 },
			{ -13, 0, -24, -5, 4, 3 },
			{ -4, 1, -8, -4, 4, 2 },
			{ 8, 0, 14, -5, 5, 2 },
			{ 17, 1, 29, -3, 4, 3 },
			{ 25, 2, 38, -1, 6, 2 },
		}) do
			local dust = uiMake("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = index % 3 == 0 and mudDark or (index % 2 == 0 and mudLight or mudMid),
				BackgroundTransparency = 0.16,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(baseX + data[1], baseY + data[2]),
				Size = UDim2.fromOffset(data[5], data[6]),
				ZIndex = pet.ZIndex - 1,
			}, mascotPanel)
			uiCorner(dust, 2)
			self.TweenService:Create(dust, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(baseX + data[3], baseY + data[4]),
				Size = UDim2.fromOffset(1, 1),
			}):Play()
			task.delay(0.42, function()
				if dust.Parent then
					dust:Destroy()
				end
			end)
		end
	end

	if lowEffects then
		holdJumpPose()
	else
		task.spawn(function()
			while mascotPanel.Parent and pet.Parent and shadow.Parent do
				if animateAllowed() then
					pet.Position = UDim2.fromOffset(-84, 24)
					shadow.Position = UDim2.fromOffset(-62, 92)
					shadow.Size = UDim2.fromOffset(78, 7)
					shadow.BackgroundTransparency = 0.74
					walkPose(0.05)

					self.TweenService:Create(pet, TweenInfo.new(1.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Position = UDim2.fromOffset(18, 24),
					}):Play()
					self.TweenService:Create(shadow, TweenInfo.new(1.9, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Position = UDim2.fromOffset(40, 92),
					}):Play()
					task.wait(1.9)
					if not pet.Parent then
						break
					end

					jumpPose()
					emitJumpSpeedLines(66, 52)
					self.TweenService:Create(pet, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						Position = UDim2.fromOffset(50, 4),
					}):Play()
					self.TweenService:Create(shadow, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0.93,
						Position = UDim2.fromOffset(76, 96),
						Size = UDim2.fromOffset(40, 4),
					}):Play()
					task.wait(0.28)
					if not pet.Parent then
						break
					end

					self.TweenService:Create(pet, TweenInfo.new(0.34, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						Position = UDim2.fromOffset(82, 24),
					}):Play()
					self.TweenService:Create(shadow, TweenInfo.new(0.34, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						BackgroundTransparency = 0.7,
						Position = UDim2.fromOffset(102, 91),
						Size = UDim2.fromOffset(84, 8),
					}):Play()
					task.wait(0.34)
					if not pet.Parent then
						break
					end

					emitLandingDust(136, 90)
					walkPose(0.16)
					self.TweenService:Create(pet, TweenInfo.new(1.62, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Position = UDim2.new(1, -12, 0, 24),
					}):Play()
					self.TweenService:Create(shadow, TweenInfo.new(1.62, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Position = UDim2.new(1, 8, 0, 92),
					}):Play()
					task.wait(1.72)
				else
					holdJumpPose()
					task.wait(0.25)
				end
			end
		end)
	end

	return mascotPanel
end

function MammozUI:CreateWindow(config)
	config = config or {}
	local self = setmetatable({
		theme = setmetatable({}, { __index = DEFAULT_THEME }),
		connections = {},
		pages = {},
		cards = {},
		cleaning = false,
		cleanups = {},
		activePopup = nil,
		visible = true,
		collapsed = false,
		maximized = false,
		touch = isTouchDevice(),
		callbacks = {},
	}, Window)

	if type(config.Theme) == "table" then
		for k, v in pairs(config.Theme) do
			self.theme[k] = v
		end
	end
	if config.Accent then
		self.theme.Accent = config.Accent
	end

	local T = self.theme
	local title = config.Title or "MAMMOZ HUB"
	local baseSize = config.Size or UDim2.fromOffset(1120, 700)

	-- responsive: shrink window on small viewports (mobile)
	local vp = viewport()
	local touch = self.touch
	local sizeOffset
	if touch or vp.X < 520 then
		sizeOffset = Vector2.new(math.min(baseSize.X.Offset, vp.X - 16), math.min(baseSize.Y.Offset, vp.Y - 16))
	else
		sizeOffset = Vector2.new(baseSize.X.Offset, baseSize.Y.Offset)
	end
	self.baseSize = UDim2.fromOffset(sizeOffset.X, sizeOffset.Y)

	-- screen gui with safe parent resolution
	local function guiParents()
		local parents = {}
		local function addParent(candidate)
			if not candidate then
				return
			end
			for _, existing in ipairs(parents) do
				if existing == candidate then
					return
				end
			end
			parents[#parents + 1] = candidate
		end
		for _, getter in ipairs({ gethui, get_hidden_gui }) do
			if type(getter) == "function" then
				local ok, parent = pcall(getter)
				if ok then
					addParent(parent)
				end
			end
		end
		local coreOk, coreGui = pcall(function()
			return game:GetService("CoreGui")
		end)
		if coreOk then
			addParent(coreGui)
		end
		if LocalPlayer then
			local playerOk, playerGui = pcall(function()
				return LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
			end)
			if playerOk then
				addParent(playerGui)
			end
		end
		return parents
	end

	local parents = guiParents()
	local guiName = config.Name or "MammozHubUI"
	for _, parent in ipairs(parents) do
		local ok, children = pcall(function()
			return parent:GetChildren()
		end)
		if ok then
			for _, child in ipairs(children) do
				if child.Name == guiName then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end

	local screen = make("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = config.DisplayOrder or 999,
	})
	pcall(function()
		screen:SetAttribute("MammozUI", true)
	end)

	local protect = protect_gui or protectgui
	if type(protect) ~= "function" and type(syn) == "table" then
		protect = syn.protect_gui
	end
	if type(protect) == "function" then
		pcall(protect, screen)
	end

	local attached = false
	for _, parent in ipairs(parents) do
		local ok = pcall(function()
			screen.Parent = parent
		end)
		if ok and screen.Parent == parent then
			attached = true
			break
		end
	end
	if not attached then
		screen:Destroy()
		error("MammozUI: could not attach ScreenGui.", 0)
	end
	self.screen = screen

	-- root
	local root = make("Frame", {
		Name = "Root",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = self.baseSize,
		BackgroundTransparency = 1,
		Active = true,
		Visible = true,
	}, screen)
	self.root = root

	-- One stable layout model scales down on smaller desktop and mobile viewports.
	self.scaleModel = make("UIScale", { Scale = 1 }, root)

	local shadow = make("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.new(0, 0, 0),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 463, 463),
		SliceScale = 1.35,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 6),
		Size = UDim2.new(1, 72, 1, 72),
	}, root)
	self.shadow = shadow

	local main = make("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
		Visible = true,
	}, root)
	corner(main, 9)
	stroke(main, T.WindowLine, 0.18)
	make("UIGradient", {
		Color = ColorSequence.new(T.Window, T.WindowBottom),
		Rotation = 90,
	}, main)
	make("Frame", {
		Name = "DashboardAccent",
		BackgroundColor3 = T.AccentBright,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 2),
		ZIndex = 4,
	}, main)
	self.main = main
	self.windowScale = make("UIScale", { Scale = 0.12 }, main)

	local openButton = make("TextButton", {
		Name = "MammozOpenButton",
		-- UIGradient tints this colour instead of replacing it.  White keeps the
		-- intended dark-blue gradient from being multiplied into near-black.
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(22, 22),
		Size = UDim2.fromOffset(210, 128),
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 120,
	}, screen)
	corner(openButton, 12)
	local openStroke = stroke(openButton, T.Accent, 0)
	openStroke.Thickness = 2
	make("UIGradient", {
		Color = ColorSequence.new(T.ElementHover, T.NavActive),
		Rotation = 90,
	}, openButton)
	-- Soft accent glow behind the chip so the elephant reads against the dark
	-- window background instead of blending into it.
	local openGlow = make("Frame", {
		Name = "OpenGlow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, 24, 1, 24),
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.82,
		BorderSizePixel = 0,
		ZIndex = openButton.ZIndex - 1,
	}, openButton)
	corner(openGlow, 999)
	-- Full animated mascot (walking/jumping elephant + trees + moon + mud)
	-- matching the Loader's restore chip, instead of the static logo.
	buildElephantMascot(self, openButton, {})
	self.openButton = openButton
	self:bind(openButton.MouseEnter, function()
		tween(openStroke, TI_FAST, { Transparency = 0, Color = T.AccentBright, Thickness = 2.6 })
		tween(openGlow, TI_FAST, { BackgroundTransparency = 0.62 })
	end)
	self:bind(openButton.MouseLeave, function()
		tween(openStroke, TI_FAST, { Transparency = 0, Color = T.Accent, Thickness = 2 })
		tween(openGlow, TI_FAST, { BackgroundTransparency = 0.82 })
	end)

	-- Best-effort persistence for the restore button position so it does not
	-- snap back to the top-left corner every time the window is folded.
	local STATE_FOLDER = "MammozHub"
	local STATE_PATH = STATE_FOLDER .. "/restore_position.json"
	local function loadSavedPosition()
		local env = (getgenv and getgenv()) or _G
		if type(env.__MAMMOZ_RESTORE_POSITION) == "table" then
			return env.__MAMMOZ_RESTORE_POSITION
		end
		if type(readfile) ~= "function" or type(isfile) ~= "function" then
			return nil
		end
		local ok, exists = pcall(isfile, STATE_PATH)
		if not ok or not exists then
			return nil
		end
		local readOk, raw = pcall(readfile, STATE_PATH)
		if not readOk or type(raw) ~= "string" or raw == "" then
			return nil
		end
		local decodedOk, data = pcall(function()
			return HttpService:JSONDecode(raw)
		end)
		if not decodedOk or type(data) ~= "table" then
			return nil
		end
		return data
	end
	local function savePosition(pos)
		local env = (getgenv and getgenv()) or _G
		env.__MAMMOZ_RESTORE_POSITION = pos
		if type(writefile) ~= "function" then
			return
		end
		if type(makefolder) == "function" then
			pcall(makefolder, STATE_FOLDER)
		end
		local encodedOk, encoded = pcall(function()
			return HttpService:JSONEncode({
				X = pos.X.Scale,
				OX = pos.X.Offset,
				Y = pos.Y.Scale,
				OY = pos.Y.Offset,
			})
		end)
		if encodedOk then
			pcall(writefile, STATE_PATH, encoded)
		end
	end

	local saved = loadSavedPosition()
	if type(saved) == "table" and saved.OX then
		openButton.Position = UDim2.new(saved.X or 0, saved.OX, saved.Y or 0, saved.OY)
		self.openButtonPosition = openButton.Position
	end

	-- Drag the restore chip anywhere on screen; a tiny movement is treated as
	-- a click so repositioning does not accidentally reopen the window.
	local dragging = false
	local dragStart, startPos, moved
	self:bind(openButton.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = openButton.Position
			moved = false
		end
	end)
	self:bind(UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - dragStart
		if delta.Magnitude > 6 then
			moved = true
		end
		openButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end)
	self:bind(openButton.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if moved then
				self.openButtonPosition = openButton.Position
				savePosition(openButton.Position)
			else
				self:setVisible(true)
			end
		end
	end)

	-- sidebar
	local sidebarWidth = touch and 210 or 224
	local sidebar = make("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, sidebarWidth, 1, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, main)
	corner(sidebar, 9)
	make("UIGradient", {
		Color = ColorSequence.new(T.Sidebar, T.SidebarBottom),
		Rotation = 90,
	}, sidebar)
	make("Frame", {
		BackgroundColor3 = T.SidebarBottom,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 12, 1, 0),
	}, sidebar)
	self.sidebar = sidebar

	local divider = make("Frame", {
		Name = "Divider",
		BackgroundColor3 = T.Divider,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(sidebarWidth, 0),
		Size = UDim2.new(0, 1, 1, 0),
	}, main)
	self.divider = divider

	local content = make("Frame", {
		Name = "Content",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(sidebarWidth + 1, 0),
		Size = UDim2.new(1, -(sidebarWidth + 1), 1, 0),
	}, main)
	make("UIGradient", {
		Color = ColorSequence.new(T.Window, T.WindowBottom),
		Rotation = 90,
	}, content)
	self.content = content

	-- The shared header mirrors the custom main dashboard.  It is owned by the
	-- backend, so every converted script gets the same visual shell.
	local contentHeader = make("Frame", {
		Name = "DashboardHeader",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 62),
		ZIndex = 2,
	}, content)
	make("UIGradient", {
		Color = ColorSequence.new(T.Header, T.HeaderBottom),
		Rotation = 90,
	}, contentHeader)
	make("Frame", {
		BackgroundColor3 = T.WindowLine,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 3,
	}, contentHeader)
	make("TextLabel", {
		Name = "HeaderKicker",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(22, 10),
		Size = UDim2.new(1, -180, 0, 14),
		Font = Enum.Font.GothamBlack,
		Text = "MAMMOZ HUB  /  CONTROL CENTER",
		TextSize = 10,
		TextColor3 = T.AccentBright,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 3,
	}, contentHeader)
	local headerPage = make("TextLabel", {
		Name = "HeaderPage",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(22, 24),
		Size = UDim2.new(1, -180, 0, 26),
		Font = Enum.Font.GothamBlack,
		Text = "DASHBOARD",
		TextSize = 18,
		TextColor3 = T.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 3,
	}, contentHeader)
	local systemBadge = make("Frame", {
		Name = "SystemBadge",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = T.Field,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -20, 0.5, 0),
		Size = UDim2.fromOffset(122, 26),
		ZIndex = 3,
	}, contentHeader)
	corner(systemBadge, 999)
	stroke(systemBadge, T.ElementLine, 0.12)
	local systemDot = make("Frame", {
		BackgroundColor3 = T.Success,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 10),
		Size = UDim2.fromOffset(6, 6),
		ZIndex = 4,
	}, systemBadge)
	corner(systemDot, 999)
	local systemLabel = make("TextLabel", {
		Name = "SystemLabel",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(27, 0),
		Size = UDim2.new(1, -33, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "SYSTEM ONLINE",
		TextSize = 9,
		TextColor3 = Color3.fromRGB(235, 247, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4,
	}, systemBadge)
	self.headerPage = headerPage
	self.headerSystemLabel = systemLabel
	self.headerSystemDot = systemDot

	self.sidebarWidth = sidebarWidth

	-- wordmark / title
	local titleText = "MAMMOZ HUB"
	local titleSize = touch and 19 or 22
	while titleSize > 11 do
		local ok, bounds = pcall(function()
			return TextService:GetTextSize(titleText, titleSize, Enum.Font.GothamMedium, Vector2.new(10000, 400))
		end)
		if not ok or not bounds or bounds.X <= sidebarWidth - 36 then
			break
		end
		titleSize = titleSize - 1
	end
	self.titleSize = titleSize

	local wordmark = make("Frame", {
		Name = "Wordmark",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 80),
	}, sidebar)
	self.wordmark = wordmark

	local fullTitle = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(18, 16),
		Size = UDim2.new(1, -22, 0, titleSize + 4),
		Font = Enum.Font.GothamBlack,
		Text = titleText,
		TextSize = titleSize,
		TextColor3 = T.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, wordmark)
	self.fullTitle = fullTitle

	local titleStar = make("TextLabel", {
		Name = "Asterisk",
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(math.floor(titleSize * 0.7), math.floor(titleSize * 0.7)),
		Font = Enum.Font.GothamBold,
		Text = "|",
		TextSize = math.floor(titleSize * 0.9),
		TextColor3 = T.Accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, wordmark)
	self.titleStar = titleStar

	local miniTitle = make("TextLabel", {
		Name = "Initial",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 16),
		Size = UDim2.new(1, 0, 0, titleSize + 4),
		Font = Enum.Font.GothamMedium,
		Text = "M",
		TextSize = titleSize,
		TextColor3 = T.Title,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Visible = false,
	}, wordmark)
	self.miniTitle = miniTitle

	local function placeAsterisk()
		local width = math.ceil(fullTitle.TextBounds.X)
		local x = math.min(18 + width, sidebarWidth - titleStar.Size.X.Offset - 3)
		titleStar.Position = UDim2.fromOffset(x, 16 - math.floor(titleSize * 0.1))
	end
	self:bind(fullTitle:GetPropertyChangedSignal("TextBounds"), placeAsterisk)
	task.defer(placeAsterisk)

	-- support badge
	local badgeY = 16 + titleSize + 10
	local supportBadge = make("Frame", {
		Name = "SupportBadge",
		BackgroundColor3 = T.Element,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(18, badgeY),
		Size = UDim2.fromOffset(0, 17),
		AutomaticSize = Enum.AutomaticSize.X,
	}, wordmark)
	corner(supportBadge, 999)
	stroke(supportBadge, T.Accent, 0)
	make("UIPadding", {
		PaddingLeft = UDim.new(0, 7),
		PaddingRight = UDim.new(0, 9),
	}, supportBadge)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, supportBadge)
	local badgeDot = make("Frame", {
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(5, 5),
		LayoutOrder = 1,
	}, supportBadge)
	corner(badgeDot, 999)
	make("TextLabel", {
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 17),
		Font = Enum.Font.GothamMedium,
		Text = config.BadgeText or title,
		TextSize = 10,
		TextColor3 = T.Accent,
		LayoutOrder = 2,
	}, supportBadge)
	wordmark.Size = UDim2.new(1, 0, 0, badgeY + 29)
	self.supportBadge = supportBadge

	-- nav scroll
	local navTop = badgeY + 31
	local nav = make("ScrollingFrame", {
		Name = "Nav",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, navTop),
		Size = UDim2.new(1, 0, 1, -(navTop + (touch and 70 or 56))),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = T.Accent,
	}, sidebar)
	make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	}, nav)
	self.nav = nav

	local navMarker = make("Frame", {
		Name = "Marker",
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 14.5),
		Size = UDim2.fromOffset(3, 18),
		Visible = false,
		ZIndex = 4,
	}, nav)
	corner(navMarker, 999)
	self.navMarker = navMarker

	-- search
	local searchHolder = make("Frame", {
		Name = "Search",
		BackgroundColor3 = T.Field,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 14, 1, -50),
		Size = UDim2.new(1, -28, 0, touch and 30 or 26),
	}, sidebar)
	corner(searchHolder, 6)
	local searchStroke = stroke(searchHolder, T.CardLine, 0)
	local searchIcon, setSearchIconColor = renderIcon(searchHolder, "search", 11, T.Dim)
	searchIcon.Position = UDim2.fromOffset(15, touch and 15 or 13)
	local searchBox = make("TextBox", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(28, 0),
		Size = UDim2.new(1, -36, 1, 0),
		Font = Enum.Font.GothamMedium,
		PlaceholderText = "Search features...",
		PlaceholderColor3 = Color3.fromRGB(195, 218, 240),
		Text = "",
		TextSize = 11,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	}, searchHolder)
	self:bind(searchBox.Focused, function()
		tween(searchStroke, TI_MED, { Color = T.Accent })
	end)
	self:bind(searchBox.FocusLost, function()
		tween(searchStroke, TI_MED, { Color = T.CardLine })
	end)
	self:bind(searchBox:GetPropertyChangedSignal("Text"), function()
		local query = searchBox.Text:lower()
		for _, page in ipairs(self.pages) do
			local match = query == "" or page.name:lower():find(query, 1, true) ~= nil
			page.navButton.Visible = match
		end
	end)
	local searchIconButton = make("TextButton", {
		Name = "SearchIcon",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 3,
	}, searchHolder)
	self.searchHolder = searchHolder
	self.searchBox = searchBox
	self.searchIconButton = searchIconButton
	self.searchStroke = searchStroke
	self.setSearchIconColor = setSearchIconColor

	-- collapse button
	local collapseButton = make("TextButton", {
		Name = "Collapse",
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 1, -20),
		Size = UDim2.fromOffset(touch and 40 or 28, 16),
		Text = "",
		AutoButtonColor = false,
	}, sidebar)
	local collapseChevron, setChevronColor = makeChevron(collapseButton, 11, T.Dim)
	collapseChevron.Position = UDim2.fromScale(0.5, 0.5)
	self:bind(collapseButton.MouseEnter, function()
		setChevronColor(T.Value)
	end)
	self:bind(collapseButton.MouseLeave, function()
		setChevronColor(T.Dim)
	end)
	self.collapseChevron = collapseChevron
	self.setChevronColor = setChevronColor

	self:bind(collapseButton.MouseButton1Click, function()
		self:setCollapsed(not self.collapsed)
	end)
	self:bind(searchIconButton.MouseEnter, function()
		setSearchIconColor(T.Value, TI_FAST)
		tween(searchStroke, TI_FAST, { Color = T.Accent })
	end)
	self:bind(searchIconButton.MouseLeave, function()
		setSearchIconColor(T.Dim, TI_FAST)
		tween(searchStroke, TI_FAST, { Color = T.CardLine })
	end)
	self:bind(searchIconButton.MouseButton1Click, function()
		self:setCollapsed(false)
		searchBox:CaptureFocus()
	end)

	-- window controls
	local controls = make("Frame", {
		Name = "WindowControls",
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -14, 0, 17),
		Size = UDim2.fromOffset(74, 22),
		ZIndex = 50,
	}, content)
	local controlButtons = {}
	for index, spec in ipairs({
		{ "Minimise", "min" },
		{ "Zoom", "max" },
		{ "Close", "close" },
	}) do
		local name, glyph = spec[1], spec[2]
		local button = make("TextButton", {
			Name = name,
			Position = UDim2.fromOffset((index - 1) * 26, 0),
			Size = UDim2.fromOffset(touch and 26 or 22, touch and 26 or 22),
			BackgroundColor3 = T.Element,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			ZIndex = 51,
		}, controls)
		corner(button, 6)
		local marks = {}
		local outlines = {}
		local function addBar(width, height, rotation, y)
			local bar = make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = T.Dim,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, 0, 0.5, y or 0),
				Size = UDim2.fromOffset(width, height),
				Rotation = rotation,
				ZIndex = 52,
			}, button)
			corner(bar, 1)
			marks[#marks + 1] = bar
		end
		if glyph == "close" then
			addBar(10, 1.5, 45)
			addBar(10, 1.5, -45)
		elseif glyph == "min" then
			addBar(10, 1.5, 0, 3)
		else
			local box = make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(9, 9),
				ZIndex = 52,
			}, button)
			corner(box, 2)
			outlines[#outlines + 1] = stroke(box, T.Dim, 0, 1.5)
		end
		local function paint(color, transparency)
			for _, mark in ipairs(marks) do
				tween(mark, TI_FAST, { BackgroundColor3 = color })
			end
			for _, line in ipairs(outlines) do
				tween(line, TI_FAST, { Color = color })
			end
			tween(button, TI_FAST, { BackgroundTransparency = transparency })
		end
		self:bind(button.MouseEnter, function()
			paint(glyph == "close" and T.Accent or T.Value, 0.55)
		end)
		self:bind(button.MouseLeave, function()
			paint(T.Dim, 1)
		end)
		controlButtons[name] = button
	end
	self.controlButtons = controlButtons

	-- drag area (top bar) — mouse + touch
	local dragArea = make("Frame", {
		Name = "DragArea",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Active = true,
		ZIndex = 40,
	}, main)
	self.dragArea = dragArea

	local dragging = false
	local dragInput, dragStart, dragPosition
	self:bind(dragArea.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			dragPosition = root.Position
			if input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end
	end)
	self:bind(dragArea.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	self:bind(UserInputService.InputChanged, function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(
				dragPosition.X.Scale,
				dragPosition.X.Offset + delta.X,
				dragPosition.Y.Scale,
				dragPosition.Y.Offset + delta.Y
			)
		end
	end)
	self:bind(UserInputService.InputEnded, function(input)
		if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			dragInput = nil
		end
	end)

	-- control button logic
	self:bind(controlButtons.Minimise.MouseButton1Click, function()
		self:setVisible(false)
	end)
	self:bind(controlButtons.Zoom.MouseButton1Click, function()
		self:toggleZoom()
	end)
	self:bind(controlButtons.Close.MouseButton1Click, function()
		if config.OnClose then
			config.OnClose()
		else
			-- Close should actually close (disconnect + destroy the ScreenGui),
			-- not just fold to the restore chip like the minimise button does.
			self:Destroy()
		end
	end)

	self.toggleKey = config.ToggleKey or Enum.KeyCode.RightShift

	-- keybinds (desktop): configurable toggle key, Ctrl+F search
	if not touch then
		self:bind(UserInputService.InputBegan, function(input, processed)
			if processed then
				return
			end
			if self.toggleKey and input.KeyCode == self.toggleKey then
				self:setVisible(not self.visible)
			elseif input.KeyCode == Enum.KeyCode.F
				and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
					or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
				if self.collapsed then
					self:setCollapsed(false)
				end
				self:setVisible(true)
				searchBox:CaptureFocus()
			end
		end)
	end

	-- toast holder
	local toastHolder = make("Frame", {
		Name = "Toasts",
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.fromOffset(280, 210),
		ZIndex = 100,
	}, screen)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	}, toastHolder)
	self.toastHolder = toastHolder
	self.toastOrder = 0
	self.notifySide = "Right"
	self.dpiScale = 1

	-- intro animation
	tween(self.windowScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = self.dpiScale or 1 })
	tween(shadow, TI_MED, { ImageTransparency = 0.55 })

	-- mobile: auto-collapse sidebar if viewport is very narrow
	if touch and vp.X < 520 then
		task.defer(function()
			self:setCollapsed(true)
		end)
	end

	-- Keep the dashboard inside the viewport after resize or mobile rotation.
	local function bindCamera(cam)
		if not cam then
			return
		end
		self:bind(cam:GetPropertyChangedSignal("ViewportSize"), function()
			self:fitViewport()
		end)
	end
	self:bind(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		self:fitViewport()
		bindCamera(workspace.CurrentCamera)
	end)
	bindCamera(workspace.CurrentCamera)
	self:bind(UserInputService.InputBegan, function(input)
		local popup = self.activePopup
		if popup and type(popup.InputBegan) == "function" then
			invokeCallback("Popup input", popup.InputBegan, input)
		end
	end)
	self:bind(UserInputService.InputChanged, function(input)
		local drag = self.activeDrag
		if drag and type(drag.Update) == "function" then
			invokeCallback("Slider drag", drag.Update, input)
		end
		local popup = self.activePopup
		if popup and type(popup.InputChanged) == "function" then
			invokeCallback("Popup scroll", popup.InputChanged, input)
		end
	end)
	self:bind(UserInputService.InputEnded, function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local drag = self.activeDrag
		self.activeDrag = nil
		if drag and type(drag.Ended) == "function" then
			invokeCallback("Slider drag end", drag.Ended, input)
		end
	end)
	task.defer(function()
		self:fitViewport()
	end)

	return self
end

function Window:bind(signal, callback)
	local connection = signal:Connect(callback)
	self.connections[#self.connections + 1] = connection
	return connection
end

function Window:addCleanup(callback)
	if type(callback) == "function" then
		self.cleanups[#self.cleanups + 1] = callback
	end
	return callback
end

function Window:openPopup(owner, handlers)
	if self.activePopup and self.activePopup.Owner ~= owner then
		self:closePopup()
	end
	handlers = type(handlers) == "table" and handlers or {}
	handlers.Owner = owner
	self.activePopup = handlers
	return handlers
end

function Window:closePopup(owner)
	local popup = self.activePopup
	if not popup or owner and popup.Owner ~= owner then
		return false
	end
	self.activePopup = nil
	if type(popup.Close) == "function" then
		invokeCallback("Close popup", popup.Close)
	end
	return true
end

function Window:setSidebarWidth(width)
	width = math.clamp(tonumber(width) or self.sidebarWidth or 184, 140, 320)
	self.sidebarWidth = width
	if self.collapsed then
		return self
	end
	self.sidebar.Size = UDim2.new(0, width, 1, 0)
	self.divider.Position = UDim2.fromOffset(width, 0)
	self.content.Position = UDim2.fromOffset(width + 1, 0)
	self.content.Size = UDim2.new(1, -(width + 1), 1, 0)
	return self
end

function Window:setToggleKey(key)
	self.toggleKey = key
	return self
end

function Window:setHeaderStatus(text, kind)
	if not self.headerSystemLabel or not self.headerSystemLabel.Parent then
		return self
	end
	local T = self.theme
	self.headerSystemLabel.Text = tostring(text or "SYSTEM ONLINE")
	if self.headerSystemDot then
		self.headerSystemDot.BackgroundColor3 = kind == "error" and T.Error
			or kind == "warn" and T.Gold
			or T.Success
	end
	return self
end

function Window:setNotifySide(side)
	local normalized = string.lower(tostring(side or "Right"))
	local left = normalized == "left" or normalized == "bottomleft" or normalized == "top-left"
	self.notifySide = left and "Left" or "Right"
	if self.toastHolder then
		self.toastHolder.AnchorPoint = left and Vector2.new(0, 1) or Vector2.new(1, 1)
		self.toastHolder.Position = left and UDim2.new(0, 18, 1, -18) or UDim2.new(1, -18, 1, -18)
		local layout = self.toastHolder:FindFirstChildOfClass("UIListLayout")
		if layout then
			layout.HorizontalAlignment = left and Enum.HorizontalAlignment.Left or Enum.HorizontalAlignment.Right
		end
	end
	return self
end

function Window:setDPIScale(value)
	self.dpiScale = math.clamp(tonumber(value) or 1, 0.65, 1.5)
	if self.windowScale then
		self.windowScale.Scale = self.dpiScale
	end
	return self
end

function Window:setFont(font)
	if not self.screen or typeof(font) ~= "EnumItem" then
		return self
	end
	for _, object in ipairs(self.screen:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			object.Font = font
		end
	end
	return self
end

function Window:fitViewport()
	if not self.scaleModel then
		return
	end
	local vp = viewport()
	local w, h = self.baseSize.X.Offset, self.baseSize.Y.Offset
	local scale = math.clamp(math.min(vp.X / (w + 36), vp.Y / (h + 36), 1), 0.5, 1)
	tween(self.scaleModel, TI_MED, { Scale = scale })
end

function Window:setVisible(on)
	if self.visible == on then
		return
	end
	self.visible = on
	if not on then
		self:closePopup()
	end
	if self.openButton then
		self.openButton.Visible = not on
	end
	if on then
		self.root.Visible = true
		self.main.Visible = true
		self.windowScale.Scale = 0.12
		tween(self.windowScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = self.dpiScale or 1 })
		tween(self.shadow, TI_MED, { ImageTransparency = 0.55 })
	else
		tween(self.windowScale, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Scale = 0.12 })
		tween(self.shadow, TI_FAST, { ImageTransparency = 1 })
		task.delay(0.21, function()
			if not self.visible and self.root.Parent then
				self.root.Visible = false
			end
		end)
	end
end

function Window:toggleZoom()
	local vp = viewport()
	if self.maximized then
		self.maximized = false
		tween(self.root, TI_SMOOTH, {
			Size = self.restoreSize or self.baseSize,
			Position = self.restorePosition or UDim2.fromScale(0.5, 0.5),
		})
	else
		self.maximized = true
		self.restoreSize = self.root.Size
		self.restorePosition = self.root.Position
		tween(self.root, TI_SMOOTH, {
			Size = UDim2.fromOffset(math.max(620, vp.X - 24), math.max(380, vp.Y - 24)),
			Position = UDim2.fromOffset(math.round(vp.X / 2), math.round(vp.Y / 2)),
		})
	end
end

function Window:setCollapsed(on)
	if self.collapsed == on then
		return
	end
	self.collapsed = on
	self:closePopup()
	local collapsedWidth = self.touch and 52 or 46
	local width = on and collapsedWidth or self.sidebarWidth
	self.miniTitle.Visible = on
	self.fullTitle.Visible = not on
	self.titleStar.Visible = not on
	self.supportBadge.Visible = not on
	self.searchBox.Visible = not on
	self.searchIconButton.Visible = on
	tween(self.searchHolder, TI_SMOOTH, {
		Position = UDim2.new(0, on and 8 or 14, 1, -50),
		Size = on and UDim2.fromOffset(collapsedWidth - 22, self.touch and 30 or 26)
			or UDim2.new(1, -28, 0, self.touch and 30 or 26),
	})
	tween(self.sidebar, TI_SMOOTH, { Size = UDim2.new(0, width, 1, 0) })
	tween(self.divider, TI_SMOOTH, { Position = UDim2.fromOffset(width, 0) })
	tween(self.content, TI_SMOOTH, {
		Position = UDim2.fromOffset(width + 1, 0),
		Size = UDim2.new(1, -(width + 1), 1, 0),
	})
	tween(self.collapseChevron, TI_SMOOTH, { Rotation = on and 180 or 0 })
	for _, page in ipairs(self.pages) do
		tween(page.navLabel, TI_FAST, { TextTransparency = on and 1 or 0 })
		tween(page.navIcon, TI_SMOOTH, { Position = UDim2.fromOffset(on and 17 or 15, page.navIconY) })
		tween(page.navButton, TI_SMOOTH, {
			Position = UDim2.fromOffset(on and 6 or 12, 0),
			Size = UDim2.new(1, on and -12 or -24, 0, page.navHeight),
		})
	end
	if on and self.searchBox:IsFocused() then
		self.searchBox:ReleaseFocus()
		self.searchBox.Text = ""
	end
end

-- ===== pages =====
function Window:CreatePage(name, icon)
	local T = self.theme
	local page = make("ScrollingFrame", {
		Name = name .. "Page",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 66),
		Size = UDim2.new(1, 0, 1, -66),
		Visible = false,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = T.Accent,
		ScrollBarImageTransparency = 0.12,
		ScrollingEnabled = true,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
	}, self.content)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 20),
	}, page)
	local fullColumn = make("Frame", {
		Name = "Full",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -52, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, page)
	make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
	}, fullColumn)

	make("TextLabel", {
		Name = "PageTitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Font = Enum.Font.GothamBold,
		Text = tostring(name),
		TextSize = 22,
		TextColor3 = T.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = -1000,
	}, fullColumn)
	make("TextLabel", {
		Name = "PageSubtitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.GothamMedium,
		Text = "MAMMOZ HUB CONTROL CENTER",
		TextSize = 12,
		TextColor3 = Color3.fromRGB(200, 220, 245),
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = -999,
	}, fullColumn)

	-- nav button
	local navHeight = self.touch and 46 or 44
	local navButton = make("TextButton", {
		Name = name,
		BackgroundColor3 = T.NavActive,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 0, navHeight),
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = #self.pages + 1,
	}, self.nav)
	corner(navButton, 6)
	local navIcon, setNavIconColor = renderIcon(navButton, icon or "code", 14, Color3.new(1, 1, 1))
	navIcon.Position = UDim2.fromOffset(15, navHeight / 2)
	local navLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(35, 0),
		Size = UDim2.new(1, -39, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = name,
		TextSize = 14,
		TextColor3 = T.NavIdle,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 2,
	}, navButton)

	local pageObj = {
		name = name,
		icon = icon or "code",
		frame = page,
		column = fullColumn,
		navButton = navButton,
		navIcon = navIcon,
		navLabel = navLabel,
		navIconY = navHeight / 2,
		navHeight = navHeight,
		setNavIconColor = setNavIconColor,
		order = 0,
		visible = false,
		window = self,
		cards = {},
	}

	local function highlight()
		tween(navButton, TI_MED, { BackgroundTransparency = 0 })
		tween(navLabel, TI_MED, { TextColor3 = Color3.new(1, 1, 1) })
		setNavIconColor(Color3.new(1, 1, 1), TI_MED)
	end
	local function idle()
		tween(navButton, TI_MED, { BackgroundTransparency = 1 })
		tween(navLabel, TI_MED, { TextColor3 = T.NavIdle })
		setNavIconColor(T.NavIdle, TI_MED)
	end
	pageObj.highlight = highlight
	pageObj.idle = idle

	self:bind(navButton.MouseEnter, function()
		if not pageObj.visible then
			tween(navButton, TI_FAST, { BackgroundTransparency = 0.4 })
		end
	end)
	self:bind(navButton.MouseLeave, function()
		if not pageObj.visible then
			tween(navButton, TI_FAST, { BackgroundTransparency = 1 })
		end
	end)
	self:bind(navButton.MouseButton1Click, function()
		self:SelectPage(pageObj)
	end)

	self.pages[#self.pages + 1] = pageObj
	if #self.pages == 1 then
		self:SelectPage(pageObj)
	end

	return setmetatable(pageObj, Page)
end

function Window:SelectPage(page)
	self:closePopup()
	for _, p in ipairs(self.pages) do
		local active = (p == page)
		p.visible = active
		p.frame.Visible = active
		if active then
			p.highlight()
		else
			p.idle()
		end
	end
	-- move nav marker
	if page then
		if self.headerPage then
			self.headerPage.Text = string.upper(tostring(page.name or "DASHBOARD"))
		end
		self.navMarker.Visible = true
		tween(self.navMarker, TI_MED, {
			Position = UDim2.fromOffset(0, page.navButton.Position.Y.Offset + page.navHeight / 2),
		})
	end
end

-- ===== toasts =====
function Window:Notify(title, body, kind)
	if self.cleaning or not self.toastHolder.Parent then
		return
	end
	local T = self.theme
	local tint = kind == "success" and T.Success
		or kind == "error" and T.Error
		or kind == "primary" and T.Primary
		or T.Accent
	self.toastOrder = self.toastOrder + 1
	local toast = make("Frame", {
		Name = "Toast",
		Size = UDim2.fromOffset(268, 56),
		BackgroundColor3 = T.Card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = self.toastOrder,
		ZIndex = 101,
	}, self.toastHolder)
	corner(toast, 7)
	local toastLine = stroke(toast, T.CardLine, 1)
	local accent = make("Frame", {
		BackgroundColor3 = tint,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(3, 56),
		ZIndex = 102,
	}, toast)
	corner(accent, 999)
	local heading = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -24, 0, 16),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextSize = 11,
		TextColor3 = T.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTransparency = 1,
		ZIndex = 102,
	}, toast)
	local detail = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 25),
		Size = UDim2.new(1, -24, 0, 21),
		Font = Enum.Font.GothamMedium,
		Text = body,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(235, 247, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextTransparency = 1,
		ZIndex = 102,
	}, toast)
	tween(toast, TI_MED, { BackgroundTransparency = 0 })
	tween(toastLine, TI_MED, { Transparency = 0 })
	tween(heading, TI_MED, { TextTransparency = 0 })
	tween(detail, TI_MED, { TextTransparency = 0 })
	local duration = 3
	task.delay(duration, function()
		if toast and toast.Parent then
			tween(toast, TI_MED, { BackgroundTransparency = 1 })
			tween(heading, TI_MED, { TextTransparency = 1 })
			tween(detail, TI_MED, { TextTransparency = 1 })
			task.wait(0.2)
			if toast.Parent then
				toast:Destroy()
			end
		end
	end)
end

function Window:Destroy()
	self.cleaning = true
	self:closePopup()
	for _, cleanup in ipairs(self.cleanups) do
		pcall(cleanup)
	end
	table.clear(self.cleanups)
	for _, connection in ipairs(self.connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	if self.screen and self.screen.Parent then
		self.screen:Destroy()
	end
end

-- ===== page / cards =====
Page = {}
Page.__index = Page

function Page:CreateCard(title, order)
	local T = self.window.theme
	local frame = make("CanvasGroup", {
		Name = title,
		-- Gradient colours are multiplied with BackgroundColor3 by Roblox.
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order or (#self.cards + 1),
		GroupTransparency = 1,
	}, self.column)
	-- Mark native so legacy styling won't stomp the card surface.
	frame:SetAttribute("MammozUI", true)
	corner(frame, 10)
	local cardStroke = stroke(frame, T.CardLine, 0.10, 1.2)
	make("UIGradient", {
		Color = ColorSequence.new(T.Card, T.CardBottom),
		Rotation = 90,
	}, frame)
	-- Accent bar across the top edge of the card.
	make("Frame", {
		Name = "CardAccent",
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 3),
		LayoutOrder = -2,
	}, frame)
	make("UIPadding", {
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 16),
	}, frame)
	make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
	}, frame)
	-- Title row, with a thin divider below it separating header from body.
	local titleHolder = make("Frame", {
		Name = "CardTitleRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = -1,
	}, frame)
	local cardTitle = make("TextLabel", {
		Name = "CardTitle",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBlack,
		Text = title,
		TextSize = 15,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, titleHolder)
	local divider = make("Frame", {
		Name = "CardDivider",
		BackgroundColor3 = T.CardLine,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		LayoutOrder = 0,
	}, frame)

	local card = setmetatable({
		frame = frame,
		order = 0,
		window = self.window,
		page = self,
	}, Card)
	self.cards[#self.cards + 1] = card

	-- intro fade (staggered). Fail-safe: whatever happens to the tween
	-- (unsupported property, interruption), force the final visible state
	-- after a moment so the card never stays half-faded/gray.
	tween(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.035 * #self.cards), { GroupTransparency = 0 })
	task.delay(1, function()
		if frame.Parent then
			pcall(function()
				frame.GroupTransparency = 0
			end)
		end
	end)
	return card
end

function Page:nextOrder()
	return #self.cards + 1
end

-- ===== card elements =====
Card = {}
Card.__index = Card

function Card:nextOrder()
	self.order = self.order + 1
	return self.order
end

function Card:AddLabel(text, note)
	local T = self.window.theme
	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = note and Enum.Font.GothamMedium or Enum.Font.GothamSemibold,
		Text = text,
		TextSize = note and 12 or 14,
		-- Keep both note and primary text bright so nothing in a Card reads
		-- as gray on the dark background.
		TextColor3 = note and Color3.fromRGB(235, 247, 255) or Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		LayoutOrder = self:nextOrder(),
	}, self.frame)
	return label
end

function Card:AddButton(text, callback)
	local T = self.window.theme
	local h = self.window.touch and 48 or 44
	local button = make("TextButton", {
		Size = UDim2.new(1, 0, 0, h),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = self:nextOrder(),
	}, self.frame)
	-- Mark as native Mammoz control so legacy styling won't overwrite it
	button:SetAttribute("MammozUI", true)
	corner(button, 8)
	-- Gradient goes light->element (NOT into Card) so the button stands apart
	-- from the card surface instead of blending into it.
	make("UIGradient", {
		Color = ColorSequence.new(T.ElementHover, T.Element),
		Rotation = 90,
	}, button)
	local line = stroke(button, T.ElementLine, 0, 1.4)
	-- Accent bar on the left edge of the button.
	local accentBar = make("Frame", {
		Name = "AccentBar",
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(3, 1),
		ZIndex = 2,
	}, button)
	corner(accentBar, 2)
	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		Font = Enum.Font.GothamBold,
		Text = text,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
	})
	label.Parent = button
	self.window:bind(button.MouseEnter, function()
		tween(line, TI_FAST, { Color = T.Accent, Transparency = 0 })
		tween(accentBar, TI_FAST, { BackgroundTransparency = 0 })
	end)
	self.window:bind(button.MouseLeave, function()
		tween(line, TI_FAST, { Color = T.ElementLine, Transparency = 0 })
		tween(accentBar, TI_FAST, { BackgroundTransparency = 0.35 })
	end)
	self.window:bind(button.MouseButton1Click, function()
		if callback then
			spawnCallback("Button: " .. tostring(text), callback, label, button)
		end
	end)
	return button, label
end

function Card:AddInput(config, callback)
	config = config or {}
	local T = self.window.theme
	local touch = self.window.touch
	local h = touch and 48 or 44
	local inputRow = make("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, h),
		LayoutOrder = self:nextOrder(),
	}, self.frame)
	if config.Label then
		make("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(0, 180, 1, 0),
			Font = Enum.Font.GothamBold,
			Text = config.Label,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}, inputRow)
	end
	local labelOffset = config.Label and 190 or 0
	local inputHolder = make("Frame", {
		Position = UDim2.fromOffset(labelOffset, 0),
		Size = UDim2.new(1, -labelOffset, 0, h),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, inputRow)
	inputHolder:SetAttribute("MammozUI", true)
	corner(inputHolder, 8)
	local inputStroke = stroke(inputHolder, T.ElementLine, 0, 1.4)
	make("UIGradient", {
		Color = ColorSequence.new(T.ElementHover, T.Element),
		Rotation = 90,
	}, inputHolder)
	local keyInput = make("TextBox", {
		Name = "Input",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		Font = Enum.Font.GothamMedium,
		PlaceholderText = config.Placeholder or "",
		PlaceholderColor3 = Color3.fromRGB(195, 218, 240),
		Text = config.Default or "",
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		MultiLine = false,
		TextEditable = true,
	}, inputHolder)

	if config.Masked then
		keyInput.TextTransparency = 1
		local bullet = utf8.char(0x2022)
		local inputFocused = false
		local scrollOffset = 0
		local selection = make("Frame", {
			Name = "SelectionHighlight",
			BackgroundColor3 = T.AccentBright,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 3),
			Size = UDim2.fromOffset(0, h - 6),
			Visible = false,
			ZIndex = keyInput.ZIndex + 1,
		}, inputHolder)
		corner(selection, 2)
		local mask = make("TextLabel", {
			BackgroundColor3 = T.AccentBright,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -16, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = config.Placeholder or "Paste your key here",
			TextSize = 11,
			TextColor3 = Color3.fromRGB(195, 218, 240),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = keyInput.ZIndex + 2,
		}, inputHolder)
		local caret = make("Frame", {
			Name = "TextCaret",
			BackgroundColor3 = T.AccentBright,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 4),
			Size = UDim2.fromOffset(2, h - 8),
			Visible = false,
			ZIndex = keyInput.ZIndex + 3,
		}, inputHolder)
		local function bulletWidth(count)
			if count <= 0 then
				return 0
			end
			return TextService:GetTextSize(string.rep(bullet, count), keyInput.TextSize, keyInput.Font, Vector2.new(10000, h)).X
		end
		local function refreshEditor()
			local length = #keyInput.Text
			local cursor = keyInput.CursorPosition
			if cursor < 1 then
				cursor = length + 1
			end
			cursor = math.clamp(cursor, 1, length + 1)
			local available = math.max(0, inputHolder.AbsoluteSize.X - 16)
			local contentWidth = bulletWidth(length)
			local cursorWidth = bulletWidth(cursor - 1)
			if cursorWidth - scrollOffset > available then
				scrollOffset = cursorWidth - available
			elseif cursorWidth - scrollOffset < 0 then
				scrollOffset = cursorWidth
			end
			scrollOffset = math.clamp(scrollOffset, 0, math.max(0, contentWidth - available))
			mask.Position = UDim2.fromOffset(8 - scrollOffset, 0)
			mask.Size = UDim2.new(1, -16 + scrollOffset, 1, 0)
			local selectionStart = keyInput.SelectionStart
			local hasSelection = inputFocused and selectionStart >= 1 and selectionStart ~= cursor and length > 0
			if hasSelection then
				selectionStart = math.clamp(selectionStart, 1, length + 1)
				local first = math.min(selectionStart, cursor) - 1
				local last = math.max(selectionStart, cursor) - 1
				local left = math.clamp(bulletWidth(first) - scrollOffset, 0, available)
				local right = math.clamp(bulletWidth(last) - scrollOffset, 0, available)
				selection.Position = UDim2.fromOffset(8 + left, 3)
				selection.Size = UDim2.fromOffset(math.max(1, right - left), h - 6)
				selection.Visible = right > left
			else
				selection.Visible = false
			end
			caret.Position = UDim2.fromOffset(8 + math.clamp(cursorWidth - scrollOffset, 0, available), 4)
			caret.Visible = inputFocused and not hasSelection
		end
		local function refreshMask()
			local length = #keyInput.Text
			mask.Text = length == 0 and (config.Placeholder or "Paste your key here") or string.rep(bullet, math.min(length, 64))
			mask.TextColor3 = length == 0 and Color3.fromRGB(190, 214, 238) or Color3.fromRGB(255, 255, 255)
			refreshEditor()
		end
		self.window:bind(keyInput:GetPropertyChangedSignal("Text"), refreshMask)
		self.window:bind(keyInput:GetPropertyChangedSignal("CursorPosition"), refreshEditor)
		self.window:bind(keyInput:GetPropertyChangedSignal("SelectionStart"), refreshEditor)
		self.window:bind(inputHolder:GetPropertyChangedSignal("AbsoluteSize"), refreshEditor)
		self.window:bind(keyInput.Focused, function()
			inputFocused = true
			tween(inputStroke, TI_MED, { Color = T.Accent })
			refreshEditor()
		end)
		self.window:bind(keyInput.FocusLost, function(enter)
			inputFocused = false
			selection.Visible = false
			caret.Visible = false
			tween(inputStroke, TI_MED, { Color = T.ElementLine })
			if callback then
				invokeCallback("Input: " .. tostring(config.Label or config.Title or "Input"), callback, keyInput.Text, false, enter)
			end
		end)
		refreshMask()
	else
		self.window:bind(keyInput.Focused, function()
			tween(inputStroke, TI_MED, { Color = T.Accent })
		end)
		self.window:bind(keyInput.FocusLost, function(enter)
			tween(inputStroke, TI_MED, { Color = T.ElementLine })
			if callback then
				invokeCallback("Input: " .. tostring(config.Label or config.Title or "Input"), callback, keyInput.Text, false, enter)
			end
		end)
		self.window:bind(keyInput:GetPropertyChangedSignal("Text"), function()
			if callback and keyInput:IsFocused() then
				invokeCallback("Input change: " .. tostring(config.Label or config.Title or "Input"), callback, keyInput.Text, true, false)
			end
		end)
	end
	return keyInput, inputHolder
end

function Card:AddToggle(text, default, callback)
	local T = self.window.theme
	local h = self.window.touch and 60 or 56
	local row = make("TextButton", {
		Size = UDim2.new(1, 0, 0, h),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = self:nextOrder(),
	}, self.frame)
	row:SetAttribute("MammozUI", true)
	corner(row, 8)
	make("UIGradient", {
		Color = ColorSequence.new(T.ElementHover, T.Element),
		Rotation = 90,
	}, row)
	local line = stroke(row, T.ElementLine, 0, 1.4)
	local accentBar = make("Frame", {
		Name = "AccentBar",
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(3, 1),
		ZIndex = 2,
	}, row)
	corner(accentBar, 2)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(1, -88, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = text,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
	}, row)
	local knobW = 44
	local knob = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.fromOffset(knobW, 24),
		BackgroundColor3 = T.Field,
		BorderSizePixel = 0,
		ZIndex = 3,
	}, row)
	corner(knob, 999)
	local dot = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.25, 0.5),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = T.Dim,
		BorderSizePixel = 0,
		ZIndex = 4,
	}, knob)
	corner(dot, 999)
	local state = default and true or false
	local control = { Instance = row, Value = state, Observers = {} }
	local function render()
		tween(knob, TI_MED, { BackgroundColor3 = state and T.Accent or T.Field })
		tween(dot, TI_MED, { Position = UDim2.fromScale(state and 0.75 or 0.25, 0.5), BackgroundColor3 = state and Color3.new(1, 1, 1) or T.Dim })
	end
	function control:Get()
		return state
	end
	function control:Set(value, silent)
		state = value == true
		self.Value = state
		render()
		if not silent and callback then
			spawnCallback("Toggle: " .. tostring(text), callback, state)
		end
		if not silent then
			for _, observer in ipairs(self.Observers) do
				spawnCallback("Toggle observer: " .. tostring(text), observer, state)
			end
		end
		return self
	end
	function control:SetValue(value)
		return self:Set(value)
	end
	function control:Toggle()
		return self:Set(not state)
	end
	function control:OnChanged(observer)
		if type(observer) == "function" then
			self.Observers[#self.Observers + 1] = observer
		end
		return self
	end
	function control:SetDesc()
		return self
	end
	function control:Disable(disabled)
		row.Active = disabled ~= false and false or true
		return self
	end
	render()
	self.window:bind(row.MouseEnter, function()
		tween(line, TI_FAST, { Color = T.Accent, Transparency = 0 })
		tween(accentBar, TI_FAST, { BackgroundTransparency = 0 })
	end)
	self.window:bind(row.MouseLeave, function()
		tween(line, TI_FAST, { Color = T.ElementLine, Transparency = 0 })
		tween(accentBar, TI_FAST, { BackgroundTransparency = 0.35 })
	end)
	self.window:bind(row.MouseButton1Click, function()
		control:Set(not state)
	end)
	return control
end

function Card:AddSlider(text, min, max, default, callback)
	local T = self.window.theme
	local touch = self.window.touch
	local h = touch and 64 or 60
	local container = make("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, h),
		LayoutOrder = self:nextOrder(),
	}, self.frame)
	container:SetAttribute("MammozUI", true)
	corner(container, 8)
	local sliderLine = stroke(container, T.ElementLine, 0, 1.4)
	local accentBar = make("Frame", {
		Name = "AccentBar",
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(3, 1),
		ZIndex = 2,
	}, container)
	corner(accentBar, 2)
	make("UIGradient", {
		Color = ColorSequence.new(T.ElementHover, T.Element),
		Rotation = 90,
	}, container)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(0, 230, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = text,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, container)
	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -64, 0, 0),
		Size = UDim2.fromOffset(54, 24),
		Font = Enum.Font.GothamBold,
		Text = tostring(default),
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Right,
	}, container)
	local track = make("TextButton", {
		Position = UDim2.fromOffset(260, 30),
		Size = UDim2.new(1, -280, 0, 10),
		BackgroundColor3 = T.Field,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, container)
	corner(track, 999)
	local fill = make("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = T.Accent,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 999)
	local knob = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = T.Value,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, track)
	corner(knob, 999)

	local minv, maxv = min or 0, max or 100
	local value = math.clamp(default or minv, minv, maxv)
	local control = { Instance = container, Value = value, Observers = {} }
	local function ratio()
		return (value - minv) / math.max(0.0001, maxv - minv)
	end
	local function render()
		local r = ratio()
		tween(fill, TI_FAST, { Size = UDim2.fromScale(r, 1) })
		tween(knob, TI_FAST, { Position = UDim2.fromScale(r, 0.5) })
		valueLabel.Text = tostring(math.floor(value * 100) / 100)
	end
	function control:Get()
		return value
	end
	function control:Set(nextValue, silent)
		value = math.clamp(tonumber(nextValue) or minv, minv, maxv)
		self.Value = value
		render()
		if not silent and callback then
			spawnCallback("Slider: " .. tostring(text), callback, value)
		end
		if not silent then
			for _, observer in ipairs(self.Observers) do
				spawnCallback("Slider observer: " .. tostring(text), observer, value)
			end
		end
		return self
	end
	function control:SetValue(nextValue)
		return self:Set(nextValue)
	end
	function control:OnChanged(observer)
		if type(observer) == "function" then
			self.Observers[#self.Observers + 1] = observer
		end
		return self
	end
	function control:SetDesc()
		return self
	end
	render()
	local function updateFromInput(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local abs = track.AbsoluteSize.X
		if abs <= 0 then
			return
		end
		local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / abs, 0, 1)
		control:Set(minv + rel * (maxv - minv))
	end
	self.window:bind(track.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.window.activeDrag = {
				Owner = control,
				Update = updateFromInput,
			}
			updateFromInput(input)
		end
	end)
	return control
end

function Card:AddDropdown(text, options, default, callback)
	local T = self.window.theme
	local touch = self.window.touch
	local win = self.window
	local h = touch and 58 or 54
	local values = type(options) == "table" and options or {}
	local current = default ~= nil and default or values[1]
	local container = make("TextButton", {
		Size = UDim2.new(1, 0, 0, h),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = self:nextOrder(),
	}, self.frame)
	container:SetAttribute("MammozUI", true)
	corner(container, 8)
	make("UIGradient", {
		Color = ColorSequence.new(T.ElementHover, T.Element),
		Rotation = 90,
	}, container)
	local line = stroke(container, T.ElementLine, 0, 1.4)
	local accentBar = make("Frame", {
		Name = "AccentBar",
		BackgroundColor3 = T.Accent,
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(3, 1),
		ZIndex = 2,
	}, container)
	corner(accentBar, 2)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(0, 224, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = tostring(text or "Dropdown"),
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
	}, container)
	local valueHolder = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.new(0.48, 0, 0, 34),
		BackgroundColor3 = T.FieldRaised,
		BorderSizePixel = 0,
	}, container)
	corner(valueHolder, 6)
	stroke(valueHolder, T.ElementLine, 0, 1.2)
	local valueLabel = make("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Font = Enum.Font.GothamMedium,
		Text = tostring(current or "Select"),
		TextSize = 13,
		TextColor3 = Color3.fromRGB(235, 247, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, valueHolder)
	local chev = makeChevron(valueHolder, 10, T.Label)
	chev.Position = UDim2.new(1, -13, 0.5)
	chev.AnchorPoint = Vector2.new(1, 0.5)

	local list = make("ScrollingFrame", {
		Name = "MammozDropdown",
		Visible = false,
		BackgroundColor3 = T.Card,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollingEnabled = true,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = T.Accent,
		ScrollBarImageTransparency = 0.08,
		ZIndex = 80,
	}, win.main)
	corner(list, 7)
	stroke(list, T.Accent, 0.08)
	local listLayout = make("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
	}, list)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 8),
	}, list)

	local open = false
	local entries = {}
	local entryConnections = {}
	local popupHeight = 48
	local proxy = { Instance = container, Value = current, Observers = {} }
	local popupInputBegan
	local popupInputChanged

	local function clearEntryConnections()
		for _, connection in ipairs(entryConnections) do
			pcall(function()
				connection:Disconnect()
			end)
		end
		table.clear(entryConnections)
	end

	local function bindEntry(signal, callbackFn)
		local connection = signal:Connect(function(...)
			invokeCallback("Dropdown entry: " .. tostring(text), callbackFn, ...)
		end)
		entryConnections[#entryConnections + 1] = connection
		return connection
	end

	local function syncPosition()
		local cAp, cAs = container.AbsolutePosition, container.AbsoluteSize
		local mAp, mAs = win.main.AbsolutePosition, win.main.AbsoluteSize
		local width = math.clamp(math.floor(cAs.X * 0.48), 240, 420)
		local x = cAp.X - mAp.X + cAs.X - width - 14
		local below = cAp.Y - mAp.Y + cAs.Y + 5
		local y = below + popupHeight <= mAs.Y - 10 and below or math.max(10, cAp.Y - mAp.Y - popupHeight - 5)
		list.Position = UDim2.fromOffset(x, y)
		list.Size = UDim2.fromOffset(width, popupHeight)
	end

	local function setOpen(on, fromManager)
		open = on == true and #values > 0
		if open then
			syncPosition()
			win:openPopup(proxy, {
				Close = function()
					setOpen(false, true)
				end,
				InputBegan = function(input)
					if popupInputBegan then
						popupInputBegan(input)
					end
				end,
				InputChanged = function(input)
					if popupInputChanged then
						popupInputChanged(input)
					end
				end,
			})
		elseif not fromManager then
			win:closePopup(proxy)
		end
		list.Visible = open
		tween(chev, TI_FAST, { Rotation = open and 180 or 0 })
		tween(line, TI_FAST, { Color = open and T.Accent or T.ElementLine })
	end

	local function choose(value, fireCallback)
		current = value
		proxy.Value = value
		valueLabel.Text = tostring(value ~= nil and value or "Select")
		setOpen(false)
		if fireCallback and callback then
			spawnCallback("Dropdown: " .. tostring(text), callback, value)
		end
		if fireCallback then
			for _, observer in ipairs(proxy.Observers) do
				spawnCallback("Dropdown observer: " .. tostring(text), observer, value)
			end
		end
	end

	local function rebuild(nextValues)
		values = type(nextValues) == "table" and nextValues or {}
		clearEntryConnections()
		for _, entry in ipairs(entries) do
			if entry.Parent then
				entry:Destroy()
			end
		end
		table.clear(entries)
		for index, option in ipairs(values) do
			local optionValue = option
			local button = make("TextButton", {
				Size = UDim2.new(1, 0, 0, touch and 40 or 36),
				BackgroundColor3 = T.FieldRaised,
				BorderSizePixel = 0,
				Text = tostring(optionValue),
				TextSize = 13,
				TextColor3 = Color3.fromRGB(235, 247, 255),
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				LayoutOrder = index,
				ZIndex = 81,
			}, list)
			button:SetAttribute("MammozUI", true)
			corner(button, 5)
			make("UIPadding", { PaddingLeft = UDim.new(0, 12) }, button)
			entries[#entries + 1] = button
			bindEntry(button.MouseEnter, function()
				tween(button, TI_FAST, { BackgroundColor3 = T.NavActive, TextColor3 = Color3.fromRGB(255, 255, 255) })
			end)
			bindEntry(button.MouseLeave, function()
				tween(button, TI_FAST, { BackgroundColor3 = T.FieldRaised, TextColor3 = Color3.fromRGB(235, 247, 255) })
			end)
			bindEntry(button.MouseButton1Click, function()
				choose(optionValue, true)
			end)
		end
		local itemHeight = touch and 40 or 36
		local contentHeight = 12 + #values * itemHeight + math.max(0, #values - 1) * 4
		popupHeight = math.clamp(contentHeight, 48, touch and 260 or 234)
		list.CanvasSize = UDim2.fromOffset(0, contentHeight)
		if current == nil and values[1] ~= nil then
			choose(values[1], false)
		end
		if open then
			syncPosition()
		end
	end

	function proxy:Get()
		return current
	end
	function proxy:Set(value)
		choose(value, true)
		return self
	end
	function proxy:Select(value)
		return self:Set(value)
	end
	function proxy:SetValue(value)
		return self:Set(value)
	end
	function proxy:SetValues(nextValues)
		rebuild(nextValues)
		return self
	end
	function proxy:SetOptions(nextValues)
		return self:SetValues(nextValues)
	end
	function proxy:Refresh(nextValues, value)
		if type(nextValues) == "table" then
			rebuild(nextValues)
		end
		if value ~= nil then
			choose(value, false)
		end
		return self
	end
	function proxy:Open()
		setOpen(true)
		return self
	end
	function proxy:Close()
		setOpen(false)
		return self
	end
	function proxy:OnChanged(observer)
		if type(observer) == "function" then
			self.Observers[#self.Observers + 1] = observer
		end
		return self
	end
	function proxy:SetDesc()
		return self
	end

	rebuild(values)
	choose(current, false)
	win:bind(container:GetPropertyChangedSignal("AbsolutePosition"), function()
		if open then
			syncPosition()
		end
	end)
	win:bind(container.MouseEnter, function()
		tween(line, TI_FAST, { Color = T.Accent })
	end)
	win:bind(container.MouseLeave, function()
		if not open then
			tween(line, TI_FAST, { Color = T.ElementLine })
		end
	end)
	win:bind(container.MouseButton1Click, function()
		setOpen(not open)
	end)
	popupInputBegan = function(input)
		if not open then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local point = input.Position
		local cAp, cAs = container.AbsolutePosition, container.AbsoluteSize
		local lAp, lAs = list.AbsolutePosition, list.AbsoluteSize
		local inContainer = point.X >= cAp.X and point.X <= cAp.X + cAs.X and point.Y >= cAp.Y and point.Y <= cAp.Y + cAs.Y
		local inList = point.X >= lAp.X and point.X <= lAp.X + lAs.X and point.Y >= lAp.Y and point.Y <= lAp.Y + lAs.Y
		if not inContainer and not inList then
			setOpen(false)
		end
	end
	popupInputChanged = function(input)
		if not open or input.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end
		local point = UserInputService:GetMouseLocation()
		local ap, size = list.AbsolutePosition, list.AbsoluteSize
		if point.X < ap.X or point.X > ap.X + size.X or point.Y < ap.Y or point.Y > ap.Y + size.Y then
			return
		end
		local maxY = math.max(0, list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y)
		list.CanvasPosition = Vector2.new(0, math.clamp(list.CanvasPosition.Y - input.Position.Z * 48, 0, maxY))
	end
	win:addCleanup(function()
		win:closePopup(proxy)
		clearEntryConnections()
		if list and list.Parent then
			list:Destroy()
		end
	end)
	return proxy
end

return MammozUI
