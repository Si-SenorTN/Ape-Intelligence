local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local ButtonBase = require("ButtonBase")
local RemoteHover = require("RemoteHover")
local SlideableBar = require("SlideableBar")

local AudioMenu = {}
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
	TextLabel.Font = Enum.Font.Oswald
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
	Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0
	Frame.Name = "Contiainer"

	local FrameDetail = Instance.new("Frame")
	FrameDetail.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FrameDetail.BorderSizePixel = 0
	FrameDetail.AnchorPoint = Vector2.new(.5, 0)
	FrameDetail.Position = UDim2.new(.5, 0, 0, 0)
	FrameDetail.Size = UDim2.new(.002, 0, .8, 0)
	FrameDetail.Name = "Detail"
	FrameDetail.Parent = Frame

	local Label = CreateLabel(Name)
	Label.Parent = Frame

	return Frame
end

local function CreateGridLayout()
	local GridLayout = Instance.new("UIGridLayout")
	GridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	GridLayout.CellSize = UDim2.new(1, 0, .05, 0)	
	return GridLayout
end

function AudioMenu.new(Gui, AudioDirectory)
	assert(Gui:IsA("Frame") or Gui:IsA("ScrollingFrame"))

	CreateGridLayout().Parent = Gui

	for Name, SoundObject in pairs(AudioDirectory:GetAll()) do
		local Collum = CreateCollum(string.upper(Name))
		Collum.Parent = Gui
		local SlideableBarTemp = SlideableBar.new(Collum, SoundObject.Directory.Volume, .3, .4, UDim2.new(.6, 0, .5, 0))
		SlideableBarTemp:Enable()

		local CollumBase = ButtonBase.new(Collum, AudioMenu.CollumProperties, AudioMenu.TweenInfo)
		CollumBase:ConnectHovers()

		local SlideableBarBase = RemoteHover.new(SlideableBarTemp.SliderBarTemplate, AudioMenu.BarProperties, SlideableBarTemp.SliderBar)
		SlideableBarBase:Enable()

		SlideableBarTemp.BarValue:GetPropertyChangedSignal("Value"):Connect(function()
			SoundObject.Directory.Volume = SlideableBarTemp.BarValue.Value/10
		end)
	end
end

return AudioMenu