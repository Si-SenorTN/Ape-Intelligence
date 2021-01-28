local require = require(game:GetService("ReplicatedStorage").ApeIntelligence)
local BaseObject = require("BaseObject")
local table = require("Table")

local SettingSwitch = setmetatable({}, BaseObject)
SettingSwitch.__index = SettingSwitch

function SettingSwitch.new(Parent, Name, Options)
	local self = setmetatable(BaseObject.new(), SettingSwitch)

	self.Switch = script.SwitchTemplate:Clone()
	self.Switch.Text = string.upper(Name)

	self.PageLayout = self.Switch:FindFirstChildWhichIsA("UIPageLayout", true)
	self.Options = Options

	local Canvas = self.PageLayout.Parent
	local ToggleContainer = Canvas.Parent
	local SwitchLeft, SwitchRight = ToggleContainer.ToggleLeft, ToggleContainer.ToggleRight

	for Index, SettingObject in ipairs(Options) do
		local OptionName = SettingObject.Name

		local SettingLabel = Instance.new("TextLabel")
		SettingLabel.BackgroundTransparency = 1
		SettingLabel.Size = UDim2.new(1, 0, 1, 0)
		SettingLabel.TextColor3 = Color3.new(1, 1, 1)
		SettingLabel.Text = string.upper(OptionName)
		SettingLabel.TextScaled = true
		SettingLabel.Font = Enum.Font.Oswald
		SettingLabel.LayoutOrder = Index

		local TextSizeConstraint = Instance.new("UITextSizeConstraint")
		TextSizeConstraint.MaxTextSize = 30
		TextSizeConstraint.Parent = SettingLabel

		SettingLabel.Parent = Canvas
	end

	self.Maid:GiveTask(SwitchLeft.Activated:Connect(function()self.PageLayout:Previous()end))
	self.Maid:GiveTask(SwitchRight.Activated:Connect(function()self.PageLayout:Next()end))

	self.Maid:GiveTask(self.Switch)
	self.Switch.Parent = Parent

	local function Update()
		local Find = self:GetOptionIndex(self.PageLayout.CurrentPage.Text)
		if Find then
			Find.Callback()
		end
	end

	self.Select = function(Index)
		if Options[Index] then
			self.PageLayout:JumpToIndex(Index)
		end
	end

	self.Maid:GiveTask(self.PageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(Update))

	return self
end

function SettingSwitch:ConnectToPageChange(func)
	self.Maid:GiveTask(self.PageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(function()
		local CurrentPage, CurrentIndex = self.PageLayout.CurrentPage, self.PageLayout.CurrentIndex
		func(CurrentPage, CurrentIndex)
	end))
end

function SettingSwitch:GetOptionIndex(Name)
	for Index, Tab in pairs(self.Options) do
		if Tab.Name:lower() == Name:lower() then
			return Tab
		end
	end
	return nil
end

return SettingSwitch