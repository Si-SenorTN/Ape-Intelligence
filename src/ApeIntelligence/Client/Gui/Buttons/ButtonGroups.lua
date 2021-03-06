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
	
	for _, Base in pairs(self.Buttons) do
		Base:ConnectHovers()
		
		self.ConnectionMaid:GiveTask(Base.Base.Activated:Connect(function()
			Base:RunCallback()
			self.SelectedButton = Base
			self.SelectionChange:Fire(self.SelectedButton)
		end))
	end
end

function ButtonGroups:FindButtonInGroup(Base)
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

function ButtonGroups:AddButtonToGroup(BaseObject)
	assert(type(BaseObject) == "table" and BaseObject.ClassName == "ButtonBase")
	table.insert(self.Buttons, BaseObject)
	self.MainMaid:GiveTask(BaseObject.Base)
	self:HandleGroup()
end

function ButtonGroups:CreateAndAddButton(instance, Properties, Info, Callback)
	local NewBase = ButtonBase.new(instance, Properties, Info, Callback)
	table.insert(self.Buttons, NewBase)
	self.MainMaid:GiveTask(NewBase.Base)
	self:HandleGroup()
end

function ButtonGroups:ConnectToChangeSignal(func)
	assert(type(func) == "function")
	self.SelectionChange:Connect(func)
end

function ButtonGroups:Disable()
	for _, BaseObject in pairs(self.Buttons) do
		BaseObject:Deactivate()
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