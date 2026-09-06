-- Mammoz UI compatibility layer for the local scripts.
-- It wraps MammozUI.lib.lua and exposes the older framework APIs:
-- UI.Window -> win:Page -> page:Card -> card:Toggle/Button/Slider/Dropdown/Stepper/Readout.

local function environmentTable()
	return (getgenv and getgenv()) or _G
end

local function rawBaseUrl()
	local env = environmentTable()
	local base = env.__MAMMOZ_RAW_BASE or env.MAMMOZ_RAW_BASE
	if type(base) ~= "string" or base == "" then
		return nil
	end
	base = base:gsub("\\", "/")
	if base:sub(-1) ~= "/" then
		base ..= "/"
	end
	return base
end

local function rawModuleUrl(path)
	local base = rawBaseUrl()
	if not base then
		return nil
	end
	path = tostring(path or ""):gsub("\\", "/"):gsub(" ", "%%20")
	return base .. path
end

local function loadRawModule(path, label)
	local url = rawModuleUrl(path)
	if not url or not (game and loadstring) then
		return nil
	end
	local ok, result = pcall(function()
		return loadstring(game:HttpGet(url, true), label or path)()
	end)
	if ok and type(result) == "table" then
		return result
	end
	return nil
end

-- The standalone distribution registers this loader before it evaluates this
-- module.  Keeping the hook here also means the normal multi-file build and
-- the standalone build expose exactly the same compatibility API.
local function loadBundledModule(path)
	local loader = environmentTable().__MAMMOZ_BUNDLE_LOAD
	if type(loader) ~= "function" then
		return nil
	end
	local ok, result = pcall(loader, path)
	if ok and type(result) == "table" then
		return result
	end
	return nil
end

local function loadMammozBackend()
	local env = environmentTable()
	if type(env.__MAMMOZ_UI_BACKEND) == "table" then
		return env.__MAMMOZ_UI_BACKEND
	end
	local bundledBackend = loadBundledModule("MammozUI.lib.lua")
	if type(bundledBackend) == "table" then
		env.__MAMMOZ_UI_BACKEND = bundledBackend
		return bundledBackend
	end

	local candidates = {
		"Mammoz-Hub-Script/MammozUI.lib.lua",
		"MammozUI.lib.lua",
		"./MammozUI.lib.lua",
	}

	for _, path in ipairs(candidates) do
		if readfile then
			local ok, source = pcall(readfile, path)
			if ok and type(source) == "string" and source ~= "" then
				local loadedOk, result = pcall(function()
					return loadstring(source, "MammozUI")()
				end)
				if loadedOk and type(result) == "table" then
					env.__MAMMOZ_UI_BACKEND = result
					return result
				end
			end
		end

		if loadfile then
			local ok, result = pcall(function()
				return loadfile(path)()
			end)
			if ok and type(result) == "table" then
				env.__MAMMOZ_UI_BACKEND = result
				return result
			end
		end
	end

	local remoteBackend = loadRawModule("MammozUI.lib.lua", "MammozUI")
	if type(remoteBackend) == "table" then
		env.__MAMMOZ_UI_BACKEND = remoteBackend
		return remoteBackend
	end

	error("MammozCompat.lua: MammozUI.lib.lua was not found.", 2)
end

local MammozUI = loadMammozBackend()

local UI = {}

UI.theme = {
	accent = Color3.fromRGB(39, 145, 255),
	band = Color3.fromRGB(83, 193, 255),
	good = Color3.fromRGB(61, 224, 167),
	warn = Color3.fromRGB(247, 191, 72),
	bad = Color3.fromRGB(255, 104, 119),
	text = Color3.fromRGB(235, 247, 255),
	dim = Color3.fromRGB(112, 150, 183),
}

-- All converted scripts share this visual system. A script may opt out only
-- explicitly with AllowCustomTheme, which keeps the default experience aligned
-- with the main Mammoz dashboard instead of each source framework's skin.
UI.LockDashboardTheme = true
UI.DashboardStyle = "main-dashboard"

UI.icon = {
	home = "home",
	bolt = "star",
	pickaxe = "code",
	coin = "star",
	chart = "search",
	list = "code",
	bag = "shield",
	eye = "search",
	target = "search",
	wave = "star",
	grid = "home",
	map = "home",
	sword = "shield",
	flask = "star",
	gear = "gear",
	user = "user",
	shield = "shield",
	star = "star",
}

UI.Options = {}
UI.Toggles = {}
UI.Tabs = {}
UI.TabButtons = {}
UI.Labels = {}
UI.Scheme = {}
UI.Unloaded = false

local environment = environmentTable()
environment.__MAMMOZ_RUNTIME_ERRORS = type(environment.__MAMMOZ_RUNTIME_ERRORS) == "table"
	and environment.__MAMMOZ_RUNTIME_ERRORS or {}
UI.RuntimeErrors = environment.__MAMMOZ_RUNTIME_ERRORS

local function traceback(message)
	return debug and debug.traceback and debug.traceback(tostring(message), 2) or tostring(message)
end

local function callbackContext(callback)
	if debug and type(debug.info) == "function" then
		local ok, source, line, name = pcall(debug.info, callback, "sln")
		if ok then
			local label = tostring(name or "callback")
			if source and source ~= "" then
				label ..= " @ " .. tostring(source)
			end
			if tonumber(line) then
				label ..= ":" .. tostring(line)
			end
			return label
		end
	end
	return "callback"
end

