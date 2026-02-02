---@diagnostic disable: undefined-global

-------------------------------------------------------------------------------------------------------------------------------
-- Animation Logger
-- Originally by: Irfannnnn (he vibe coded it) 
-- Rework written by: .kingdream
-- Changes:
-- Export Menu
-- Import Menu
-- Importing/Exporting KeyframeSequences now wrap them all
-- into one rbxm file to save space
-- basic anti detection
-- swapped to a better saveinstance
--
-- Notice:
-- YOU CAN ONLY EXPORT IDS IN THE GAME YOU ORIGINALLY
-- LOGGED THEM IN!!!!
-------------------------------------------------------------------------------------------------------------------------------

if not game:IsLoaded() then game.Loaded:Wait() end

local cloneref = cloneref or function(x) return x end
local TweenService = cloneref(game:GetService("TweenService"))
local players = cloneref(game:GetService("Players"))
local marketplaceservice = cloneref(game:GetService("MarketplaceService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local localplayer = players.LocalPlayer
local gethui = get_hidden_ui or gethui or function() return CoreGui end

local function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function clik()
	local s = Instance.new("Sound") 
	s.SoundId = "rbxassetid://87152549167464"
	s.Parent = workspace
	s.Volume = 1.2
	s.TimePosition = 0.1
	s:Play()
	task.delay(1, function() s:Destroy() end)
end

local function extractanimationid(id)
	return tostring(id):gsub("%D","")
end

local function sanitize(name)
	return name:gsub("[^%w%s%-_]", "")
end

local function ensureFolder(path)
	if not isfolder(path) then makefolder(path) end
end

local function getAnimationInfo(assetid)
	local success, result = pcall(function()
		return marketplaceservice:GetProductInfo(assetid, Enum.InfoType.Asset)
	end)
	if success and result then return result end
	return { Name = "Unknown", Creator = { Name = "Unknown" }, IsPublicDomain = false }
end

local disabledAnimations = {
	["WalkAnim"] = true, ["JumpAnim"] = true, ["RunAnim"] = true,
	["SwimAnim"] = true, ["IdleAnim"] = true, ["FallAnim"] = true,
	["SwimIdleAnim"] = true, ["ClimbAnim"] = true,
}

local gameName = "Unknown"
pcall(function()
	gameName = marketplaceservice:GetProductInfo(game.PlaceId).Name
end)

local gui = Instance.new("ScreenGui")
gui.Name = randomString()
gui.Parent = gethui()
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.35, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 30)
topbar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
topbar.BorderSizePixel = 0
topbar.Parent = frame

local titlelabel = Instance.new("TextLabel")
titlelabel.Size = UDim2.new(1, -250, 1, 0)
titlelabel.BackgroundTransparency = 1
titlelabel.Text = " Animation Logger"
titlelabel.Font = Enum.Font.RobotoMono
titlelabel.TextXAlignment = Enum.TextXAlignment.Left
titlelabel.TextColor3 = Color3.new(1, 1, 1)
titlelabel.TextSize = 18
titlelabel.Parent = topbar

local function createbutton(position, size, color, text)
	local button = Instance.new("TextButton")
	button.Name = randomString()
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 16
	button.Font = Enum.Font.RobotoMono
	button.BorderSizePixel = 0
	button.BackgroundTransparency = 0.7
	button.Parent = topbar
	return button
end

local exportbutton = createbutton(UDim2.new(1, -186, 0, 5), UDim2.new(0, 60, 0, 20), Color3.fromRGB(60, 150, 60), "Export")
local importbutton = createbutton(UDim2.new(1, -255, 0, 5), UDim2.new(0, 60, 0, 20), Color3.fromRGB(0, 102, 255), "Import")
local clearbutton = createbutton(UDim2.new(1, -116, 0, 5), UDim2.new(0, 60, 0, 20), Color3.fromRGB(200, 50, 50), "Clear")
local minimizebutton = createbutton(UDim2.new(1, -51, 0, 5), UDim2.new(0, 20, 0, 20), Color3.fromRGB(50, 50, 200), "–")
local xbutton = createbutton(UDim2.new(1, -25, 0, 5), UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 50, 50), "X")

local scrollframe = Instance.new("ScrollingFrame")
scrollframe.Size = UDim2.new(1, -10, 1, -40)
scrollframe.Position = UDim2.new(0, 5, 0, 35)
scrollframe.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollframe.ScrollBarThickness = 5
scrollframe.BorderSizePixel = 0
scrollframe.BackgroundTransparency = 1
scrollframe.Parent = frame

