--[[
	-- Snackbar Class
	-- Creates a visual Snackbar at the bottom corner of the screen
	-- Disappears after timeout
	-- There can only be one snackbar on screen at a time

	Calling one snackbar will not pause the thread. The que will 
	pause any incomming Snackbars's until the que ahead of it is
	cleared.
--]]

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local TweenService = game:GetService("TweenService")

local Maid = require("Maid")
local Signal = require("Signal")
local PlayerGui = require("PlayerGui").GetPlayerGui()
local Bootstrap = require("BootstrapPalette")

local SnackTray = PlayerGui:WaitForChild("SnackTray", 4)
-- we'll wait a little bit for the snack tray, if its not there we'll make one
if not SnackTray then
	SnackTray = Instance.new("ScreenGui")
	SnackTray.Name = "SnackTray"
	SnackTray.DisplayOrder = 1
	SnackTray.Parent = PlayerGui
end

local Singleton = {}
Singleton.QueChange = Signal.new()
Singleton.PlayingQue = false
Singleton.Que = {}

local SnackBar = {}
SnackBar.__index = SnackBar
SnackBar.ClassName = "SnackBar"
SnackBar.Height = 48
SnackBar.MinimumWidth = 288
SnackBar.MaximumWidth = 700
SnackBar.TextWidthOffset = 24
SnackBar.Position = UDim2.new(1, -10, 1, -10 - SnackBar.Height)
SnackBar.FadeTime = .16

-- use off colors(more appealing to the eyes)
SnackBar.DarkTheme = Color3.fromRGB(20, 20, 20)
SnackBar.LightTheme = Color3.fromRGB(249, 249, 249)

function SnackBar:CreateSnackbar(Text, Theme, Timeout, TextStyle)
	if TextStyle and Bootstrap[TextStyle] then
		TextStyle = Bootstrap[TextStyle].RGB
	elseif TextStyle then
		TextStyle = Bootstrap.White.RGB
	else
		TextStyle = Theme == "Light" and self.DarkTheme or self.LightTheme
	end

	local self = setmetatable({}, SnackBar)

	self.Maid = Maid.new()

	local Container = Instance.new("ImageButton")
	Container.Name = "Snackbar"
	Container.Size = UDim2.new(0, 100, 0, self.Height)
	Container.BorderSizePixel = 0
	Container.Position = self.Position
	Container.Archivable = false
	Container.AutoButtonColor = false
	Container.BackgroundColor3 = Theme == "Light" and self.LightTheme or self.DarkTheme -- defalut to dark theme
	Container.ClipsDescendants = true
	Container.ZIndex = 10
	self.Gui = Container

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Size = UDim2.new(1, -self.TextWidthOffset * 2, 0, 16)
	Label.Position = UDim2.new(0, self.TextWidthOffset, 0, 16)
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.TextYAlignment = Enum.TextYAlignment.Center
	Label.Name = "SnackbarLabel"
	Label.TextColor3 = TextStyle
	Label.Font = Enum.Font.SourceSansBold
	Label.Text = Text
	Label.TextScaled = true
	Label.ZIndex = self.Gui.ZIndex - 1
	self.TextLabel = Label
	self.TextLabel.Parent = self.Gui

	local FadeBar = Instance.new("Frame")
	FadeBar.BackgroundColor3 = Theme == "Light" and self.DarkTheme or self.LightTheme
	FadeBar.BorderSizePixel = 0
	FadeBar.AnchorPoint = Vector2.new(0, 1)
	FadeBar.Name = "SnackbarFade"
	FadeBar.ZIndex = self.Gui.ZIndex - 1
	FadeBar.Parent = self.Gui
	-- fade bar is internal so we wont make a self value for it

	local Width = math.clamp(self.TextLabel.TextBounds.X + self.TextWidthOffset * 2, self.MinimumWidth, self.MaximumWidth)
	local Pos = self.Position + UDim2.new(0, -Width, 0, 0)

	-- scale and size properly
	self.Gui.Size = UDim2.fromOffset(Width, self.Height)
	self.Gui.Position = Pos

	FadeBar.Size = UDim2.new(1, 0, .05, 0) -- cant use .fromScale because offset values persist(i think?)
	FadeBar.Position = UDim2.new(0, 0, 1, 0)

	local Info = TweenInfo.new(Timeout or 3, Enum.EasingStyle.Linear)
	self.Tween = TweenService:Create(FadeBar, Info, {Size = UDim2.fromScale(0, FadeBar.Size.Y.Scale)})

	table.insert(Singleton.Que, self)

	coroutine.wrap(RenderQue)()
end

function RenderQue()
	if Singleton.PlayingQue then return end
	Singleton.PlayingQue = true
	
	local _, Snackbars = next(Singleton.Que)
	while Snackbars do
		Snackbars.Gui.Parent = SnackTray
		Snackbars.Tween:Play()

		Snackbars.Tween.Completed:Wait()
		Singleton.QueChange:Fire(Snackbars)

		_, Snackbars = next(Singleton.Que)
	end
	Singleton.PlayingQue = false
end

function FadeSnackbar(SnackbarGui, Speed, Properties)
	assert(typeof(SnackbarGui) == "Instance" and SnackbarGui:IsA("GuiBase"), "SnackbarGui must be a GuiBase")

	local Info = TweenInfo.new(Speed, Enum.EasingStyle.Linear)
	-- only properties of SnackBarUI should be TextLabel
	local BaseProperties = {
		Position = SnackbarGui.Position + UDim2.fromOffset(0, -30);
		BackgroundTransparency = 1;
		ImageTransparency = 1
	}
	local Tween = TweenService:Create(SnackbarGui, Info, BaseProperties) -- tween it up 30 pixels

	local PropertiesTable = Properties or {
		["TextLabel"] = {TextTransparency = 1; TextStrokeTransparency = 1;};
	}

	for Index, GuiBase in pairs(SnackbarGui:GetDescendants()) do
		if GuiBase:IsA("GuiBase") and PropertiesTable[GuiBase.ClassName] then
			local DescTween = TweenService:Create(GuiBase, Info, PropertiesTable[GuiBase.ClassName])
			DescTween:Play()
		end
	end
	Tween:Play()
	Tween.Completed:Wait()
end

Singleton.QueChange:Connect(function(Snackbar)
	local Find = table.find(Singleton.Que, Snackbar)

	if Find then
		table.remove(Singleton.Que, Find)
		FadeSnackbar(Snackbar.Gui, .2)
		Snackbar.Maid:DoCleaning()
	end
end)

return SnackBar