local reportingError = false
local function reportRuntimeError(context, err)
	local entry = {
		Time = os.date and os.date("%H:%M:%S") or tostring(math.floor(os.clock())),
		Context = tostring(context or "Runtime"),
		Error = tostring(err or "Unknown error"),
	}
	UI.RuntimeErrors[#UI.RuntimeErrors + 1] = entry
	while #UI.RuntimeErrors > 40 do
		table.remove(UI.RuntimeErrors, 1)
	end
	if type(warn) == "function" then
		warn(("[Mammoz] %s: %s"):format(entry.Context, entry.Error))
	end
	if not reportingError then
		reportingError = true
		local window = UI.LastWindow
		if window and type(window.ShowRuntimeError) == "function" then
			pcall(window.ShowRuntimeError, window, entry)
		end
		reportingError = false
	end
	return entry
end

function UI:ReportError(context, err)
	return reportRuntimeError(context, err)
end

environment.__MAMMOZ_REPORT_ERROR = function(context, err)
	return reportRuntimeError(context, err)
end

local function placeId()
	local ok, value = pcall(function()
		return game.PlaceId
	end)
	return ok and tostring(value) or "0"
end

local function sanitizePathPart(value)
	local text = tostring(value or "default"):gsub("[^%w%._%-]", "_")
	text = text:gsub("_+", "_")
	return text ~= "" and string.sub(text, 1, 80) or "default"
end

local function configNamespace()
	return sanitizePathPart(UI.ConfigNamespace or "default")
end

local function configStore()
	environment.__MAMMOZ_UI_CONFIG_STORE = type(environment.__MAMMOZ_UI_CONFIG_STORE) == "table"
		and environment.__MAMMOZ_UI_CONFIG_STORE or {}
	local key = placeId() .. "|" .. configNamespace()
	environment.__MAMMOZ_UI_CONFIG_STORE[key] = type(environment.__MAMMOZ_UI_CONFIG_STORE[key]) == "table"
		and environment.__MAMMOZ_UI_CONFIG_STORE[key] or {}
	return environment.__MAMMOZ_UI_CONFIG_STORE[key]
end

local function configDirectory()
	return "Mammoz-Hub-Script/configs/" .. sanitizePathPart(placeId()) .. "/" .. configNamespace()
end

local function configPath(name)
	return configDirectory() .. "/" .. sanitizePathPart(name) .. ".json"
end

local function ensureConfigDirectory()
	if type(makefolder) ~= "function" then
		return false
	end
	for _, path in ipairs({
		"Mammoz-Hub-Script",
		"Mammoz-Hub-Script/configs",
		"Mammoz-Hub-Script/configs/" .. sanitizePathPart(placeId()),
		configDirectory(),
	}) do
		local exists = false
		if type(isfolder) == "function" then
			local ok, result = pcall(isfolder, path)
			exists = ok and result == true
		end
		if not exists then
			pcall(makefolder, path)
		end
	end
	return true
end

local function serializeValue(value, depth)
	depth = depth or 0
	if depth > 8 then
		return nil
	end
	local luaType = type(value)
	if luaType == "nil" or luaType == "string" or luaType == "number" or luaType == "boolean" then
		return value
	end
	local robloxType = typeof(value)
	if robloxType == "Color3" then
		return { __mammozType = "Color3", R = value.R, G = value.G, B = value.B }
	elseif robloxType == "Vector2" or robloxType == "Vector3" then
		return { __mammozType = robloxType, X = value.X, Y = value.Y, Z = value.Z }
	elseif robloxType == "EnumItem" then
		return { __mammozType = "EnumItem", Value = tostring(value) }
	elseif luaType == "table" then
		local result = {}
		for key, child in pairs(value) do
			local encoded = serializeValue(child, depth + 1)
			if encoded ~= nil then
				result[tostring(key)] = encoded
			end
		end
		return result
	end
	return tostring(value)
end

local function deserializeValue(value)
	if type(value) ~= "table" then
		return value
	end
	if value.__mammozType == "Color3" then
		return Color3.new(tonumber(value.R) or 0, tonumber(value.G) or 0, tonumber(value.B) or 0)
	elseif value.__mammozType == "Vector2" then
		return Vector2.new(tonumber(value.X) or 0, tonumber(value.Y) or 0)
	elseif value.__mammozType == "Vector3" then
		return Vector3.new(tonumber(value.X) or 0, tonumber(value.Y) or 0, tonumber(value.Z) or 0)
	elseif value.__mammozType == "EnumItem" then
		local enumType, itemName = tostring(value.Value or ""):match("^Enum%.([^.]+)%.(.+)$")
		local ok, item = pcall(function()
			return enumType and itemName and Enum[enumType][itemName]
		end)
		return ok and item or value.Value
	end
	local result = {}
	for key, child in pairs(value) do
		if key ~= "__mammozType" then
			local numericKey = tonumber(key)
			result[numericKey and math.floor(numericKey) == numericKey and numericKey or key] = deserializeValue(child)
		end
	end
	return result
end

local function httpService()
	local ok, service = pcall(function()
		return game:GetService("HttpService")
	end)
	return ok and service or nil
end

function UI:SaveConfig(name)
	local store = configStore()
	local key = tostring(name or "default")
	local data = {}
	for id, proxy in pairs(UI.Options) do
		local ok, value = pcall(function()
			return type(proxy.Get) == "function" and proxy:Get() or proxy.Value
		end)
		if ok then
			data[id] = value
		end
	end
	store[key] = data
	local service = httpService()
	if service and type(writefile) == "function" then
		local ok, err = pcall(function()
			ensureConfigDirectory()
			writefile(configPath(key), service:JSONEncode({
				Version = 1,
				PlaceId = placeId(),
				Namespace = configNamespace(),
				Values = serializeValue(data),
			}))
		end)
		if not ok then
			reportRuntimeError("SaveConfig " .. key, err)
		end
	end
	return true
end

function UI:LoadConfig(name)
	local key = tostring(name or "default")
	local data = configStore()[key]
	if type(data) ~= "table" and type(readfile) == "function" then
		local service = httpService()
		local path = configPath(key)
		local exists = true
		if type(isfile) == "function" then
			local ok, result = pcall(isfile, path)
			exists = ok and result == true
		end
		if service and exists then
			local ok, decoded = pcall(function()
				local payload = service:JSONDecode(readfile(path))
				return deserializeValue(payload.Values or payload)
			end)
			if ok and type(decoded) == "table" then
				data = decoded
				configStore()[key] = data
			elseif not ok then
				reportRuntimeError("LoadConfig " .. key, decoded)
			end
		end
	end
	if type(data) ~= "table" then
		return false
	end
	for id, value in pairs(data) do
		local proxy = UI.Options[id]
		if proxy then
			pcall(function()
				if type(proxy.Set) == "function" then
					proxy:Set(value)
				elseif type(proxy.SetValue) == "function" then
					proxy:SetValue(value)
				else
					proxy.Value = value
				end
			end)
		end
	end
	return true
end

function UI:SetFlag(id, value)
	local proxy = UI.Options[tostring(id or "")]
	if not proxy then
		return false
	end
	pcall(function()
		if type(proxy.Set) == "function" then
			proxy:Set(value)
		elseif type(proxy.SetValue) == "function" then
			proxy:SetValue(value)
		else
			proxy.Value = value
		end
	end)
	return true
end

function UI:ListConfigs()
	local list, seen = {}, {}
	for name in pairs(configStore()) do
		seen[name] = true
		list[#list + 1] = name
	end
	if type(listfiles) == "function" then
		local ok, files = pcall(listfiles, configDirectory())
		if ok and type(files) == "table" then
			for _, path in ipairs(files) do
				local name = tostring(path):match("([^/\\]+)%.json$")
				if name and not seen[name] then
					seen[name] = true
					list[#list + 1] = name
				end
			end
		end
	end
	table.sort(list)
	return list
end

function UI.t(text)
	return tostring(text or "")
end

local Window = {}
Window.__index = Window

local Page = {}
Page.__index = Page

local Card = {}
Card.__index = Card

local function normalizeIcon(icon)
	if type(icon) == "string" and icon ~= "" then
		local lowered = string.lower(icon)
		if UI.icon[lowered] then
			return UI.icon[lowered]
		end
		for pattern, mapped in pairs({
			["home"] = "home",
			["farm"] = "home",
			["player"] = "user",
			["user"] = "user",
			["setting"] = "gear",
			["gear"] = "gear",
			["wrench"] = "gear",
			["combat"] = "shield",
			["sword"] = "shield",
			["shield"] = "shield",
			["esp"] = "search",
			["eye"] = "search",
			["target"] = "search",
			["search"] = "search",
			["gift"] = "star",
			["reward"] = "star",
			["star"] = "star",
		}) do
			if string.find(lowered, pattern, 1, true) then
				return mapped
			end
		end
		return "code"
	end
	return "code"
end

local function call(callback, ...)
	if type(callback) == "function" then
		local args = table.pack(...)
		local context = callbackContext(callback)
		task.spawn(function()
			local ok, err = xpcall(function()
				callback(table.unpack(args, 1, args.n))
			end, traceback)
			if not ok then
				reportRuntimeError(context, err)
			end
		end)
	end
end

local function mirrorButtonText(button, label)
	if not (button and label) then
		return
	end
	button.TextTransparency = 1
	button:GetPropertyChangedSignal("Text"):Connect(function()
		label.Text = button.Text
	end)
end

local function textOf(value)
	local ok, result = pcall(value)
	if ok then
		return tostring(result)
	end
	return "-"
end

function UI.Window(first, second)
	local config = first == UI and (second or {}) or (first or {})
	config = config or {}
	UI.Unloaded = false
	local useCustomTheme = UI.LockDashboardTheme == false or config.AllowCustomTheme == true
	if not useCustomTheme then
		UI.theme.accent = Color3.fromRGB(39, 145, 255)
		UI.theme.band = Color3.fromRGB(83, 193, 255)
		UI.theme.good = Color3.fromRGB(61, 224, 167)
		UI.theme.warn = Color3.fromRGB(247, 191, 72)
		UI.theme.bad = Color3.fromRGB(255, 104, 119)
		UI.theme.text = Color3.fromRGB(235, 247, 255)
		UI.theme.dim = Color3.fromRGB(112, 150, 183)
	end
	local title = config.Title or config.title or config.Name or config.name or "Mammoz"
	local accentTitle = config.AccentTitle or config.accentTitle
	if accentTitle and accentTitle ~= "" then
		title = tostring(title) .. " " .. tostring(accentTitle)
	end

	local requestedSize = config.Size
	if typeof(requestedSize) == "UDim2" and requestedSize.X.Scale == 0 and requestedSize.Y.Scale == 0 then
		requestedSize = UDim2.fromOffset(math.max(900, requestedSize.X.Offset), math.max(600, requestedSize.Y.Offset))
	elseif typeof(requestedSize) ~= "UDim2" then
		local width = math.max(900, tonumber(config.width or config.Width) or 1120)
		local height = math.max(600, tonumber(config.height or config.Height) or 700)
		requestedSize = UDim2.fromOffset(width, height)
	end
	local raw = MammozUI:CreateWindow({
		Title = title,
		Name = config.Name or config.name or "MammozHubUI",
		BadgeText = config.badge or config.BadgeText or config.Subtitle or config.subtitle or config.Author or title,
		Accent = useCustomTheme and (config.Accent or UI.theme.accent) or UI.theme.accent,
		Theme = useCustomTheme and type(config.MammozTheme) == "table" and config.MammozTheme or nil,
		Size = requestedSize,
		OnClose = config.OnClose,
	})

	local self = setmetatable({
		raw = raw,
		gui = raw.screen,
		status = "",
		stats = {},
		masterValue = false,
		masterLabel = "Master",
		masterCallback = nil,
		homePage = nil,
		homeStatus = nil,
		homeStats = {},
		homeMasterRefresh = nil,
		pages = {},
	}, Window)
	UI.ScreenGui = raw.screen
	UI.LastWindow = self
	if UI.NotifySide and type(raw.setNotifySide) == "function" then
		raw:setNotifySide(UI.NotifySide)
	end
	if UI.DPIScale and type(raw.setDPIScale) == "function" then
		raw:setDPIScale(UI.DPIScale)
	end
	if UI.Font and type(raw.setFont) == "function" then
		raw:setFont(UI.Font)
	end
	if config.ToggleKey or config.ToggleKeybind then
		self:SetToggleKey(config.ToggleKey or config.ToggleKeybind)
	end
	self.ConfigManager = {
		CreateConfig = function()
			return true
		end,
		LoadConfig = function()
			return true
		end,
		SaveConfig = function()
			return true
		end,
	}

	return self
end

function Window:Destroy()
	local result = self.raw:Destroy()
	if UI.LastWindow == self then
		UI.LastWindow = nil
		UI.ScreenGui = nil
	end
	return result
end

function Window:SetStatus(text)
	self.status = tostring(text or "")
	if self.raw and type(self.raw.setHeaderStatus) == "function" then
		local statusKind = string.find(string.lower(self.status), "error", 1, true) and "error"
			or string.find(string.lower(self.status), "warn", 1, true) and "warn"
			or nil
		self.raw:setHeaderStatus(self.status ~= "" and self.status or "SYSTEM ONLINE", statusKind)
	end
	if self.homeStatus then
		self.homeStatus.Text = self.status
	end

	local badge = self.raw.supportBadge
	if badge then
		local label = badge:FindFirstChildWhichIsA("TextLabel")
		if label then
			label.Text = self.status ~= "" and string.sub(self.status, 1, 34) or "UI Library"
		end
	end
end

function Window:SetStat(index, value, label)
	index = tonumber(index) or 1
	self.stats[index] = {
		value = tostring(value or ""),
		label = tostring(label or ""),
	}

	local statLabel = self.homeStats[index]
	if statLabel then
		local item = self.stats[index]
		statLabel.Text = item.label ~= "" and (item.value .. "  " .. item.label) or item.value
	end
end

function Window:SetMaster(value, label)
	self.masterValue = value and true or false
	if label then
		self.masterLabel = tostring(label)
	end
	if self.homeMasterRefresh then
		self.homeMasterRefresh()
	end
end

function Window:OnMaster(callback)
	self.masterCallback = callback
end

function Window:Refresh()
	if self.homeStatus then
		self.homeStatus.Text = self.status or ""
	end
	for index, item in pairs(self.stats) do
		self:SetStat(index, item.value, item.label)
	end
end

function Window:Home()
	if self.homePage then
		self.raw:SelectPage(self.homePage.raw)
		return self.homePage
	end

	local page = self:Page("HOME", "home")
	local card = page:Card("STATUS", 0)
	self.homeStatus = card.raw:AddLabel(self.status ~= "" and self.status or "Ready", true)

	for i = 1, 3 do
		local item = self.stats[i] or { value = "-", label = "" }
		self.homeStats[i] = card.raw:AddLabel(item.label ~= "" and (item.value .. "  " .. item.label) or item.value, true)
	end

	local refreshMaster
	card:Toggle(self.masterLabel, self.masterValue, function(on)
		self.masterValue = on
		call(self.masterCallback, on)
	end)
	refreshMaster = function() end
	self.homeMasterRefresh = refreshMaster

	self.homePage = page
	self.raw:SelectPage(page.raw)
	return page
end

function Window:Page(name, icon)
	local rawPage = self.raw:CreatePage(tostring(name or "Page"), normalizeIcon(icon))
	local page = setmetatable({
		raw = rawPage,
		window = self,
	}, Page)
	self.pages[#self.pages + 1] = page
	return page
end

function Page:Card(title, order)
	local rawCard = self.raw:CreateCard(tostring(title or "Card"), order)
	return setmetatable({
		raw = rawCard,
		page = self,
		window = self.window,
	}, Card)
end

function Card:Accent()
	return self
end

function Card:Label(text, note)
	return self.raw:AddLabel(tostring(text or ""), note ~= false)
end

function Card:Button(text, callback, tone)
	local button, label
	button, label = self.raw:AddButton(tostring(text or "Button"), function()
		call(callback, button, label)
	end)
	button.Text = tostring(text or "Button")
	mirrorButtonText(button, label)
	return button
end

function Card:Toggle(text, default, callback, hint, tone)
	local row = self.raw:AddToggle(tostring(text or "Toggle"), default and true or false, function(value)
		call(callback, value)
	end)
	if hint and hint ~= "" then
		self.raw:AddLabel(tostring(hint), true)
	end
	return row
end

function Card:Slider(text, min, max, default, callback, suffix)
	return self.raw:AddSlider(tostring(text or "Slider"), min or 0, max or 100, default or min or 0, function(value)
		if math.abs(value - math.floor(value + 0.5)) < 0.001 then
			value = math.floor(value + 0.5)
		end
		call(callback, value)
	end)
end

function Card:Dropdown(text, options, default, callback)
	options = type(options) == "table" and options or {}
	return self.raw:AddDropdown(tostring(text or "Dropdown"), options, default or options[1], function(value)
		call(callback, value)
	end)
end

function Card:Stepper(text, getter, callback, hint, tone)
	local labelText = tostring(text or "Value")
	local valueLabel = self.raw:AddLabel(labelText .. ": " .. textOf(getter), false)

	local function refresh()
		valueLabel.Text = labelText .. ": " .. textOf(getter)
	end

	local minus = self:Button("- " .. labelText, function()
		if type(callback) == "function" then
			callback(-1)
		end
		refresh()
	end)
	local plus = self:Button("+ " .. labelText, function()
		if type(callback) == "function" then
			callback(1)
		end
		refresh()
	end)

	if hint and hint ~= "" then
		self.raw:AddLabel(tostring(hint), true)
	end

	refresh()
	return refresh, minus, plus
end

function Card:Readout(count, colorFn)
	count = tonumber(count) or 8
	local labels = {}
	for i = 1, count do
		labels[i] = self.raw:AddLabel("", true)
		labels[i].Font = Enum.Font.Code
		labels[i].TextSize = 10
		labels[i].TextXAlignment = Enum.TextXAlignment.Left
	end

	local readout = {}

	function readout:set(lines)
		lines = type(lines) == "table" and lines or {}
		for i = 1, count do
			local text = tostring(lines[i] or "")
			labels[i].Text = text
			if type(colorFn) == "function" then
				local ok, color = pcall(colorFn, text, i)
				if ok and typeof(color) == "Color3" then
					labels[i].TextColor3 = color
				end
			end
		end
	end

	function readout:Set(lines)
		return self:set(lines)
	end

	return readout
end

local function valueFrom(config, ...)
	if type(config) ~= "table" then
		return nil
	end
	for _, key in ipairs({ ... }) do
		if config[key] ~= nil then
			return config[key]
		end
	end
	return nil
end

local function makeControlProxy(refresh)
	local proxy = {}
	local callbacks = {}
	function proxy:SetValue(value)
		self.Value = value
		if refresh then
			refresh(value)
		end
		for _, callback in ipairs(callbacks) do
			call(callback, value)
		end
	end
	function proxy:Set(value)
		return self:SetValue(value)
	end
	function proxy:SetValues(value)
		return self:SetValue(value)
	end
	function proxy:Get()
		return self.Value
	end
	function proxy:SetOptions()
		return self
	end
	function proxy:Refresh()
		return self
	end
	function proxy:Update()
		return self
	end
	function proxy:SetDesc()
		return self
	end
	function proxy:SetText(value)
		return self:SetValue(value)
	end
	function proxy:SetValueRGB(value)
		return self:SetValue(value)
	end
	function proxy:OnChanged(callback)
		if type(callback) == "function" then
			callbacks[#callbacks + 1] = callback
		end
		return self
	end
	return proxy
end

function Window:Notify(config, body, kind)
	if type(config) == "table" then
		return self.raw:Notify(config.Title or config.title or "Notice", config.Content or config.content or config.Body or config.body or "", kind or config.Type or config.type or config.Kind or config.kind)
	end
	return self.raw:Notify(tostring(config or "Notice"), tostring(body or ""), kind)
end

function Window:Toast(config, body, kind)
	if type(config) == "table" then
		return self:Notify({
			Title = config.Title or config.title or config.Name or config.name or "Notice",
			Content = config.Content or config.content or config.Subtitle or config.subtitle
				or config.Description or config.description or config.Body or config.body or "",
			Type = config.Type or config.type or kind,
		})
	end
	return self:Notify(config, body, kind)
end

function Window:SetSidebarWidth(width)
	width = math.clamp(tonumber(width) or 184, 140, 320)
	if self.raw and type(self.raw.setSidebarWidth) == "function" then
		self.raw:setSidebarWidth(width)
	elseif self.raw then
		self.raw.sidebarWidth = width
	end
	return self
end

function Window:SetFooter(text)
	local value = tostring(text or "")
	local badge = self.raw and self.raw.supportBadge
	local label = badge and badge:FindFirstChildWhichIsA("TextLabel")
	if label then
		label.Text = value
	end
	return self
end

function Window:ChangeTitle(text)
	local value = tostring(text or "MAMMOZ HUB")
	if self.raw then
		if self.raw.fullTitle then
			self.raw.fullTitle.Text = value
		end
		if self.raw.miniTitle then
			self.raw.miniTitle.Text = string.sub(value, 1, 1)
		end
	end
	return self
end

function Window:ShowRuntimeError(entry)
	if not self.raw or self.raw.cleaning then
		return
	end
	if not self.errorCard then
		local page = self:Page("ERRORS", "shield")
		self.errorCard = page:Card("RUNTIME DIAGNOSTICS", 999)
		self.errorLabels = {}
		self.errorCard:Label("Errors are captured here without stopping the remaining UI callbacks.", true)
		self.errorCard:Button("Clear errors", function()
			table.clear(UI.RuntimeErrors)
			for _, label in ipairs(self.errorLabels) do
				if label and label.Parent then
					label.Text = ""
					label.Visible = false
				end
			end
		end)
	end
	local message = ("[%s] %s\n%s"):format(
		tostring(entry.Time or "--:--:--"),
		tostring(entry.Context or "Runtime"),
		string.sub(tostring(entry.Error or "Unknown error"), 1, 420)
	)
	local label
	if #self.errorLabels < 10 then
		label = self.errorCard:Label(message, true)
		self.errorLabels[#self.errorLabels + 1] = label
	else
		label = table.remove(self.errorLabels, 1)
		self.errorLabels[#self.errorLabels + 1] = label
		label.Text = message
		label.Visible = true
	end
	self:SetStatus("Runtime error captured - open ERRORS")
end

function Window:Popup(config)
	if type(config) == "table" then
		self:Notify(config.title or config.Title or "Popup", config.content or config.Content or "")
	end
	return makeControlProxy()
end

function Window:Notification(config, body, kind)
	return self:Notify(config, body, kind)
end

function Window:Unload()
	return self:Destroy()
end


local function enumKey(value)
	if typeof(value) == "EnumItem" then
		return value
	end
	local name = tostring(value or ""):gsub("^Enum%.KeyCode%.", "")
	if Enum and Enum.KeyCode and Enum.KeyCode[name] then
		return Enum.KeyCode[name]
	end
	return nil
end

function Window:SetToggleKey(key)
	local resolved = enumKey(key)
	if resolved and self.raw and type(self.raw.setToggleKey) == "function" then
		self.raw:setToggleKey(resolved)
		self.toggleKey = resolved
	end
	return self
end

function Window:EditOpenButton()
	return self
end

function Window:Divider()
	return makeControlProxy()
end

function Window:Tab(config)
	local title = type(config) == "table" and (config.Title or config.name or config.Name) or config
	local icon = type(config) == "table" and (config.Icon or config.icon) or nil
	return self:Page(title or "Tab", icon)
end

function Window:CreateTab(config, icon)
	if type(config) == "table" then
		return self:Page(config.name or config.Name or config.Title or "Tab", config.icon or config.Icon)
	end
	return self:Page(config or "Tab", icon)
end

function Window:AddTab(name, icon)
	if type(name) == "table" then
		return self:Page(name.Name or name.name or name.Title or "Tab", name.Icon or name.icon)
	end
	return self:Page(name or "Tab", icon)
end

function Window:Section(config)
	local section = {}
	function section:Tab(tabConfig)
		return Window.Tab(self.window, tabConfig)
	end
	section.window = self
	return section
end

function Page:_defaultCard()
	if not self.defaultCard then
		self.defaultCard = self:Card("MAIN", 0)
	end
	return self.defaultCard
end

function Page:Section(config)
	local title = type(config) == "table" and (config.Title or config.Name or config.name) or config
	return self:Card(title or "SECTION", 0)
end

function Page:CreateSection(config)
	local title = type(config) == "table" and (config.Name or config.name or config.Title) or config
	return self:Card(title or "SECTION", 0)
end

function Page:PageSection(config)
	local card = self:Card(type(config) == "table" and (config.Title or config.Name) or config or "SECTION", 0)
	function card:Form()
		return self
	end
	return card
end

function Page:Row(config)
	local card = self:_defaultCard()
	if type(config) == "table" and (config.SearchIndex or config.Title) then
		card:Label(config.SearchIndex or config.Title, false)
	end
	return card
end

function Page:Button(...)
	return self:_defaultCard():Button(...)
end

function Page:Toggle(...)
	return self:_defaultCard():Toggle(...)
end

function Page:Slider(...)
	return self:_defaultCard():Slider(...)
end

function Page:Dropdown(...)
	return self:_defaultCard():Dropdown(...)
end

function Page:Input(...)
	return self:_defaultCard():Input(...)
end

function Page:CreateButton(...)
	return self:_defaultCard():CreateButton(...)
end

function Page:CreateToggle(...)
	return self:_defaultCard():CreateToggle(...)
end

function Page:CreateSlider(...)
	return self:_defaultCard():CreateSlider(...)
end

function Page:CreateDropdown(...)
	return self:_defaultCard():CreateDropdown(...)
end

function Page:CreateParagraph(...)
	return self:_defaultCard():CreateParagraph(...)
end

function Page:CreateLabel(...)
	return self:_defaultCard():AddLabel(...)
end

function Page:CreateDivider(...)
	return self:_defaultCard():AddDivider(...)
end

function Page:CreateKeybind(...)
	return self:_defaultCard():KeybindField(...)
end

function Page:AddSubTab(name, icon)
	return self:Card(name or "SubTab", 0)
end

function Page:CreateSubTab(name, icon)
	return self:AddSubTab(name, icon)
end

function Page:SubTab(name, icon)
	return self:AddSubTab(name, icon)
end

function Page:AddLeftGroupbox(name, icon)
	return self:Card(name or "Group", 0)
end

function Page:AddRightGroupbox(name, icon)
	return self:Card(name or "Group", 0)
end

function Page:AddRightTabbox()
	local tabbox = {}
	function tabbox:AddTab(name, icon)
		return Page.Card(self.page, name or "Tab", 0)
	end
	tabbox.page = self
	return tabbox
end

function Card:Left()
	return self
end

function Card:Right()
	return self
end

function Card:Form()
	return self
end

function Card:TitleStack(config)
	if type(config) == "table" then
		self:Label(config.Title or "", false)
		if config.Subtitle then
			self:Label(config.Subtitle, true)
		end
	end
	return self
end

function Card:Section(config)
	local title = type(config) == "table" and (config.Title or config.Name or config.name) or config
	if title then
		self:Label(title, false)
	end
	return self
end

local makeLabelProxy
function Card:Label(config, note)
	local text = type(config) == "table"
		and (config.Text or config.Name or config.name or config.Title or config.Content or config.Label or "")
		or config
	return makeLabelProxy(self.raw:AddLabel(tostring(text or ""), note ~= false), self)
end

function Card:Paragraph(config)
	return self:CreateParagraph(config)
end

function Card:CreateParagraph(config)
	local title = type(config) == "table" and (config.Title or config.Name or config.name) or "Paragraph"
	local content = type(config) == "table" and (config.Content or config.Text or "") or tostring(config or "")
	local label = self.raw:AddLabel(tostring(title) .. (content ~= "" and (": " .. tostring(content)) or ""), true)
	local proxy = makeControlProxy(function(value)
		label.Text = tostring(value or "")
	end)
	function proxy:SetDesc(value)
		label.Text = tostring(title) .. ": " .. tostring(value or "")
	end
	return proxy
end

function Card:CreateLabel(...)
	return self:AddLabel(...)
end

function Card:CreateDivider(...)
	return self:AddDivider(...)
end

function Card:CreateKeybind(...)
	return self:KeybindField(...)
end

function Card:AddParagraph(config)
	return self:CreateParagraph(config)
end

function Card:Input(config, callback)
	config = type(config) == "table" and config or { Placeholder = tostring(config or "") }
	local current = config.Value or config.CurrentValue or config.Default or ""
	local proxy
	local input = self.raw:AddInput({
		Label = config.Label or config.Title or config.Name,
		Placeholder = config.Placeholder or config.placeholder or "",
		Default = current,
		Masked = config.Masked,
	}, function(text, focused, enter)
		current = text
		if proxy then
			proxy.Value = text
		end
		call(callback or config.Callback or config.ValueChanged or config.TextChanged, text, focused, enter)
	end)
	proxy = makeControlProxy(function(value)
		current = tostring(value or "")
		if input then
			input.Text = current
		end
		call(callback or config.Callback or config.ValueChanged or config.TextChanged, current, false, false)
	end)
	proxy.Value = current
	proxy.Instance = input
	function proxy:Get()
		return current
	end
	return proxy
end

function Card:TextField(config)
	return self:Input(config, valueFrom(config, "ValueChanged", "TextChanged", "Callback"))
end

function Card:CreateInput(config)
	return self:Input(config, valueFrom(config, "Callback", "ValueChanged", "TextChanged"))
end

function Card:Textbox(config)
	return self:Input(config, valueFrom(config, "Callback", "ValueChanged", "TextChanged"))
end

function Card:Button(config, callback, tone)
	if type(config) == "table" then
		return self:Button(config.Name or config.name or config.Title or config.Label or "Button", config.Callback or config.Pushed or callback, tone)
	end
	-- VectorHub also accepts Button(name, disabled, callback).  The middle
	-- argument is not meaningful to MammozUI, but retaining the callback is.
	if type(callback) ~= "function" and type(tone) == "function" then
		callback = tone
	end
	local button, label
	button, label = self.raw:AddButton(tostring(config or "Button"), function()
		call(callback, button, label)
	end)
	button.Text = tostring(config or "Button")
	mirrorButtonText(button, label)
	return button
end

function Card:CreateButton(config)
	return self:Button(config, valueFrom(config, "Callback", "Pushed"))
end

function Card:Toggle(config, default, callback, hint, tone)
	if type(config) == "table" then
		local cb = config.Callback or config.ValueChanged or callback
		return self:Toggle(config.Name or config.name or config.Title or config.Label or "Toggle", config.Value ~= nil and config.Value or config.CurrentValue ~= nil and config.CurrentValue or config.Default, function(value)
			call(cb, value, value)
		end, config.Desc or config.Description or hint, tone)
	end
	local row = self.raw:AddToggle(tostring(config or "Toggle"), default and true or false, function(value)
		call(callback, value)
	end)
	if hint and hint ~= "" then
		self.raw:AddLabel(tostring(hint), true)
	end
	return row
end

function Card:CreateToggle(config)
	return self:Toggle(config, valueFrom(config, "CurrentValue", "Value", "Default"), valueFrom(config, "Callback", "ValueChanged"))
end

function Card:Slider(config, min, max, default, callback, suffix)
	if type(config) == "table" then
		return self:Slider(
			config.Name or config.name or config.Title or config.Label or "Slider",
			config.Min or config.Minimum or config.min or min or 0,
			config.Max or config.Maximum or config.max or max or 100,
			config.Value or config.CurrentValue or config.Default or default or 0,
			config.Callback or config.ValueChanged or callback,
			suffix
		)
	end
	return self.raw:AddSlider(tostring(config or "Slider"), min or 0, max or 100, default or min or 0, function(value)
		if math.abs(value - math.floor(value + 0.5)) < 0.001 then
			value = math.floor(value + 0.5)
		end
		call(callback, value)
	end)
end

function Card:CreateSlider(config)
	return self:Slider(config)
end

function Card:Dropdown(config, options, default, callback)
	if type(config) == "table" then
		local values = config.Values or config.Options or config.List or config.Items or config.values or options or {}
		local cb = config.Callback or config.ValueChanged or callback
		local current = config.Value or config.CurrentValue or config.Default or config.Selected or default or values[1]
		return self:Dropdown(config.Name or config.name or config.Title or config.Label or "Dropdown", values, current, function(value)
			call(cb, value)
		end)
	end
	options = type(options) == "table" and options or {}
	local current = default or options[1]
	local control = self.raw:AddDropdown(tostring(config or "Dropdown"), options, default or options[1], function(value)
		current = value
		call(callback, value)
	end)
	local backendSet = control.Set
	local backendSetOptions = control.SetOptions
	local backendRefresh = control.Refresh
	function control:Get()
		return current
	end
	function control:Set(value)
		current = value
		if backendSet then
			backendSet(self, value)
		else
			call(callback, value)
		end
		return self
	end
	function control:Select(value)
		return self:Set(value)
	end
	function control:SetOptions(newValues)
		options = type(newValues) == "table" and newValues or options
		if backendSetOptions then
			backendSetOptions(self, options)
		end
		if current == nil and options[1] ~= nil then
			current = options[1]
		end
		return self
	end
	function control:Refresh(newValues, selected)
		options = type(newValues) == "table" and newValues or options
		if backendRefresh then
			backendRefresh(self, options, selected)
		elseif backendSetOptions then
			backendSetOptions(self, options)
		end
		if selected ~= nil then
			current = selected
		end
		return self
	end
	function control:SetValue(value)
		return self:Set(value)
	end
	function control:SetValues(value)
		if type(value) == "table" then
			return self:SetOptions(value)
		end
		return self:Set(value)
	end
	function control:Clear()
		options = {}
		current = nil
		if backendSetOptions then
			backendSetOptions(self, options)
		elseif backendRefresh then
			backendRefresh(self, options)
		end
		if backendSet then
			backendSet(self, nil)
		end
		return self
	end
	function control:Add(value)
		options[#options + 1] = value
		if backendSetOptions then
			backendSetOptions(self, options)
		elseif backendRefresh then
			backendRefresh(self, options)
		end
		return self
	end
	function control:Remove(value)
		for index, option in ipairs(options) do
			if option == value then
				table.remove(options, index)
				break
			end
		end
		if current == value then
			current = nil
		end
		if backendSetOptions then
			backendSetOptions(self, options)
		elseif backendRefresh then
			backendRefresh(self, options)
		end
		return self
	end
	function control:GetOptions()
		local result = {}
		for index, option in ipairs(options) do
			result[index] = option
		end
		return result
	end
	return control
end

local function cloneArray(values)
	local result = {}
	if type(values) == "table" then
		for _, value in ipairs(values) do
			result[#result + 1] = value
		end
	end
	return result
end

local function arraySet(values)
	local set = {}
	for _, value in ipairs(cloneArray(values)) do
		set[tostring(value)] = true
	end
	return set
end

local function selectionFromSet(options, set)
	local result = {}
	for _, option in ipairs(options or {}) do
		if set[tostring(option)] then
			result[#result + 1] = option
		end
	end
	return result
end

function Card:MultiDropdown(config, options, default, callback)
	config = type(config) == "table" and config or {
		Name = config,
		Options = options,
		Default = default,
		Callback = callback,
	}
	local values = config.Values or config.Options or config.List or config.Items or {}
	local selectedSet = arraySet(config.Default or config.Value or config.CurrentValue or config.Selected or {})
	local cb = config.Callback or config.ValueChanged or callback
	local title = config.Name or config.name or config.Title or config.Label or "Multi Dropdown"
	local status = self:AddLabel(title .. ": " .. (#selectionFromSet(values, selectedSet) > 0 and table.concat(selectionFromSet(values, selectedSet), ", ") or "None"), true)

	local function currentSelection()
		return selectionFromSet(values, selectedSet)
	end

	local function syncLabel()
		local selected = currentSelection()
		status:Set(title .. ": " .. (#selected > 0 and table.concat(selected, ", ") or "None"))
	end

	local proxy = makeControlProxy(function(selection)
		selectedSet = arraySet(selection)
		syncLabel()
		call(cb, currentSelection())
	end)
	proxy.Value = currentSelection()

	local selector = self:Dropdown("Toggle " .. tostring(title), values, values[1], function(value)
		local key = tostring(value)
		selectedSet[key] = not selectedSet[key] or nil
		proxy.Value = currentSelection()
		syncLabel()
		call(cb, proxy.Value)
	end)

	function proxy:Get()
		return cloneArray(self.Value)
	end
	function proxy:Set(selection)
		self.Value = cloneArray(selection)
		selectedSet = arraySet(self.Value)
		syncLabel()
		call(cb, self:Get())
		return self
	end
	function proxy:SetValue(selection)
		return self:Set(selection)
	end
	function proxy:SetValues(selection)
		return self:Set(selection)
	end
	function proxy:SetOptions(newValues)
		values = type(newValues) == "table" and newValues or values
		self.Value = currentSelection()
		if selector and type(selector.SetOptions) == "function" then
			selector:SetOptions(values)
		end
		syncLabel()
		return self
	end
	function proxy:Refresh(newValues)
		return self:SetOptions(newValues)
	end
	function proxy:Clear()
		values = {}
		selectedSet = {}
		self.Value = {}
		if selector and type(selector.Clear) == "function" then
			selector:Clear()
		elseif selector and type(selector.SetOptions) == "function" then
			selector:SetOptions(values)
		end
		syncLabel()
		call(cb, self.Value)
		return self
	end
	function proxy:Add(value)
		values[#values + 1] = value
		if selector and type(selector.SetOptions) == "function" then
			selector:SetOptions(values)
		end
		return self
	end
	function proxy:Remove(value)
		for index, option in ipairs(values) do
			if option == value then
				table.remove(values, index)
				break
			end
		end
		selectedSet[tostring(value)] = nil
		self.Value = currentSelection()
		if selector and type(selector.SetOptions) == "function" then
			selector:SetOptions(values)
		end
		syncLabel()
		call(cb, self.Value)
		return self
	end
	function proxy:GetOptions()
		return cloneArray(values)
	end

	return proxy
end

function Card:CreateDropdown(config)
	return self:Dropdown(config)
end

function Card:AddButton(...)
	return self:Button(...)
end

makeLabelProxy = function(label, card)
	local proxy = makeControlProxy(function(value)
		label.Text = tostring(value or "")
	end)
	rawset(proxy, "Label", label)
	rawset(proxy, "Instance", label)
	rawset(proxy, "Value", label.Text)
	function proxy:SetText(value)
		label.Text = tostring(value or "")
		self.Value = label.Text
		return self
	end
	function proxy:SetDesc(value)
		return self:SetText(value)
	end
	function proxy:SetValue(value)
		return self:SetText(value)
	end
	function proxy:Destroy()
		if label then
			label:Destroy()
		end
		return self
	end
	proxy.Remove = proxy.Destroy
	return setmetatable(proxy, {
		__index = function(tableSelf, key)
			if key == "Text" then
				return label.Text
			end
			if key == "Parent" then
				return label.Parent
			end
			return rawget(tableSelf, key) or function(_, ...)
				local method = card[key]
				if type(method) == "function" then
					return method(card, ...)
				end
				return makeControlProxy()
			end
		end,
		__newindex = function(tableSelf, key, value)
			if key == "Text" then
				label.Text = tostring(value or "")
			else
				rawset(tableSelf, key, value)
			end
		end,
	})
end

function Card:AddLabel(text, note)
	return self:Label(text, note)
end

function Card:AddDropdown(...)
	return self:Dropdown(...)
end

function Card:AddMultiDropdown(...)
	return self:MultiDropdown(...)
end

function Card:AddSlider(...)
	return self:Slider(...)
end

function Card:AddToggle(...)
	return self:Toggle(...)
end

function Card:AddDivider()
	return makeControlProxy()
end

local function registerOption(id, proxy, isToggle)
	if type(id) == "string" and id ~= "" then
		UI.Options[id] = proxy
		if isToggle then
			UI.Toggles[id] = proxy
		end
	end
	return proxy
end

function Card:AddMultiDropdown(id, config, default, callback)
	if type(id) == "table" and config == nil then
		config = id
		local proxy = self:MultiDropdown(config)
		return registerOption(config.Flag or config.Id or config.ID or config.Name or config.Title, proxy, false)
	end
	if type(config) == "table" and (config.Values or config.Options or config.Name or config.Title or config.Flag or config.Default) then
		config.Name = config.Name or config.Title or tostring(id or "Multi Dropdown")
		local proxy = self:MultiDropdown(config)
		return registerOption(config.Flag or config.Id or config.ID or id, proxy, false)
	end
	return self:MultiDropdown(id, config, default, callback)
end

function Card:AddCheckbox(id, config)
	if type(id) == "table" and config == nil then
		config = id
		id = config.Flag or config.Id or config.ID or config.Name or config.Title
	end
	config = type(config) == "table" and config or {}
	local cb = config.Callback or config.Changed
	local default = config.Default ~= nil and config.Default or config.Value ~= nil and config.Value or config.CurrentValue ~= nil and config.CurrentValue or false
	local control = self:Toggle(config.Text or config.Title or config.Name or id or "Checkbox", default, function(value)
		call(cb, value)
	end, config.Desc or config.Description)
	return registerOption(config.Flag or id, control, true)
end

function Card:AddToggle(id, config, third, fourth)
	if type(id) == "table" and config == nil then
		return self:AddCheckbox(id)
	end
	if type(config) == "table" then
		return self:AddCheckbox(id, config)
	end
	if type(config) == "string" and type(third) == "boolean" then
		return self:Toggle(id, third, fourth, config)
	end
	if type(config) == "function" then
		return self:Toggle(id, false, config)
	end
	return self:Toggle(id, config, third)
end

function Card:AddInput(id, config, callback)
	if type(id) == "table" and config == nil then
		config = id
		id = config.Flag or config.Id or config.ID or config.Name or config.Title
	end
	if type(config) ~= "table" then
		local placeholder = type(config) == "string" and config or tostring(id or "")
		local cb = type(config) == "function" and config or callback
		return self:Input({ Label = tostring(id or "Input"), Placeholder = placeholder }, cb)
	end
	config = type(config) == "table" and config or {}
	local cb = config.Callback or config.Changed
	local proxy = makeControlProxy(function(value)
		call(cb, value)
	end)
	proxy.Value = config.Default or config.Value or ""
	self:Input({
		Label = config.Text or config.Title or config.Name or id,
		Placeholder = config.Placeholder or "",
		Default = proxy.Value,
	}, function(value)
		proxy:SetValue(value)
	end)
	return registerOption(config.Flag or id, proxy, false)
end

function Card:AddTextbox(text, callback)
	if type(text) == "table" then
		return self:Input(text, text.Callback or text.Changed or callback)
	end
	return self:Input({ Placeholder = tostring(text or ""), Default = "" }, callback)
end

Card.AddTextBox = Card.AddTextbox

function Card:AddSlider(id, config, maxValue, defaultValue, callback, sixth)
	if type(id) == "table" and config == nil then
		config = id
		id = config.Flag or config.Id or config.ID or config.Name or config.Title
	end
	if type(config) == "string" and type(maxValue) == "number" then
		return self:Slider(id, maxValue, defaultValue, callback, sixth)
	end
	if type(config) ~= "table" then
		return self:Slider(id, config, maxValue, defaultValue, callback)
	end
	local cb = config.Callback or config.Changed
	local default = config.Default or config.Value or config.Min or 0
	local control = self:Slider(config.Text or config.Title or config.Name or id or "Slider", config.Min or config.Minimum or 0, config.Max or config.Maximum or 100, default, function(value)
		call(cb, value)
	end)
	return registerOption(config.Flag or id, control, false)
end

function Card:AddDropdown(id, config, defaultValue, callback, fifth)
	if type(id) == "table" and config == nil then
		config = id
		id = config.Flag or config.Id or config.ID or config.Name or config.Title
	end
	if type(config) == "string" and type(defaultValue) == "table" then
		return self:Dropdown(id, defaultValue, callback, fifth)
	end
	if type(config) ~= "table" then
		return self:Dropdown(id, {}, defaultValue, callback)
	end
	local isConfig = config.Values ~= nil or config.Options ~= nil or config.Name ~= nil or config.Title ~= nil
		or config.Flag ~= nil or config.Default ~= nil or config.Multi ~= nil
	if not isConfig then
		return self:Dropdown(id, config, defaultValue, callback)
	end
	if config.Multi == true or config.MultiSelect == true then
		return self:AddMultiDropdown(id, config)
	end
	local cb = config.Callback or config.Changed
	local values = config.Values or config.Options or {}
	local control = self:Dropdown(config.Text or config.Title or config.Name or id or "Dropdown", values, config.Default or config.Value or values[1], function(value)
		call(cb, value)
	end)
	return registerOption(config.Flag or id, control, false)
end

local function colourValue(value)
	if typeof(value) == "Color3" then
		return value
	end
	if type(value) == "table" then
		local red = tonumber(value.R or value.r or value[1]) or 0
		local green = tonumber(value.G or value.g or value[2]) or 0
		local blue = tonumber(value.B or value.b or value[3]) or 0
		if red <= 1 and green <= 1 and blue <= 1 then
			return Color3.new(red, green, blue)
		end
		return Color3.fromRGB(math.clamp(red, 0, 255), math.clamp(green, 0, 255), math.clamp(blue, 0, 255))
	end
	return UI.theme.accent
end

local function colourText(value)
	return ("#%02X%02X%02X"):format(
		math.floor(value.R * 255 + 0.5),
		math.floor(value.G * 255 + 0.5),
		math.floor(value.B * 255 + 0.5)
	)
end

function Card:Colorpicker(config)
	config = type(config) == "table" and config or { Name = tostring(config or "Color") }
	local title = config.Name or config.name or config.Title or config.Label or "Color"
	local callback = config.Callback or config.ValueChanged or config.Changed
	local current = colourValue(config.Default or config.Value or config.CurrentValue)
	local preview = self.raw:AddLabel(tostring(title) .. ": " .. colourText(current), true)
	local proxy
	local sliders = {}

	local function render(value)
		current = colourValue(value)
		preview.Text = tostring(title) .. ": " .. colourText(current)
		if sliders[1] then
			sliders[1]:Set(math.floor(current.R * 255 + 0.5), true)
			sliders[2]:Set(math.floor(current.G * 255 + 0.5), true)
			sliders[3]:Set(math.floor(current.B * 255 + 0.5), true)
		end
	end

	proxy = makeControlProxy(render)
	proxy.Value = current
	proxy:OnChanged(callback)

	local function updateChannel(index, value)
		local channels = {
			math.floor(current.R * 255 + 0.5),
			math.floor(current.G * 255 + 0.5),
			math.floor(current.B * 255 + 0.5),
		}
		channels[index] = math.clamp(math.floor((tonumber(value) or 0) + 0.5), 0, 255)
		proxy:SetValue(Color3.fromRGB(channels[1], channels[2], channels[3]))
	end

	sliders[1] = self.raw:AddSlider(tostring(title) .. " Red", 0, 255, math.floor(current.R * 255 + 0.5), function(value)
		updateChannel(1, value)
	end)
	sliders[2] = self.raw:AddSlider(tostring(title) .. " Green", 0, 255, math.floor(current.G * 255 + 0.5), function(value)
		updateChannel(2, value)
	end)
	sliders[3] = self.raw:AddSlider(tostring(title) .. " Blue", 0, 255, math.floor(current.B * 255 + 0.5), function(value)
		updateChannel(3, value)
	end)

	function proxy:Get()
		return current
	end
	function proxy:Set(value)
		self:SetValue(value)
		return self
	end
	function proxy:SetValueRGB(value)
		return self:Set(value)
	end
	return proxy
end

function Card:AddColorPicker(id, config, callback)
	if type(id) == "table" and config == nil then
		config = id
		id = config.Flag or config.Id or config.ID or config.Name or config.Title
	elseif typeof(config) == "Color3" then
		config = { Name = id, Default = config, Callback = callback }
	elseif type(config) ~= "table" then
		config = { Name = id, Callback = callback }
	end
	config.Name = config.Name or config.Title or config.Text or id or "Color"
	local proxy = self:Colorpicker(config)
	return registerOption(config.Flag or id, proxy, false)
end

function Card:AddColorpicker(id, config, callback)
	return self:AddColorPicker(id, config, callback)
end

local function keyDisplay(value)
	if typeof(value) == "EnumItem" then
		return value.Name
	end
	local text = tostring(value or "None")
	return text:gsub("^Enum%.[^.]+%.", "")
end

function Card:AddKeyPicker(id, config)
	config = type(config) == "table" and config or {}
	config.Name = config.Name or config.Title or config.Text or id or "Keybind"
	local proxy = self:KeybindField(config)
	return registerOption(config.Flag or id, proxy, false)
end

function Card:CreateColorSlider(config)
	return self:Colorpicker(config)
end

function Card:CreateColorpicker(config)
	return self:Colorpicker(config)
end

function Card:CreateColorPicker(config)
	return self:CreateColorpicker(config)
end

function Card:RadioButtonGroup(config)
	local options = type(config) == "table" and (config.Options or {}) or {}
	return self:Dropdown("Options", options, options[(type(config) == "table" and config.Value) or 1], function(value)
		if type(config) == "table" and config.ValueChanged then
			config.ValueChanged(config, table.find(options, value) or value)
		end
	end)
end

function Card:PopUpButton(config)
	return self:RadioButtonGroup(config)
end

function Card:PullDownButton(config)
	return self:PopUpButton(config)
end

function Card:KeybindField(config, defaultKey, currentKey, callback)
	if type(config) ~= "table" then
		config = {
			Name = tostring(config or "Keybind"),
			Default = currentKey or defaultKey,
			Callback = callback,
		}
	end
	local title = config.Label or config.Title or config.Name or config.Text or "Keybind"
	local value = config.CurrentKeybind or config.CurrentKey or config.Default or config.Value or defaultKey
	local callbackFn = config.Callback or config.ValueChanged or config.Changed or callback
	local waiting = false
	local proxy
	local button, label

	local function render(nextValue)
		value = nextValue
		if label then
			label.Text = tostring(title) .. ": " .. keyDisplay(value)
		end
	end

	proxy = makeControlProxy(render)
	proxy.Value = value
	proxy:OnChanged(callbackFn)
	button, label = self.raw:AddButton(tostring(title) .. ": " .. keyDisplay(value), function()
		waiting = true
		if label then
			label.Text = tostring(title) .. ": press a key..."
		end
	end)

	local service
	pcall(function()
		service = game:GetService("UserInputService")
	end)
	if service and self.window and self.window.raw then
		self.window.raw:bind(service.InputBegan, function(input, processed)
			if not waiting or processed then
				return
			end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				waiting = false
				proxy:SetValue(input.KeyCode)
			end
		end)
	end

	function proxy:Get()
		return value
	end
	function proxy:Set(nextValue)
		self:SetValue(nextValue)
		return self
	end
	function proxy:Update()
		render(self.Value)
		return self
	end
	proxy.Instance = button
	return proxy
end

local oldStepper = Card.Stepper
function Card:Stepper(config, getter, callback, hint, tone)
	if type(config) == "table" then
		local current = config.Value or config.Default or config.Minimum or 0
		return oldStepper(self, config.Title or config.Name or "Value", function()
			return tostring(current)
		end, function(direction)
			local step = config.Step or 1
			current = math.clamp((tonumber(current) or 0) + direction * step, config.Minimum or config.Min or -math.huge, config.Maximum or config.Max or math.huge)
			call(config.Callback or config.ValueChanged, current)
		end)
	end
	return oldStepper(self, config, getter, callback, hint, tone)
end

UI.CreateWindow = function(first, second)
	local config = first == UI and second or first
	return UI.Window(config)
end

-- Simple, framework-neutral API for new scripts. It intentionally wraps the
-- compatibility methods above, so a hub built with this API still shares flags,
-- callbacks, notifications, mobile handling, and the Dashboard visual shell.
local SimpleHub = {}
SimpleHub.__index = function(self, key)
	local method = SimpleHub[key]
	if method ~= nil then
		return method
	end
	local window = rawget(self, "window")
	local member = window and window[key]
	if type(member) == "function" then
		return function(_, ...)
			return member(window, ...)
		end
	end
	return member
end

local function simpleTabKey(value)
	return string.lower(tostring(value or "main"))
end

local function resolveSimpleTarget(hub, target)
	if type(target) == "string" then
		target = hub.tabs[simpleTabKey(target)] or hub:Tab(target)
	end
	if type(target) ~= "table" then
		error("MammozUI Hub needs a Tab or Section target.", 3)
	end
	return target
end

function SimpleHub:Tab(config, icon)
	local title = type(config) == "table" and (config.Title or config.Name or config.name) or config
	title = tostring(title or "Main")
	local key = simpleTabKey(title)
	if self.tabs[key] then
		return self.tabs[key]
	end
	local page = self.window:CreateTab({
		Title = title,
		Icon = type(config) == "table" and (config.Icon or config.icon) or icon,
	})
	self.tabs[key] = page
	return page
end

-- Existing converted scripts often use Window:AddTab/CreateTab. Keeping these
-- aliases lets them move to CreateHub without changing game callbacks.
SimpleHub.AddTab = SimpleHub.Tab
SimpleHub.CreateTab = SimpleHub.Tab

function SimpleHub:Section(tab, title)
	tab = resolveSimpleTarget(self, tab)
	return tab:CreateSection(title or "CONTROLS")
end

function SimpleHub:Label(target, text, note)
	target = resolveSimpleTarget(self, target)
	return target:CreateLabel(type(text) == "table" and text or { Text = text, Note = note })
end

function SimpleHub:Button(target, name, callback)
	target = resolveSimpleTarget(self, target)
	local config = type(name) == "table" and name or { Name = name, Callback = callback }
	return target:CreateButton(config)
end

function SimpleHub:Toggle(target, name, default, callback)
	target = resolveSimpleTarget(self, target)
	local config = type(name) == "table" and name or {
		Name = name,
		CurrentValue = default == true,
		Callback = callback,
	}
	return target:CreateToggle(config)
end

function SimpleHub:Slider(target, name, minimum, maximum, default, callback)
	target = resolveSimpleTarget(self, target)
	local config = type(name) == "table" and name or {
		Name = name,
		Min = minimum,
		Max = maximum,
		CurrentValue = default,
		Callback = callback,
	}
	return target:CreateSlider(config)
end

function SimpleHub:Dropdown(target, name, values, default, callback)
	target = resolveSimpleTarget(self, target)
	local config = type(name) == "table" and name or {
		Name = name,
		Options = values,
		CurrentValue = default,
		Callback = callback,
	}
	return target:CreateDropdown(config)
end

function SimpleHub:Input(target, name, placeholder, callback)
	target = resolveSimpleTarget(self, target)
	local config = type(name) == "table" and name or {
		Name = name,
		Placeholder = placeholder,
		Callback = callback,
	}
	return target:CreateInput(config)
end

function SimpleHub:Notify(title, content, kind)
	if type(title) == "table" then
		return self.window:Notify(title, content, kind)
	end
	return self.window:Notify({ Title = title, Content = content, Type = kind })
end

function SimpleHub:SetStatus(text)
	return self.window:SetStatus(text)
end

function SimpleHub:SetFlag(id, value)
	return UI:SetFlag(id, value)
end

function SimpleHub:Destroy()
	return self.window:Destroy()
end

UI.CreateHub = function(first, second)
	local config = first == UI and (second or {}) or (first or {})
	config = type(config) == "table" and config or {}
	local hub = setmetatable({
		window = UI:CreateWindow(config),
		Window = nil,
		tabs = {},
		Tabs = nil,
	}, SimpleHub)
	hub.Window = hub.window
	hub.Tabs = hub.tabs
	return hub
end
UI.Hub = UI.CreateHub
UI.CreateApp = UI.CreateHub

-- VectorHub's Evil factory and similar libraries return a tabbed window.
-- Keeping this alias in the shared compatibility layer lets converted scripts
-- retain their original UI calls without bundling a second UI implementation.
function UI:Evil(config)
	config = type(config) == "table" and config or {}
	config.Title = config.Title or config.Name or "VectorHub"
	config.Name = config.Name or "VectorHub"
	return self:CreateWindow(config)
end

UI.New = function()
	return UI
end

UI.Notify = function(first, config, body)
	local target = first == UI and config or first
	local win = UI.LastWindow
	if type(target) == "table" then
		win = win or UI.Window({ Title = "MAMMOZ HUB", Name = "MammozNotice" })
		win:Notify(target)
		return win
	end
	if target ~= nil then
		win = win or UI.Window({ Title = "MAMMOZ HUB", Name = "MammozNotice" })
		win:Notify(tostring(target), tostring(body or ""))
		return win
	end
	return nil
end

UI.Themes = { Dark = "Dark", Midnight = "Midnight" }
UI.Accents = { Pink = UI.theme.accent, Red = UI.theme.bad, Blue = UI.theme.band }
UI.Symbols = setmetatable({}, {
	__index = function(_, key)
		return tostring(key)
	end,
})

UI.UILibrary = UI
UI.MinimizeButton = function()
	return makeControlProxy()
end
UI.ConfigManager = function()
	local state = {}
	return {
		SC = function()
			return state
		end,
		S = function()
			return state
		end,
		SG = function()
			return true
		end,
	}
end

function UI:AddDraggableLabel(text)
	local label = { Text = tostring(text or "") }
	function label:SetText(value)
		self.Text = tostring(value or "")
	end
	return label
end

function UI:GetCustomIcon()
	return nil
end

function UI:GetThemes()
	return self.Themes
end

function UI:SetTheme(name)
	self.CurrentTheme = tostring(name or "Mammoz")
	return self
end

function UI:GetCurrentTheme()
	return self.CurrentTheme or "Mammoz"
end

function UI:SetTransparency(value)
	self.Transparency = math.clamp(tonumber(value) or 0, 0, 1)
	return self
end

function UI:GetTransparency()
	return self.Transparency or 0
end

function UI:ToggleTransparency()
	return self:SetTransparency(self:GetTransparency() > 0 and 0 or 0.25)
end

local function legacyGuiParents()
	local parents = {}
	local seen = {}
	local function add(parent)
		if parent and not seen[parent] then
			seen[parent] = true
			parents[#parents + 1] = parent
		end
	end
	for _, getter in ipairs({ gethui, get_hidden_gui }) do
		if type(getter) == "function" then
			local ok, parent = pcall(getter)
			if ok then
				add(parent)
			end
		end
	end
	pcall(function()
		add(game:GetService("CoreGui"))
	end)
	pcall(function()
		local player = game:GetService("Players").LocalPlayer
		add(player and (player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui", 3)))
	end)
	return parents
end

local function applyLegacyStyle(object, root)
	if not object:IsA("GuiObject") then
		if object:IsA("UIStroke") then
			object.Color = UI.theme.accent
			object.Transparency = math.max(object.Transparency, 0.2)
		end
		return
	end
	if object:IsA("TextLabel") then
		object.TextColor3 = object.TextSize >= 16 and UI.theme.text or Color3.fromRGB(169, 204, 231)
		if object.TextSize >= 16 then
			object.Font = Enum.Font.GothamBold
		elseif object.Font ~= Enum.Font.Code then
			object.Font = Enum.Font.GothamMedium
		end
	elseif object:IsA("TextButton") then
		object.TextColor3 = UI.theme.text
		object.Font = Enum.Font.GothamBold
		-- Do not stomp the colors/corners that native Mammoz controls set;
		-- legacy styling is only for controls imported from other sources.
		if not object:GetAttribute("MammozUI") then
			if object.BackgroundTransparency < 0.95 then
				object.BackgroundColor3 = Color3.fromRGB(10, 34, 62)
			end
			if not object:FindFirstChildOfClass("UICorner") then
				local radius = Instance.new("UICorner")
				radius.CornerRadius = UDim.new(0, 7)
				radius.Parent = object
			end
		end
	elseif object:IsA("TextBox") then
		object.BackgroundColor3 = Color3.fromRGB(3, 13, 29)
		object.TextColor3 = UI.theme.text
		object.PlaceholderColor3 = UI.theme.dim
		object.Font = Enum.Font.GothamMedium
	elseif object:IsA("ScrollingFrame") then
		object.ScrollBarThickness = math.max(5, object.ScrollBarThickness)
		object.ScrollBarImageColor3 = UI.theme.accent
	elseif object:IsA("Frame") or object:IsA("CanvasGroup") then
		if object.BackgroundTransparency < 0.95 then
			object.BackgroundColor3 = object.Parent == root and Color3.fromRGB(4, 12, 26) or Color3.fromRGB(11, 31, 56)
		end
	end
end

function UI:StyleLegacyGui(screen)
	if not screen or not screen:IsA("ScreenGui") or tostring(screen.Name):find("Mammoz", 1, true) then
		return false
	end
	for _, object in ipairs(screen:GetDescendants()) do
		pcall(applyLegacyStyle, object, screen)
	end
	local connection = screen.DescendantAdded:Connect(function(object)
		task.defer(function()
			if object.Parent then
				pcall(applyLegacyStyle, object, screen)
			end
		end)
	end)
	screen.Destroying:Connect(function()
		pcall(function()
			connection:Disconnect()
		end)
	end)
	return true
end

local fullLayoutAdapter
local legacyInstanceProxy

local function loadFullLayoutAdapter()
	if type(fullLayoutAdapter) == "table" then
		return fullLayoutAdapter
	end
	local env = environmentTable()
	if type(env.__MAMMOZ_LEGACY_LAYOUT) == "table" then
		fullLayoutAdapter = env.__MAMMOZ_LEGACY_LAYOUT
		return fullLayoutAdapter
	end
	local bundledAdapter = loadBundledModule("MammozLegacyLayout.lua")
	if type(bundledAdapter) == "table" then
		fullLayoutAdapter = bundledAdapter
		env.__MAMMOZ_LEGACY_LAYOUT = bundledAdapter
		return bundledAdapter
	end
	local candidates = {
		"Mammoz-Hub-Script/MammozLegacyLayout.lua",
		"MammozLegacyLayout.lua",
		"./MammozLegacyLayout.lua",
	}
	for _, path in ipairs(candidates) do
		if readfile and loadstring then
			local ok, result = pcall(function()
				return loadstring(readfile(path), "MammozLegacyLayout")()
			end)
			if ok and type(result) == "table" then
				fullLayoutAdapter = result
				return result
			end
		end
		if loadfile then
			local ok, result = pcall(function()
				return loadfile(path)()
			end)
			if ok and type(result) == "table" then
				fullLayoutAdapter = result
				return result
			end
		end
	end
	local remoteAdapter = loadRawModule("MammozLegacyLayout.lua", "MammozLegacyLayout")
	if type(remoteAdapter) == "table" then
		fullLayoutAdapter = remoteAdapter
		env.__MAMMOZ_LEGACY_LAYOUT = remoteAdapter
		return remoteAdapter
	end
	error("MammozCompat.lua: MammozLegacyLayout.lua was not found.", 2)
end

function UI:InstallLegacyLayout(config)
	return loadFullLayoutAdapter().Install(self, config)
end

UI.InstallFullLayout = UI.InstallLegacyLayout

local function loadLegacyInstanceProxy()
	if type(legacyInstanceProxy) == "table" then
		return legacyInstanceProxy
	end
	local env = environmentTable()
	if type(env.__MAMMOZ_LEGACY_PROXY) == "table" then
		legacyInstanceProxy = env.__MAMMOZ_LEGACY_PROXY
		return legacyInstanceProxy
	end
	local bundledProxy = loadBundledModule("MammozLegacyProxy.lua")
	if type(bundledProxy) == "table" then
		legacyInstanceProxy = bundledProxy
		env.__MAMMOZ_LEGACY_PROXY = bundledProxy
		return legacyInstanceProxy
	end
	local candidates = {
		"Mammoz-Hub-Script/MammozLegacyProxy.lua",
		"MammozLegacyProxy.lua",
		"./MammozLegacyProxy.lua",
	}
	for _, path in ipairs(candidates) do
		if readfile and loadstring then
			local ok, result = pcall(function()
				return loadstring(readfile(path), "MammozLegacyProxy")()
			end)
			if ok and type(result) == "table" then
				legacyInstanceProxy = result
				return result
			end
		end
		if loadfile then
			local ok, result = pcall(function()
				return loadfile(path)()
			end)
			if ok and type(result) == "table" then
				legacyInstanceProxy = result
				return result
			end
		end
	end
	local remoteProxy = loadRawModule("MammozLegacyProxy.lua", "MammozLegacyProxy")
	if type(remoteProxy) == "table" then
		legacyInstanceProxy = remoteProxy
		env.__MAMMOZ_LEGACY_PROXY = remoteProxy
		return remoteProxy
	end
	error("MammozCompat.lua: MammozLegacyProxy.lua was not found.", 2)
end

function UI:CreateLegacyInstanceFactory(config)
	return loadLegacyInstanceProxy().Create(self, loadFullLayoutAdapter(), config)
end

UI.CreateVirtualInstanceFactory = UI.CreateLegacyInstanceFactory

function UI:InstallLegacyBridge(config)
	config = type(config) == "table" and config or {}
	local environment = (getgenv and getgenv()) or _G
	if type(environment.__MAMMOZ_LEGACY_BRIDGE) == "table" then
		for _, connection in ipairs(environment.__MAMMOZ_LEGACY_BRIDGE) do
			pcall(function()
				connection:Disconnect()
			end)
		end
	end
	local known = {}
	local parents = legacyGuiParents()
	for _, parent in ipairs(parents) do
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("ScreenGui") then
				known[child] = true
			end
		end
	end
	local connections = {}
	local adopted = 0
	for _, parent in ipairs(parents) do
		connections[#connections + 1] = parent.ChildAdded:Connect(function(child)
			if known[child] or not child:IsA("ScreenGui") or adopted >= (tonumber(config.MaxGuis) or 3) then
				return
			end
			known[child] = true
			adopted += 1
			task.defer(function()
				self:StyleLegacyGui(child)
			end)
		end)
	end
	environment.__MAMMOZ_LEGACY_BRIDGE = connections
	task.delay(tonumber(config.Duration) or 8, function()
		if environment.__MAMMOZ_LEGACY_BRIDGE == connections then
			for _, connection in ipairs(connections) do
				pcall(function()
					connection:Disconnect()
				end)
			end
			environment.__MAMMOZ_LEGACY_BRIDGE = nil
		end
	end)
	return connections
end

function UI:Toggle()
	local window = self.LastWindow
	if window and window.raw then
		window.raw:setVisible(not window.raw.visible)
		return window.raw.visible
	end
	return false
end

function UI:IsVisible()
	local window = self.LastWindow
	return window and window.raw and window.raw.visible == true or false
end

function UI:SetVisibility(visible)
	local window = self.LastWindow
	if window and window.raw then
		window.raw:setVisible(visible == true)
	end
	return self
end

function UI:MakeDraggable()
	return true
end


function UI:SetNotifySide(side)
	self.NotifySide = tostring(side or "Right")
	if self.LastWindow and self.LastWindow.raw and type(self.LastWindow.raw.setNotifySide) == "function" then
		self.LastWindow.raw:setNotifySide(self.NotifySide)
	end
	return self
end


function UI:SetDPIScale(value)
	self.DPIScale = math.clamp(tonumber(value) or 1, 0.65, 1.5)
	if self.LastWindow and self.LastWindow.raw and type(self.LastWindow.raw.setDPIScale) == "function" then
		self.LastWindow.raw:setDPIScale(self.DPIScale)
	end
	return self
end


function UI:SetFont(font)
	self.Font = font
	if self.LastWindow and self.LastWindow.raw and type(self.LastWindow.raw.setFont) == "function" then
		self.LastWindow.raw:setFont(font)
	end
	return self
end

function UI:UpdateColorsUsingRegistry()
	return self
end

function UI:UpdateDependencyBoxes()
	return self
end

local managerStub = {}
function managerStub:SetLibrary(library)
	self.Library = library
	self.Options = library and library.Options or UI.Options
	return self
end
function managerStub:SetFolder(folder)
	self.Folder = tostring(folder or "default")
	UI.ConfigNamespace = self.SubFolder and (self.Folder .. "/" .. self.SubFolder) or self.Folder
	return self
end
function managerStub:SetSubFolder(folder)
	self.SubFolder = tostring(folder or "default")
	UI.ConfigNamespace = (self.Folder and (self.Folder .. "/") or "") .. self.SubFolder
	return self
end
function managerStub:SetDefaultTheme()
	return self
end
function managerStub:SetIgnoreIndexes(indexes)
	self.IgnoreIndexes = type(indexes) == "table" and indexes or {}
	return self
end
function managerStub:BuildConfigSection(tab)
	if self._sectionBuilt or type(tab) ~= "table" then
		return self
	end
	self._sectionBuilt = true
	local section = type(tab.AddSubTab) == "function" and tab:AddSubTab("Configuration")
		or type(tab.CreateSection) == "function" and tab:CreateSection("Configuration")
		or tab
	if type(section.AddButton) == "function" then
		section:AddButton({ Name = "Save configuration", Callback = function() UI:SaveConfig("autoload") end })
		section:AddButton({ Name = "Load configuration", Callback = function() UI:LoadConfig("autoload") end })
	end
	return self
end
function managerStub:LoadAutoloadConfig()
	UI:LoadConfig("autoload")
	return self
end
function managerStub:Save(name)
	return UI:SaveConfig(name or "autoload")
end
function managerStub:Load(name)
	return UI:LoadConfig(name or "autoload")
end
function managerStub:IgnoreThemeSettings()
	self.IgnoreThemeSettingsValue = true
	return self
end
function managerStub:ApplyToTab()
	return self
end
function managerStub:ApplyToGroupbox()
	return self
end

UI.ThemeManager = setmetatable({ BuiltInThemes = {} }, { __index = managerStub })
UI.SaveManager = setmetatable({ Options = UI.Options }, { __index = managerStub })

-- Common framework aliases. They all route to the same Mammoz controls, so a
-- converted script keeps one UI tree instead of opening a second library.
UI.MakeWindow = UI.CreateWindow
UI.CreateLib = function(first, second)
	local title = first == UI and second or first
	if type(title) == "table" then
		return UI.Window(title)
	end
	return UI.Window({ Title = tostring(title or "MAMMOZ HUB") })
end

function UI:LoadConfiguration()
	return self:LoadConfig("autoload")
end

function UI:OnUnload(callback)
	self.UnloadCallbacks = self.UnloadCallbacks or {}
	if type(callback) == "function" then
		self.UnloadCallbacks[#self.UnloadCallbacks + 1] = callback
	end
	return self
end

function UI:Unload()
	for _, callback in ipairs(self.UnloadCallbacks or {}) do
		pcall(callback)
	end
	self.UnloadCallbacks = {}
	self.Unloaded = true
	if self.LastWindow then
		pcall(function()
			self.LastWindow:Destroy()
		end)
	end
	table.clear(self.Options)
	table.clear(self.Toggles)
	return true
end

function UI:Destroy()
	return self:Unload()
end


function UI:Notification(config, body)
	return UI.Notify(self, config, body)
end

function UI:SetWatermark()
	return self
end

function UI:SetWatermarkVisibility()
	return self
end

function Window:MakeTab(config, icon)
	return self:CreateTab(config, icon)
end

function Window:CreatePage(config, icon)
	return self:CreateTab(config, icon)
end

function Window:SelectTab(page)
	local rawPage = type(page) == "table" and (page.raw or page) or page
	if rawPage then
		self.raw:SelectPage(rawPage)
	end
	return page
end

function Window:Toggle()
	self.raw:setVisible(not self.raw.visible)
	return self.raw.visible
end

function Window:IsVisible()
	return self.raw and self.raw.visible == true or false
end

function Window:SetVisibility(visible)
	if self.raw then
		self.raw:setVisible(visible == true)
	end
	return self
end

function Window:Minimize()
	self.raw:setVisible(false)
	return self
end

function Window:Open()
	self.raw:setVisible(true)
	return self
end

function Window:AddMinimizeButton()
	return makeControlProxy()
end

function Page:AddSection(config)
	return self:CreateSection(config)
end

function Page:AddButton(...)
	return self:_defaultCard():AddButton(...)
end

function Page:AddToggle(...)
	return self:_defaultCard():AddToggle(...)
end

function Page:AddSlider(...)
	return self:_defaultCard():AddSlider(...)
end

function Page:AddDropdown(...)
	return self:_defaultCard():AddDropdown(...)
end

function Page:AddMultiDropdown(...)
	return self:_defaultCard():AddMultiDropdown(...)
end

function Page:AddInput(...)
	return self:_defaultCard():AddInput(...)
end

function Page:AddTextbox(...)
	return self:_defaultCard():AddTextbox(...)
end

function Page:AddLabel(...)
	return self:_defaultCard():AddLabel(...)
end

function Page:AddParagraph(...)
	return self:_defaultCard():AddParagraph(...)
end

function Page:AddDivider(...)
	return self:_defaultCard():AddDivider(...)
end

function Page:SetSubTabAlignment()
	return self
end

function Page:DynamicLabel(config)
	return self:_defaultCard():AddLabel(config)
end

function Page:Stat(config)
	return self:DynamicLabel(config)
end

function Page:List(config)
	return self:DynamicLabel(config)
end

function Page:Keybind(config)
	return self:_defaultCard():KeybindField(config)
end

function Page:PullDownButton(config)
	return self:_defaultCard():PullDownButton(config)
end

function Card:AddSection(config)
	return self:Section(config)
end

function Card:Disable()
	return self
end

function Card:DynamicLabel(config)
	return self:AddLabel(config)
end

function Card:Stat(config)
	return self:AddLabel(config)
end

function Card:List(config)
	return self:AddLabel(config)
end

function Card:Keybind(config)
	return self:KeybindField(config)
end

function Card:AddKeybind(id, config)
	return self:AddKeyPicker(id, config)
end

return UI
