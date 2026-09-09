if not game:IsLoaded() then
    game.Loaded:Wait()
end

--[[
	Mammoz Hub
	Rayfield wrapper using the no-notification source requested by the project.

	Quick start:
		local MammozHub = loadstring(readfile("Mammoz Hub/MammozHub.lib.lua"), "MammozHub")()
		local Window = MammozHub:CreateWindow()
		local Main = MammozHub:CreateTab(Window, "Main", 0)
		MammozHub:Button(Main, "Run", function()
			print("Mammoz Hub")
		end)
]]

local PeterHubV2 = {
	Name = "Mammoz Hub",
	FolderName = "MammozHub",
	RayfieldUrl = "https://raw.githubusercontent.com/MrAhmed13/Scripts/refs/heads/main/rayfield%20no%20notification",
	Rayfield = nil,
}

PeterHubV2.BlueTheme = {
	TextColor = Color3.fromRGB(232, 244, 255),

	Background = Color3.fromRGB(8, 13, 24),
	Topbar = Color3.fromRGB(12, 24, 42),
	Shadow = Color3.fromRGB(3, 6, 12),

	NotificationBackground = Color3.fromRGB(10, 18, 32),
	NotificationActionsBackground = Color3.fromRGB(219, 238, 255),

	TabBackground = Color3.fromRGB(16, 33, 58),
	TabStroke = Color3.fromRGB(35, 77, 126),
	TabBackgroundSelected = Color3.fromRGB(73, 166, 255),
	TabTextColor = Color3.fromRGB(190, 219, 247),
	SelectedTabTextColor = Color3.fromRGB(4, 18, 32),

	ElementBackground = Color3.fromRGB(13, 25, 43),
	ElementBackgroundHover = Color3.fromRGB(18, 37, 63),
	SecondaryElementBackground = Color3.fromRGB(9, 18, 32),
	ElementStroke = Color3.fromRGB(36, 78, 128),
	SecondaryElementStroke = Color3.fromRGB(26, 58, 96),

	SliderBackground = Color3.fromRGB(16, 72, 126),
	SliderProgress = Color3.fromRGB(58, 161, 255),
	SliderStroke = Color3.fromRGB(99, 190, 255),

	ToggleBackground = Color3.fromRGB(10, 22, 38),
	ToggleEnabled = Color3.fromRGB(31, 145, 255),
	ToggleDisabled = Color3.fromRGB(65, 83, 104),
	ToggleEnabledStroke = Color3.fromRGB(97, 190, 255),
	ToggleDisabledStroke = Color3.fromRGB(94, 112, 135),
	ToggleEnabledOuterStroke = Color3.fromRGB(36, 95, 159),
	ToggleDisabledOuterStroke = Color3.fromRGB(46, 58, 76),

	DropdownSelected = Color3.fromRGB(20, 50, 84),
	DropdownUnselected = Color3.fromRGB(10, 22, 38),

	InputBackground = Color3.fromRGB(8, 18, 32),
	InputStroke = Color3.fromRGB(44, 91, 147),
	PlaceholderColor = Color3.fromRGB(121, 150, 181),
}

PeterHubV2.VisualTheme = {
	Accent = Color3.fromRGB(45, 156, 255),
	AccentHover = Color3.fromRGB(83, 188, 255),
	AccentSoft = Color3.fromRGB(15, 50, 88),
	Success = Color3.fromRGB(59, 226, 170),
	Warning = Color3.fromRGB(111, 190, 255),
	Error = Color3.fromRGB(255, 110, 120),
	Root = Color3.fromRGB(5, 12, 24),
	RootTransparency = 0.08,
	Sidebar = Color3.fromRGB(7, 16, 31),
	SidebarTransparency = 0.07,
	Panel = Color3.fromRGB(9, 23, 42),
	PanelTransparency = 0.08,
	Card = Color3.fromRGB(8, 21, 39),
	CardTransparency = 0.05,
	Field = Color3.fromRGB(4, 12, 24),
	FieldTransparency = 0.04,
	Stroke = Color3.fromRGB(42, 126, 202),
	StrokeSoft = Color3.fromRGB(24, 67, 111),
	Text = Color3.fromRGB(232, 246, 255),
	Muted = Color3.fromRGB(145, 177, 205),
	Dim = Color3.fromRGB(83, 112, 142),
	Gold = Color3.fromRGB(111, 190, 255),
}

PeterHubV2.DefaultGames = {
	{
		Name = "Attack On Titan Rev.",
		Description = "AOTR - Titan Farm",
		Details = "Auto Farm, Titan Kill, Auto Quest",
		Status = "FREE",
		PlaceId = 13379208636,
	},
	{
		Name = "Anime Card Farm",
		Description = "Auto Pack - Reroll",
		Details = "Pack opener, card fusion and farm",
		Status = "FREE",
		PlaceId = 125039475354804,
	},
	{
		Name = "Arena Sniper",
		Description = "Auto Kill - Sniper",
		Details = "Hitbox expand, auto shoot and kill",
		Status = "FREE",
		PlaceId = 122446657157717,
	},
	{
		Name = "Roll Anime To Fight",
		Description = "RATF - Auto Roll",
		Details = "Auto roll, auto fight bosses, upgrades",
		Status = "FREE",
		PlaceId = 107653945083776,
	},
	{
		Name = "Gakuran",
		Description = "GKR - Auto Farm",
		Details = "Auto combat, auto quest, skill spam",
		Status = "FREE",
		PlaceId = 128736949265057,
	},
	{
		Name = "99 Nights",
		Description = "99Nights - Forest",
		Details = "Auto survive, wood/scrap farm, AFK",
		Status = "FREE",
		PlaceId = 126509999114328,
	},
	{
		Name = "Shindo Life",
		Description = "Shindo Life - Ninja RPG",
		Details = "Shindo Life protected route",
		Status = "FREE",
		PlaceId = 4616652839,
	},
	{
		Name = "Mine a Mountain",
		Description = "MaM - Auto Mine",
		Details = "Unlock VIP and auto mine routes",
		Status = "VIP",
		PlaceId = 0,
	},
	{
		Name = "Dungeon Quest Reborn",
		Description = "DQR - Auto Farm",
		Details = "Auto dungeon, kite, dodge, difficulty climb, gear management",
		Status = "FREE",
		PlaceId = 77649408247578,
	},
	{
		Name = "Murder Mystery 2",
		Description = "MM2 - Exclusive",
		Details = "VIP maps and exclusive features",
		Status = "VIP",
		PlaceId = 142823291,
	},
}

local HUD_ICON_ASSETS = {
	key = {
		Id = 16898613509,
		Offset = Vector2.new(967, 306),
		Size = Vector2.new(48, 48),
	},
	discord = {
		Id = 16898613613,
		Offset = Vector2.new(563, 820),
		Size = Vector2.new(48, 48),
	},
	hwid = {
		Id = 16898613044,
		Offset = Vector2.new(820, 563),
		Size = Vector2.new(48, 48),
	},
	vip = {
		Id = 16898613044,
		Offset = Vector2.new(404, 918),
		Size = Vector2.new(48, 48),
	},
	verify = {
		Id = 16898612629,
		Offset = Vector2.new(967, 147),
		Size = Vector2.new(48, 48),
	},
	play = {
		Id = 16898613699,
		Offset = Vector2.new(918, 257),
		Size = Vector2.new(48, 48),
	},
	farm = {
		Id = 16898613869,
		Offset = Vector2.new(453, 967),
		Size = Vector2.new(48, 48),
	},
	combat = {
		Id = 16898613777,
		Offset = Vector2.new(967, 759),
		Size = Vector2.new(48, 48),
	},
	aim = {
		Id = 16898613869,
		Offset = Vector2.new(514, 771),
		Size = Vector2.new(48, 48),
	},
	utility = {
		Id = 16898613869,
		Offset = Vector2.new(918, 906),
		Size = Vector2.new(48, 48),
	},
}

local INTERNAL_WINDOW_KEYS = {
	RayfieldUrl = true,
	DisableRayfieldRequests = true,
	SecureMode = true,
	Scripts = true,
	HomeTabName = true,
	HomeIcon = true,
	SectionName = true,
	Description = true,
	OnlyCurrentGame = true,
	SettingsTab = true,
}

local function safeGetGenv()
	if type(getgenv) ~= "function" then
		return nil
	end

	local ok, env = pcall(getgenv)
	if ok and type(env) == "table" then
		return env
	end

	return nil
end

local function httpGet(url)
	local requestFunction = nil

	if type(syn) == "table" and type(syn.request) == "function" then
		requestFunction = syn.request
	elseif type(http) == "table" and type(http.request) == "function" then
		requestFunction = http.request
	elseif type(http_request) == "function" then
		requestFunction = http_request
	elseif type(request) == "function" then
		requestFunction = request
	end

	if requestFunction then
		local ok, response = pcall(requestFunction, {
			Url = url,
			Method = "GET",
		})

		if ok then
			if type(response) == "table" then
				local statusCode = response.StatusCode or response.status_code or response.Status or 200
				local body = response.Body or response.body or response.Response or ""

				if statusCode >= 200 and statusCode < 300 and type(body) == "string" and body ~= "" then
					return body
				end

				return nil, "HTTP " .. tostring(statusCode)
			elseif type(response) == "string" and response ~= "" then
				return response
			end
		end
	end

	local ok, body = pcall(function()
		return game:HttpGet(url, true)
	end)

	if ok and type(body) == "string" and body ~= "" then
		return body
	end

	return nil, tostring(body)
end

local function copyTable(source)
	local result = {}

	for key, value in pairs(source or {}) do
		if type(value) == "table" then
			result[key] = copyTable(value)
		else
			result[key] = value
		end
	end

	return result
end

local function mergeTables(base, override)
	local result = copyTable(base)

	for key, value in pairs(override or {}) do
		if type(value) == "table" and type(result[key]) == "table" and key ~= "Theme" and key ~= "KeySettings" then
			result[key] = mergeTables(result[key], value)
		else
			result[key] = value
		end
	end

	return result
end

local function cleanWindowSettings(settings)
	local clean = {}

	for key, value in pairs(settings or {}) do
		if not INTERNAL_WINDOW_KEYS[key] then
			clean[key] = value
		end
	end

	return clean
end

local function makeFlag(name)
	local flag = tostring(name or "Flag"):gsub("%W+", "")
	if flag == "" then
		flag = "Flag"
	end

	return flag
end

function PeterHubV2:CopyTable(source)
	return copyTable(source)
end

function PeterHubV2:GetDefaultWindowSettings()
	return {
		Name = self.Name,
		LoadingTitle = self.Name,
		LoadingSubtitle = "Blue Edition",
		ShowText = self.Name,
		Icon = 0,
		Theme = copyTable(self.BlueTheme),
		DisableBuildWarnings = true,
		ConfigurationSaving = {
			Enabled = true,
			FolderName = self.FolderName,
			FileName = "Settings",
		},
		Discord = {
			Enabled = false,
		},
		KeySystem = false,
	}
end

function PeterHubV2:LoadRayfield(options)
	options = options or {}

	if self.Rayfield then
		return self.Rayfield
	end

	local env = safeGetGenv()
	if env and options.DisableRayfieldRequests ~= false then
		env.DISABLE_RAYFIELD_REQUESTS = true
	end
	if env and options.SecureMode then
		env.RAYFIELD_SECURE = true
	end

	local source, fetchError = httpGet(options.RayfieldUrl or self.RayfieldUrl)
	assert(source and source ~= "", "[Mammoz Hub] Could not fetch Rayfield: " .. tostring(fetchError))

	local chunk, compileError = loadstring(source, "RayfieldNoNotification")
	assert(chunk, "[Mammoz Hub] Rayfield compile error: " .. tostring(compileError))

	local ok, rayfield = pcall(chunk)
	assert(ok and type(rayfield) == "table", "[Mammoz Hub] Rayfield load error: " .. tostring(rayfield))

	if type(rayfield.Theme) == "table" then
		rayfield.Theme.PeterHubBlue = copyTable(self.BlueTheme)
	end

	self.Rayfield = rayfield
	return rayfield
end

function PeterHubV2:CreateWindow(settings)
	settings = settings or {}

	local rayfield = self:LoadRayfield(settings)
	local windowSettings = mergeTables(self:GetDefaultWindowSettings(), cleanWindowSettings(settings))

	if windowSettings.Theme == "Blue" or windowSettings.Theme == "PeterHubBlue" then
		windowSettings.Theme = copyTable(self.BlueTheme)
	elseif windowSettings.Theme == nil then
		windowSettings.Theme = copyTable(self.BlueTheme)
	end

	return rayfield:CreateWindow(windowSettings), rayfield
end

function PeterHubV2:CreateTab(window, name, icon)
	assert(window and type(window.CreateTab) == "function", "[Mammoz Hub] CreateTab needs a Rayfield window.")
	return window:CreateTab(name or "Main", icon or 0)
end

function PeterHubV2:Section(tab, name)
	if tab and type(tab.CreateSection) == "function" then
		return tab:CreateSection(name or "")
	end

	return nil
end

function PeterHubV2:Paragraph(tab, title, content)
	if tab and type(tab.CreateParagraph) == "function" then
		return tab:CreateParagraph({
			Title = title or self.Name,
			Content = content or "",
		})
	end

	return nil
end

function PeterHubV2:Button(tab, name, callback)
	assert(tab and type(tab.CreateButton) == "function", "[Mammoz Hub] Button needs a Rayfield tab.")
	return tab:CreateButton({
		Name = name or "Button",
		Callback = callback or function() end,
	})
end

function PeterHubV2:Toggle(tab, name, default, callback, flag)
	assert(tab and type(tab.CreateToggle) == "function", "[Mammoz Hub] Toggle needs a Rayfield tab.")
	return tab:CreateToggle({
		Name = name or "Toggle",
		CurrentValue = default and true or false,
		Flag = flag or makeFlag(name),
		Callback = callback or function() end,
	})
end

function PeterHubV2:Slider(tab, name, min, max, default, increment, callback, suffix, flag)
	assert(tab and type(tab.CreateSlider) == "function", "[Mammoz Hub] Slider needs a Rayfield tab.")
	return tab:CreateSlider({
		Name = name or "Slider",
		Range = { min or 0, max or 100 },
		Increment = increment or 1,
		Suffix = suffix or "",
		CurrentValue = default or min or 0,
		Flag = flag or makeFlag(name),
		Callback = callback or function() end,
	})
end

function PeterHubV2:Dropdown(tab, name, options, default, callback, multiple, flag)
	assert(tab and type(tab.CreateDropdown) == "function", "[Mammoz Hub] Dropdown needs a Rayfield tab.")

	options = options or {}
	local currentOption = default
	if type(currentOption) ~= "table" then
		currentOption = { currentOption or options[1] or "" }
	end

	return tab:CreateDropdown({
		Name = name or "Dropdown",
		Options = options,
		CurrentOption = currentOption,
		MultipleOptions = multiple and true or false,
		Flag = flag or makeFlag(name),
		Callback = callback or function() end,
	})
end

function PeterHubV2:Input(tab, name, placeholder, default, callback, flag, removeTextAfterFocusLost)
	assert(tab and type(tab.CreateInput) == "function", "[Mammoz Hub] Input needs a Rayfield tab.")
	return tab:CreateInput({
		Name = name or "Input",
		CurrentValue = default or "",
		PlaceholderText = placeholder or "",
		RemoveTextAfterFocusLost = removeTextAfterFocusLost and true or false,
		Flag = flag or makeFlag(name),
		Callback = callback or function() end,
	})
end

function PeterHubV2:Notify(title, content, duration, image)
	local rayfield = self.Rayfield

	if rayfield and type(rayfield.Notify) == "function" then
		return rayfield:Notify({
			Title = title or self.Name,
			Content = content or "",
			Duration = duration or 4,
			Image = image or 4483362458,
		})
	end

	warn("[Mammoz Hub] " .. tostring(title or self.Name) .. ": " .. tostring(content or ""))
	return nil
end

function PeterHubV2:RunSource(source, chunkName)
	if type(source) ~= "string" or source == "" then
		return false, "empty source"
	end

	local chunk, compileError = loadstring(source, chunkName or "PeterHubV2Script")
	if not chunk then
		return false, compileError
	end

	local ok, runtimeError = pcall(chunk)
	if not ok then
		return false, runtimeError
	end

	return true
end

function PeterHubV2:RunUrl(url, chunkName)
	if type(url) ~= "string" or url == "" then
		return false, "empty url"
	end

	local source, fetchError = httpGet(url)
	if not source then
		return false, fetchError
	end

	return self:RunSource(source, chunkName or url)
end

function PeterHubV2:CreateLoaderWindow(options)
	options = options or {}

	local scripts = options.Scripts or {}
	local window = self:CreateWindow(options)
	local home = self:CreateTab(window, options.HomeTabName or "Home", options.HomeIcon or 0)

	self:Section(home, options.SectionName or "Loader")
	if options.Description ~= false then
		self:Paragraph(home, self.Name, options.Description or "Blue Rayfield loader is ready.")
	end

	local shownScripts = 0
	local matchedCurrentGame = false

	for index, scriptInfo in ipairs(scripts) do
		local name = scriptInfo.Name or scriptInfo.name or ("Script " .. tostring(index))
		local placeIds = scriptInfo.PlaceIds or scriptInfo.placeIds
		local showScript = true

		if options.OnlyCurrentGame and type(placeIds) == "table" then
			showScript = false

			for _, placeId in ipairs(placeIds) do
				if tostring(placeId) == tostring(game.PlaceId) then
					showScript = true
					matchedCurrentGame = true
					break
				end
			end
		end

		if showScript then
			shownScripts = shownScripts + 1
			self:Button(home, name, function()
				local callback = scriptInfo.Callback or scriptInfo.callback
				local source = scriptInfo.Source or scriptInfo.source
				local url = scriptInfo.Url or scriptInfo.url

				if callback then
					callback(scriptInfo, self, window)
					return
				end

				local ok, err
				if source then
					ok, err = self:RunSource(source, name)
				elseif url then
					ok, err = self:RunUrl(url, name)
				else
					ok, err = false, "missing Url, Source, or Callback"
				end

				if not ok then
					warn("[Mammoz Hub] " .. tostring(name) .. " failed: " .. tostring(err))
				end
			end)
		end
	end

	if shownScripts == 0 then
		if options.OnlyCurrentGame and not matchedCurrentGame then
			self:Paragraph(home, "No script found", "No script entry matches this PlaceId: " .. tostring(game.PlaceId))
		else
			self:Paragraph(home, "No scripts", "Add entries to the Scripts table in loader.lua.")
		end
	end

	if options.SettingsTab ~= false then
		local settingsTab = self:CreateTab(window, "Settings", 0)
		self:Section(settingsTab, "Window")
		self:Button(settingsTab, "Apply Blue Theme", function()
			if window and type(window.ModifyTheme) == "function" then
				window.ModifyTheme(copyTable(self.BlueTheme))
			end
		end)
		self:Button(settingsTab, "Destroy UI", function()
			if self.Rayfield and type(self.Rayfield.Destroy) == "function" then
				self.Rayfield:Destroy()
			end
		end)
	end

	return window, home, self.Rayfield
end

local function uiMake(className, properties, parent)
	local object = Instance.new(className)
	for property, value in pairs(properties or {}) do
		object[property] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function uiCorner(object, radius)
	return uiMake("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
	}, object)
end

local function uiStroke(object, color, thickness, transparency)
	return uiMake("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
	}, object)
end

local function uiPadding(object, left, right, top, bottom)
	return uiMake("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	}, object)
end

local function uiList(object, direction, padding)
	return uiMake("UIListLayout", {
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, padding or 0),
	}, object)
end

local function guiParent(player)
	local candidates = {}
	local function add(candidate)
		if not candidate then
			return
		end
		for _, existing in ipairs(candidates) do
			if existing == candidate then
				return
			end
		end
		candidates[#candidates + 1] = candidate
	end

	if type(gethui) == "function" then
		local ok, parent = pcall(gethui)
		if ok then
			add(parent)
		end
	end
	if type(get_hidden_gui) == "function" then
		local ok, parent = pcall(get_hidden_gui)
		if ok then
			add(parent)
		end
	end

	local coreOk, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if coreOk then
		add(coreGui)
	end

	if player then
		local playerOk, playerGui = pcall(function()
			return player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 5)
		end)
		if playerOk then
			add(playerGui)
		end
	end

	return candidates
end

local function firstLetter(text)
	text = tostring(text or "P")
	return string.upper(string.sub(text, 1, 1))
end

local function getPrimaryPlaceId(gameInfo)
	if not gameInfo then
		return nil
	end

	if gameInfo.PlaceId then
		return gameInfo.PlaceId
	end

	local placeIds = gameInfo.PlaceIds or gameInfo.placeIds
	if type(placeIds) == "table" then
		return placeIds[1]
	end

	return gameInfo.Id or gameInfo.id
end

-- rbxthumb://type=GameIcon / GameThumbnail need the *universe* id, not the
-- place id. Many games have place != universe, so thumbnails built from the
-- place id silently fail to load. We resolve universe ids once at startup
-- via the multiget place-details endpoint and cache them here.
local universeCache = {}
-- Cached real thumbnail URLs (from thumbnails.roblox.com -> tr.rbxcdn.com).
-- Keyed by place id: { icon = "...", preview = "..." }. The rbxthumb:// scheme
-- fails to load on some executors and for some games, so we prefer the direct
-- CDN URL when we can resolve one.
local thumbnailCache = {}
local function httpGetJson(url)
	local ok, body = pcall(function()
		return game:HttpGet(url, true)
	end)
	if not ok or type(body) ~= "string" or body == "" then
		return nil
	end
	local HttpService
	pcall(function() HttpService = game:GetService("HttpService") end)
	if type(HttpService) ~= "table" or type(HttpService.JSONDecode) ~= "function" then
		return nil
	end
	local decOk, data = pcall(function()
		return HttpService:JSONDecode(body)
	end)
	if not decOk or type(data) ~= "table" then
		return nil
	end
	return data
