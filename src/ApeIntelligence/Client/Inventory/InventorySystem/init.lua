local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InventoryItems = require(script.InventoryItem)

local require = require(ReplicatedStorage.ApeIntelligence)
local Signal = require("Signal")
local Nodes = require("Nodes")
local table = require("Table")

local InventorySystem = setmetatable({}, Nodes)
InventorySystem.__index = InventorySystem

function InventorySystem.new(...)
	local self = setmetatable(Nodes.new(...), InventorySystem)
	self.EquippedSignal = Signal.new()

	self.Items = {}
	self.EquippedItems = {}

	return self
end

function InventorySystem:Add(Object)
	if not Object or self.Items[Object.Name] then return end

	local InvItem = InventoryItems.new(Object)
	if not InvItem then
		return -- item was invalid
	end

	InvItem:SetInputEndedCallback(function()
		local PreviousNode = InvItem.CurrentNode
		local IsNewNode = self:SetToNearestNode(InvItem, PreviousNode)
		local HandName = PreviousNode and PreviousNode().Name

		if PreviousNode and PreviousNode.IsImportant and IsNewNode then
			self.EquippedSignal:Fire(false, HandName, Object.Name)
			self.EquippedItems[HandName] = nil
		end

		if InvItem.CurrentNode.IsImportant and not table.get(self.EquippedItems, InvItem) then
			self.EquippedSignal:Fire(true, InvItem.CurrentNode().Name, Object.Name)
			self.EquippedItems[InvItem.CurrentNode().Name] = InvItem
		end
	end)
	InvItem.DraggableObject:EnableDragging()

	local AnyOpenSlot = self:GetAnyOpenSlot(true)
	InvItem:GiveNode(AnyOpenSlot)

	self.Items[Object.Name] = InvItem

	Object.AncestryChanged:Connect(function(_, Parent)
		if not Parent then
			self:Remove(Object)
		end
	end)

	return InvItem
end

function InventorySystem:Remove(Object)
	if self.Items[Object.Name] then
		if self.Items[Object.Name].CurrentNode and self.Items[Object.Name].CurrentNode.IsImportant then
			self.EquippedSignal:Fire(false, self.Items[Object.Name].CurrentNode().Name)
		end

		self.Items[Object.Name]:Destroy()
		self.Items[Object.Name] = nil
	end
end

function InventorySystem:IsItemFocused()
	for _, Object in pairs(self.Items) do
		if Object:IsFocused() then
			return true
		end
	end
	return false
end

--[[
function InventorySystem:Use(Object)
	--Events.UseItemFromInventory:FireServer(Object.Name)
end

--[[
function InventorySystem:Move(Object, Node)
	if self.Items[Object.Name] then
		
	end
end]]

return InventorySystem