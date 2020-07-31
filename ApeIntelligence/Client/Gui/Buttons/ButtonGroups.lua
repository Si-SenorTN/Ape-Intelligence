local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local ButtonBase = require("ButtonBase")
local Signal = require("Signal")
local table = require("Table")
local Maid = require("Maid")

local ButtonGroups = {}
ButtonGroups.__index = ButtonGroups
ButtonGroups.ClassName = "ButtonGroup"

function ButtonGroups.new()
	local self = setmetatable({}, ButtonGroups)

	self.MainMaid = Maid.new()
	self.ConnectionMaid = Maid.new()

	self.SelectionChange = Signal.new()
	self.SelectedButton = nil
	self.PrevSelected = nil

	self.Buttons = {}

	self.SelectionChange:Connect(function(SelectedButton)
		if not SelectedButton then return end
		SelectedButton:OnMouseEnter(true)
		SelectedButton.Selected = true

		if self.PrevSelected == nil then
			self.PrevSelected = SelectedButton
		elseif self.PrevSelected ~= SelectedButton then
			self.PrevSelected.Selected = false
			self.PrevSelected:OnMouseLeave()
			self.PrevSelected = SelectedButton
		end
	end)

	return self
end

function ButtonGroups:HandleGroup()
	self:Disable() -- clean everything

	for _, ButtonBase in pairs(self.Buttons) do
		ButtonBase:Activate()

		self.ConnectionMaid:GiveTask(ButtonBase.Base.Activated:Connect(function()
			ButtonBase:RunCallback()
			self.SelectedButton = ButtonBase
			self.SelectionChange:Fire(self.SelectedButton)
		end))
	end
end

function ButtonGroups:FindButtonInGroup(Base)
	local Find
	for _, Table in pairs(self.Buttons) do
		if Table.Base == Base then
			return Table
		end
	end
end

function ButtonGroups:ManualDeselect(Base)
	local Find = self:FindButtonInGroup(Base)
	if not Find then return end
	self.SelectionChange:Fire(nil)
	self.PrevSelected = nil
	Find.Selected = false
	Find:OnMouseLeave()
end

function ButtonGroups:ManualSelect(Base)
	local Find = self:FindButtonInGroup(Base)
	if not Find then return end
	Find:RunCallback(true)
	self.SelectedButton = Find
	self.SelectionChange:Fire(self.SelectedButton)
end

function ButtonGroups:AddButtonToGroup(ButtonBase)
	assert(type(ButtonBase) == "table" and ButtonBase.ClassName == "ButtonBase")
	table.insert(self.Buttons, ButtonBase)
	self.MainMaid:GiveTask(ButtonBase.Base)
	self:HandleGroup()
end

function ButtonGroups:CreateAndAddButton(instance, Properties, Info, Callback)
	local NewBase = ButtonBase.new(instance, Properties, Info, Callback)
	table.insert(self.Buttons, NewBase)
	self.MainMaid:GiveTask(NewBase.Base)
	self:HandleGroup()
end

function ButtonGroups:ConnectToChangeSignal(func)
	assert(typeof(func) == "function")
	self.SelectionChange:Connect(func)
end

function ButtonGroups:Disable()
	for _, ButtonBase in pairs(self.Buttons) do
		ButtonBase:Deactivate()
	end
	self.SelectedButton = nil
	self.PrevSelected = nil
	self.ConnectionMaid:DoCleaning()
end

function ButtonGroups:Destroy()
	self.ConnectionMaid:DoCleaning()
	self.MainMaid:DoCleaning()
	self.SelectedButton = nil
	self.PrevSelected = nil
	self.Buttons = {}
end

return ButtonGroups