end
local function resolveUniverseIdsForGames(games)
	local placeIds = {}
	local seen = {}
	for _, gameInfo in ipairs(games or {}) do
		local pid = tonumber(getPrimaryPlaceId(gameInfo))
		if pid and pid > 0 and not seen[pid] then
			seen[pid] = true
			placeIds[#placeIds + 1] = pid
		end
	end
	if #placeIds == 0 then
		return
	end
	local resolved = 0
	-- Batch attempt first (one or two requests). Note: this endpoint started
	-- requiring auth for anonymous callers, so it may return nothing here —
	-- the per-place fallback below covers that case.
	for i = 1, #placeIds, 100 do
		local chunk = {}
		for j = i, math.min(i + 99, #placeIds) do
			chunk[#chunk + 1] = tostring(placeIds[j])
		end
		local url = "https://games.roblox.com/v1/games/multiget-place-details?placeIds=" .. table.concat(chunk, ",")
		local data = httpGetJson(url)
		if not data then
			-- Try the public mirror if the direct endpoint is blocked.
			data = httpGetJson("https://games.roproxy.com/v1/games/multiget-place-details?placeIds=" .. table.concat(chunk, ","))
		end
		if type(data) == "table" then
			for _, entry in ipairs(data) do
				if type(entry) == "table" and entry.universeId then
					universeCache[tonumber(entry.placeId)] = tonumber(entry.universeId)
					resolved = resolved + 1
				end
			end
		end
	end
	if resolved > 0 then
		return
	end
	-- Fallback: resolve one place at a time via the anonymous single-place
	-- endpoint. Slow (~1 request per game), so the caller must run this in a
	-- background task; a short pause every few requests keeps us polite.
	for index, pid in ipairs(placeIds) do
		local data = httpGetJson("https://apis.roblox.com/universes/v1/places/" .. tostring(pid) .. "/universe")
		if not data then
			data = httpGetJson("https://apis.roproxy.com/universes/v1/places/" .. tostring(pid) .. "/universe")
		end
		if type(data) == "table" and data.universeId then
			universeCache[pid] = tonumber(data.universeId)
		end
		if index % 8 == 0 then
			task.wait(0.2)
		end
	end
end

-- Pull the first real thumbnail/icon URL for every resolved universe and cache
-- it by place id. Best-effort: failures fall back to rbxthumb:// later.
local function resolveThumbnailsForGames(games)
	local placeToUniverse = {}
	local universeSet = {}
	for _, gameInfo in ipairs(games or {}) do
		local pid = tonumber(getPrimaryPlaceId(gameInfo))
		if pid and pid > 0 and universeCache[pid] then
			placeToUniverse[pid] = universeCache[pid]
			universeSet[universeCache[pid]] = true
		end
	end
	local uidList = {}
	for uid in pairs(universeSet) do
		uidList[#uidList + 1] = tostring(uid)
	end
	if #uidList == 0 then
		return
	end
	-- Build a reverse lookup universe -> place so we can store by place id.
	local universeToPlaces = {}
	for pid, uid in pairs(placeToUniverse) do
		universeToPlaces[uid] = universeToPlaces[uid] or {}
		table.insert(universeToPlaces[uid], pid)
	end
	local function storeByUniverse(universeId, kind, imageUrl)
		local places = universeToPlaces[universeId]
		if not places then
			return
		end
		for _, pid in ipairs(places) do
			thumbnailCache[pid] = thumbnailCache[pid] or {}
			thumbnailCache[pid][kind] = imageUrl
		end
	end
	local function fetchChunk(kind, endpoint, sizeParam)
		for i = 1, #uidList, 100 do
			local chunk = {}
			for j = i, math.min(i + 99, #uidList) do
				chunk[#chunk + 1] = uidList[j]
			end
			local param = kind == "icon" and ("universeIds=" .. table.concat(chunk, ",") .. "&size=" .. sizeParam .. "&format=Png&isCircular=false")
				or ("universeIds=" .. table.concat(chunk, ",") .. "&size=" .. sizeParam .. "&format=Webp&isCircular=false")
			local url = "https://thumbnails.roblox.com/v1/games/" .. endpoint .. "?" .. param
			local data = httpGetJson(url)
			if not data then
				data = httpGetJson("https://thumbnails.roproxy.com/v1/games/" .. endpoint .. "?" .. param)
			end
			if type(data) == "table" and type(data.data) == "table" then
				for _, entry in ipairs(data.data) do
					if type(entry) == "table" and entry.imageUrl and entry.targetId then
						storeByUniverse(tonumber(entry.targetId), kind, entry.imageUrl)
					end
				end
			end
		end
	end
	fetchChunk("icon", "icons", "150x150")
	fetchChunk("preview", "thumbnails", "768x432")
end

local function thumbIdFor(gameInfo)
	local placeId = tonumber(getPrimaryPlaceId(gameInfo))
	if not placeId or placeId <= 0 then
		return nil
	end
	-- Prefer the resolved universe id; fall back to the place id so older
	-- games (where place == universe root) still render.
	return universeCache[placeId] or placeId
end

local function gameImage(gameInfo)
	if gameInfo.Image then
		return gameInfo.Image
	end
	if gameInfo.Icon then
		return gameInfo.Icon
	end
	if gameInfo.ImageId then
		return "rbxassetid://" .. tostring(gameInfo.ImageId)
	end

	-- Prefer a real CDN URL resolved at startup; rbxthumb:// fails on some
	-- executors and for some games.
	local pid = tonumber(getPrimaryPlaceId(gameInfo))
	if pid and thumbnailCache[pid] and thumbnailCache[pid].icon then
		return thumbnailCache[pid].icon
	end

	local id = thumbIdFor(gameInfo)
	if id then
		return "rbxthumb://type=GameIcon&id=" .. tostring(id) .. "&w=150&h=150"
	end

	return nil
end

local function gamePreviewImage(gameInfo)
	if gameInfo.PreviewImage then
		return gameInfo.PreviewImage
	end
	if gameInfo.BannerImage then
		return gameInfo.BannerImage
	end

	local pid = tonumber(getPrimaryPlaceId(gameInfo))
	if pid and thumbnailCache[pid] and thumbnailCache[pid].preview then
		return thumbnailCache[pid].preview
	end

	local id = thumbIdFor(gameInfo)
	if id then
		return "rbxthumb://type=GameThumbnail&id=" .. tostring(id) .. "&w=768&h=432"
	end

	return gameImage(gameInfo)
end

local function gameRecommendedFeatures(gameInfo)
	local direct = gameInfo.Features or gameInfo.Functions or gameInfo.FeatureTags
	if type(direct) == "table" and #direct > 0 then
		return direct
	end

	local text = string.lower(table.concat({
		tostring(gameInfo.Name or ""),
		tostring(gameInfo.Description or ""),
		tostring(gameInfo.Details or ""),
	}, " "))
	local result = {}
	local used = {}
	local function add(label)
		if not used[label] then
			used[label] = true
			result[#result + 1] = label
		end
	end

	if string.find(text, "auto farm", 1, true) or string.find(text, "farm", 1, true) then
		add("AUTO FARM")
	end
	if string.find(text, "aim", 1, true) or string.find(text, "sniper", 1, true) or string.find(text, "hitbox", 1, true) then
		add("AIM")
	end
	if string.find(text, "quest", 1, true) then
		add("AUTO QUEST")
	end
	if string.find(text, "boss", 1, true) or string.find(text, "titan", 1, true) then
		add("BOSS FARM")
	end
	if string.find(text, "roll", 1, true) or string.find(text, "reroll", 1, true) then
		add("AUTO ROLL")
	end
	if string.find(text, "pack", 1, true) or string.find(text, "card", 1, true) then
		add("CARD FARM")
	end
	if string.find(text, "survive", 1, true) or string.find(text, "afk", 1, true) then
		add("AFK FARM")
	end
	if string.find(text, "skill", 1, true) then
		add("SKILL SPAM")
	end

	if #result == 0 then
		add("AUTO FARM")
		add("AUTO QUEST")
		add("TELEPORT")
	end

	return result
end

local function featureIconName(feature)
	local text = string.lower(tostring(feature or ""))
	if string.find(text, "farm", 1, true)
		or string.find(text, "mine", 1, true)
		or string.find(text, "wood", 1, true)
		or string.find(text, "scrap", 1, true)
		or string.find(text, "ore", 1, true)
		or string.find(text, "pack", 1, true)
	then
		return "farm"
	end
	if string.find(text, "aim", 1, true)
		or string.find(text, "hitbox", 1, true)
		or string.find(text, "shoot", 1, true)
		or string.find(text, "sniper", 1, true)
		or string.find(text, "esp", 1, true)
	then
		return "aim"
	end
	if string.find(text, "kill", 1, true)
		or string.find(text, "combat", 1, true)
		or string.find(text, "fight", 1, true)
		or string.find(text, "boss", 1, true)
		or string.find(text, "titan", 1, true)
		or string.find(text, "skill", 1, true)
	then
		return "combat"
	end

	return "utility"
end

local function normalizeGameList(games)
	local output = {}

	for _, gameInfo in ipairs(games or {}) do
		output[#output + 1] = gameInfo
	end

	return output
end

local function mergeVisualTheme(baseTheme, overrideTheme)
	local theme = copyTable(baseTheme or {})

	for key, value in pairs(overrideTheme or {}) do
		theme[key] = value
	end

	return theme
end

local function connect(app, signal, callback)
	local connection = signal:Connect(callback)
	app.Connections[#app.Connections + 1] = connection
	return connection
end

local function createText(parent, text, size, color, font, properties)
	properties = properties or {}
	properties.BackgroundTransparency = properties.BackgroundTransparency == nil and 1 or properties.BackgroundTransparency
	properties.BorderSizePixel = 0
	properties.Font = font or Enum.Font.GothamMedium
	properties.Text = text or ""
	properties.TextColor3 = color
	properties.TextSize = size or 12
	properties.TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Left
	properties.TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center
	properties.Parent = nil

	return uiMake("TextLabel", properties, parent)
end

local function addDepth(parent, theme, level, radius)
	level = level or 1
	local shadowOffset = 4 + level * 2
	local shadowTransparency = math.clamp(0.7 - level * 0.1, 0.36, 0.76)
	local glowTransparency = math.clamp(0.88 - level * 0.08, 0.48, 0.9)

	local shadow = uiMake("Frame", {
		Name = "DepthShadow",
		AnchorPoint = parent.AnchorPoint,
		BackgroundColor3 = Color3.fromRGB(0, 3, 10),
		BackgroundTransparency = shadowTransparency,
		BorderSizePixel = 0,
		Position = parent.Position + UDim2.fromOffset(shadowOffset, shadowOffset),
		Size = parent.Size,
		ZIndex = math.max(0, (parent.ZIndex or 1) - 2),
	}, parent.Parent)
	uiCorner(shadow, radius or 8)

	local glow = uiMake("Frame", {
		Name = "DepthGlow",
		AnchorPoint = parent.AnchorPoint,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = parent.Position,
		Size = parent.Size,
		ZIndex = math.max(0, (parent.ZIndex or 1) - 1),
	}, parent.Parent)
	uiCorner(glow, radius or 8)
	uiStroke(glow, theme.Accent, math.max(1, level), glowTransparency)

	-- Keep the depth layers aligned with parent when it moves/resizes/hides.
	-- They are siblings of `parent` (parented to parent.Parent) so parent's
	-- ClipsDescendants does not crop them; without syncing they lag behind
	-- on drag and stay visible after a minimize (parent.Visible = false).
	shadow.Visible = parent.Visible
	glow.Visible = parent.Visible
	parent:GetPropertyChangedSignal("Position"):Connect(function()
		local position = parent.Position
		shadow.Position = position + UDim2.fromOffset(shadowOffset, shadowOffset)
		glow.Position = position
	end)
	parent:GetPropertyChangedSignal("Size"):Connect(function()
		shadow.Size = parent.Size
		glow.Size = parent.Size
	end)
	parent:GetPropertyChangedSignal("Visible"):Connect(function()
		local visible = parent.Visible
		shadow.Visible = visible
		glow.Visible = visible
	end)
	-- Shadow/glow are siblings of `parent`, so destroying the parent leaves
	-- them orphaned on screen. Clean them up together with the parent.
	parent.Destroying:Connect(function()
		if shadow.Parent then
			shadow:Destroy()
		end
		if glow.Parent then
			glow:Destroy()
		end
	end)

	return shadow, glow
end

local function createAssetIcon(parent, iconName, properties)
	local iconAsset = HUD_ICON_ASSETS[iconName]
	if not iconAsset then
		return nil
	end

	properties = properties or {}
	return uiMake("ImageLabel", {
		Name = properties.Name or "IconImage",
		AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://" .. tostring(iconAsset.Id),
		ImageColor3 = properties.Color3 or Color3.fromRGB(255, 255, 255),
		ImageRectOffset = iconAsset.Offset,
		ImageRectSize = iconAsset.Size,
		ImageTransparency = properties.Transparency or 0,
		Position = properties.Position or UDim2.new(),
		ScaleType = Enum.ScaleType.Fit,
		Size = properties.Size or UDim2.fromOffset(20, 20),
		ZIndex = properties.ZIndex or ((parent.ZIndex or 1) + 1),
	}, parent)
end

local function createButton(parent, theme, text, properties, callback)
	properties = properties or {}
	local button = uiMake("TextButton", {
		Name = properties.Name or tostring(text or "Button"),
		AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0),
		Position = properties.Position or UDim2.new(),
		Size = properties.Size or UDim2.fromOffset(120, 34),
		BackgroundColor3 = properties.BackgroundColor3 or theme.Accent,
		BackgroundTransparency = properties.BackgroundTransparency or 0,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = properties.LayoutOrder or 0,
		ZIndex = properties.ZIndex or 1,
	}, parent)
	uiCorner(button, properties.Radius or 8)
	local label = createText(button, text, properties.TextSize or 12, properties.TextColor3 or theme.Text, properties.Font or Enum.Font.GothamBold, {
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		ZIndex = button.ZIndex + 1,
	})

	if properties.StrokeColor then
		uiStroke(button, properties.StrokeColor, properties.StrokeThickness or 1, properties.StrokeTransparency or 0)
	end

	if callback then
		connect(properties.App, button.MouseButton1Click, callback)
	end

	if properties.App then
		connect(properties.App, button.MouseEnter, function()
			pcall(function()
				properties.App.TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = properties.HoverColor or theme.AccentHover,
				}):Play()
			end)
		end)
		connect(properties.App, button.MouseLeave, function()
			pcall(function()
				properties.App.TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = properties.BackgroundColor3 or theme.Accent,
				}):Play()
			end)
		end)
	end

	return button, label
end

local function createLogo(parent, theme, options, size)
	size = size or 72
	local holder = uiMake("Frame", {
		Name = "Logo",
		BackgroundColor3 = theme.AccentSoft,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(size, size),
		ClipsDescendants = true,
	}, parent)
	uiCorner(holder, 999)
	uiStroke(holder, theme.Accent, 2, 0)

	if options and options.LogoImage then
		uiMake("ImageLabel", {
			BackgroundTransparency = 1,
			Image = options.LogoImage,
			ScaleType = Enum.ScaleType.Crop,
			Size = UDim2.fromScale(1, 1),
		}, holder)
	else
		createText(holder, firstLetter(options and options.Name or "Mammoz Hub"), math.floor(size * 0.42), theme.Text, Enum.Font.GothamBlack, {
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end

	return holder
end

local function createGameThumb(parent, theme, gameInfo, size)
	size = size or 54
	local thumb = uiMake("Frame", {
		Name = "Thumb",
		BackgroundColor3 = theme.AccentSoft,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(size, size),
		ClipsDescendants = true,
	}, parent)
	uiCorner(thumb, 8)
	createText(thumb, firstLetter(gameInfo.Name), math.floor(size * 0.42), theme.Text, Enum.Font.GothamBlack, {
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	local image = gameImage(gameInfo)
	if image then
		uiMake("ImageLabel", {
			BackgroundTransparency = 1,
			Image = image,
			ScaleType = Enum.ScaleType.Crop,
			Size = UDim2.fromScale(1, 1),
			ZIndex = thumb.ZIndex + 1,
		}, thumb)
	end

	return thumb
end

function PeterHubV2:CreateStyledWindow(options)
	options = options or {}

	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local TeleportService = game:GetService("TeleportService")
	local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
	local LocalPlayer = Players.LocalPlayer
	local theme = mergeVisualTheme(self.VisualTheme, options.VisualTheme or options.Theme)
	local games = normalizeGameList(options.Scripts or options.Games or self.DefaultGames)
	local windowName = options.GuiName or "PeterHubV2Styled"

	for _, parent in ipairs(guiParent(LocalPlayer)) do
		local ok, children = pcall(function()
			return parent:GetChildren()
		end)
		if ok then
			for _, child in ipairs(children) do
				if child.Name == windowName then
					pcall(function()
						child:Destroy()
					end)
				end
			end
		end
	end

	local screen = uiMake("ScreenGui", {
		Name = windowName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = options.DisplayOrder or 999,
	})

	local attached = false
	for _, parent in ipairs(guiParent(LocalPlayer)) do
		local ok = pcall(function()
			screen.Parent = parent
		end)
		if ok and screen.Parent == parent then
			attached = true
			break
		end
	end
	assert(attached, "[Mammoz Hub] Could not attach styled ScreenGui.")

	local app = {
		Library = self,
		Screen = screen,
		Options = options,
		Theme = theme,
		Games = games,
		Connections = {},
		TweenService = TweenService,
		CurrentPage = nil,
		StatusLabel = nil,
		HudSlideIndex = 1,
		HudSlideToken = 0,
		LowEffects = options.LowEffects == true,
		ToastSerial = 0,
	}

	local rootWidth = options.Width or 1180
	local rootHeight = options.Height or 620
	local sidebarWidth = options.SidebarWidth or 210

	local root = uiMake("Frame", {
		Name = "Root",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(rootWidth, rootHeight),
		BackgroundColor3 = theme.Root,
		BackgroundTransparency = theme.RootTransparency,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Active = true,
	}, screen)
	uiCorner(root, 18)
	uiStroke(root, theme.Accent, 1.4, 0.08)
	addDepth(root, theme, 2, 18)
	app.Root = root

	for index = 1, 8 do
		uiMake("Frame", {
			Name = "CircuitVertical",
			BackgroundColor3 = index % 3 == 0 and theme.Accent or theme.StrokeSoft,
			BackgroundTransparency = index % 3 == 0 and 0.9 or 0.94,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(sidebarWidth + 24 + index * 84, 36),
			Size = UDim2.new(0, 1, 1, -72),
			ZIndex = 0,
		}, root)
	end
	for index = 1, 7 do
		uiMake("Frame", {
			Name = "CircuitHorizontal",
			BackgroundColor3 = index % 2 == 0 and theme.Accent or theme.StrokeSoft,
			BackgroundTransparency = index % 2 == 0 and 0.91 or 0.95,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(sidebarWidth + 22, 38 + index * 72),
			Size = UDim2.new(1, -(sidebarWidth + 50), 0, 1),
			ZIndex = 0,
		}, root)
	end
	for index = 1, 8 do
		uiMake("Frame", {
			Name = "CircuitSegment",
			BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 0.84 + ((index % 3) * 0.03),
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(sidebarWidth + 70 + index * 96, 52 + ((index * 53) % 470)),
			Rotation = index % 2 == 0 and 0 or 90,
			Size = UDim2.fromOffset(36 + (index % 2) * 28, 1),
			ZIndex = 0,
		}, root)
	end

	local scale = uiMake("UIScale", { Scale = 1 }, root)
	local function updateScale()
		local camera = workspace.CurrentCamera
		local viewportSize = camera and camera.ViewportSize or Vector2.new(1920, 1080)
		local nextScale = math.min(1, (viewportSize.X - 24) / rootWidth, (viewportSize.Y - 24) / rootHeight)
		scale.Scale = math.max(0.58, nextScale)
	end
	updateScale()
	if workspace.CurrentCamera then
		connect(app, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), updateScale)
	end

	local sidebar = uiMake("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = theme.Sidebar,
		BackgroundTransparency = theme.SidebarTransparency,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.new(0, sidebarWidth, 1, 0),
		ClipsDescendants = true,
	}, root)
	app.Sidebar = sidebar

	local divider = uiMake("Frame", {
		Name = "Divider",
		BackgroundColor3 = theme.StrokeSoft,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(sidebarWidth, 0),
		Size = UDim2.new(0, 1, 1, 0),
	}, root)
	app.Divider = divider

	local content = uiMake("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(sidebarWidth + 1, 0),
		Size = UDim2.new(1, -(sidebarWidth + 1), 1, 0),
		ClipsDescendants = true,
	}, root)
	app.Content = content

	local dragBar = uiMake("Frame", {
		Name = "DragBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -90, 0, 48),
		Active = true,
		ZIndex = 50,
	}, root)

	local controls = uiMake("Frame", {
		Name = "Controls",
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -16, 0, 16),
		Size = UDim2.fromOffset(70, 32),
		ZIndex = 60,
	}, root)
	uiList(controls, Enum.FillDirection.Horizontal, 8)

	local restorePanel
	local restoreShadow
	local restoreGlow
	-- Remember where the user dragged the restore chip so the next fold
	-- reopens it there instead of snapping back to the top-left corner.
	local lastRestorePosition
	local function destroyRestore()
		if restoreShadow then
			pcall(function() restoreShadow:Destroy() end)
			restoreShadow = nil
		end
		if restoreGlow then
			pcall(function() restoreGlow:Destroy() end)
			restoreGlow = nil
		end
		if restorePanel then
			restorePanel:Destroy()
			restorePanel = nil
		end
	end
	local function showRestore()
		if restorePanel and restorePanel.Parent then
			return
		end
		restorePanel = uiMake("Frame", {
			Name = "MammozRestore",
			Position = lastRestorePosition or UDim2.fromOffset(16, 16),
			Size = UDim2.fromOffset(196, 132),
			BackgroundColor3 = theme.Panel,
			BackgroundTransparency = 0.06,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Active = true,
			ZIndex = 80,
		}, screen)
		uiCorner(restorePanel, 14)
		uiStroke(restorePanel, theme.Accent, 1.4, 0.08)
		restoreShadow, restoreGlow = addDepth(restorePanel, theme, 2, 14)

		-- The mascot is shared with the sidebar so minimizing leaves the
		-- same elephant walking/jumping on a small draggable chip.
		app:BuildElephantMascot(restorePanel, {
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			AlwaysAnimate = true,
			LowEffects = app:IsLowEffects(),
		})

		local dragging = false
		local dragStart = nil
		local startPos = nil
		local moved = false
		connect(app, restorePanel.InputBegan, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = restorePanel.Position
				moved = false
				connect(app, input.Changed, function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		connect(app, UserInputService.InputChanged, function(input)
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
			local nextPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			restorePanel.Position = nextPosition
			lastRestorePosition = nextPosition
		end)
		connect(app, restorePanel.InputEnded, function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				-- Treat as a click only when the pointer barely moved, so a
				-- drag to reposition does not also reopen the window.
				if not moved then
					root.Visible = true
					if app.CurrentPage == "GetKey" then
						app:ShowGetKey()
					end
					destroyRestore()
				end
			end
		end)
	end

	createButton(controls, theme, "-", {
		App = app,
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = theme.Panel,
		HoverColor = theme.AccentSoft,
		StrokeColor = theme.StrokeSoft,
		TextSize = 16,
		ZIndex = 61,
	}, function()
		root.Visible = false
		showRestore()
	end)
	createButton(controls, theme, "x", {
		App = app,
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = theme.Panel,
		HoverColor = theme.Accent,
		StrokeColor = theme.StrokeSoft,
		TextSize = 13,
		ZIndex = 61,
	}, function()
		app:Destroy()
	end)

	local dragging = false
	local dragStart = nil
	local startPos = nil
	connect(app, dragBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = root.Position
			connect(app, input.Changed, function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	connect(app, UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - dragStart
		root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end)

	for index = 1, 38 do
		local dotSize = (index % 4 == 0) and 2 or 1
		local dot = uiMake("Frame", {
			Name = "Particle",
			BackgroundColor3 = Color3.fromRGB(255, 224, 234),
			BackgroundTransparency = 0.35 + ((index % 5) * 0.1),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(((index * 37) % 100) / 100, ((index * 61) % 100) / 100),
			Size = UDim2.fromOffset(dotSize, dotSize),
			ZIndex = 2,
		}, root)
		uiCorner(dot, 999)
	end

	function app:Clear(frame)
		for _, child in ipairs(frame:GetChildren()) do
			child:Destroy()
		end
	end

	function app:IsLowEffects()
		return self.LowEffects == true or self.Options.LowEffects == true
	end

	function app:HudEffectsAllowed()
		return not self:IsLowEffects()
			and self.CurrentPage == "GetKey"
			and self.Screen
			and self.Screen.Parent ~= nil
			and self.Root
			and self.Root.Parent ~= nil
			and self.Root.Visible == true
	end

	function app:EnsureHudSidebar()
		local lowEffects = self:IsLowEffects()
		if self.SidebarMode ~= "Hud" or self.SidebarLowEffectsState ~= lowEffects then
			self:BuildHudSidebar()
		end
	end

	function app:ShowToast(message, kind)
		message = tostring(message or "")
		if message == "" then
			return
		end

		if self.ActiveToast and self.ActiveToast.Parent then
			self.ActiveToast:Destroy()
		end

		self.ToastSerial = (self.ToastSerial or 0) + 1
		local serial = self.ToastSerial
		local tone = self.Theme.Accent
		local title = "NOTICE"
		if kind == "success" then
			tone = self.Theme.Success
			title = "SUCCESS"
		elseif kind == "error" then
			tone = self.Theme.Error
			title = "ERROR"
		elseif kind == "warn" then
			tone = self.Theme.Warning
			title = "WARNING"
		end

		local toast = uiMake("Frame", {
			Name = "Toast",
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = self.Theme.Field,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(1, 24, 0, 24),
			Size = UDim2.fromOffset(286, 54),
			ZIndex = 1000,
		}, self.Root)
		self.ActiveToast = toast
		uiCorner(toast, 7)
		uiStroke(toast, tone, 1, 0.08)

		local marker = uiMake("Frame", {
			BackgroundColor3 = tone,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromOffset(4, 54),
			ZIndex = toast.ZIndex + 1,
		}, toast)
		uiCorner(marker, 7)

		local iconBox = uiMake("Frame", {
			BackgroundColor3 = tone,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(16, 12),
			Size = UDim2.fromOffset(30, 30),
			ZIndex = toast.ZIndex + 1,
		}, toast)
		uiCorner(iconBox, 6)
		createAssetIcon(iconBox, kind == "success" and "verify" or "key", {
			Color3 = self.Theme.Text,
			Transparency = 1,
			Position = UDim2.fromOffset(6, 6),
			Size = UDim2.fromOffset(18, 18),
			ZIndex = iconBox.ZIndex + 1,
		})

		local titleLabel = createText(toast, title, 9, tone, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(56, 9),
			Size = UDim2.new(1, -72, 0, 14),
			TextTransparency = 1,
			ZIndex = toast.ZIndex + 1,
		})
		local messageLabel = createText(toast, message, 11, self.Theme.Text, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(56, 25),
			Size = UDim2.new(1, -72, 0, 20),
			TextTransparency = 1,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = toast.ZIndex + 1,
		})

		self.TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.06,
			Position = UDim2.new(1, -24, 0, 24),
		}):Play()
		self.TweenService:Create(marker, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0,
		}):Play()
		self.TweenService:Create(iconBox, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.2,
		}):Play()
		for _, child in ipairs(iconBox:GetChildren()) do
			if child:IsA("ImageLabel") then
				self.TweenService:Create(child, TweenInfo.new(0.18), { ImageTransparency = 0 }):Play()
			end
		end
		self.TweenService:Create(titleLabel, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
		self.TweenService:Create(messageLabel, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()

		task.delay(2.4, function()
			if self.ToastSerial ~= serial or not toast.Parent then
				return
			end

			self.TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
				Position = UDim2.new(1, 24, 0, 24),
			}):Play()
			task.delay(0.2, function()
				if self.ToastSerial == serial and toast.Parent then
					toast:Destroy()
				end
			end)
		end)
	end

	function app:SetStatus(message, kind)
		if kind then
			self:ShowToast(message, kind)
		end

		if not self.StatusLabel then
			return
		end

		self.StatusLabel.Text = message or ""
		if kind == "success" then
			self.StatusLabel.TextColor3 = self.Theme.Success
		elseif kind == "error" then
			self.StatusLabel.TextColor3 = self.Theme.Error
		elseif kind == "warn" then
			self.StatusLabel.TextColor3 = self.Theme.Warning
		else
			self.StatusLabel.TextColor3 = self.Theme.Muted
		end
	end

	-- Full-screen key verification overlay: a spinner while the JNKiE request
	-- is in flight, a checkmark on success. Parented to Root so it survives
	-- Content rebuilds and sits above the GetKey page.
	function app:ShowKeyOverlay(state, message)
		if state == "hide" then
			if self.KeyOverlay then
				pcall(function() self.KeyOverlay:Destroy() end)
				self.KeyOverlay = nil
			end
			return
		end

		if self.KeyOverlay then
			pcall(function() self.KeyOverlay:Destroy() end)
		end

		local overlay = uiMake("Frame", {
			Name = "KeyOverlay",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.fromOffset(220, 168),
			BackgroundColor3 = self.Theme.Panel,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			ZIndex = 200,
		}, self.Root)
		uiCorner(overlay, 14)
		uiStroke(overlay, self.Theme.Accent, 1.4, 0.08)
		addDepth(overlay, self.Theme, 2, 14)
		self.KeyOverlay = overlay

		local iconHolder = uiMake("Frame", {
			Name = "IconHolder",
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 22),
			Size = UDim2.fromOffset(56, 56),
			BackgroundTransparency = 1,
		}, overlay)

		local messageLabel = createText(overlay, message or "", 12, self.Theme.Text, Enum.Font.GothamBold, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 1, -44),
			Size = UDim2.new(1, -28, 0, 36),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = overlay.ZIndex + 2,
		})

		if state == "loading" then
			local ring = uiMake("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(44, 44),
				BackgroundTransparency = 1,
				ZIndex = overlay.ZIndex + 1,
			}, iconHolder)
			uiCorner(ring, 999)
			uiStroke(ring, self.Theme.Accent, 3, 0.65)
			local ringFill = uiMake("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(44, 44),
				BackgroundTransparency = 1,
				ZIndex = overlay.ZIndex + 2,
			}, iconHolder)
			uiCorner(ringFill, 999)
			uiStroke(ringFill, self.Theme.Accent, 3, 0)
			local spinTween = self.TweenService:Create(ringFill, TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
				Rotation = 360,
			})
			spinTween:Play()
			self.KeyOverlaySpin = spinTween
			messageLabel.Text = message or "Verifying key..."
		elseif state == "success" then
			local circle = uiMake("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.fromOffset(52, 52),
				BackgroundColor3 = self.Theme.Success,
				BackgroundTransparency = 0.12,
				BorderSizePixel = 0,
				ZIndex = overlay.ZIndex + 1,
			}, iconHolder)
			uiCorner(circle, 999)
			uiStroke(circle, self.Theme.Success, 2, 0)
			createText(circle, "✓", 30, self.Theme.Root, Enum.Font.GothamBlack, {
				Size = UDim2.fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
				ZIndex = circle.ZIndex + 1,
			})
			messageLabel.Text = message or "Key verified"
		end

		overlay.BackgroundTransparency = 1
		self.TweenService:Create(overlay, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.04,
		}):Play()
	end

	function app:ShakeKeyInput(keyBox)
		if not keyBox or not keyBox.Parent then
			return
		end
		local original = keyBox.Position
		for step = 1, 3 do
			self.TweenService:Create(keyBox, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(original.X.Scale, original.X.Offset - 7, original.Y.Scale, original.Y.Offset),
			}):Play()
			task.wait(0.05)
			self.TweenService:Create(keyBox, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(original.X.Scale, original.X.Offset + 7, original.Y.Scale, original.Y.Offset),
			}):Play()
			task.wait(0.05)
		end
		keyBox.Position = original
	end

	function app:Copy(value, successMessage)
		value = tostring(value or "")
		local clip = setclipboard or toclipboard
		if type(syn) == "table" and type(syn.write_clipboard) == "function" then
			clip = syn.write_clipboard
		end

		if clip then
			pcall(clip, value)
			self:SetStatus(successMessage or "Copied to clipboard.", "success")
			return true
		end

		self:SetStatus(value, "warn")
		return false
	end

	function app:GetResolvedKeyLink()
		if type(self.Options.GetKeyLink) == "function" then
			local ok, linkOrMessage = pcall(self.Options.GetKeyLink, self)
			if ok and linkOrMessage and tostring(linkOrMessage) ~= "" then
				return tostring(linkOrMessage)
			end

			self:SetStatus(ok and "Could not get key link." or tostring(linkOrMessage), "error")
			return nil
		end

		return self.Options.KeyUrl or self.Options.GetKeyUrl or "https://discord.gg/Xfa9nAsTCJ"
	end

	function app:GetHwid()
		local ok, value = pcall(function()
			return RbxAnalyticsService:GetClientId()
		end)
		if ok and value then
			return value
		end

		return tostring(LocalPlayer and LocalPlayer.UserId or "Unknown")
	end

	function app:RunGame(gameInfo)
		local callback = gameInfo.Callback or gameInfo.callback
		if callback then
			local ok, err = pcall(callback, gameInfo, self.Library, self)
			if not ok then
				self:SetStatus(tostring(err), "error")
			end
			return
		end

		local source = gameInfo.Source or gameInfo.source
		if source then
			self:SetStatus("Running " .. tostring(gameInfo.Name) .. "...", "warn")
			local ok, err = self.Library:RunSource(source, gameInfo.Name)
			self:SetStatus(ok and "Script executed." or tostring(err), ok and "success" or "error")
			return
		end

		local path = gameInfo.Path or gameInfo.path or gameInfo.LocalPath or gameInfo.localPath
		if path then
			if type(readfile) ~= "function" then
				self:SetStatus("readfile is not available for local scripts.", "error")
				return
			end

			local function readLocal(candidate)
				local ok, result = pcall(readfile, tostring(candidate))
				if ok and type(result) == "string" and result ~= "" then
					return true, result, tostring(candidate)
				end
				return false, result
			end

			local ok, fileSource, usedPath = readLocal(path)
			local fallbackPaths = gameInfo.FallbackPaths or gameInfo.fallbackPaths
			if not ok and type(fallbackPaths) == "table" then
				for _, candidate in ipairs(fallbackPaths) do
					ok, fileSource, usedPath = readLocal(candidate)
					if ok then
						break
					end
				end
			end

			if not ok then
				self:SetStatus("Could not read local script: " .. tostring(path), "error")
				return
			end

			self:SetStatus("Running " .. tostring(gameInfo.Name) .. "...", "warn")
			local runOk, err = self.Library:RunSource(fileSource, gameInfo.Name or usedPath)
			self:SetStatus(runOk and "Script executed." or tostring(err), runOk and "success" or "error")
			return
		end

		local url = gameInfo.Url or gameInfo.url
		if url then
			self:SetStatus("Loading " .. tostring(gameInfo.Name) .. "...", "warn")
			local ok, err = self.Library:RunUrl(url, gameInfo.Name)
			self:SetStatus(ok and "Script executed." or tostring(err), ok and "success" or "error")
			return
		end

		local placeId = tonumber(getPrimaryPlaceId(gameInfo))
		if placeId and placeId > 0 then
			self:SetStatus("Teleporting to " .. tostring(gameInfo.Name) .. "...", "warn")
			local ok, err = pcall(function()
				TeleportService:Teleport(placeId, LocalPlayer)
			end)
			if not ok then
				self:SetStatus(tostring(err), "error")
			end
			return
		end

		self:SetStatus("No loader configured for " .. tostring(gameInfo.Name) .. ".", "warn")
	end

	function app:NavButton(parent, text, active, callback)
		local holder = uiMake("TextButton", {
			Name = text,
			BackgroundColor3 = active and self.Theme.AccentSoft or self.Theme.Panel,
			BackgroundTransparency = active and 0.03 or 0.42,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 40),
			Text = "",
			AutoButtonColor = false,
		}, parent)
		uiCorner(holder, 8)
		local marker = uiMake("Frame", {
			BackgroundColor3 = self.Theme.Accent,
			BackgroundTransparency = active and 0 or 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 9),
			Size = UDim2.fromOffset(3, 22),
		}, holder)
		uiCorner(marker, 999)
		createText(holder, text, 12, active and self.Theme.Text or self.Theme.Muted, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -24, 1, 0),
		})
		connect(self, holder.MouseButton1Click, callback)
		return holder
	end

	function app:BuildProfileSidebar(activePage)
		self:Clear(self.Sidebar)
		self.SidebarMode = "Profile"
		self.SidebarLowEffectsState = nil
		uiPadding(self.Sidebar, 16, 16, 16, 16)

		local profile = uiMake("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 76),
		}, self.Sidebar)
		createLogo(profile, self.Theme, {
			Name = self.Options.Name or self.Library.Name,
			LogoImage = self.Options.LogoImage,
		}, 48).Position = UDim2.fromOffset(0, 0)
		createText(profile, self.Options.Name or self.Library.Name, 13, self.Theme.Text, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(60, 4),
			Size = UDim2.new(1, -60, 0, 20),
		})
		createText(profile, "@" .. tostring(LocalPlayer and LocalPlayer.Name or "Player"), 11, self.Theme.Muted, Enum.Font.GothamMedium, {
			Position = UDim2.fromOffset(60, 24),
			Size = UDim2.new(1, -60, 0, 18),
		})

		local chip = uiMake("Frame", {
			BackgroundColor3 = self.Theme.Field,
			BackgroundTransparency = 0.16,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 58),
			Size = UDim2.new(1, 0, 0, 18),
		}, profile)
		uiCorner(chip, 6)
		createText(chip, "03:07  |  " .. tostring(math.random(52, 388)) .. " ms", 10, self.Theme.Accent, Enum.Font.GothamBold, {
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})

		local navTitle = createText(self.Sidebar, "NAVIGATION MENU", 10, self.Theme.Text, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(0, 100),
			Size = UDim2.new(1, 0, 0, 16),
		})
		navTitle.TextTransparency = 0.05

		local nav = uiMake("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 126),
			Size = UDim2.new(1, 0, 0, 138),
		}, self.Sidebar)
		uiList(nav, Enum.FillDirection.Vertical, 10)

		self:NavButton(nav, "Supported Games", activePage == "Support", function()
			self:ShowSupportGames()
		end)
		self:NavButton(nav, "Get Key / VIP / Discord", activePage == "GetKey", function()
			self:ShowGetKey()
		end)
		self:NavButton(nav, "System Status", false, function()
			self:SetStatus("System online. PlaceId: " .. tostring(game.PlaceId), "success")
		end)

		local bottom = uiMake("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = self.Theme.Panel,
			BackgroundTransparency = 0.14,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 44),
		}, self.Sidebar)
		uiCorner(bottom, 8)
		createText(bottom, "Waiting for Game", 13, self.Theme.Text, Enum.Font.GothamBold, {
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end

	function app:BuildGamesSidebar()
		self:Clear(self.Sidebar)
		self.SidebarMode = "Games"
		self.SidebarLowEffectsState = nil
		uiPadding(self.Sidebar, 16, 16, 16, 16)

		local tabs = uiMake("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 42),
		}, self.Sidebar)
		uiList(tabs, Enum.FillDirection.Horizontal, 8)
		createButton(tabs, self.Theme, "User Info", {
			App = self,
			Size = UDim2.new(0.48, -4, 0, 34),
			BackgroundColor3 = self.Theme.Panel,
			HoverColor = self.Theme.AccentSoft,
			StrokeColor = self.Theme.StrokeSoft,
			TextSize = 10,
		}, function()
			self:SetStatus("User: " .. tostring(LocalPlayer and LocalPlayer.Name or "Player"), "success")
		end)
		createButton(tabs, self.Theme, "Games (" .. tostring(#self.Games) .. ")", {
			App = self,
			Size = UDim2.new(0.52, -4, 0, 34),
			BackgroundColor3 = self.Theme.AccentSoft,
			HoverColor = self.Theme.AccentSoft,
			StrokeColor = self.Theme.Accent,
			TextSize = 10,
		}, function()
			self:ShowSupportGames()
		end)

		createText(self.Sidebar, "GAME SUPPORT", 12, self.Theme.Accent, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(0, 66),
			Size = UDim2.new(1, 0, 0, 16),
		})
		createText(self.Sidebar, "Official supported game loaders", 10, self.Theme.Muted, Enum.Font.GothamMedium, {
			Position = UDim2.fromOffset(0, 82),
			Size = UDim2.new(1, 0, 0, 14),
		})

		local list = uiMake("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 108),
			Size = UDim2.new(1, 0, 1, -120),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = self.Theme.Accent,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, self.Sidebar)
		uiList(list, Enum.FillDirection.Vertical, 10)

		for index, gameInfo in ipairs(self.Games) do
			local item = uiMake("Frame", {
				Name = gameInfo.Name or ("Game" .. tostring(index)),
				BackgroundColor3 = self.Theme.Panel,
				BackgroundTransparency = 0.16,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -4, 0, 72),
				LayoutOrder = index,
			}, list)
			uiCorner(item, 10)
			uiStroke(item, self.Theme.StrokeSoft, 1, 0.25)
			local thumb = createGameThumb(item, self.Theme, gameInfo, 48)
			thumb.Position = UDim2.fromOffset(9, 12)
			createText(item, gameInfo.Name or "Game", 11, self.Theme.Text, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(66, 12),
				Size = UDim2.new(1, -128, 0, 18),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			createText(item, gameInfo.Description or gameInfo.Details or "Supported loader", 9, self.Theme.Muted, Enum.Font.GothamMedium, {
				Position = UDim2.fromOffset(66, 31),
				Size = UDim2.new(1, -128, 0, 16),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})

			local status = string.upper(tostring(gameInfo.Status or "FREE"))
			local statusColor = status == "VIP" and self.Theme.Gold or self.Theme.Success
			local badge = uiMake("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = statusColor,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -10, 0, 12),
				Size = UDim2.fromOffset(42, 18),
			}, item)
			uiCorner(badge, 6)
			createText(badge, status, 8, self.Theme.Root, Enum.Font.GothamBlack, {
				Size = UDim2.fromScale(1, 1),
				TextXAlignment = Enum.TextXAlignment.Center,
			})

			createButton(item, self.Theme, "Play", {
				App = self,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -10, 1, -10),
				Size = UDim2.fromOffset(44, 24),
				BackgroundColor3 = self.Theme.Accent,
				HoverColor = self.Theme.AccentHover,
				TextSize = 9,
				Radius = 7,
			}, function()
				self:RunGame(gameInfo)
			end)
		end
	end

	function app:BuildHudSidebar()
		self:Clear(self.Sidebar)
		self.SidebarMode = "Hud"
		self.SidebarLowEffectsState = self:IsLowEffects()
		uiPadding(self.Sidebar, 14, 14, 18, 18)
		local lowEffects = self:IsLowEffects()

		createText(self.Sidebar, string.upper(self.Options.Name or self.Library.Name), 22, self.Theme.Text, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.new(1, 0, 0, 28),
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		createText(self.Sidebar, "GAME CONTROL CENTER", 10, self.Theme.Muted, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(0, 30),
			Size = UDim2.new(1, 0, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Left,
		})

		local navPanel = uiMake("Frame", {
			Name = "HudNavPanel",
			BackgroundColor3 = self.Theme.Panel,
			BackgroundTransparency = 0.22,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 74),
			Size = UDim2.new(1, 0, 0, 318),
		}, self.Sidebar)
		uiCorner(navPanel, 10)
		uiStroke(navPanel, self.Theme.Stroke, 1, 0.2)
		addDepth(navPanel, self.Theme, 1, 10)

		local navList = uiMake("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 38),
			Size = UDim2.new(1, -28, 0, 258),
		}, navPanel)
		uiList(navList, Enum.FillDirection.Vertical, 14)

		local sidebarVipGold = Color3.fromRGB(255, 198, 75)
		local sidebarVipGoldSoft = Color3.fromRGB(86, 62, 24)

		local function drawHudIcon(parent, iconName, primary)
			local isVipIcon = iconName == "vip"
			local iconColor = isVipIcon and sidebarVipGold or self.Theme.Text
			local box = uiMake("Frame", {
				Name = "Icon",
				BackgroundColor3 = isVipIcon and sidebarVipGoldSoft or (primary and self.Theme.Accent or self.Theme.AccentSoft),
				BackgroundTransparency = isVipIcon and 0.1 or (primary and 0.06 or 0.2),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(12, 10),
				Size = UDim2.fromOffset(32, 32),
				ZIndex = parent.ZIndex + 2,
			}, parent)
			uiCorner(box, 7)
			uiStroke(box, isVipIcon and sidebarVipGold or self.Theme.Accent, 1, isVipIcon and 0.08 or (primary and 0.05 or 0.28))

			if createAssetIcon(box, iconName, {
					Name = "IconImage",
					Color3 = iconColor,
					Transparency = primary and 0 or 0.04,
					Position = UDim2.fromOffset(5, 5),
					Size = UDim2.fromOffset(22, 22),
					ZIndex = box.ZIndex + 3,
				}) then
				return box
			end

			local function bar(x, y, w, h, rotation)
				local part = uiMake("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = iconColor,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(x, y),
					Rotation = rotation or 0,
					Size = UDim2.fromOffset(w, h),
					ZIndex = box.ZIndex + 2,
				}, box)
				uiCorner(part, math.max(1, math.floor(h / 2)))
				return part
			end

			local function dot(x, y, size)
				local part = uiMake("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = iconColor,
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(x, y),
					Size = UDim2.fromOffset(size, size),
					ZIndex = box.ZIndex + 3,
				}, box)
				uiCorner(part, 999)
				return part
			end

			if iconName == "key" then
				local ring = uiMake("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(6, 7),
					Size = UDim2.fromOffset(13, 13),
					ZIndex = box.ZIndex + 1,
				}, box)
				uiCorner(ring, 999)
				uiStroke(ring, iconColor, 2, 0)
				dot(12.5, 13.5, 3)
				bar(20, 19, 14, 3, 0)
				bar(25, 22, 3, 6, 0)
				bar(20, 22, 3, 4, 0)
			elseif iconName == "discord" then
				local face = uiMake("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(6, 9),
					Size = UDim2.fromOffset(20, 14),
					ZIndex = box.ZIndex + 1,
				}, box)
				uiCorner(face, 6)
				uiStroke(face, iconColor, 2, 0)
				bar(9, 8, 6, 2, -18)
				bar(23, 8, 6, 2, 18)
				dot(13, 16, 3)
				dot(19, 16, 3)
				bar(16, 22, 7, 2, 0)
			elseif iconName == "hwid" then
				local chip = uiMake("Frame", {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(8, 8),
					Size = UDim2.fromOffset(16, 16),
					ZIndex = box.ZIndex + 1,
				}, box)
				uiCorner(chip, 3)
				uiStroke(chip, iconColor, 2, 0)
				for _, pin in ipairs({
					{ 3, 4, 3, 1 }, { 3, 10, 3, 1 }, { 26, 4, 3, 1 }, { 26, 10, 3, 1 },
					{ 10, 3, 1, 3 }, { 16, 3, 1, 3 }, { 10, 26, 1, 3 }, { 16, 26, 1, 3 },
				}) do
					uiMake("Frame", {
						BackgroundColor3 = iconColor,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(pin[1], pin[2]),
						Size = UDim2.fromOffset(pin[3], pin[4]),
						ZIndex = box.ZIndex + 1,
					}, box)
				end
				dot(16, 16, 4)
			elseif iconName == "vip" then
				bar(10, 20, 14, 3, 0)
				bar(21, 20, 14, 3, 0)
				bar(9, 16, 12, 3, 58)
				bar(16, 14, 12, 3, 0)
				bar(23, 16, 12, 3, -58)
				dot(7, 12, 4)
				dot(16, 9, 4)
				dot(25, 12, 4)
				bar(16, 24, 17, 3, 0)
			else
				createText(box, firstLetter(iconName), 11, iconColor, Enum.Font.GothamBlack, {
					Size = UDim2.fromScale(1, 1),
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = box.ZIndex + 1,
				})
			end

			return box
		end

		local function hudNavButton(label, iconName, primary, callback)
			local isVipButton = iconName == "vip"
			local baseColor = isVipButton and Color3.fromRGB(33, 24, 10) or (primary and self.Theme.AccentSoft or self.Theme.Field)
			local hoverColor = isVipButton and sidebarVipGoldSoft or (primary and self.Theme.Accent or self.Theme.AccentSoft)
			local strokeColor = isVipButton and sidebarVipGold or (primary and self.Theme.Accent or self.Theme.StrokeSoft)
			local strokeTransparency = isVipButton and 0.04 or (primary and 0.05 or 0.16)
			local labelColor = isVipButton and sidebarVipGold or self.Theme.Text
			local button = uiMake("TextButton", {
				Name = label,
				BackgroundColor3 = baseColor,
				BackgroundTransparency = isVipButton and 0.02 or (primary and 0 or 0.08),
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 52),
				Text = "",
				AutoButtonColor = false,
			}, navList)
			uiCorner(button, 6)
			local buttonStroke = uiStroke(button, strokeColor, 1, strokeTransparency)
			local hoverGlow = uiMake("Frame", {
				Name = "HoverGlow",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(-3, -3),
				Size = UDim2.new(1, 6, 1, 6),
				ZIndex = button.ZIndex + 1,
			}, button)
			uiCorner(hoverGlow, 8)
			local hoverGlowStroke = uiStroke(hoverGlow, strokeColor, 2, 1)
			drawHudIcon(button, iconName, primary)
			createText(button, label, 12, labelColor, Enum.Font.GothamBlack, {
				Position = UDim2.fromOffset(54, 0),
				Size = UDim2.new(1, -62, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = button.ZIndex + 2,
			})
			connect(self, button.MouseEnter, function()
				self.TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = hoverColor,
				}):Play()
				self.TweenService:Create(buttonStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = isVipButton and 0 or 0.02,
				}):Play()
				self.TweenService:Create(hoverGlow, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.fromOffset(-5, -5),
					Size = UDim2.new(1, 10, 1, 10),
				}):Play()
				self.TweenService:Create(hoverGlowStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = isVipButton and 0.22 or 0.36,
				}):Play()
			end)
			connect(self, button.MouseLeave, function()
				self.TweenService:Create(button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = baseColor,
				}):Play()
				self.TweenService:Create(buttonStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = strokeTransparency,
				}):Play()
				self.TweenService:Create(hoverGlow, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.fromOffset(-3, -3),
					Size = UDim2.new(1, 6, 1, 6),
				}):Play()
				self.TweenService:Create(hoverGlowStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
				}):Play()
			end)
			connect(self, button.MouseButton1Click, callback)
			return button
		end

		hudNavButton("GET KEY", "key", true, function()
			local keyUrl = self:GetResolvedKeyLink()
			if keyUrl then
				self:Copy(keyUrl, "Key link copied.")
			end
		end)
		hudNavButton("DISCORD", "discord", false, function()
			self:Copy(self.Options.DiscordUrl or "https://discord.gg/Xfa9nAsTCJ", "Discord link copied.")
		end)
		hudNavButton("COPY HWID", "hwid", false, function()
			self:Copy(self:GetHwid(), "HWID copied.")
		end)
		hudNavButton("VIP", "vip", false, function()
			self:Copy(self.Options.VipUrl or self.Options.DiscordUrl or "https://discord.gg/Xfa9nAsTCJ", "VIP link copied.")
		end)

		local lowEffectsTone = lowEffects and self.Theme.Success or self.Theme.StrokeSoft
		local lowEffectsToggle = uiMake("TextButton", {
			Name = "LowEffectsToggle",
			BackgroundColor3 = lowEffects and Color3.fromRGB(14, 48, 48) or self.Theme.Panel,
			BackgroundTransparency = lowEffects and 0.04 or 0.18,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 410),
			Size = UDim2.new(1, 0, 0, 38),
			Text = "",
			AutoButtonColor = false,
		}, self.Sidebar)
		uiCorner(lowEffectsToggle, 7)
		local lowEffectsStroke = uiStroke(lowEffectsToggle, lowEffectsTone, 1, lowEffects and 0.04 or 0.22)
		createText(lowEffectsToggle, "LOW FX", 10, lowEffects and self.Theme.Success or self.Theme.Muted, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(0.5, -14, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = lowEffectsToggle.ZIndex + 1,
		})
		createText(lowEffectsToggle, lowEffects and "ON" or "OFF", 10, lowEffects and self.Theme.Success or self.Theme.Text, Enum.Font.GothamBlack, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 0),
			Size = UDim2.new(0.5, -14, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = lowEffectsToggle.ZIndex + 1,
		})
		connect(self, lowEffectsToggle.MouseEnter, function()
			self.TweenService:Create(lowEffectsStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = lowEffects and 0 or 0.04,
			}):Play()
		end)
		connect(self, lowEffectsToggle.MouseLeave, function()
			self.TweenService:Create(lowEffectsStroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = lowEffects and 0.04 or 0.22,
			}):Play()
		end)
		connect(self, lowEffectsToggle.MouseButton1Click, function()
			self.LowEffects = not self:IsLowEffects()
			self.Options.LowEffects = self.LowEffects
			self.SidebarMode = nil
			self:ShowGetKey()
			self:ShowToast(self.LowEffects and "Low Effects enabled." or "Full Effects enabled.", "success")
		end)

		self:BuildElephantMascot(self.Sidebar, {
			Size = UDim2.new(1, 0, 0, 112),
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
		})
	end

	function app:BuildElephantMascot(parent, opts)
		opts = opts or {}
		local alwaysAnimate = opts.AlwaysAnimate == true
		local lowEffects = opts.LowEffects ~= nil and opts.LowEffects or self:IsLowEffects()
		local animateAllowed = function()
			return alwaysAnimate or self:HudEffectsAllowed()
		end

		local mascotPanel = uiMake("Frame", {
			Name = opts.Name or "AnimatedMascot",
			AnchorPoint = opts.AnchorPoint or Vector2.new(0, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Position = opts.Position or UDim2.new(0, 0, 1, 0),
			Size = opts.Size or UDim2.new(1, 0, 0, 112),
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
		local pixelBlueLight = Color3.fromRGB(178, 229, 255)
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

	function app:CreateGameCard(parent, gameInfo, index)
		local primaryPlaceId = tonumber(getPrimaryPlaceId(gameInfo))
		local isCurrentGame = gameInfo.Current == true or (primaryPlaceId and primaryPlaceId > 0 and primaryPlaceId == tonumber(game.PlaceId))
		local card = uiMake("Frame", {
			Name = gameInfo.Name or ("Game" .. tostring(index)),
			BackgroundColor3 = self.Theme.Card,
			BackgroundTransparency = self.Theme.CardTransparency,
			BorderSizePixel = 0,
			LayoutOrder = index,
			ClipsDescendants = true,
		}, parent)
		uiCorner(card, 10)
		local line = uiStroke(card, isCurrentGame and self.Theme.AccentHover or self.Theme.Stroke, 1, isCurrentGame and 0.02 or 0.12)

		connect(self, card.MouseEnter, function()
			self.TweenService:Create(line, TweenInfo.new(0.15), { Transparency = 0 }):Play()
		end)
		connect(self, card.MouseLeave, function()
			self.TweenService:Create(line, TweenInfo.new(0.15), { Transparency = 0.12 }):Play()
		end)

		local thumb = createGameThumb(card, self.Theme, gameInfo, 58)
		thumb.Position = UDim2.fromOffset(10, 12)

		local status = isCurrentGame and "READY" or string.upper(tostring(gameInfo.Status or "VIP"))
		local statusColor = status == "VIP" and self.Theme.Gold or self.Theme.Success
		if status == "PAID" then
			statusColor = self.Theme.Gold
		elseif status == "READY" then
			statusColor = self.Theme.AccentHover
		end
		local badge = uiMake("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = statusColor,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -10, 0, 12),
			Size = UDim2.fromOffset(54, 20),
		}, card)
		uiCorner(badge, 7)
		createText(badge, status, 9, self.Theme.Root, Enum.Font.GothamBlack, {
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
		})

		createText(card, gameInfo.Name or "Supported Game", 13, self.Theme.Text, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(78, 12),
			Size = UDim2.new(1, -146, 0, 20),
			TextTruncate = Enum.TextTruncate.AtEnd,
		})
		createText(card, gameInfo.Details or gameInfo.Description or "Auto farm loader", 9, self.Theme.Muted, Enum.Font.GothamMedium, {
			Position = UDim2.fromOffset(78, 32),
			Size = UDim2.new(1, -96, 0, 28),
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		createText(card, "ID: " .. tostring(primaryPlaceId or "N/A"), 9, self.Theme.Muted, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(10, 78),
			Size = UDim2.new(0.52, -12, 0, 18),
		})

		createButton(card, self.Theme, "Play", {
			App = self,
			Position = UDim2.new(1, -152, 1, -30),
			Size = UDim2.fromOffset(72, 24),
			BackgroundColor3 = self.Theme.Accent,
			HoverColor = self.Theme.AccentHover,
			TextSize = 9,
			Radius = 7,
		}, function()
			self:RunGame(gameInfo)
		end)
		createButton(card, self.Theme, "Copy ID", {
			App = self,
			Position = UDim2.new(1, -74, 1, -30),
			Size = UDim2.fromOffset(64, 24),
			BackgroundColor3 = self.Theme.AccentSoft,
			HoverColor = self.Theme.Accent,
			TextSize = 8,
			Radius = 7,
		}, function()
			self:Copy(tostring(getPrimaryPlaceId(gameInfo) or ""), "Place ID copied.")
		end)

		local featureText = ""
		local features = gameRecommendedFeatures(gameInfo)
		if type(features) == "table" then
			featureText = table.concat(features, " ")
		end

		card:SetAttribute("SearchText", string.lower(table.concat({
			tostring(gameInfo.Name or ""),
			tostring(gameInfo.Description or ""),
			tostring(gameInfo.Details or ""),
			tostring(gameInfo.Category or ""),
			tostring(gameInfo.Path or gameInfo.Url or ""),
			featureText,
			tostring(primaryPlaceId or ""),
		}, " ")))
		return card
	end

	function app:ShowSupportGames()
		self.CurrentPage = "Support"
		self.StatusLabel = nil
		self:BuildProfileSidebar("Support")
		self:Clear(self.Content)

		createText(self.Content, (self.Options.Name or self.Library.Name) .. " - Waiting Menu", 18, self.Theme.Text, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(24, 22),
			Size = UDim2.new(1, -96, 0, 24),
		})
		createText(self.Content, "Supported game loaders and VIP entries", 10, self.Theme.Muted, Enum.Font.GothamMedium, {
			Position = UDim2.fromOffset(24, 46),
			Size = UDim2.new(1, -96, 0, 16),
		})

		local notice = uiMake("Frame", {
			BackgroundColor3 = self.Theme.Field,
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(24, 72),
			Size = UDim2.new(1, -48, 0, 40),
		}, self.Content)
		uiCorner(notice, 8)
		uiStroke(notice, self.Theme.Gold, 1, 0.08)
		createText(notice, "VIP maps are available through Discord. Upgrade to unlock exclusive loaders.", 11, self.Theme.Gold, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -28, 1, 0),
		})

		local searchHolder = uiMake("Frame", {
			BackgroundColor3 = self.Theme.Field,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(24, 122),
			Size = UDim2.new(1, -48, 0, 36),
		}, self.Content)
		uiCorner(searchHolder, 8)
		uiStroke(searchHolder, self.Theme.Stroke, 1, 0.15)
		local searchBox = uiMake("TextBox", {
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			Font = Enum.Font.GothamMedium,
			PlaceholderText = "Search game or Place ID...",
			PlaceholderColor3 = self.Theme.Dim,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -28, 1, 0),
			Text = "",
			TextColor3 = self.Theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, searchHolder)

		local grid = uiMake("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(24, 168),
			Size = UDim2.new(1, -48, 1, -184),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = self.Theme.Accent,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, self.Content)
		uiMake("UIGridLayout", {
			CellPadding = UDim2.fromOffset(10, 10),
			CellSize = UDim2.new(0.5, -6, 0, 106),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, grid)

		local cards = {}
		for index, gameInfo in ipairs(self.Games) do
			cards[#cards + 1] = self:CreateGameCard(grid, gameInfo, index)
		end

		self.StatusLabel = createText(self.Content, "", 11, self.Theme.Muted, Enum.Font.GothamBold, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 24, 1, -8),
			Size = UDim2.new(1, -48, 0, 18),
		})
		self:SetStatus("Waiting for selected game...", nil)

		connect(self, searchBox:GetPropertyChangedSignal("Text"), function()
			local query = string.lower(searchBox.Text or "")
			for _, card in ipairs(cards) do
				local searchText = card:GetAttribute("SearchText") or ""
				card.Visible = query == "" or string.find(searchText, query, 1, true) ~= nil
			end
		end)
	end

	function app:ShowGetKey()
		self.CurrentPage = "GetKey"
		self.StatusLabel = nil
		self:EnsureHudSidebar()
		self:Clear(self.Content)

		local gameCount = #self.Games
		if gameCount > 0 then
			self.HudSlideIndex = math.clamp(self.HudSlideIndex or 1, 1, gameCount)
		else
			self.HudSlideIndex = 1
		end

		local selectedGame = self.Options.SelectedGame or self.Games[self.HudSlideIndex] or {
			Name = "Roblox Map",
			Description = "Adventure World",
			Details = "Secure loader preview",
			PlaceId = game.PlaceId,
		}

		local lowEffects = self:IsLowEffects()
		self.HudSlideToken = (self.HudSlideToken or 0) + 1
		local slideToken = self.HudSlideToken
		local shouldAnimateSlide = self.HudSlideFadeIn == true and not lowEffects
		self.HudSlideFadeIn = false

		local function techPanel(parent, properties)
			properties = properties or {}
			local frame = uiMake("Frame", {
				Name = properties.Name or "TechPanel",
				AnchorPoint = properties.AnchorPoint or Vector2.new(0, 0),
				BackgroundColor3 = properties.BackgroundColor3 or self.Theme.Panel,
				BackgroundTransparency = properties.BackgroundTransparency or 0.1,
				BorderSizePixel = 0,
				Position = properties.Position or UDim2.new(),
				Size = properties.Size or UDim2.fromOffset(100, 100),
				ClipsDescendants = properties.ClipsDescendants == nil and true or properties.ClipsDescendants,
				ZIndex = properties.ZIndex or 1,
			}, parent)
			uiCorner(frame, properties.Radius or 6)
			uiStroke(frame, properties.StrokeColor or self.Theme.Stroke, properties.StrokeThickness or 1, properties.StrokeTransparency or 0.05)
			if properties.Depth and properties.Depth > 0 then
				addDepth(frame, self.Theme, properties.Depth, properties.Radius or 6)
			end

			local cornerColor = properties.CornerColor or self.Theme.Accent
			for _, cornerInfo in ipairs({
				{ 0, 0, 26, 2 },
				{ 0, 0, 2, 26 },
				{ 1, 0, -26, 2 },
				{ 1, 0, -2, 26 },
				{ 0, 1, 26, -2 },
				{ 0, 1, 2, -26 },
				{ 1, 1, -26, -2 },
				{ 1, 1, -2, -26 },
			}) do
				local xScale, yScale, width, height = cornerInfo[1], cornerInfo[2], cornerInfo[3], cornerInfo[4]
				uiMake("Frame", {
					AnchorPoint = Vector2.new(xScale, yScale),
					BackgroundColor3 = cornerColor,
					BackgroundTransparency = 0.05,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(xScale, yScale),
					Size = UDim2.fromOffset(math.abs(width), math.abs(height)),
					ZIndex = frame.ZIndex + 1,
				}, frame)
			end

			return frame
		end

		local function hudInput(parent, label, placeholder, order, iconName)
			createText(parent, label, 10, self.Theme.Accent, Enum.Font.GothamBlack, {
				Position = UDim2.fromOffset(16, order),
				Size = UDim2.new(1, -32, 0, 16),
			})
		local holder = techPanel(parent, {
				Position = UDim2.fromOffset(16, order + 22),
				Size = UDim2.new(1, -32, 0, 42),
				BackgroundColor3 = self.Theme.Field,
				BackgroundTransparency = 0.04,
				StrokeColor = self.Theme.StrokeSoft,
				StrokeTransparency = 0.08,
				Radius = 5,
				Depth = 1,
			})
			local box = uiMake("TextBox", {
				BackgroundColor3 = self.Theme.Root,
				BackgroundTransparency = 0.12,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				Font = Enum.Font.GothamBold,
				PlaceholderText = placeholder,
				PlaceholderColor3 = self.Theme.Dim,
				Position = UDim2.fromOffset(44, 8),
				Size = UDim2.new(1, -58, 0, 26),
				Text = "",
				TextColor3 = self.Theme.Text,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = holder.ZIndex + 2,
			}, holder)
			uiCorner(box, 5)
			if not createAssetIcon(holder, iconName or "key", {
				Color3 = self.Theme.AccentHover,
				Position = UDim2.fromOffset(13, 11),
				Size = UDim2.fromOffset(20, 20),
				ZIndex = holder.ZIndex + 2,
			}) then
				createText(holder, "KEY", 9, self.Theme.Accent, Enum.Font.GothamBlack, {
					Position = UDim2.fromOffset(12, 0),
					Size = UDim2.fromOffset(32, 42),
					TextXAlignment = Enum.TextXAlignment.Center,
					ZIndex = holder.ZIndex + 2,
				})
			end
			return box
		end

		local function verifyKey(keyBox)
			local key = (keyBox.Text or ""):gsub("%s+", "")
			if key == "" then
				self:SetStatus("Paste your key first.", "error")
				self:ShakeKeyInput(keyBox)
				return
			end

			if type(self.Options.VerifyKey) == "function" then
				-- sdk.check_key performs an HTTP request and can block, so run
				-- it off the input thread and show a loading overlay meanwhile.
				if keyBox.Interactable ~= nil then
					keyBox.Interactable = false
				end
				self:ShowKeyOverlay("loading", "Verifying key...")
				task.spawn(function()
					local callOk, verified, message = pcall(self.Options.VerifyKey, key, self)
					if callOk and verified then
						self:ShowKeyOverlay("success", message or "Key verified")
						task.wait(0.8)
						self:ShowKeyOverlay("hide")
						self:SetStatus(message or "Key verified.", "success")
						if type(self.Options.OnKeyVerified) == "function" then
							task.spawn(self.Options.OnKeyVerified, key, self)
						end
					else
						self:ShowKeyOverlay("hide")
						if keyBox.Interactable ~= nil then
							keyBox.Interactable = true
						end
						self:SetStatus(message or tostring(verified or "Invalid key."), "error")
						self:ShakeKeyInput(keyBox)
					end
				end)
				return
			end

			local valid = false
			if type(self.Options.ValidKeys) == "table" then
				for _, allowedKey in ipairs(self.Options.ValidKeys) do
					if tostring(allowedKey) == key then
						valid = true
						break
					end
				end
			end

			if valid then
				if keyBox.Interactable ~= nil then
					keyBox.Interactable = false
				end
				task.spawn(function()
					self:ShowKeyOverlay("success", "Key verified")
					task.wait(0.8)
					self:ShowKeyOverlay("hide")
					self:SetStatus("Key verified.", "success")
					if type(self.Options.OnKeyVerified) == "function" then
						task.spawn(self.Options.OnKeyVerified, key, self)
					end
				end)
			else
				self:SetStatus("No verify callback configured.", "warn")
				self:ShakeKeyInput(keyBox)
			end
		end

		createText(self.Content, "GAME CONTROL CENTER", 10, self.Theme.Muted, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(22, 18),
			Size = UDim2.new(1, -360, 0, 16),
		})

		local rightWidth = 284
		local mainLeft = 20
		local panelTop = 48
		local gap = 18
		local mainWidth = self.Content.AbsoluteSize.X > 0 and (self.Content.AbsoluteSize.X - mainLeft * 2 - rightWidth - gap) or 622
		mainWidth = math.max(560, mainWidth)

		local mainPanel = techPanel(self.Content, {
			Name = "SelectedGame",
			Position = UDim2.fromOffset(mainLeft, panelTop),
			Size = UDim2.new(1, -(rightWidth + gap + mainLeft * 2), 1, -(panelTop + 18)),
			BackgroundColor3 = self.Theme.Root,
			BackgroundTransparency = 0.08,
			StrokeColor = self.Theme.Accent,
			StrokeThickness = 1.4,
			Radius = 8,
			Depth = 2,
		})
		local fadeLabels = {}
		local function trackFade(label)
			if shouldAnimateSlide and label then
				label.TextTransparency = 1
				fadeLabels[#fadeLabels + 1] = label
			end
			return label
		end
		if shouldAnimateSlide then
			mainPanel.Position = UDim2.fromOffset(mainLeft + 10, panelTop)
			mainPanel.BackgroundTransparency = 0.18
		end

		trackFade(createText(mainPanel, "SELECTED GAME", 10, self.Theme.Accent, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(24, 18),
			Size = UDim2.new(1, -210, 0, 18),
		}))
		trackFade(createText(mainPanel, "MAP " .. tostring(self.HudSlideIndex) .. " / " .. tostring(math.max(gameCount, 1)), 10, self.Theme.Muted, Enum.Font.GothamBlack, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -24, 0, 18),
			Size = UDim2.fromOffset(96, 18),
			TextXAlignment = Enum.TextXAlignment.Right,
		}))
		trackFade(createText(mainPanel, string.upper(selectedGame.Title or selectedGame.Name or "ROBLOX MAP"), 21, self.Theme.Text, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(24, 40),
			Size = UDim2.new(1, -48, 0, 30),
			TextTruncate = Enum.TextTruncate.AtEnd,
		}))
		trackFade(createText(mainPanel, selectedGame.Description or "Adventure World", 14, self.Theme.Accent, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(24, 70),
			Size = UDim2.new(1, -48, 0, 22),
			TextTruncate = Enum.TextTruncate.AtEnd,
		}))
		trackFade(createText(mainPanel, "Players: 12/24   |   Mode: " .. tostring(selectedGame.Mode or "Adventure"), 11, self.Theme.Muted, Enum.Font.GothamMedium, {
			Position = UDim2.fromOffset(24, 98),
			Size = UDim2.new(1, -48, 0, 18),
		}))

		local preview = techPanel(mainPanel, {
			Name = "MapPreview",
			Position = UDim2.fromOffset(24, 126),
			Size = UDim2.new(1, -48, 0, 278),
			BackgroundColor3 = self.Theme.Field,
			BackgroundTransparency = 0,
			StrokeColor = self.Theme.Accent,
			StrokeThickness = 1.2,
			Radius = 7,
			Depth = 3,
		})
		local previewImage = gamePreviewImage(selectedGame)
		local previewArt = nil
		if previewImage then
			previewArt = uiMake("ImageLabel", {
				BackgroundTransparency = 1,
				Image = previewImage,
				ImageTransparency = shouldAnimateSlide and 1 or 0,
				Position = shouldAnimateSlide and UDim2.fromOffset(24, 0) or UDim2.new(),
				ScaleType = Enum.ScaleType.Crop,
				Size = shouldAnimateSlide and UDim2.new(1, 24, 1, 0) or UDim2.fromScale(1, 1),
				ZIndex = preview.ZIndex + 1,
			}, preview)
		end
		local previewTint = uiMake("Frame", {
			BackgroundColor3 = self.Theme.Accent,
			BackgroundTransparency = shouldAnimateSlide and 0.58 or 0.86,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 0),
			Size = UDim2.fromScale(1, 1),
			ZIndex = preview.ZIndex + 2,
		}, preview)
		local animateFeatureIntro = self.Options.AnimateFeatureIntro ~= false and not lowEffects
		local featurePanel = techPanel(mainPanel, {
			Position = UDim2.fromOffset(24, 438),
			Size = UDim2.new(1, -48, 0, 86),
			BackgroundColor3 = self.Theme.Field,
			BackgroundTransparency = 0.1,
			StrokeColor = self.Theme.StrokeSoft,
			StrokeTransparency = 0.08,
			Radius = 5,
			Depth = 1,
		})
		local featureSlideOffset = shouldAnimateSlide and 22 or 0
		local featureTitleStartY = animateFeatureIntro and 16 or 8
		local featureInfoStartY = animateFeatureIntro and 34 or 25
		local featureRowStartY = animateFeatureIntro and 58 or 48
		local featureTitle = createText(featurePanel, "RECOMMENDED FUNCTIONS", 10, self.Theme.Accent, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(16 + featureSlideOffset, featureTitleStartY),
			Size = UDim2.new(1, -32, 0, 16),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTransparency = animateFeatureIntro and 1 or 0,
			ZIndex = featurePanel.ZIndex + 1,
		})
		local featureMapInfo = createText(featurePanel, "MAP INFO  " .. tostring(selectedGame.MapSize or selectedGame.Size or "LARGE") .. " / " .. tostring(selectedGame.Difficulty or "MEDIUM") .. " / " .. tostring(selectedGame.Region or "US-EAST"), 9, self.Theme.Muted, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(16 + featureSlideOffset, featureInfoStartY),
			Size = UDim2.new(1, -32, 0, 14),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTransparency = animateFeatureIntro and 1 or 0,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = featurePanel.ZIndex + 1,
		})
		local featureLoader = uiMake("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = self.Theme.AccentHover,
			BackgroundTransparency = animateFeatureIntro and 0.24 or 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0.5, 0, 0, 42),
			Size = UDim2.fromOffset(animateFeatureIntro and 0 or 120, 1),
			ZIndex = featurePanel.ZIndex + 1,
		}, featurePanel)
		local featureRow = uiMake("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14 + featureSlideOffset, featureRowStartY),
			Size = UDim2.new(1, -28, 0, 28),
			ZIndex = featurePanel.ZIndex + 1,
		}, featurePanel)
		uiMake("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}, featureRow)
		local features = gameRecommendedFeatures(selectedGame)
		local featureAnimations = {}
		for index = 1, math.min(4, #features) do
			local featureText = tostring(features[index])
			local chipTextColor = index == 1 and self.Theme.Text or self.Theme.Muted
			local targetChipTransparency = index == 1 and 0.02 or 0.14
			local targetStrokeTransparency = index == 1 and 0.08 or 0.22
			local targetIconTransparency = index == 1 and 0 or 0.12
			local chip = uiMake("Frame", {
				BackgroundColor3 = index == 1 and self.Theme.AccentSoft or self.Theme.Root,
				BackgroundTransparency = animateFeatureIntro and 1 or targetChipTransparency,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(112, 28),
				ZIndex = featureRow.ZIndex + 1,
			}, featureRow)
			uiCorner(chip, 5)
			local chipStroke = uiStroke(chip, index == 1 and self.Theme.Accent or self.Theme.StrokeSoft, 1, animateFeatureIntro and 1 or targetStrokeTransparency)
			local chipScale = uiMake("UIScale", {
				Scale = animateFeatureIntro and 0.86 or 1,
			}, chip)
			local chipIcon = createAssetIcon(chip, featureIconName(featureText), {
				Color3 = chipTextColor,
				Transparency = animateFeatureIntro and 1 or targetIconTransparency,
				Position = UDim2.fromOffset(8, 6),
				Size = UDim2.fromOffset(14, 14),
				ZIndex = chip.ZIndex + 1,
			})
			local chipLabel = createText(chip, featureText, 9, chipTextColor, Enum.Font.GothamBlack, {
				Position = UDim2.fromOffset(28, 0),
				Size = UDim2.new(1, -34, 1, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = animateFeatureIntro and 1 or 0,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = chip.ZIndex + 1,
			})
			featureAnimations[#featureAnimations + 1] = {
				Chip = chip,
				Stroke = chipStroke,
				Scale = chipScale,
				Icon = chipIcon,
				Label = chipLabel,
				ChipTransparency = targetChipTransparency,
				StrokeTransparency = targetStrokeTransparency,
				IconTransparency = targetIconTransparency,
			}
		end

		if animateFeatureIntro then
			local introDelay = shouldAnimateSlide and 0.02 or 0
			task.delay(introDelay, function()
				if not featurePanel.Parent then
					return
				end
				self.TweenService:Create(featureTitle, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(16, 8),
				TextTransparency = 0,
				}):Play()
				self.TweenService:Create(featureMapInfo, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(16, 25),
				TextTransparency = 0,
				}):Play()
				self.TweenService:Create(featureLoader, TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(120, 1),
				}):Play()
				self.TweenService:Create(featureRow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(14, 48),
				}):Play()
			end)

			for index, item in ipairs(featureAnimations) do
				task.delay(introDelay + 0.08 + index * 0.07, function()
					if not item.Chip.Parent then
						return
					end
					self.TweenService:Create(item.Chip, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						BackgroundTransparency = item.ChipTransparency,
					}):Play()
					self.TweenService:Create(item.Scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Scale = 1,
					}):Play()
					self.TweenService:Create(item.Stroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Transparency = item.StrokeTransparency,
					}):Play()
					if item.Icon then
						self.TweenService:Create(item.Icon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							ImageTransparency = item.IconTransparency,
						}):Play()
					end
					self.TweenService:Create(item.Label, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextTransparency = 0,
					}):Play()
				end)
			end
			task.delay(introDelay + 0.56, function()
				if featureLoader.Parent then
					self.TweenService:Create(featureLoader, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 1,
					}):Play()
				end
			end)
		end

		if shouldAnimateSlide then
			self.TweenService:Create(mainPanel, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.08,
				Position = UDim2.fromOffset(mainLeft, panelTop),
			}):Play()
			for _, label in ipairs(fadeLabels) do
				self.TweenService:Create(label, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextTransparency = 0,
				}):Play()
			end
			if previewArt then
				self.TweenService:Create(previewArt, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 0,
					Position = UDim2.new(),
					Size = UDim2.fromScale(1, 1),
				}):Play()
			end
			self.TweenService:Create(previewTint, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.86,
			}):Play()

			local scanLine = uiMake("Frame", {
				BackgroundColor3 = self.Theme.AccentHover,
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(-18, 0),
				Size = UDim2.new(0, 18, 1, 0),
				ZIndex = preview.ZIndex + 6,
			}, preview)
			self.TweenService:Create(scanLine, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.78,
				Position = UDim2.new(1, 18, 0, 0),
			}):Play()
			task.delay(0.42, function()
				if scanLine.Parent then
					scanLine:Destroy()
				end
			end)
		end

		local rightPanel = techPanel(self.Content, {
			Name = "KeyPanel",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -22, 0, panelTop),
			Size = UDim2.new(0, rightWidth, 1, -(panelTop + 18)),
			BackgroundColor3 = self.Theme.Root,
			BackgroundTransparency = 0.09,
			StrokeColor = self.Theme.Accent,
			StrokeThickness = 1.2,
			Radius = 8,
			Depth = 2,
		})
		local titleIcon = uiMake("Frame", {
			Name = "KeyPanelIcon",
			BackgroundColor3 = self.Theme.AccentSoft,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(22, 20),
			Size = UDim2.fromOffset(38, 38),
			ZIndex = rightPanel.ZIndex + 1,
		}, rightPanel)
		uiCorner(titleIcon, 6)
		uiStroke(titleIcon, self.Theme.Accent, 1, 0.08)
		addDepth(titleIcon, self.Theme, 1, 6)
		createAssetIcon(titleIcon, "key", {
			Color3 = self.Theme.Text,
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.fromOffset(22, 22),
			ZIndex = titleIcon.ZIndex + 2,
		})
		createText(rightPanel, "GET KEY", 22, self.Theme.Text, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(70, 22),
			Size = UDim2.new(1, -96, 0, 30),
		})
		createText(rightPanel, "Secure access to " .. string.upper(self.Options.Name or self.Library.Name), 10, self.Theme.Muted, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(70, 54),
			Size = UDim2.new(1, -96, 0, 18),
		})

		local keyBox = hudInput(rightPanel, "KEY", "XXXXX-XXXXX-XXXXX-XXXXX", 98, "key")

		local buttonRow = uiMake("Frame", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(16, 190),
			Size = UDim2.new(1, -32, 0, 46),
		}, rightPanel)
		uiList(buttonRow, Enum.FillDirection.Horizontal, 12)
		local getKeyButton, getKeyLabel = createButton(buttonRow, self.Theme, "GET KEY", {
			App = self,
			Size = UDim2.new(0.5, -6, 1, 0),
			BackgroundColor3 = self.Theme.Accent,
			HoverColor = self.Theme.AccentHover,
			StrokeColor = self.Theme.AccentHover,
			TextSize = 12,
			Radius = 5,
		}, function()
			local keyUrl = self:GetResolvedKeyLink()
			if keyUrl then
				self:Copy(keyUrl, "Key link copied.")
			end
		end)
		createAssetIcon(getKeyButton, "key", {
			Color3 = self.Theme.Text,
			Position = UDim2.fromOffset(12, 14),
			Size = UDim2.fromOffset(17, 17),
			ZIndex = getKeyButton.ZIndex + 2,
		})
		getKeyLabel.Position = UDim2.fromOffset(22, 0)
		getKeyLabel.Size = UDim2.new(1, -28, 1, 0)

		local verifyButton, verifyLabel = createButton(buttonRow, self.Theme, "VERIFY KEY", {
			App = self,
			Size = UDim2.new(0.5, -6, 1, 0),
			BackgroundColor3 = self.Theme.Field,
			HoverColor = self.Theme.AccentSoft,
			StrokeColor = self.Theme.Stroke,
			TextSize = 10,
			Radius = 5,
		}, function()
			verifyKey(keyBox)
		end)
		createAssetIcon(verifyButton, "verify", {
			Color3 = self.Theme.AccentHover,
			Position = UDim2.fromOffset(11, 14),
			Size = UDim2.fromOffset(17, 17),
			ZIndex = verifyButton.ZIndex + 2,
		})
		verifyLabel.Position = UDim2.fromOffset(22, 0)
		verifyLabel.Size = UDim2.new(1, -28, 1, 0)

		local vipGold = Color3.fromRGB(255, 198, 75)
		local vipGoldSoft = Color3.fromRGB(86, 62, 24)
		local vipPanel = techPanel(rightPanel, {
			Name = "VipPromo",
			Position = UDim2.fromOffset(16, 294),
			Size = UDim2.new(1, -32, 0, 212),
			BackgroundColor3 = Color3.fromRGB(18, 15, 12),
			BackgroundTransparency = 0.08,
			StrokeColor = vipGold,
			StrokeThickness = 1.25,
			StrokeTransparency = 0.02,
			CornerColor = vipGold,
			Radius = 6,
			Depth = 2,
		})
		local vipPanelStroke = vipPanel:FindFirstChildOfClass("UIStroke")
		local vipGlow = uiMake("Frame", {
			Name = "VipGoldGlow",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = vipPanel.Position,
			Size = vipPanel.Size,
			ZIndex = math.max(0, vipPanel.ZIndex - 1),
		}, rightPanel)
		uiCorner(vipGlow, 6)
		local vipGlowStroke = uiStroke(vipGlow, vipGold, 3, 0.62)
		if not lowEffects then
			task.spawn(function()
				while rightPanel.Parent and vipPanel.Parent and vipGlow.Parent do
					if self:HudEffectsAllowed() then
						self.TweenService:Create(vipGlowStroke, TweenInfo.new(0.86, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							Transparency = 0.24,
							Thickness = 4,
						}):Play()
						if vipPanelStroke then
							self.TweenService:Create(vipPanelStroke, TweenInfo.new(0.86, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
								Transparency = 0,
								Thickness = 1.7,
							}):Play()
						end
						task.wait(0.86)
						if not (rightPanel.Parent and vipPanel.Parent and vipGlow.Parent) then
							break
						end
						self.TweenService:Create(vipGlowStroke, TweenInfo.new(0.94, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
							Transparency = 0.68,
							Thickness = 2.4,
						}):Play()
						if vipPanelStroke then
							self.TweenService:Create(vipPanelStroke, TweenInfo.new(0.94, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
								Transparency = 0.05,
								Thickness = 1.25,
							}):Play()
						end
						task.wait(0.94)
					else
						task.wait(0.25)
					end
				end
			end)
		end

		uiMake("Frame", {
			BackgroundColor3 = vipGold,
			BackgroundTransparency = 0.34,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(14, 68),
			Size = UDim2.new(1, -28, 0, 1),
			ZIndex = vipPanel.ZIndex + 1,
		}, vipPanel)

		local vipIcon = uiMake("Frame", {
			Name = "VipPromoIcon",
			BackgroundColor3 = vipGoldSoft,
			BackgroundTransparency = 0.08,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(14, 15),
			Size = UDim2.fromOffset(38, 38),
			ZIndex = vipPanel.ZIndex + 1,
		}, vipPanel)
		uiCorner(vipIcon, 6)
		uiStroke(vipIcon, vipGold, 1, 0.08)
		createAssetIcon(vipIcon, "vip", {
			Color3 = vipGold,
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.fromOffset(22, 22),
			ZIndex = vipIcon.ZIndex + 1,
		})
		createText(vipPanel, self.Options.VipPromoTitle or "VIP RECOMMENDED", 11, vipGold, Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(62, 13),
			Size = UDim2.new(1, -78, 0, 18),
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = vipPanel.ZIndex + 1,
		})
		createText(vipPanel, self.Options.VipPromoSubtitle or "Unlock premium maps and features.", 10, self.Theme.Text, Enum.Font.GothamBold, {
			Position = UDim2.fromOffset(62, 33),
			Size = UDim2.new(1, -78, 0, 26),
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = vipPanel.ZIndex + 1,
		})

		local priceBox = uiMake("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = vipGold,
			BackgroundTransparency = 0.02,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -14, 0, 82),
			Size = UDim2.fromOffset(92, 56),
			ZIndex = vipPanel.ZIndex + 1,
		}, vipPanel)
		uiCorner(priceBox, 6)
		createText(priceBox, "VIP PRICE", 8, Color3.fromRGB(45, 31, 8), Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.new(1, -16, 0, 10),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = priceBox.ZIndex + 1,
		})
		createText(priceBox, tostring(self.Options.VipPrice or "149 THB"), 14, Color3.fromRGB(45, 31, 8), Enum.Font.GothamBlack, {
			Position = UDim2.fromOffset(6, 24),
			Size = UDim2.new(1, -12, 0, 20),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = priceBox.ZIndex + 1,
		})

		local vipBadge = uiMake("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = vipGoldSoft,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Position = UDim2.new(1, -14, 0, 146),
			Size = UDim2.fromOffset(92, 20),
			ZIndex = vipPanel.ZIndex + 1,
		}, vipPanel)
		uiCorner(vipBadge, 5)
		uiStroke(vipBadge, vipGold, 1, 0.05)
		createText(vipBadge, self.Options.VipPromoBadge or "BEST VALUE", 8, vipGold, Enum.Font.GothamBlack, {
			Size = UDim2.fromScale(1, 1),
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = vipBadge.ZIndex + 1,
		})

		for index, detail in ipairs(self.Options.VipPromoDetails or {
			"VIP game loaders",
			"Priority support",
			"Exclusive auto farm",
		}) do
			local y = 86 + (index - 1) * 22
			uiMake("Frame", {
				BackgroundColor3 = vipGold,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(18, y + 8),
				Size = UDim2.fromOffset(4, 4),
				ZIndex = vipPanel.ZIndex + 1,
			}, vipPanel)
			createText(vipPanel, tostring(detail), 9, self.Theme.Muted, Enum.Font.GothamBold, {
				Position = UDim2.fromOffset(30, y),
				Size = UDim2.new(1, -150, 0, 16),
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = vipPanel.ZIndex + 1,
			})
		end

		local buyVipButton, buyVipLabel = createButton(vipPanel, self.Theme, "BUY VIP", {
			App = self,
			Position = UDim2.new(0, 14, 1, -44),
			Size = UDim2.new(1, -28, 0, 30),
			BackgroundColor3 = vipGold,
			HoverColor = Color3.fromRGB(255, 220, 112),
			StrokeColor = vipGold,
			TextColor3 = Color3.fromRGB(45, 31, 8),
			TextSize = 10,
			Radius = 5,
			ZIndex = vipPanel.ZIndex + 1,
		}, function()
			self:Copy(self.Options.VipUrl or self.Options.DiscordUrl or "https://discord.gg/Xfa9nAsTCJ", "VIP link copied.")
		end)
		createAssetIcon(buyVipButton, "vip", {
			Color3 = Color3.fromRGB(45, 31, 8),
			Position = UDim2.fromOffset(74, 7),
			Size = UDim2.fromOffset(16, 16),
			ZIndex = buyVipButton.ZIndex + 2,
		})
		buyVipLabel.Position = UDim2.fromOffset(18, 0)
		buyVipLabel.Size = UDim2.new(1, -24, 1, 0)

		if gameCount > 1 then
			task.delay(self.Options.AutoSlideDelay or 4, function()
				if slideToken ~= self.HudSlideToken then
					return
				end
				if self.CurrentPage ~= "GetKey" then
					return
				end
				if not self.Screen or not self.Screen.Parent then
					return
				end
				if self.Root and self.Root.Visible == false then
					return
				end

				self.HudSlideIndex = ((self.HudSlideIndex or 1) % gameCount) + 1
				self.HudSlideFadeIn = not self:IsLowEffects()
				self:ShowGetKey()
			end)
		end
	end

	function app:Destroy()
		for _, connection in ipairs(self.Connections) do
			pcall(function()
				connection:Disconnect()
			end)
		end
		if self.Screen and self.Screen.Parent then
			self.Screen:Destroy()
		end
	end

	if tostring(options.DefaultPage or "GetKey"):lower() == "support" then
		app:ShowSupportGames()
	else
		app:ShowGetKey()
	end

	-- If a previously-verified key is cached, re-check it in the background
	-- and skip the key prompt when it is still valid. The user still sees the
	-- key page for a moment; a successful auto-verify immediately loads the
	-- payload via OnKeyVerified.
	if type(options.AutoVerifyKey) == "function" then
		task.spawn(function()
			local key = options.AutoVerifyKey()
			if type(key) == "string" and key ~= "" and app.CurrentPage == "GetKey" then
				app:SetStatus("Restoring session...", "warn")
				if type(options.OnKeyVerified) == "function" then
					task.spawn(options.OnKeyVerified, key, app)
				end
			end
		end)
	end

	return app
