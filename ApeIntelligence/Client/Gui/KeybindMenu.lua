local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local ButtonGroups = require("ButtonGroups")
local ButtonBase = require("ButtonBase")
local Maid = require("Maid")

local KeybindMenu = {}
KeybindMenu.__index = KeybindMenu
KeybindMenu.TweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Quad)

KeybindMenu.ButtonProperties = {
	HoverSound = {SoundId = 745109242, Volume = .3};
	ClickSound = {SoundId = 1248196659, Volume = 2};

	BaseProperties = {TextColor3 = Color3.fromRGB(255, 255, 255)};
	FinishedProperties = {TextColor3 = Color3.fromRGB(255, 10, 10)};
}
KeybindMenu.CollumProperties = {
	BaseProperties = {BackgroundTransparency = 1};
	FinishedProperties = {BackgroundTransparency = 0};
}

local function CreateTextButton(Text, Name)
	local TextButton = Instance.new("TextButton")
	TextButton.AutoButtonColor = false
	TextButton.BackgroundTransparency = 1
	TextButton.Position = UDim2.new(.5, 0, 0, 0)
	TextButton.Size = UDim2.new(.5, 0, 1, 0)
	TextButton.Font = Enum.Font.SourceSansBold
	TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.TextScaled = true
	TextButton.Text = Text
	TextButton.Name = Name

	local TextSizeConstraint = Instance.new("UITextSizeConstraint")
	TextSizeConstraint.MaxTextSize = 30
	TextSizeConstraint.Parent = TextButton

	return TextButton
end

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

local function CreateCollum(Text, Name, Description)
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

	local Label = CreateLabel(Description)
	Label.Parent = Frame

	local Button = CreateTextButton(Text, Name)
	Button.Parent = Frame

	return Frame
end

local function CreateGridLayout()
	local GridLayout = Instance.new("UIGridLayout")
	GridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
	GridLayout.CellSize = UDim2.new(1, 0, .06, 0)	
	return GridLayout
end

function KeybindMenu.new(Gui, KeybindMap)
	assert(Gui:IsA("Frame") or Gui:IsA("ScrollingFrame"))

	local self = setmetatable({}, KeybindMenu)

	self.KeybindMap = KeybindMap
	self.Maid = Maid.new()
	self.Gui = Gui
	self.ButtonGroup = ButtonGroups.new()
	self.Maid.DestroyButtons = self.ButtonGroup

	local GridLayout = CreateGridLayout()
	GridLayout.Parent = self.Gui

	for Name, Table in pairs(self.KeybindMap.Map) do
		--local String = UserInputService:GetStringForKeyCode(Table.Key) -- this doesnt return for some reason(i must be dumb)
		local Collum = CreateCollum(string.upper(Table.Key.Name), Name, string.upper(Name..": This is a sample button"))
		local Button = Collum:FindFirstChildOfClass("TextButton")
		Collum.Parent = self.Gui

		self.ButtonGroup:CreateAndAddButton(Button, self.ButtonProperties, self.TweenInfo, function()
			self.KeybindMap:TrackNewKeyFromName(Name)
		end)

		local FrameBase = ButtonBase.new(Collum, self.CollumProperties, self.TweenInfo)
		FrameBase:Activate()
	end

	self.KeybindMap.KeyChange:Connect(function(Name, Keycode)
		local TextButton = self.Gui:FindFirstChild(Name, true)

		if TextButton and TextButton:IsA("TextButton") then
			self.ButtonGroup:ManualDeselect(TextButton)
			if Keycode ~= "Cancelled" then
				TextButton.Text = string.upper(Keycode.Name)
			end
		end
	end)

	return self
end

function KeybindMenu:Disable()
	self.Maid:DoCleaning()
end

return KeybindMenu