local loglayout = Instance.new("UIListLayout")
loglayout.Padding = UDim.new(0, 5)
loglayout.Parent = scrollframe
loglayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollframe.CanvasSize = UDim2.new(0, 0, 0, loglayout.AbsoluteContentSize.Y)
end)

local function tweenGui(guiObject, properties, duration, style, direction)
	local info = TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(guiObject, info, properties)
	tween:Play()
	return tween
end

local loggedanimations = {}

local function animateLogEntry(entry)
	entry.Position = UDim2.new(0, -400, entry.Position.Y.Scale, entry.Position.Y.Offset)
	entry.BackgroundTransparency = 1
	for _, child in ipairs(entry:GetChildren()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			child.TextTransparency = 1
		end
	end
	tweenGui(entry, {Position = UDim2.new(0, 10, entry.Position.Y.Scale, entry.Position.Y.Offset), BackgroundTransparency = 0}, 0.4)
	for _, child in ipairs(entry:GetChildren()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			tweenGui(child, {TextTransparency = 0}, 0.4)
		end
	end
end

local function createlogentry(animationname, animationid, source)
	local displayid = extractanimationid(animationid)
	local numericid = tonumber(displayid)
	if not numericid then return end

	local entryframe = Instance.new("Frame")
	entryframe.Size = UDim2.new(0, 390, 0, 130)
	entryframe.Position = UDim2.new(0, 10, 0, 10)
	entryframe.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	entryframe.BorderSizePixel = 0
	entryframe.Parent = scrollframe

	local info = getAnimationInfo(numericid)
	if info.Creator.Name == "Roblox" then
		entryframe:Destroy()
		loggedanimations[animationid] = nil
		return
	end

	local function createLabel(text, yPos, size, color)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -170, 0, 20)
		label.Position = UDim2.new(0, 5, 0, yPos)
		label.BackgroundTransparency = 1
		label.Text = text
		label.Font = Enum.Font.RobotoMono
		label.TextColor3 = color or Color3.new(1,1,1)
		label.TextSize = size
		label.BorderSizePixel = 0
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = entryframe
		return label
	end

	createLabel("Game: "..gameName,5,14,Color3.fromRGB(200,200,200))
	createLabel("ID: "..displayid,25,16)
	createLabel("Creator: "..info.Creator.Name,45,14,Color3.fromRGB(200,200,200))
	createLabel("Status: "..(info.IsPublicDomain and "Public" or "Private"),65,14,Color3.fromRGB(200,200,200))
	createLabel("Source: "..source,85,14,Color3.fromRGB(200,200,200))
	createLabel("Animation Name: "..info.Name,105,14,Color3.fromRGB(200,200,200))

	local function createEntryButton(text, yPos, color, xOffset)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 75, 0, 20)
		button.Position = UDim2.new(1, -80-(xOffset or 0), 0, yPos)
		button.BackgroundColor3 = color
		button.Text = text
		button.Font = Enum.Font.RobotoMono
		button.BorderSizePixel = 0
		button.TextColor3 = Color3.new(1,1,1)
		button.TextSize = 12
		button.Parent = entryframe
		return button
	end

	local copyidbutton   = createEntryButton("Copy ID", 5, Color3.fromRGB(60,60,150),80)
	local copynamebutton = createEntryButton("Copy Name", 30, Color3.fromRGB(60,60,150),80)
	local copyurlbutton  = createEntryButton("Copy Url", 55, Color3.fromRGB(60,60,150),80)

	local playbutton     = createEntryButton("Play", 5, Color3.fromRGB(60,150,60))
	local stopbutton     = createEntryButton("Stop", 30, Color3.fromRGB(150,60,60))
	local removebutton   = createEntryButton("Remove", 55, Color3.fromRGB(200,80,80))

	local track = nil

	playbutton.MouseButton1Click:Connect(function()
		clik()
		if localplayer.Character then
			local humanoid = localplayer.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				if track then track:Stop() track=nil end
				local animation = Instance.new("Animation")
				animation.AnimationId = "rbxassetid://"..numericid
				track = humanoid:LoadAnimation(animation)
				track:Play()
				track:AdjustWeight(999)
				playbutton.Text="Playing"
				task.delay(1,function() if playbutton then playbutton.Text="Play" end end)
			end
		end
	end)

	stopbutton.MouseButton1Click:Connect(function()
		clik()
		if track then track:Stop() track=nil end
	end)

	local function copyToClipboard(textToCopy, button)
		clik()
		if setclipboard then
			setclipboard(textToCopy)
			local orig = button.Text
			button.Text="Copied!"
			task.wait(1)
			button.Text=orig
		end
	end

	copyidbutton.MouseButton1Click:Connect(function() copyToClipboard(displayid, copyidbutton) end)
	copynamebutton.MouseButton1Click:Connect(function() copyToClipboard(info.Name, copynamebutton) end)
	copyurlbutton.MouseButton1Click:Connect(function() copyToClipboard("https://www.roblox.com/library/"..displayid, copyurlbutton) end)

	removebutton.MouseButton1Click:Connect(function()
		clik()
		loggedanimations[animationid]=nil
		tweenGui(entryframe, {Size = UDim2.new(entryframe.Size.X.Scale, entryframe.Size.X.Offset, 0, 0), BackgroundTransparency = 1}, 0.25)
		task.delay(0.25, function() entryframe:Destroy() end)
	end)

	animateLogEntry(entryframe)
	return entryframe
