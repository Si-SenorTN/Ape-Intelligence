local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local ButtonGroups = require("ButtonGroups")
local ButtonBase = require("ButtonBase")
local RemoteHover = require("RemoteHover")
local SlideableBar = require("SlideableBar")
local Maid = require("Maid")

local AudioMenu = {}
AudioMenu.__index = AudioMenu
AudioMenu.ClassName = "AudioMenu"
AudioMenu.TweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Quad)

AudioMenu.CollumProperties = {
	BaseProperties = {BackgroundTransparency = 1};
	FinishedProperties = {BackgroundTransparency = 0};
}

AudioMenu.BarProperties = {
	BaseProperties = {BackgroundColor3 = Color3.fromRGB(255, 255, 255)};
	FinishedProperties = {BackgroundColor3 = Color3.fromRGB(255, 10, 10)};
	Info = AudioMenu.TweenInfo;
}

local function CreateLabel(Text)
	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundTransparency = 1
	TextLabel.Position = UDim2.new(0, 0, 0, 0)
	TextLabel.Size = UDim2.new(.5, 0, 1, 0)
	TextLabel.Font = Enum.Font.SourceSansBold
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextScaled = true
	TextLabel.Text = Text
	TextLabel.Name = "KeybindLabel"

	local TextSizeConstraint = Instance.new("UITextSizeConstraint")
	TextSizeConstraint.MaxTextSize = 25
	TextSizeConstraint.Parent = TextLabel

	return TextLabel
end

local function CreateCollum(Name)
	local Frame = Instance.new("Frame")
	Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0
	Frame.Name = "Contiainer"
	
	local FrameDetail = Instance.new("Frame")
	FrameDetail.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FrameDetail.BorderSizePixel = 0
	FrameDetail.AnchorPoint = Vector2.new(.5, 0)
	FrameDetail.Position = UDim2.new(.5, 0, 0, 0)
	FrameDetail.Size = UDim2.new(.002, 0, 1, 0)
	FrameDetail.Name = "Detail"
	FrameDetail.Parent = Frame

	local Label = CreateLabel(Name)
	Label.Parent = Frame

	return Frame
end

local function CreateGridLayout()
	local GridLayout = Instance.new("UIGridLayout")
	GridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	GridLayout.CellSize = UDim2.new(1, 0, .06, 0)	
	return GridLayout
end

function AudioMenu.new(Gui, AudioLibrary)
	assert(Gui:IsA("Frame") or Gui:IsA("ScrollingFrame"))

	local self = setmetatable({}, AudioMenu)

	self.AudioLibrary = AudioLibrary
	self.Maid = Maid.new()
	self.Gui = Gui
	self.ButtonGroup = ButtonGroups.new()
	CreateGridLayout().Parent = self.Gui

	for Name, Table in pairs(self.AudioLibrary) do
		local Collum = CreateCollum(Name)
		Collum.Parent = self.Gui
		local SlideableBarTemp = SlideableBar.new(Collum, Table.SoundGroup.Volume, .3, .4, UDim2.new(.6, 0, .5, 0))
		SlideableBarTemp:Enable()

		local CollumBase = ButtonBase.new(Collum, self.CollumProperties, self.TweenInfo)
		CollumBase:Activate()

		local SlideableBarBase = RemoteHover.new(SlideableBarTemp.SliderBarTemplate, self.BarProperties, SlideableBarTemp.SliderBar)
		SlideableBarBase:Enable()

		SlideableBarTemp.BarValue:GetPropertyChangedSignal("Value"):Connect(function()
			local Value = SlideableBarTemp.BarValue.Value/10
			Table:AdjustSoundLibraryVolume(Value)
		end)
	end

	return self
end

return AudioMenu