end

function PeterHubV2:CreateSupportGamesWindow(options)
	options = options or {}
	options.DefaultPage = "Support"
	return self:CreateStyledWindow(options)
end

function PeterHubV2:CreateGetKeyWindow(options)
	options = options or {}
	options.DefaultPage = "GetKey"
	return self:CreateStyledWindow(options)
end


local MammozHub = PeterHubV2
-- Backwards-compatible alias for payloads that still reference the old name.
local PeterHub = MammozHub

local JUNKIE_SERVICE = "test"
local JUNKIE_IDENTIFIER = "1184939"
local JUNKIE_PROVIDER = "test"
local Junkie

-- Verified-key persistence so the user does not re-enter the key every run.
-- Best-effort: executors without file APIs simply skip caching. Keys are
-- stored per game route because a JNKiE key is bound to one service.
local KEY_FOLDER = "MammozHub"
local function keyPath(routeKey)
	return KEY_FOLDER .. "/verified_key_" .. tostring(routeKey or "default") .. ".txt"
end
local function hasFileSystemSupport()
	local okW = pcall(function() return type(writefile) == "function" end)
	local okR = pcall(function() return type(readfile) == "function" end)
	local okI = pcall(function() return type(isfile) == "function" end)
	return okW and okR and okI
end
local fileSystemSupported = hasFileSystemSupport()