end

local function loganimation(animationname, animationid, source)
	if not animationid or loggedanimations[animationid] or disabledAnimations[animationname] then return end
	loggedanimations[animationid]=true
	task.spawn(function()
		createlogentry(animationname, animationid, source)
	end)
end

local function trackanimationplaying(humanoid)
	humanoid.AnimationPlayed:Connect(function(track)
		if track and track.Animation then
			loganimation(track.Animation.Name, track.Animation.AnimationId, "Played Animation")
		end
	end)
end

local function setupcharacter(character)
	local humanoid = character:WaitForChild("Humanoid",5)
	if not humanoid then return end
	local animate = character:FindFirstChild("Animate")
	if animate then
		for _,obj in ipairs(animate:GetDescendants()) do
			if obj:IsA("Animation") then
				loganimation(obj.Name, obj.AnimationId, "Animate Script")
			end
		end
	end
	trackanimationplaying(humanoid)
end

localplayer.CharacterAdded:Connect(setupcharacter)
if localplayer.Character then setupcharacter(localplayer.Character) end

local exportdropdown = Instance.new("Frame")
exportdropdown.Size=UDim2.new(0,120,0,60)
exportdropdown.Position=UDim2.new(1,-190,0,30)
exportdropdown.BackgroundColor3=Color3.fromRGB(35,35,35)
exportdropdown.BorderSizePixel=0
exportdropdown.Visible=false
exportdropdown.Parent=frame

