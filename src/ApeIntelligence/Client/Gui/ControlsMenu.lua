local SoundService = game:GetService("SoundService")

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local ButtonGroups = require("ButtonGroups")
local ButtonBase = require("ButtonBase")
local ScreenCoverStatic = require("ScreenCover")
local MessageSpawnerStatic = require("MessageSpawner")
local Maid = require("Maid")

local KeybindMenu = {}
KeybindMenu.__index = KeybindMenu
KeybindMenu.TweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Quad)

local MessageProp = {
	TextColor3 = Color3.fromRGB(255, 255, 255); BackgroundTransparency = 1; Font = Enum.Font.Oswald;
	AnchorPoint = Vector2.new(.5, .5); Size = UDim2.new(.5, 0, .2, 0); Position = UDim2.new(.5, 0, .5, 0);
	Visible = false; TextScaled = true; TextTransparency = 1;
}
local ScreenCover = ScreenCoverStatic.new()
local MessageSpawner = MessageSpawnerStatic.new(ScreenCover.Frame, MessageProp)

local BackSound = Instance.new("Sound")
BackSound.SoundId = "rbxassetid://2773894926"
BackSound.Volume = 1

KeybindMenu.ButtonProperties = {
	HoverSound = {SoundId = 2773895920, Volume = .5};
	ClickSound = {SoundId = 2773894365, Volume = 1};

	BaseProperties = {TextColor3 = Color3.fromRGB(255, 255, 255)};
	FinishedProperties = {TextColor3 = Color3.fromRGB(255, 10, 10)};

	PossibleChilren = nil;
}
KeybindMenu.CollumProperties = {
	BaseProperties = {BackgroundTransparency = 1};
	FinishedProperties = {BackgroundTransparency = 0};

	PossibleChildren = nil;
}

local function CreateTextButton(Text, Name)
	local TextButton = Instance.new("TextButton")
	TextButton.AutoButtonColor = false
	TextButton.BackgroundTransparency = 1
	TextButton.Position = UDim2.new(.5, 0, 0, 0)
	TextButton.Size = UDim2.new(.5, 0, 1, 0)
	TextButton.Font = Enum.Font.Oswald
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

local function CreateCollum(Text, Name, Description)
	local Frame = Instance.new("Frame")
	Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Frame.BackgroundTransparency = 1
	Frame.BorderSizePixel = 0
	Frame.Name = "Contiainer"

	local FrameDetail = Instance.new("Frame")
	FrameDetail.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FrameDetail.BorderSizePixel = 0
	FrameDetail.AnchorPoint = Vector2.new(.5, .5)
	FrameDetail.Position = UDim2.new(.5, 0, .5, 0)
	FrameDetail.Size = UDim2.new(.002, 0, .8, 0)
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
	GridLayout.CellSize = UDim2.new(1, 0, .1, 0)	
	return GridLayout
end

function KeybindMenu.new(Gui, KeybindGroup)
	assert(Gui:IsA("Frame") or Gui:IsA("ScrollingFrame"))

	local self = setmetatable({}, KeybindMenu)
	local TextSizeConstraint = Instance.new("UITextSizeConstraint")
	TextSizeConstraint.MaxTextSize = 50

	self.ButtonGroup = ButtonGroups.new()
	self.Maid = Maid.new()

	self.IsKeyFocused = false
	self.Gui = Gui

	self.Maid.DestroyButtons = self.ButtonGroup
	TextSizeConstraint.Parent = MessageSpawner.TextLabel

	local GridLayout = CreateGridLayout()
	GridLayout.Parent = self.Gui

	for Name, Table in pairs(KeybindGroup.Map) do
		--local String = UserInputService:GetStringForKeyCode(Table.Key) -- this doesnt return for some reason(i must be dumb)
		local Collum = CreateCollum(string.upper(Table.Key.Name), Name, string.upper(Name..":"))
		local Button = Collum:FindFirstChildOfClass("TextButton")
		Collum.Parent = self.Gui

		self.ButtonGroup:CreateAndAddButton(Button, self.ButtonProperties, self.TweenInfo, function()
			KeybindGroup:TrackNewKeyFromName(Name)
		end)

		local FrameBase = ButtonBase.new(Collum, self.CollumProperties, self.TweenInfo)
		FrameBase:ConnectHovers()
	end

	KeybindGroup.EnterKeyFocus:Connect(function(Name)
		self.IsKeyFocused = true
		MessageSpawner:SendMessage(string.upper("please select a key not already mapped | esc to cancel"))
		ScreenCover:FreeHand(.4, .2)
	end)

	KeybindGroup.LeaveKeyFocus:Connect(function(Result, Name, Key)
		self.IsKeyFocused = false
		MessageSpawner:Hide()
		ScreenCover:ShowScreen(.2)
	end)

	KeybindGroup.KeyChange:Connect(function(Name, Keycode)
		local TextButton = self.Gui:FindFirstChild(Name, true)

		if TextButton and TextButton:IsA("TextButton") then
			self.ButtonGroup:ManualDeselect(TextButton)
			if Keycode ~= "Cancelled" then
				TextButton.Text = string.upper(Keycode.Name)
			else
				SoundService:PlayLocalSound(BackSound)
			end
		end
	end)

	return self
end

function KeybindMenu:IsKeyFocused()
	return self.IsKeyFocused
end

function KeybindMenu:Destroy()
	self.Maid:DoCleaning()
end

return KeybindMenu