local function saveVerifiedKey(routeKey, key)
	if not fileSystemSupported or type(key) ~= "string" or key == "" then
		return false
	end
	if type(makefolder) == "function" then
		pcall(makefolder, KEY_FOLDER)
	end
	local path = keyPath(routeKey)
	local ok = pcall(writefile, path, key)
	return ok
end
local function loadSavedVerifiedKey(routeKey)
	if not fileSystemSupported then
		return nil
	end
	local path = keyPath(routeKey)
	local okExists, exists = pcall(isfile, path)
	if not okExists or not exists then
		return nil
	end
	local ok, content = pcall(readfile, path)
	if not ok or type(content) ~= "string" or content == "" then
		return nil
	end
	return content
end
local function clearSavedVerifiedKey(routeKey)
	if not fileSystemSupported then
		return false
	end
	local path = keyPath(routeKey)
	if type(delfile) == "function" then
		return pcall(delfile, path)
	end
	return pcall(writefile, path, "")
end

-- JNKiE error codes documented for External Loader. The code is kept in the
-- message so service/dashboard configuration problems are easy to diagnose.
local JUNKIE_ERROR_TEXT = {
	KEY_INVALID = "The key is invalid.",
	KEY_EXPIRED = "The key has expired.",
	HWID_BANNED = "This device is banned.",
	KEY_INVALIDATED = "The key has been invalidated.",
	ALREADY_USED = "This key has already been used.",
	HWID_MISMATCH = "This key belongs to a different device.",
	SERVICE_NOT_FOUND = "JNKiE service was not found. Check the service setting.",
	SERVICE_MISMATCH = "This key does not belong to the configured service.",
	PREMIUM_REQUIRED = "A premium key is required.",
	RATE_LIMITTED = "Too many requests. Please wait five minutes and try again.",
	ERROR = "JNKiE could not process this request.",
}