local function makeExportOption(text,y)
	local btn=Instance.new("TextButton")
	btn.Size = UDim2.new(1,0,0,30)
	btn.Position = UDim2.new(0,0,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.Text = text
	btn.Font = Enum.Font.RobotoMono
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BorderSizePixel = 0
	btn.Parent = exportdropdown
	return btn
end

local Params = {
	RepoURL = "https://raw.githubusercontent.com/Devraj2010isme/BetterSaveinstance/refs/heads/main/",
	SSI = "saveinstance",
}

local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

local function exportKeyframes()
	local base = "AnimationExports"
	local gameFolder = base .. "/" .. sanitize(gameName)
	local kfFolder = gameFolder .. "/exported-keyframes"
	ensureFolder(base)
	ensureFolder(gameFolder)
	ensureFolder(kfFolder)

	local containerFolder = Instance.new("Folder")
	containerFolder.Name = ""

	for id in pairs(loggedanimations) do
		local clean = extractanimationid(id)
		local numeric = tonumber(clean)
		if not numeric then continue end

		local ok, obj = pcall(function()
			return game:GetObjects("rbxassetid://" .. clean)[1]
		end)
		if not ok or not obj or not obj:IsA("KeyframeSequence") then continue end

		obj.Parent = containerFolder
	end

	local outputData
	synsaveinstance({
		Object = containerFolder,
		Callback = function(data) outputData = data end,
		__DEBUG_MODE = true,
		mode = "full",
        ReadMe = false,
		SaveBytecode = false
	})
	if outputData then
		writefile(kfFolder .. "/output.rbxm", outputData)
	end
end

local function importKeyframesFromText(text)
	local lines = {}
	for line in text:gmatch("[^\r\n]+") do
		local id = line:match("(%d+)")
		if id then table.insert(lines, id) end
	end

	if #lines == 0 then
		warn("No valid animation IDs found in import box")
		return
	end

	local containerFolder = Instance.new("Folder")
	containerFolder.Name = ""

	for _, animId in ipairs(lines) do
		local clean = extractanimationid(animId)
		local numeric = tonumber(clean)
		if not numeric then continue end

		local ok, obj = pcall(function()
			return game:GetObjects("rbxassetid://" .. clean)[1]
		end)
		if not ok or not obj or not obj:IsA("KeyframeSequence") then continue end

		obj.Parent = containerFolder
		local info = getAnimationInfo(numeric)
		loganimation(info.Name, clean, "Imported")
	end

	local base = "AnimationExports"
	local gameFolder = base .. "/" .. sanitize(gameName)
	local kfFolder = gameFolder .. "/exported-keyframes"
	ensureFolder(base)
	ensureFolder(gameFolder)
	ensureFolder(kfFolder)

	local outputData
	synsaveinstance({
		Object = containerFolder,
		Callback = function(data) outputData = data end,
		__DEBUG_MODE = true,
		mode = "full",
        ReadMe = false,
		SaveBytecode = false
	})
	if outputData then
		writefile(kfFolder .. "/output.rbxm", outputData)
	end
end

local function exportIDs()
	local base="AnimationExports"
	local gameFolder=base.."/"..sanitize(gameName)
	ensureFolder(base)
	ensureFolder(gameFolder)

	local path = gameFolder.."/animation_ids.txt"
	local out = {}
	if isfile(path) then
		for line in readfile(path):gmatch("[^\r\n]+") do
			table.insert(out,line)
		end
	end

	for id in pairs(loggedanimations) do
		local clean = extractanimationid(id)
		local info = getAnimationInfo(tonumber(clean))
		table.insert(out,string.format('"%s" -- %s', clean, info.Name))
	end
	writefile(path, table.concat(out,"\n"))
end

local exportIDsBtn=makeExportOption("Export IDs",0)
exportIDsBtn.MouseButton1Click:Connect(function() clik() exportdropdown.Visible=false exportIDs() end)
local exportKFBtn=makeExportOption("Export Keyframes",30)
exportKFBtn.MouseButton1Click:Connect(function() clik() exportdropdown.Visible=false exportKeyframes() end)

local function animateImportFrame(frame)
	frame.Visible = true
	frame.BackgroundTransparency = 1
	tweenGui(frame, {BackgroundTransparency = 0}, 0.3)
end

local importFrame = Instance.new("Frame")
importFrame.Size = UDim2.new(0, 200, 0, 150)
importFrame.Position = UDim2.new(1, -400, 0, 40)
importFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
importFrame.BorderSizePixel = 0
importFrame.Visible = false
importFrame.Parent = frame

local importBox = Instance.new("TextBox")
importBox.Size = UDim2.new(1, -10, 1, -40)
importBox.Position = UDim2.new(0, 5, 0, 5)
importBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
importBox.TextColor3 = Color3.new(1,1,1)
importBox.Font = Enum.Font.RobotoMono
importBox.TextSize = 14
importBox.ClearTextOnFocus = false
importBox.MultiLine = true
importBox.TextWrapped = true
importBox.PlaceholderText = "Paste animation IDs here, one per line"
importBox.Parent = importFrame
importBox.Text = ""

local doImportBtn = Instance.new("TextButton")
doImportBtn.Size = UDim2.new(1, -10, 0, 30)
doImportBtn.Position = UDim2.new(0, 5, 1, -35)
doImportBtn.BackgroundColor3 = Color3.fromRGB(60,150,60)
doImportBtn.TextColor3 = Color3.new(1,1,1)
doImportBtn.Font = Enum.Font.RobotoMono
doImportBtn.TextSize = 14
doImportBtn.Text = "Import Keyframes"
doImportBtn.Parent = importFrame

doImportBtn.MouseButton1Click:Connect(function()
	clik()
	importKeyframesFromText(importBox.Text)
end)

importbutton.MouseButton1Click:Connect(function()
	clik()
	if importFrame.Visible then
		importFrame.Visible = false
	else
		animateImportFrame(importFrame)
	end
end)

exportbutton.MouseButton1Click:Connect(function()
	clik()
	if exportdropdown.Visible then
		exportdropdown.Visible = false
	else
		exportdropdown.Visible = true
	end
end)

clearbutton.MouseButton1Click:Connect(function()
	clik()
	loggedanimations={}
	for _,v in ipairs(scrollframe:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	scrollframe.CanvasSize = UDim2.new(0,0,0,0)
end)

xbutton.MouseButton1Click:Connect(function()
	clik()
	gui:Destroy()
end)

local minimized = false
local oldSize = frame.Size
minimizebutton.MouseButton1Click:Connect(function()
	clik()
	minimized = not minimized
	if minimized then
		for _, child in ipairs(frame:GetChildren()) do
			if child ~= topbar then
				child.Visible = false
			end
		end
		tweenGui(frame, {Size = UDim2.new(oldSize.X.Scale, oldSize.X.Offset, 0, 30)}, 0.25)
		minimizebutton.Text = "+"
	else
		for _, child in ipairs(frame:GetChildren()) do
			if child ~= topbar then
				child.Visible = true
			end
		end
		tweenGui(frame, {Size = oldSize}, 0.25)
		minimizebutton.Text = "–"
	end
end)