local function junkieReason(result, fallback)
	local code = type(result) == "table" and (result.error or result.message) or result
	if code == nil or tostring(code) == "" then
		return fallback
	end
	code = tostring(code)
	local explanation = JUNKIE_ERROR_TEXT[code]
	if explanation then
		return "[" .. code .. "] " .. explanation
	end
	return code
end

local function loadJunkie()
	if Junkie then
		return Junkie
	end

	local ok, result = pcall(function()
		return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua", true), "JunkieSDK")()
	end)
	if not ok or type(result) ~= "table" then
		error("Could not load Junkie SDK: " .. tostring(result))
	end

	result.service = JUNKIE_SERVICE
	result.identifier = JUNKIE_IDENTIFIER
	result.provider = JUNKIE_PROVIDER
	Junkie = result
	return Junkie
end

local function getJunkieKeyLink()
	local sdk = loadJunkie()
	local ok, link, err = pcall(function()
		return sdk.get_key_link()
	end)
	if not ok then
		error("Could not create JNKiE key link: " .. tostring(link), 2)
	end
	if not link or tostring(link) == "" then
		error(junkieReason(err, "JNKiE did not return a key link."), 2)
	end
	return tostring(link)
end

local function verifyJunkieKey(key, routeKey)
	if type(key) ~= "string" then
		return false, "Enter a valid key."
	end

	local sdk = loadJunkie()
	local ok, result = pcall(function()
		return sdk.check_key(key)
	end)
	if not ok then
		return false, "Could not verify the key: " .. tostring(result)
	end

	local env = type(getgenv) == "function" and getgenv() or _G
	if type(result) == "table" and result.valid == true then
		if result.message == "KEYLESS" then
			env.SCRIPT_KEY = "KEYLESS"
			return true, "Keyless mode"
		end

		env.SCRIPT_KEY = key
		-- Cache the verified key so the next launch can skip the prompt.
		if routeKey then
			saveVerifiedKey(routeKey, key)
		end
		return true, result.message or "Key valid"
	end

	-- An invalid/expired/used key should not be trusted again: drop the
	-- cached copy so the user is prompted to enter a fresh one.
	if routeKey then
		clearSavedVerifiedKey(routeKey)
	end
	return false, junkieReason(result, "Invalid key")
end

-- One public JNKiE /download URL per supported game. The UI is embedded in
-- this file; only the protected payloads live on JNKiE.
local GAME_ROUTES = {
	{
		Key = "aotr",
		Name = "Attack On Titan Rev.",
		PlaceIds = { 13379208636, 14916516914 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/253aebb2ea396addfc45b9a58f33678e753176d2d07bf72c4be8d11f6bcca3ea/download",
	},
	{
		Key = "anime_card_farm",
		Name = "Anime Card Farm",
		PlaceIds = { 125039475354804 },
		Url = "",
	},
	{
		Key = "arena_sniper",
		Name = "Arena Sniper",
		PlaceIds = { 122446657157717 },
		Url = "",
	},
	{
		Key = "roll_anime_to_fight",
		Name = "Roll Anime To Fight",
		PlaceIds = { 107653945083776 },
		Url = "",
	},
	{
		Key = "gakuran",
		Name = "Gakuran",
		PlaceIds = { 128736949265057 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/42ef9ede2c560e3c679423ec1725ce2d294ca5249d9c903400ac71c2ddd9c39d/download",
	},
	{
		Key = "dungeon_quest_reborn",
		Name = "Dungeon Quest Reborn",
		PlaceIds = { 77649408247578 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/dfd22390daef74d45ac7db57e534ba11b6c4c010a34fd6181d24c3570ae35cf4/download",
	},
	{
		Key = "dungeon_lootr",
		Name = "Dungeon Lootr",
		PlaceIds = { 106484206883664 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/e4268721fe855776a87b46a4d90e43a2766542ea043ce07a132f4f9bea2b47dc/download",
	},
	{
		Key = "da_hood",
		Name = "Da Hood",
		PlaceIds = { 2788229376 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/dc19ed8275ef5a430f7ba1de06f5eccfaef7a74e6959f3fa336981b7f2cb37bf/download",
	},
	{
		Key = "cut_grass_adventure",
		Name = "+1 Cut Grass Adventure",
		PlaceIds = { 90086669327265 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/1d35b364d18aa456ad99c0a3f85be9afab82901135c85f4f02d830ee92be14d5/download",
	},
	{
		Key = "fish_bait_tora",
		Name = "BE A FISH BAIT - Tora IsMe",
		PlaceIds = { 99702578544768 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/056e24b06970ad2ec68007d65c6fbb58d3d91e2ab908138c4da06996382dd8fe/download",
	},
	{
		Key = "ninetynine_nights",
		Name = "99 Nights in the Forest",
		PlaceIds = { 126509999114328, 79546208627805 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/575f56111ca77d63ce0cdc0bd72018027568dc7f40f24db90875af10e507b5bd/download",
	},
	{
		Key = "grow_a_chicken_fighter",
		Name = "Grow a Chicken Fighter",
		PlaceIds = { 94640181989498 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/80a9aea0793a944d072e4b9b0ff5167844999afb7d466bc507f21e2cad6abcfc/download",
	},
	{
		Key = "steal_an_egg",
		Name = "Steal An Egg",
		PlaceIds = { 107778070777162, 114667206840982 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/57ba694c90ab41553d0e587a16827e5c459b797686c2bc25ba771cb8bfadaef6/download",
	},
	{
		Key = "fish",
		Name = "Fish",
		PlaceIds = { 77773900773577 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/d7aee93943ad978441fb5753377a4452aba26b1f53593db987b414d96e8d974f/download",
	},
	{
		Key = "shindo_life",
		Name = "Shindo Life",
		PlaceIds = { 4616652839 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/62a798a8aae5de96a5002c9c924f00d841993428318f2681ad4d69e42397e031/download",
	},
	{
		Key = "mine_a_mountain",
		Name = "Mine a Mountain",
		PlaceIds = { 125927821145949 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/1edbca0dee54fc259c9c8e8316de07d01f54b63b0b86d72f042dd41c60a58478/download",
	},
	{
		Key = "mm2",
		Name = "Murder Mystery 2",
		PlaceIds = { 142823291 },
		Url = "",
	},
	{
		Key = "ammoclick",
		Name = "+1 Ammo Per Click",
		PlaceIds = { 139907538117897 },
		Url = "",
	},
	{
		Key = "cleanleaves",
		Name = "Clean all the leaves",
		PlaceIds = { 92637789841354, 100068273119174 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/7a854954183f1602c43ed8acf0d37d8fef0c114c712e4f4bb4752ebb910cb94a/download",
	},
	{
		Key = "aurabrainrots",
		Name = "Aura For Brainrots",
		PlaceIds = { 122526789002601 },
		Url = "",
	},
	{
		Key = "beflash",
		Name = "Be Flash For Brainrots",
		PlaceIds = { 136066387156306 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/7a47c2f4944dbd493ba4009afab19af7881c1ceced0b5c1aa1f094d5df46e869/download",
	},
	{
		Key = "drainwater",
		Name = "+1 Drain Water Per Click",
		PlaceIds = { 103883942725157 },
		Url = "",
	},
	{
		Key = "demon_blade",
		Name = "Demon Blade",
		PlaceIds = { 15014439457, 98470671607734 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/3b1e9491ca51e4f620f68091ec5646fff35f0ebd79d1df64b8678642eedad5a5/download",
	},
	{
		Key = "drillfarm",
		Name = "Make a Drill Farm",
		PlaceIds = { 79315121100812 },
		Url = "",
	},
	{
		Key = "digclean",
		Name = "Dig & Clean",
		PlaceIds = { 83038462357724 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/3e1a303cf1403a689fa9c316dc05f0fb08cf0cf3f2b860856267bc1d59b2ba60/download",
	},
	{
		Key = "jetpackbrainrots",
		Name = "+1 Jetpack for Brainrots",
		PlaceIds = { 80234914611737 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/48efe3f42ccea6dafa3073b84c7c2a781c2a9ddff1a7170b3e92821a80d3ac18/download",
	},
	{
		Key = "haze_piece",
		Name = "Haze Piece",
		PlaceIds = { 6918802270, 14979402479, 99664616626491 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/c211661194d71b20404a0086546bb622605105948f287ac8ed05bc677f5fbc9d/download",
	},
	{
		Key = "king_legacy",
		Name = "King Legacy",
		PlaceIds = { 4520749081, 6381829480, 15759515082 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/e4f3b980212219f26173f0892af2cc324f6f758008455dd578db39fdd31e58da/download",
	},
	{
		Key = "sailor_piece",
		Name = "Sailor Piece",
		PlaceIds = { 77747658251236, 130167267952199 },
		Url = "",
	},
	{
		Key = "logobrainrots",
		Name = "Logo For Brainrots",
		PlaceIds = { 123959902101040 },
		Url = "",
	},
	{
		Key = "mineclick",
		Name = "+1 Mine Per Click",
		PlaceIds = { 74193805629461 },
		Url = "",
	},
	{
		Key = "muscleevo",
		Name = "+1 Muscle Evolution",
		PlaceIds = { 133007106457547 },
		Url = "",
	},
	{
		Key = "looksclick",
		Name = "+1 Looks Per Click",
		PlaceIds = { 102355196524321 },
		Url = "",
	},
	{
		Key = "poortorich",
		Name = "+1 Poor To Rich",
		PlaceIds = { 96003649748017 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/6a772895a410d4e9126734ac8b609a23cd3d06b6265972e2f9846ec69865493e/download",
	},
	{
		Key = "luckyfish",
		Name = "Pull a Lucky Fish",
		PlaceIds = { 112781315318195 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/589242dff68f22ccb85b3051c2561b283544339a1b1b0847334595065fd1be9d/download",
	},
	{
		Key = "powerclick",
		Name = "+1 Power Per Click",
		PlaceIds = { 74889851913797 },
		Url = "",
	},
	{
		Key = "powerblast",
		Name = "Power Blast Lucky Blocks",
		PlaceIds = { 119822977170203 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/67506f3fe78dfb971c372667f42db89bd5251368c1aa59a55437c23283dd6c90/download",
	},
	{
		Key = "pickaxesim",
		Name = "Pickaxe Simulator",
		PlaceIds = { 82013336390273 },
		Url = "",
	},
	{
		Key = "selllemons",
		Name = "Sell Lemons",
		PlaceIds = { 79268393072444 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/ca93543f288196adebbb4acb7c25325d39659089623c32f2e4a4603fa7b871bb/download",
	},
	{
		Key = "skillpoints",
		Name = "+1 Skill Point Legends",
		PlaceIds = { 135668295983945 },
		Url = "",
	},
	{
		Key = "speedevolve",
		Name = "+1 Speed Evolve",
		PlaceIds = { 83569851223739, 107654875426558 },
		Url = "",
	},
	{
		Key = "speedmonkey",
		Name = "+1 Speed Monkey Escape",
		PlaceIds = { 114697347887839 },
		Url = "",
	},
	{
		Key = "spinjitsu",
		Name = "+1 Spinjitsu Escape",
		PlaceIds = { 131910189515331 },
		Url = "",
	},
	{
		Key = "strengthclick",
		Name = "+1 Strength Per Click",
		PlaceIds = { 120766736586332 },
		Url = "",
	},
	{
		Key = "wingsbrainrots",
		Name = "+1 Wings for Brainrots",
		PlaceIds = { 84332574190497 },
		Url = "",
	},
	{
		Key = "blox_fruits",
		Name = "Blox Fruits",
		PlaceIds = { 2753915549, 4442272183, 7449423635 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/f561f30cbab2242f2cac72a8509b3f9b6ef35fe0c91c2a83bc85c6cc7ba9ac28/download",
	},
	{
		Key = "anime_apocalypse",
		Name = "Anime Apocalypse",
		PlaceIds = { 140409475718339 },
		Url = "",
	},
	{
		Key = "brookhaven",
		Name = "Brookhaven RP",
		PlaceIds = { 7247162321 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/77ed55725358b22ae8b8b95355f302f567b703a1f8d529d531da42722e4fc9f6/download",
	},
	{
		Key = "adopt_me",
		Name = "Adopt Me!",
		PlaceIds = { 920587237 },
		Url = "",
	},
	{
		Key = "arsenal",
		Name = "Arsenal",
		PlaceIds = { 286090429 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/9e01b589d4082a6952502b75538b08195db7a77262ea01510a996d4b16082fba/download",
	},
	{
		Key = "blade_ball",
		Name = "Blade Ball",
		PlaceIds = { 13769526381 },
		Url = "",
	},
	{
		Key = "doors",
		Name = "DOORS",
		PlaceIds = { 6839171747 },
		Url = "",
	},
	{
		Key = "pet_sim_99",
		Name = "Pet Simulator 99",
		PlaceIds = { 8737602446 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/212a0f031d9c0ef875d92ffe999588ce8bda7b9b42f1ddd35921b3cfd8068d67/download",
	},
	{
		Key = "bee_swarm",
		Name = "Bee Swarm Simulator",
		PlaceIds = { 1537690962 },
		Url = "",
	},
	{
		Key = "tower_of_hell",
		Name = "Tower of Hell",
		PlaceIds = { 196208686 },
		Url = "",
	},
	{
		Key = "grow_a_garden",
		Name = "Grow A Garden",
		PlaceIds = { 16708373721 },
		Url = "",
	},
	{
		Key = "anime_defenders",
		Name = "Anime Defenders",
		PlaceIds = { 16568935554 },
		Url = "",
	},
	{
		Key = "sakura_stand",
		Name = "Sakura Stand",
		PlaceIds = { 15332590452 },
		Url = "",
	},
	{
		Key = "anime_adventures",
		Name = "Anime Adventures",
		PlaceIds = { 8304191830 },
		Url = "",
	},
	{
		Key = "phantom_forces",
		Name = "Phantom Forces",
		PlaceIds = { 292439477 },
		Url = "",
	},
	{
		Key = "natural_disaster",
		Name = "Natural Disaster Survival",
		PlaceIds = { 189707 },
		Url = "",
	},
	{
		Key = "build_a_boat",
		Name = "Build A Boat For Treasure",
		PlaceIds = { 5374784273 },
		Url = "",
	},
	{
		-- 2788229376 is Da Hood; it was previously mislabeled Ragdoll Engine
		-- with an empty URL, which dead-ended the loader in Da Hood.
		Key = "ragdoll_engine",
		Name = "Ragdoll Engine",
		PlaceIds = { 1212010974 },
		Url = "",
	},
	{
		Key = "big_paintball",
		Name = "Big Paintball",
		PlaceIds = { 3537628128 },
		Url = "",
	},
	{
		Key = "counter_blox",
		Name = "Counter Blox",
		PlaceIds = { 3003369924 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/542fde9c70c8cb4146acd2417d913bc3f95537dc61ea12a7d9673ea6f8209510/download",
	},
	{
		Key = "anime_vanguards",
		Name = "Anime Vanguards",
		PlaceIds = { 8786550243 },
		Url = "",
	},
	{
		Key = "jujutsu_shenanigans",
		Name = "Jujutsu Shenanigans",
		PlaceIds = { 8641358417 },
		Url = "",
	},
	{
		Key = "sols_rng",
		Name = "Sol's RNG",
		PlaceIds = { 15368605381 },
		Url = "",
	},
	{
		Key = "anime_champions",
		Name = "Anime Champions",
		PlaceIds = { 10313427406 },
		Url = "",
	},
	{
		Key = "anime_fighters",
		Name = "Anime Fighters Simulator",
		PlaceIds = { 5297603592 },
		Url = "",
	},
	{
		Key = "destiny_stars",
		Name = "Destiny Stars Battlegrounds",
		PlaceIds = { 13775932850 },
		Url = "",
	},
	{
		Key = "anime_rifts",
		Name = "Anime Rifts",
		PlaceIds = { 6615551380 },
		Url = "",
	},
	{
		Key = "anime_world_td",
		Name = "Anime World Tower Defense",
		PlaceIds = { 11638978456 },
		Url = "",
	},
	{
		Key = "elemental_bg",
		Name = "Elemental Battlegrounds",
		PlaceIds = { 3016663482 },
		Url = "",
	},
	{
		Key = "world_zero",
		Name = "World // Zero",
		PlaceIds = { 2717805547 },
		Url = "",
	},
	{
		Key = "ninja_legends",
		Name = "Ninja Legends",
		PlaceIds = { 3954604612 },
		Url = "",
	},
	{
		Key = "bubble_gum",
		Name = "Bubble Gum Simulator",
		PlaceIds = { 314516530 },
		Url = "",
	},
	{
		Key = "mining_sim",
		Name = "Mining Simulator",
		PlaceIds = { 1411076837 },
		Url = "",
	},
	{
		Key = "treasure_quest",
		Name = "Treasure Quest",
		PlaceIds = { 2372544382 },
		Url = "",
	},
	{
		Key = "saber_sim",
		Name = "Saber Simulator",
		PlaceIds = { 3462270031 },
		Url = "",
	},
	{
		Key = "anime_adventure",
		Name = "Anime Adventure",
		PlaceIds = { 8384257137 },
		Url = "",
	},
	{
		Key = "forsaken",
		Name = "Forsaken",
		PlaceIds = { 13770989446 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/9bb1e096c86002e6a0142bdc9135911338438573aaee1392759ad7ddb0770221/download",
	},
	{
		Key = "zombie_uprising",
		Name = "Zombie Uprising",
		PlaceIds = { 5159239355 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/3917586b98aad373b0bd99ae077bf1f661d3af75eae56577be312d545547ee87/download",
	},
	{
		Key = "world_fighters",
		Name = "World Fighters",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/222f8d6f9dbcdd471ecae3e7c4d75298e08896978d9ac0a0eb339706b52e0fca/download",
	},
	{
		Key = "weak_legacy_2",
		Name = "Weak Legacy 2",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "one_piece_mythical",
		Name = "One Piece Mythical",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "anime_warriors",
		Name = "Anime Warriors",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/4cdd2112156453550efaca9703c13f6d08ca16d70ce667233e141a89336b5ff1/download",
	},
	{
		Key = "anime_expedition",
		Name = "Anime Expedition",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/2586c8e644360d8801a514aa3f7278658e5a752ebd1ea13d4eaa9ee4694ab1e1/download",
	},
	{
		Key = "anime_final_quest",
		Name = "Anime Final Quest",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "anime_tactical",
		Name = "Anime Tactical",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "anime_ranger_x",
		Name = "AnimeRangerX",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "blade_spin",
		Name = "BLADE SPIN",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "brainblast",
		Name = "Brainblast",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "broken_blade",
		Name = "Broken Blade",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "pool_1v1",
		Name = "8 Ball Pool 1v1",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "guess_logo",
		Name = "Guess My Logo",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "guess_football",
		Name = "Guess My Football Country",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "kaitun",
		Name = "Kaitun",
		PlaceIds = { 0 },
		Url = "",
	},
	{
		Key = "allstar",
		Name = "All Star Tower Defense",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/b8c1e042e0a36b9dc69f77ea799638e492f5a5b2cfee22f62d1558afb71bee1c/download",
	},
	{
		Key = "lucky_block",
		Name = "Kick a Lucky Block",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/019c4acfd2b7ab99d76ed2210abd89126669065fbfb6321e68125ecdeda85eac/download",
	},
	{
		Key = "jump_slimes",
		Name = "Jump to Steal Slimes",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/0d802bf5d2b5c44fdaea4d1ad533fc94b8c1fd7f8fbdd1dd5f8c461e71eb6fd9/download",
	},
	{
		Key = "jump_soccer",
		Name = "Jump to Steal Soccer Players",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/ae45688dd8b242eccaa376075b58a5ba0a8865857d9ae362e3b218847ce99c7a/download",
	},
	{
		Key = "iron_soul",
		Name = "Iron Soul",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/ee08bbb578eb0ba496d1f6a3ab73285d058409fc2fc9275174d78a51703cc7d9/download",
	},
	{
		Key = "rebirth_champions",
		Name = "Rebirth Champions",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/09de2ec0d7f1d294460153d72fcdc70c445877a45abb8b1465bf04a617c826df/download",
	},
	{
		Key = "slime_rng",
		Name = "Slime RNG",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/f998b55745da2f20710a11b0634872161ade8d8fa1a886e0b95e603d25964c46/download",
	},
	{
		Key = "sell_ores",
		Name = "Sell Ores",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/76995ec1240d8c4cd819b07152766da456370dcdc09b8fe44741c52d7167ef24/download",
	},
	{
		Key = "1_skinny_per_step",
		Name = "+1 Skinny Per Step",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/879dfa508ef1dd1d4b51c7d2a06cb07b5d6734365117e4625a102cd79639adaf/download",
	},
	{
		Key = "catch_a_brainrot",
		Name = "Catch a brainrot",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/62e7b76e5807d54e00a8fb439f1b7ebc1520fd9d13458bb0f1589193824b33cc/download",
	},
	{
		Key = "loot_evo",
		Name = "Loot Evo",
		PlaceIds = { 0 },
		Url = "https://api.jnkie.com/api/v1/luascripts/public/cf49a04fbe66402f7f432314736f2e0c9f0e5cb8c6ae9e663fcb84404b1af33f/download",
	},
}

local function routeContainsPlaceId(route, placeId)
	for _, id in ipairs(route.PlaceIds or {}) do
		if tostring(id) == tostring(placeId) then
			return true
		end
	end
	return false
end

local function findGameRoute()
	for _, route in ipairs(GAME_ROUTES) do
		if routeContainsPlaceId(route, game.PlaceId) then
			return route
		end
	end
	return nil, "Unsupported map. PlaceId: " .. tostring(game.PlaceId)
end

-- This happens before CreateStyledWindow(), so no key UI is shown in a game
-- that has no matching payload route.
local CURRENT_ROUTE, ROUTE_ERROR = findGameRoute()
if not CURRENT_ROUTE then
	warn("[Mammoz Hub] " .. tostring(ROUTE_ERROR))
	return nil
end

if type(CURRENT_ROUTE.Url) ~= "string" or CURRENT_ROUTE.Url == "" then
	warn("[Mammoz Hub] JNKiE download URL is missing for " .. tostring(CURRENT_ROUTE.Name))
	return nil
end

local MAIN_URL = CURRENT_ROUTE.Url

local function makeMainContext(key, app)
	local env = type(getgenv) == "function" and getgenv() or _G
	-- KEYLESS is a special success value returned by JNKiE. Do not overwrite it
	-- with the empty input field when the selected service is keyless.
	local scriptKey = env.SCRIPT_KEY == "KEYLESS" and "KEYLESS" or (key or env.SCRIPT_KEY)
	env.SCRIPT_KEY = scriptKey
	env.PETER_HUB_V2_CONTEXT = {
		Key = scriptKey,
		App = app,
		LoaderApp = app,
		PeterHub = PeterHub,
		MammozHub = MammozHub,
		MainUrl = MAIN_URL,
		ScriptUrl = MAIN_URL,
		Route = CURRENT_ROUTE,
		Game = CURRENT_ROUTE,
		GameKey = CURRENT_ROUTE.Key,
		GameName = CURRENT_ROUTE.Name,
		PlaceId = game.PlaceId,
		UniverseId = game.GameId,
	}
	env.MAMMOZ_LOADER_CONTEXT = env.PETER_HUB_V2_CONTEXT
	env.MAMMOZ_HUB_CONTEXT = env.PETER_HUB_V2_CONTEXT
	env.MAMMOZ_GAME_ROUTE = CURRENT_ROUTE
	return env.PETER_HUB_V2_CONTEXT
end

local function runMainSource(source, label, context)
	if type(loadstring) ~= "function" then
		return false, "loadstring is not available"
	end
	if type(source) ~= "string" or source == "" then
		return false, "empty main source"
	end

	local chunk, compileError = loadstring(source, label or "PeterHubV2Main")
	if not chunk then
		return false, compileError
	end

	local ok, result = pcall(chunk)
	if not ok then
		return false, result
	end

	if type(result) == "table" and type(result.Start) == "function" then
		local startOk, startResult = pcall(result.Start, result, context)
		if not startOk then
			return false, startResult
		end
	end

	return true
end

local function runJunkieMain(context)
	if MAIN_URL == "" then
		return false, "MAIN_URL is empty"
	end

	local ok, result = pcall(function()
		return loadstring(game:HttpGet(MAIN_URL))()
	end)
	if not ok then
		return false, result
	end

	if type(result) == "table" and type(result.Start) == "function" then
		local startOk, startResult = pcall(result.Start, result, context)
		if not startOk then
			return false, startResult
		end
	end

	return true
end

local function runLocalMain(context)
	if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(MAIN_LOCAL_PATH) then
		return false, "local main is not available"
	end
	local ok, source = pcall(readfile, MAIN_LOCAL_PATH)
	if not ok then
		return false, source
	end
	return runMainSource(source, "MammozLocalMain", context)
end

local LoaderPreviewGames = {
	{
		Name = "Attack On Titan Rev.",
		Description = "AOTR - Titan Farm",
		Details = "Auto Farm, Titan Kill, Auto Quest",
		Features = { "AUTO FARM", "TITAN KILL", "AUTO QUEST", "MOBILE" },
		Status = "FREE",
		PlaceId = 13379208636,
	},
	{
		Name = "Anime Card Farm",
		Description = "Auto Pack - Reroll",
		Details = "Pack opener, card fusion and farm",
		Features = { "AUTO PACK", "REROLL", "CARD FUSION", "AUTO FARM" },
		Status = "SOON",
		PlaceId = 125039475354804,
	},
	{
		Name = "Arena Sniper",
		Description = "Auto Kill - Sniper",
		Details = "Hitbox expand, auto shoot and kill",
		Features = { "AIM", "HITBOX", "AUTO SHOOT", "AUTO KILL" },
		Status = "SOON",
		PlaceId = 122446657157717,
	},
	{
		Name = "Roll Anime To Fight",
		Description = "RATF - Auto Roll",
		Details = "Auto roll, auto fight bosses, upgrades",
		Features = { "AUTO ROLL", "BOSS FARM", "AUTO FIGHT", "UPGRADES" },
		Status = "SOON",
		PlaceId = 107653945083776,
	},
	{
		Name = "Gakuran",
		Description = "GKR - Auto Farm",
		Details = "Auto combat, auto quest, skill spam",
		Features = { "AUTO COMBAT", "AUTO QUEST", "SKILL SPAM", "SPEED" },
		Status = "SOON",
		PlaceId = 128736949265057,
	},
	{
		Name = "99 Nights in the Forest",
		Description = "99Nights - Forest",
		Details = "Auto survive, wood/scrap farm, AFK",
		Features = { "AUTO SURVIVE", "WOOD FARM", "SCRAP FARM", "AFK" },
		Status = "FREE",
		PlaceId = 126509999114328,
	},
	{
		Name = "Grow a Chicken Fighter",
		Description = "Hatch, battle and fuse chickens",
		Details = "Chicken farm route",
		Features = { "HATCH", "BATTLE", "FUSE" },
		Status = "FREE",
		PlaceId = 94640181989498,
	},
	{
		Name = "Steal An Egg",
		Description = "Hatch pets and collect eggs",
		Details = "Egg route",
		Features = { "EGG", "PET", "FARM" },
		Status = "FREE",
		PlaceId = 107778070777162,
	},
	{
		Name = "Fish",
		Description = "Fishing adventure",
		Details = "Fish route",
		Features = { "FISHING", "GEAR", "COLLECTION" },
		Status = "FREE",
		PlaceId = 77773900773577,
	},
	{
		Name = "Shindo Life",
		Description = "Ninja RPG adventure",
		Details = "Shindo Life protected route",
		Features = { "NINJA", "RPG", "FARM" },
		Status = "FREE",
		PlaceId = 4616652839,
	},
	{
		Name = "Mine a Mountain",
		Description = "MaM - Auto Mine",
		Details = "Unlock premium maps and VIP features",
		Features = { "AUTO MINE", "ORE FARM", "VIP ROUTES", "SELL AUTO" },
		Status = "FREE",
		PlaceId = 125927821145949,
	},
	{
		Name = "Murder Mystery 2",
		Description = "MM2 - Exclusive",
		Details = "Premium maps and exclusive features",
		Features = { "ESP", "AUTO FARM", "COIN FARM", "SERVER HOP" },
		Status = "VIP",
		PlaceId = 142823291,
	},
	{
		Name = "+1 Ammo Per Click",
		Description = "Clicker farm",
		Details = "Ammo click farm loop",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 139907538117897,
	},
	{
		Name = "Clean all the leaves",
		Description = "Leaf cleanup",
		Details = "Collect, deposit and farm leaves",
		Features = { "AUTO COLLECT", "AUTO DEPOSIT", "FARM" },
		Status = "FREE",
		PlaceId = 92637789841354,
	},
	{
		Name = "Aura For Brainrots",
		Description = "Brainrot farm",
		Details = "Aura farm loop",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "SOON",
		PlaceId = 122526789002601,
	},
	{
		Name = "Be Flash For Brainrots",
		Description = "Brainrot farm",
		Details = "Flash speed farm",
		Features = { "AUTO FARM", "SPEED", "UPGRADES" },
		Status = "FREE",
		PlaceId = 136066387156306,
	},
	{
		Name = "+1 Drain Water Per Click",
		Description = "Clicker farm",
		Details = "Drain water click farm",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 103883942725157,
	},
	{
		Name = "Demon Blade",
		Description = "Blade RPG",
		Details = "Auto farm and combat",
		Features = { "AUTO FARM", "COMBAT", "BOSS" },
		Status = "FREE",
		PlaceId = 15014439457,
	},
	{
		Name = "Make a Drill Farm",
		Description = "Drill farm",
		Details = "Drill and farm resources",
		Features = { "AUTO DRILL", "AUTO FARM", "SELL" },
		Status = "SOON",
		PlaceId = 79315121100812,
	},
	{
		Name = "Dig & Clean",
		Description = "Dig and clean",
		Details = "Dig, clean and farm",
		Features = { "AUTO DIG", "AUTO CLEAN", "FARM" },
		Status = "FREE",
		PlaceId = 83038462357724,
	},
	{
		Name = "+1 Jetpack for Brainrots",
		Description = "Brainrot farm",
		Details = "Jetpack farm loop",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 80234914611737,
	},
	{
		Name = "Haze Piece",
		Description = "One Piece RPG",
		Details = "Auto farm, quests and bosses",
		Features = { "AUTO FARM", "AUTO QUEST", "BOSS FARM" },
		Status = "FREE",
		PlaceId = 6918802270,
	},
	{
		Name = "King Legacy",
		Description = "One Piece RPG",
		Details = "Auto farm and raids",
		Features = { "AUTO FARM", "RAID", "BOSS" },
		Status = "FREE",
		PlaceId = 4520749081,
	},
	{
		Name = "Sailor Piece",
		Description = "One Piece RPG",
		Details = "Auto farm and sea events",
		Features = { "AUTO FARM", "SEA EVENT", "BOSS" },
		Status = "SOON",
		PlaceId = 77747658251236,
	},
	{
		Name = "Logo For Brainrots",
		Description = "Brainrot farm",
		Details = "Logo farm loop",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "SOON",
		PlaceId = 123959902101040,
	},
	{
		Name = "+1 Mine Per Click",
		Description = "Clicker mine",
		Details = "Mine click farm",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 74193805629461,
	},
	{
		Name = "+1 Muscle Evolution",
		Description = "Evolution sim",
		Details = "Muscle evolution farm",
		Features = { "AUTO FARM", "EVOLVE", "UPGRADES" },
		Status = "SOON",
		PlaceId = 133007106457547,
	},
	{
		Name = "+1 Looks Per Click",
		Description = "Clicker farm",
		Details = "Looks click farm",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 102355196524321,
	},
	{
		Name = "+1 Poor To Rich",
		Description = "Clicker rich",
		Details = "Poor to rich farm",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 96003649748017,
	},
	{
		Name = "Pull a Lucky Fish",
		Description = "Fishing sim",
		Details = "Lucky fish farm",
		Features = { "AUTO FISH", "SELL", "COLLECTION" },
		Status = "FREE",
		PlaceId = 112781315318195,
	},
	{
		Name = "+1 Power Per Click",
		Description = "Clicker power",
		Details = "Power click farm",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 74889851913797,
	},
	{
		Name = "Power Blast Lucky Blocks",
		Description = "Lucky blocks",
		Details = "Power blast farm",
		Features = { "AUTO FARM", "LUCKY BLOCK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 119822977170203,
	},
	{
		Name = "Pickaxe Simulator",
		Description = "Mining sim",
		Details = "Pickaxe mine farm",
		Features = { "AUTO MINE", "SELL", "UPGRADES" },
		Status = "SOON",
		PlaceId = 82013336390273,
	},
	{
		Name = "Sell Lemons",
		Description = "Lemon farm",
		Details = "Sell lemons farm",
		Features = { "AUTO FARM", "SELL", "UPGRADES" },
		Status = "FREE",
		PlaceId = 79268393072444,
	},
	{
		Name = "+1 Skill Point Legends",
		Description = "Skill sim",
		Details = "Skill point farm",
		Features = { "AUTO FARM", "SKILL", "UPGRADES" },
		Status = "SOON",
		PlaceId = 135668295983945,
	},
	{
		Name = "+1 Speed Evolve",
		Description = "Evolution sim",
		Details = "Speed evolve farm",
		Features = { "AUTO FARM", "EVOLVE", "UPGRADES" },
		Status = "SOON",
		PlaceId = 83569851223739,
	},
	{
		Name = "+1 Speed Monkey Escape",
		Description = "Speed sim",
		Details = "Speed monkey farm",
		Features = { "AUTO FARM", "SPEED", "UPGRADES" },
		Status = "SOON",
		PlaceId = 114697347887839,
	},
	{
		Name = "+1 Spinjitsu Escape",
		Description = "Spinjitsu sim",
		Details = "Spinjitsu escape farm",
		Features = { "AUTO FARM", "SPIN", "UPGRADES" },
		Status = "SOON",
		PlaceId = 131910189515331,
	},
	{
		Name = "+1 Strength Per Click",
		Description = "Clicker strength",
		Details = "Strength click farm",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 120766736586332,
	},
	{
		Name = "+1 Wings for Brainrots",
		Description = "Brainrot farm",
		Details = "Wings farm loop",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "SOON",
		PlaceId = 84332574190497,
	},
	{
		Name = "Blox Fruits",
		Description = "One Piece RPG",
		Details = "Auto farm, raids and fruits",
		Features = { "AUTO FARM", "RAID", "FRUIT", "BOSS" },
		Status = "FREE",
		PlaceId = 2753915549,
	},
	{
		Name = "Anime Apocalypse",
		Description = "Anime RPG",
		Details = "Auto farm and quests",
		Features = { "AUTO FARM", "AUTO QUEST", "BOSS" },
		Status = "SOON",
		PlaceId = 140409475718339,
	},
	{
		Name = "Brookhaven RP",
		Description = "Roleplay",
		Details = "Brookhaven roleplay tools",
		Features = { "TELEPORT", "TOOLS", "PLAYER" },
		Status = "FREE",
		PlaceId = 7247162321,
	},
	{
		Name = "Adopt Me!",
		Description = "Pet sim",
		Details = "Adopt and trade pets",
		Features = { "AUTO FARM", "PETS", "TRADE" },
		Status = "SOON",
		PlaceId = 920587237,
	},
	{
		Name = "Arsenal",
		Description = "FPS",
		Details = "Arsenal aimbot and farm",
		Features = { "AIMBOT", "AUTO FARM", "KILL" },
		Status = "FREE",
		PlaceId = 286090429,
	},
	{
		Name = "Blade Ball",
		Description = "Deflect game",
		Details = "Blade ball deflect and farm",
		Features = { "AUTO DEFLECT", "AUTO FARM", "BLOCK" },
		Status = "SOON",
		PlaceId = 13769526381,
	},
	{
		Name = "DOORS",
		Description = "Horror",
		Details = "Doors entity and farm",
		Features = { "AUTO FARM", "ENTITY", "COLLECT" },
		Status = "SOON",
		PlaceId = 6839171747,
	},
	{
		Name = "Pet Simulator 99",
		Description = "Pet sim",
		Details = "Pet farm and eggs",
		Features = { "AUTO FARM", "EGGS", "HATCH" },
		Status = "FREE",
		PlaceId = 8737602446,
	},
	{
		Name = "Bee Swarm Simulator",
		Description = "Sim",
		Details = "Bee swarm farm",
		Features = { "AUTO FARM", "COLLECT", "QUEST" },
		Status = "SOON",
		PlaceId = 1537690962,
	},
	{
		Name = "Tower of Hell",
		Description = "Obby",
		Details = "Tower of hell skip",
		Features = { "AUTO SKIP", "SPEED", "TELEPORT" },
		Status = "SOON",
		PlaceId = 196208686,
	},
	{
		Name = "Grow A Garden",
		Description = "Farm sim",
		Details = "Grow a garden farm",
		Features = { "AUTO FARM", "PLANT", "SELL" },
		Status = "SOON",
		PlaceId = 16708373721,
	},
	{
		Name = "Anime Defenders",
		Description = "Tower defense",
		Details = "Anime defenders farm",
		Features = { "AUTO FARM", "AUTO PLACE", "UPGRADE" },
		Status = "SOON",
		PlaceId = 16568935554,
	},
	{
		Name = "Sakura Stand",
		Description = "Anime RPG",
		Details = "Sakura stand farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 15332590452,
	},
	{
		Name = "Anime Adventures",
		Description = "Tower defense",
		Details = "Anime adventures farm",
		Features = { "AUTO FARM", "AUTO PLACE", "UPGRADE" },
		Status = "SOON",
		PlaceId = 8304191830,
	},
	{
		Name = "Phantom Forces",
		Description = "FPS",
		Details = "Phantom forces aimbot",
		Features = { "AIMBOT", "ESP", "AUTO FARM" },
		Status = "SOON",
		PlaceId = 292439477,
	},
	{
		Name = "Natural Disaster Survival",
		Description = "Survival",
		Details = "Natural disaster survive",
		Features = { "AUTO SURVIVE", "FARM" },
		Status = "SOON",
		PlaceId = 189707,
	},
	{
		Name = "Build A Boat For Treasure",
		Description = "Build",
		Details = "Build a boat farm",
		Features = { "AUTO BUILD", "FARM" },
		Status = "SOON",
		PlaceId = 5374784273,
	},
	{
		Name = "Ragdoll Engine",
		Description = "Fun",
		Details = "Ragdoll engine tools",
		Features = { "TOOLS", "FLING", "PLAYER" },
		Status = "SOON",
		PlaceId = 2788229376,
	},
	{
		Name = "Big Paintball",
		Description = "FPS",
		Details = "Big paintball aimbot",
		Features = { "AIMBOT", "AUTO FARM", "KILL" },
		Status = "SOON",
		PlaceId = 3537628128,
	},
	{
		Name = "Counter Blox",
		Description = "FPS",
		Details = "Counter blox aimbot",
		Features = { "AIMBOT", "ESP", "AUTO FARM" },
		Status = "FREE",
		PlaceId = 3003369924,
	},
	{
		Name = "Anime Vanguards",
		Description = "Tower defense",
		Details = "Anime vanguards farm",
		Features = { "AUTO FARM", "AUTO PLACE", "UPGRADE" },
		Status = "SOON",
		PlaceId = 8786550243,
	},
	{
		Name = "Jujutsu Shenanigans",
		Description = "Fighting",
		Details = "Jujutsu shenanigans farm",
		Features = { "AUTO FARM", "COMBAT", "BOSS" },
		Status = "SOON",
		PlaceId = 8641358417,
	},
	{
		Name = "Sol's RNG",
		Description = "RNG",
		Details = "Sol's RNG auto roll",
		Features = { "AUTO ROLL", "AUTO FARM" },
		Status = "SOON",
		PlaceId = 15368605381,
	},
	{
		Name = "Anime Champions",
		Description = "Anime RPG",
		Details = "Anime champions farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 10313427406,
	},
	{
		Name = "Anime Fighters Simulator",
		Description = "Fighting sim",
		Details = "Anime fighters farm",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "SOON",
		PlaceId = 5297603592,
	},
	{
		Name = "Destiny Stars Battlegrounds",
		Description = "Battlegrounds",
		Details = "Destiny stars farm",
		Features = { "AUTO FARM", "COMBAT", "BOSS" },
		Status = "SOON",
		PlaceId = 13775932850,
	},
	{
		Name = "Anime Rifts",
		Description = "Anime RPG",
		Details = "Anime rifts farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 6615551380,
	},
	{
		Name = "Anime World Tower Defense",
		Description = "Tower defense",
		Details = "Anime world TD farm",
		Features = { "AUTO FARM", "AUTO PLACE", "UPGRADE" },
		Status = "SOON",
		PlaceId = 11638978456,
	},
	{
		Name = "Elemental Battlegrounds",
		Description = "Fighting",
		Details = "Elemental battlegrounds farm",
		Features = { "AUTO FARM", "COMBAT", "BOSS" },
		Status = "SOON",
		PlaceId = 3016663482,
	},
	{
		Name = "World // Zero",
		Description = "RPG",
		Details = "World zero farm",
		Features = { "AUTO FARM", "QUEST", "BOSS" },
		Status = "SOON",
		PlaceId = 2717805547,
	},
	{
		Name = "Ninja Legends",
		Description = "Training sim",
		Details = "Ninja legends farm",
		Features = { "AUTO TRAIN", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 3954604612,
	},
	{
		Name = "Bubble Gum Simulator",
		Description = "Sim",
		Details = "Bubble gum farm",
		Features = { "AUTO FARM", "HATCH", "PETS" },
		Status = "SOON",
		PlaceId = 314516530,
	},
	{
		Name = "Mining Simulator",
		Description = "Mining sim",
		Details = "Mining simulator farm",
		Features = { "AUTO MINE", "SELL", "UPGRADES" },
		Status = "SOON",
		PlaceId = 1411076837,
	},
	{
		Name = "Treasure Quest",
		Description = "RPG",
		Details = "Treasure quest farm",
		Features = { "AUTO FARM", "BOSS", "LOOT" },
		Status = "SOON",
		PlaceId = 2372544382,
	},
	{
		Name = "Saber Simulator",
		Description = "Training sim",
		Details = "Saber simulator farm",
		Features = { "AUTO TRAIN", "AUTO FARM", "UPGRADES" },
		Status = "SOON",
		PlaceId = 3462270031,
	},
	{
		Name = "Anime Adventure",
		Description = "Anime RPG",
		Details = "Anime adventure farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 8384257137,
	},
	{
		Name = "Forsaken",
		Description = "Asym horror",
		Details = "Forsaken survive and farm",
		Features = { "AUTO FARM", "SURVIVE", "KILL" },
		Status = "FREE",
		PlaceId = 13770989446,
	},
	{
		Name = "Zombie Uprising",
		Description = "Zombie FPS",
		Details = "Zombie uprising farm",
		Features = { "AUTO FARM", "KILL", "WAVE" },
		Status = "FREE",
		PlaceId = 5159239355,
	},
	{
		Name = "World Fighters",
		Description = "Fighting",
		Details = "World fighters farm",
		Features = { "AUTO FARM", "COMBAT", "BOSS" },
		Status = "FREE",
		PlaceId = 0,
	},

	-- Oxide UI library conversions (see scripts/oxide)
	{
		Name = "Da Hood",
		Description = "Oxide route",
		Details = "Da Hood - Oxide route",
		Features = { "AUTO FARM", "ESP", "TELEPORT", "COMBAT" },
		Status = "FREE",
		PlaceId = 2788229376,
	},
	{
		Name = "Dungeon Lootr",
		Description = "Oxide route",
		Details = "Dungeon-Lootr - Oxide route",
		Features = { "AUTO FARM", "LOOT", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Gakuran",
		Description = "Oxide route",
		Details = "Gakuran - Oxide route",
		Features = { "AUTO FARM", "AUTO QUEST", "SKILL SPAM" },
		Status = "FREE",
		PlaceId = 128736949265057,
	},
	{
		Name = "Graben und Reinigen",
		Description = "Oxide route - richer feature set",
		Details = "Dig & clean - Oxide route",
		Features = { "AUTO DIG", "AUTO CLEAN", "FARM" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Grow a Chicken Fighter",
		Description = "Oxide route - richer feature set",
		Details = "GACF - Oxide route",
		Features = { "AUTO FARM", "AUTO HATCH", "AUTO PIT" },
		Status = "FREE",
		PlaceId = 94640181989498,
	},
	{
		Name = "Jump for Pets",
		Description = "Oxide route",
		Details = "Jump for Pets - Oxide route",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Leaf Simulator",
		Description = "Oxide route - richer feature set",
		Details = "Leaf sim - Oxide route",
		Features = { "AUTO FARM", "AUTO REBIRTH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "MM2",
		Description = "Oxide route",
		Details = "MM2 - Oxide route",
		Features = { "ESP", "AUTO FARM", "TELEPORT" },
		Status = "FREE",
		PlaceId = 142823291,
	},
	{
		Name = "Steal an Egg",
		Description = "Oxide route - richer feature set",
		Details = "Steal an Egg - Oxide route",
		Features = { "AUTO STEAL", "AUTO HATCH", "ESP" },
		Status = "FREE",
		PlaceId = 107778070777162,
	},
	{
		Name = "Universal",
		Description = "Oxide route",
		Details = "Universal tools - Oxide route",
		Features = { "SERVER HOP", "REJOIN", "ANTI-AFK" },
		Status = "FREE",
		PlaceId = 0,
	},

	-- Paazlis Mods/Games conversions (see scripts/paazlis + paazlis-manifest.csv)
	{
		Name = "Catch 1 Billion Ducks",
		Description = "Paazlis route",
		Details = "Catch 1 Billion Ducks",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 100293509865504,
	},
	{
		Name = "[UPD] Merge a Spinner!",
		Description = "Paazlis route",
		Details = "[UPD] Merge a Spinner!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 101396571928321,
	},
	{
		Name = "Kaucja Symulator (Deposit)",
		Description = "Paazlis route",
		Details = "Kaucja Symulator",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 101607790076338,
	},
	{
		Name = "Butterfly Legends",
		Description = "Paazlis route",
		Details = "Butterfly Legends",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 102050885098531,
	},
	{
		Name = "Secure the Airport",
		Description = "Paazlis route",
		Details = "Secure the Airport",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 102054284786904,
	},
	{
		Name = "+1 Strength Soccer Escape",
		Description = "Paazlis route",
		Details = "+1 Strength Soccer Escape",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 104459855378825,
	},
	{
		Name = "+1 Stretch Escape",
		Description = "Paazlis route",
		Details = "+1 Stretch Escape",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 105940087682495,
	},
	{
		Name = "Secure the Supermarket",
		Description = "Paazlis route",
		Details = "Secure the Supermarket",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 107573271137575,
	},
	{
		Name = "RNG Heroes",
		Description = "Paazlis route",
		Details = "RNG Heroes",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 108307565942574,
	},
	{
		Name = "+1 Scream Per Click",
		Description = "Paazlis route",
		Details = "+1 Scream Per Click",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 108354344401029,
	},
	{
		Name = "Merge an Army",
		Description = "Paazlis route",
		Details = "Merge an Army",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 109274213361590,
	},
	{
		Name = "Paper Plane for Brainrots",
		Description = "Paazlis route",
		Details = "Paper Plane for Brainrots",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 110373292461174,
	},
	{
		Name = "+1 Web Wing Escape",
		Description = "Paazlis route",
		Details = "+1 Web Wing Escape",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 110668201954727,
	},
	{
		Name = "Sell Ice Cream",
		Description = "Paazlis route",
		Details = "Sell Ice Cream",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 110793563946846,
	},
	{
		Name = "+1 Fat Evolution",
		Description = "Paazlis route",
		Details = "+1 Fat Evolution",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO REBIRTH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 112167159515934,
	},
	{
		Name = "+1 Wood Per Click",
		Description = "Paazlis route",
		Details = "+1 Wood Per Click",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 112231208081788,
	},
	{
		Name = "Link a Brainrots",
		Description = "Paazlis route",
		Details = "Link a Brainrots",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 112500097711893,
	},
	{
		Name = "Shred the Secrets",
		Description = "Paazlis route",
		Details = "Shred the Secrets",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 113175013158657,
	},
	{
		Name = "+1 Kaiju Power Per Click",
		Description = "Paazlis route",
		Details = "+1 Kaiju Power Per Click",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 114386067746582,
	},
	{
		Name = "Find the Egg for a Brainrot",
		Description = "Paazlis route",
		Details = "Find the Egg for a Brainrot",
		Features = { "AUTO FARM", "AUTO STEAL", "UPGRADES" },
		Status = "FREE",
		PlaceId = 114507117535918,
	},
	{
		Name = "Throw a Coin",
		Description = "Paazlis route",
		Details = "Throw a Coin",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 115681808123944,
	},
	{
		Name = "One Block",
		Description = "Paazlis route",
		Details = "One Block",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 117295931291816,
	},
	{
		Name = "Bomb Fishing",
		Description = "Paazlis route",
		Details = "Bomb Fishing",
		Features = { "AUTO FARM", "AUTO FISH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 118677256126351,
	},
	{
		Name = "+1 Speed Phonk Escape",
		Description = "Paazlis route",
		Details = "+1 Speed Phonk Escape",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 119416070805734,
	},
	{
		Name = "Idle Balls",
		Description = "Paazlis route",
		Details = "Idle Balls",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 119529264392781,
	},
	{
		Name = "Pickpocket!",
		Description = "Paazlis route",
		Details = "Pickpocket!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 120348634319012,
	},
	{
		Name = "Merge Swords And Kill Zombies!",
		Description = "Paazlis route",
		Details = "Merge Swords And Kill Zombies!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 122004026354492,
	},
	{
		Name = "Make Hotsauce",
		Description = "Paazlis route",
		Details = "Make Hotsauce",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 122391683154858,
	},
	{
		Name = "Build a +1 Obby",
		Description = "Paazlis route",
		Details = "Build a +1 Obby",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 122507029092776,
	},
	{
		Name = "Steal A Lucky Egg",
		Description = "Paazlis route",
		Details = "Steal A Lucky Egg",
		Features = { "AUTO FARM", "AUTO STEAL", "UPGRADES" },
		Status = "FREE",
		PlaceId = 123698673940079,
	},
	{
		Name = "My Parking Lot",
		Description = "Paazlis route",
		Details = "My Parking Lot",
		Features = { "AUTO FARM", "AUTO COLLECT", "UPGRADES" },
		Status = "FREE",
		PlaceId = 124714370744277,
	},
	{
		Name = "+1 Fat Per Click",
		Description = "Paazlis route",
		Details = "+1 Fat Per Click",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 128329680321338,
	},
	{
		Name = "Merge a Nuke!",
		Description = "Paazlis route",
		Details = "Merge a Nuke!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 128784467030899,
	},
	{
		Name = "Roll to Survive",
		Description = "Paazlis route",
		Details = "Roll to Survive",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 132508978828159,
	},
	{
		Name = "Build a Gun Army",
		Description = "Paazlis route",
		Details = "Build a Gun Army",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 134162299584012,
	},
	{
		Name = "+1 Speed Per Click",
		Description = "Paazlis route",
		Details = "+1 Speed Per Click",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 134660056748270,
	},
	{
		Name = "Idle Ball Bounce",
		Description = "Paazlis route",
		Details = "Idle Ball Bounce",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 136680208905701,
	},
	{
		Name = "Chicken Farm",
		Description = "Paazlis route",
		Details = "Chicken Farm",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 137233438285284,
	},
	{
		Name = "Drain The Lake",
		Description = "Paazlis route",
		Details = "Drain The Lake",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 138381251771774,
	},
	{
		Name = "Dig for Dinos!",
		Description = "Paazlis route",
		Details = "Dig for Dinos!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 138485603458691,
	},
	{
		Name = "Airport Tycoon",
		Description = "Paazlis route",
		Details = "Airport Tycoon",
		Features = { "AUTO FARM", "AUTO COLLECT", "UPGRADES" },
		Status = "FREE",
		PlaceId = 138486812747835,
	},
	{
		Name = "My Giant Sandwich",
		Description = "Paazlis route",
		Details = "My Giant Sandwich",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 139546619723000,
	},
	{
		Name = "Drop Balls For Brainrots",
		Description = "Paazlis route",
		Details = "Drop Balls For Brainrots",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 139992937215031,
	},
	{
		Name = "Zombie Turret Farm",
		Description = "Paazlis route",
		Details = "Zombie Turret Farm",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 70790155462881,
	},
	{
		Name = "Mow League",
		Description = "Paazlis route",
		Details = "Mow League",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 71129549729775,
	},
	{
		Name = "Gumball Tycoon",
		Description = "Paazlis route",
		Details = "Gumball Tycoon",
		Features = { "AUTO FARM", "AUTO COLLECT", "UPGRADES" },
		Status = "FREE",
		PlaceId = 71896418752645,
	},
	{
		Name = "Clean the Backyard",
		Description = "Paazlis route",
		Details = "Clean the Backyard",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 72417782950794,
	},
	{
		Name = "Hack the World",
		Description = "Paazlis route",
		Details = "Hack the World",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 73221000424242,
	},
	{
		Name = "+1 Long Arm Toy Escape",
		Description = "Paazlis route",
		Details = "+1 Long Arm Toy Escape",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 74341114342499,
	},
	{
		Name = "Throw a Hammers For Brainrots",
		Description = "Paazlis route",
		Details = "Throw a Hammers For Brainrots",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 74442575449267,
	},
	{
		Name = "Search For The Needle",
		Description = "Paazlis route",
		Details = "Search For The Needle",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 77108422251420,
	},
	{
		Name = "Vacuum Simulator",
		Description = "Paazlis route",
		Details = "Vacuum Simulator",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 77133321531129,
	},
	{
		Name = "Tower VS Slimes",
		Description = "Paazlis route",
		Details = "Tower VS Slimes",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 78417665924734,
	},
	{
		Name = "Speedsters Infinite",
		Description = "Paazlis route",
		Details = "Speedsters Infinite",
		Features = { "AUTO FARM", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 79658956070105,
	},
	{
		Name = "My Dino Park!",
		Description = "Paazlis route",
		Details = "My Dino Park!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 80701570784699,
	},
	{
		Name = "AI Grows Smarter",
		Description = "Paazlis route",
		Details = "AI Grows Smarter",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 80935824895991,
	},
	{
		Name = "Make an Party",
		Description = "Paazlis route",
		Details = "Make an Party",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 82570142697239,
	},
	{
		Name = "Clean Your Keycaps",
		Description = "Paazlis route",
		Details = "Clean Your Keycaps",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 82745432464897,
	},
	{
		Name = "Crunch My Butter!",
		Description = "Paazlis route",
		Details = "Crunch My Butter!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 87555052900625,
	},
	{
		Name = "+1 Hack Per Click",
		Description = "Paazlis route",
		Details = "+1 Hack Per Click",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 88968590411663,
	},
	{
		Name = "Endless GAMES",
		Description = "Paazlis route",
		Details = "Endless GAMES",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 89035794510548,
	},
	{
		Name = "Build A Skyscraper",
		Description = "Paazlis route",
		Details = "Build A Skyscraper",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 89798397953399,
	},
	{
		Name = "Garden Cleaner Evolution",
		Description = "Paazlis route",
		Details = "Garden Cleaner Evolution",
		Features = { "AUTO FARM", "AUTO REBIRTH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 89907728898683,
	},
	{
		Name = "Build a House",
		Description = "Paazlis route",
		Details = "Build a House",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 90038414385014,
	},
	{
		Name = "+1 Cut Grass Adventure",
		Description = "Paazlis route",
		Details = "+1 Cut Grass Adventure",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 90086669327265,
	},
	{
		Name = "BONK for Brainrots!",
		Description = "Paazlis route",
		Details = "BONK for Brainrots!",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 90691590225165,
	},
	{
		Name = "Farm a Fish",
		Description = "Paazlis route",
		Details = "Farm a Fish",
		Features = { "AUTO FARM", "AUTO FISH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 91296119701853,
	},
	{
		Name = "Soccer Manager Tycoon",
		Description = "Paazlis route",
		Details = "Soccer Manager Tycoon",
		Features = { "AUTO FARM", "AUTO COLLECT", "UPGRADES" },
		Status = "FREE",
		PlaceId = 91529114721292,
	},
	{
		Name = "+1 Shrink per Step",
		Description = "Paazlis route",
		Details = "+1 Shrink per Step",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 91695551099066,
	},
	{
		Name = "Fish a Slime",
		Description = "Paazlis route",
		Details = "Fish a Slime",
		Features = { "AUTO FARM", "AUTO FISH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 91723890596097,
	},
	{
		Name = "Crab Tycoon",
		Description = "Paazlis route",
		Details = "Crab Tycoon",
		Features = { "AUTO FARM", "AUTO COLLECT", "UPGRADES" },
		Status = "FREE",
		PlaceId = 92605157087535,
	},
	{
		Name = "+1 Speed Super Hero Escape",
		Description = "Paazlis route",
		Details = "+1 Speed Super Hero Escape",
		Features = { "AUTO FARM", "AUTO CLICK", "AUTO WIN", "UPGRADES" },
		Status = "FREE",
		PlaceId = 92937726498067,
	},
	{
		Name = "My Flower Shop",
		Description = "Paazlis route",
		Details = "My Flower Shop",
		Features = { "AUTO FARM", "AUTO COLLECT", "UPGRADES" },
		Status = "FREE",
		PlaceId = 93028168925975,
	},
	{
		Name = "Grow a Chicken Fighter - Spiritual Gaming",
		Description = "Paazlis route",
		Details = "Grow a Chicken Fighter - Spiritual Gamin",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 94640181989498,
	},
	{
		Name = "My Fishing Empire",
		Description = "Paazlis route",
		Details = "My Fishing Empire",
		Features = { "AUTO FARM", "AUTO FISH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 94872498041813,
	},
	{
		Name = "Find the Chameleon",
		Description = "Paazlis route",
		Details = "Find the Chameleon",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 95496064393804,
	},
	{
		Name = "Dumpling Stars",
		Description = "Paazlis route",
		Details = "Dumpling Stars",
		Features = { "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 95829667226336,
	},
	{
		Name = "Heavyweight Fishing",
		Description = "Paazlis route",
		Details = "Heavyweight Fishing",
		Features = { "AUTO FARM", "AUTO FISH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 98502499119821,
	},
	{
		Name = "+1 Follower Per Click",
		Description = "Paazlis route",
		Details = "+1 Follower Per Click",
		Features = { "AUTO FARM", "AUTO CLICK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 98695134949589,
	},
	{
		Name = "BE A FISH BAIT - Tora IsMe",
		Description = "Paazlis route",
		Details = "BE A FISH BAIT - Tora IsMe",
		Features = { "AUTO FARM", "AUTO FISH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 99702578544768,
	},
	{
		Name = "Weak Legacy 2",
		Description = "Anime RPG",
		Details = "Weak legacy 2 farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "One Piece Mythical",
		Description = "One Piece RPG",
		Details = "One piece mythical farm",
		Features = { "AUTO FARM", "BOSS", "RAID" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "Anime Warriors",
		Description = "Anime RPG",
		Details = "Anime warriors farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Anime Expedition",
		Description = "Anime RPG",
		Details = "Anime expedition farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Anime Final Quest",
		Description = "Anime RPG",
		Details = "Anime final quest farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "Anime Tactical",
		Description = "Anime RPG",
		Details = "Anime tactical farm",
		Features = { "AUTO FARM", "COMBAT", "UPGRADES" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "AnimeRangerX",
		Description = "Anime RPG",
		Details = "AnimeRangerX farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "BLADE SPIN",
		Description = "Spinner",
		Details = "Blade spin farm",
		Features = { "AUTO FARM", "SPIN", "UPGRADES" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "Brainblast",
		Description = "Brainrot",
		Details = "Brainblast farm",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "Broken Blade",
		Description = "Blade RPG",
		Details = "Broken blade farm",
		Features = { "AUTO FARM", "COMBAT", "BOSS" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "8 Ball Pool 1v1",
		Description = "Sports",
		Details = "8 ball pool tools",
		Features = { "AIM", "TOOLS", "AUTO FARM" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "Guess My Logo",
		Description = "Quiz",
		Details = "Guess my logo solver",
		Features = { "AUTO SOLVE", "FARM" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "Guess My Football Country",
		Description = "Quiz",
		Details = "Guess football country solver",
		Features = { "AUTO SOLVE", "FARM" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "Kaitun",
		Description = "Anime RPG",
		Details = "Kaitun farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "SOON",
		PlaceId = 0,
	},
	{
		Name = "All Star Tower Defense",
		Description = "Tower defense",
		Details = "All star TD farm",
		Features = { "AUTO FARM", "AUTO PLACE", "UPGRADE" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Kick a Lucky Block",
		Description = "Lucky block",
		Details = "Kick lucky block farm",
		Features = { "AUTO FARM", "LUCKY BLOCK", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Jump to Steal Slimes",
		Description = "Fun",
		Details = "Jump steal slimes farm",
		Features = { "AUTO FARM", "JUMP", "COLLECT" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Jump to Steal Soccer Players",
		Description = "Fun",
		Details = "Jump steal soccer farm",
		Features = { "AUTO FARM", "JUMP", "COLLECT" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Iron Soul",
		Description = "RPG",
		Details = "Iron soul farm",
		Features = { "AUTO FARM", "BOSS", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Rebirth Champions",
		Description = "Clicker",
		Details = "Rebirth champions farm",
		Features = { "AUTO CLICK", "REBIRTH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Slime RNG",
		Description = "RNG",
		Details = "Slime RNG auto roll",
		Features = { "AUTO ROLL", "AUTO FARM" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Sell Ores",
		Description = "Ore farm",
		Details = "Sell ores auto farm",
		Features = { "AUTO MINE", "SELL", "FARM" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "+1 Skinny Per Step",
		Description = "Clicker farm",
		Details = "Skinny per step farm",
		Features = { "AUTO CLICK", "AUTO FARM", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Catch a brainrot",
		Description = "Brainrot farm",
		Details = "Catch brainrot slop",
		Features = { "AUTO FARM", "AUTO HATCH", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},
	{
		Name = "Loot Evo",
		Description = "Loot sim",
		Details = "Loot evolution farm",
		Features = { "AUTO FARM", "EVOLVE", "UPGRADES" },
		Status = "FREE",
		PlaceId = 0,
	},

}

local function startMain(key, app)
	local context = makeMainContext(key, app)
	context.MainSource = "jnkie"
	local ok, err = runJunkieMain(context)

	if not ok then
		app:SetStatus("Could not load " .. tostring(CURRENT_ROUTE.Name) .. ": " .. tostring(err), "error")
		return false
	end

	app:SetStatus("Loaded " .. tostring(CURRENT_ROUTE.Name) .. ".", "success")
	if type(app.Destroy) == "function" then
		task.delay(0.2, function()
			pcall(function()
				app:Destroy()
			end)
		end)
	end

	return true
end

-- Tries a previously-cached verified key so the user does not have to re-enter
-- it on every launch. Returns the key on success, nil otherwise.
local function tryAutoVerifyKey()
	local routeKey = CURRENT_ROUTE and CURRENT_ROUTE.Key
	if not routeKey then
		return nil
	end
	local saved = loadSavedVerifiedKey(routeKey)
	if type(saved) ~= "string" or saved == "" then
		return nil
	end
	local ok, valid = pcall(verifyJunkieKey, saved, routeKey)
	if ok and valid then
		return saved
	end
	-- verifyJunkieKey already drops the cache when it rejects a key, but the
	-- pcall above may swallow that for non-string returns — clear defensively.
	clearSavedVerifiedKey(routeKey)
	return nil
end

-- Resolve universe ids + real thumbnail URLs for the preview games so images
-- render. Runs in a background task so the per-place fallback (up to ~100
-- sequential requests) never delays the window from opening; images simply
-- pop in on the next page rebuild (the GetKey page auto-slides every few
-- seconds). Wrapped so a network/API failure never breaks the UI.
task.spawn(function()
	pcall(function()
		resolveUniverseIdsForGames(LoaderPreviewGames)
		resolveThumbnailsForGames(LoaderPreviewGames)
	end)
end)

local App = MammozHub:CreateStyledWindow({
	Name = "Mammoz Hub",
	Subtitle = "Game Control Center",
	StudioName = "Mammoz Studios",
	DefaultPage = "GetKey",
	AutoSlideDelay = 4,
	LowEffects = false,
	Scripts = LoaderPreviewGames,
	GetKeyLink = function()
		return getJunkieKeyLink()
	end,
	DiscordUrl = "https://discord.gg/Xfa9nAsTCJ",
	VipUrl = "https://discord.gg/Xfa9nAsTCJ",
	VipPrice = "149 THB",
	VipPromoBadge = "BEST VALUE",
	VipPromoDetails = {
		"VIP game loaders",
		"Priority support",
		"Exclusive auto farm",
	},
	VerifyKey = function(key)
		return verifyJunkieKey(key, CURRENT_ROUTE and CURRENT_ROUTE.Key)
	end,
	OnKeyVerified = function(key, app)
		app:SetStatus("Access granted. Loading " .. tostring(CURRENT_ROUTE.Name) .. "...", "success")
		startMain(key, app)
	end,
	AutoVerifyKey = tryAutoVerifyKey,
})

return App
