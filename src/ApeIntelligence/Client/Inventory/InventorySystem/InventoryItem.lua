local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage.Assets

local TemplateIcon = Assets.Gui.Inventory.ItemPath

local require = require(ReplicatedStorage.ApeIntelligence)
local DraggableBar = require("DraggableBar")

local InventoryItem = {}
InventoryItem.__index = InventoryItem

function InventoryItem.new(Object)
	local IsValid = InventoryItem:ValidateItem(Object)

	if not IsValid then
		return
	end

	local Instance = Object:FindFirstChild("Instance")
	local Type = Object:FindFirstChild("Type")
	local ImageId = Object:FindFirstChild("ImageId")

	local GuiObject = TemplateIcon:Clone()
	GuiObject.Position = UDim2.fromScale(.5, .5)
	GuiObject.Size = UDim2.new(1, 0, 1, 0)
	GuiObject.ItemIcon.Image = "rbxassetid://"..(ImageId.Value and ImageId.Value or "") -- question mark image

	local self = setmetatable({}, InventoryItem)
	self.Equipped = false

	self.Type = Type.Value
	self.Instance = Instance
	--self.EquippedAt = nil

	local _, Name = next(string.split(Object.Name, "+"))
	self.Name = Name
	self.RawSetName = Object.Name

	self.GuiObject = GuiObject

	self.DraggableObject = DraggableBar.new(GuiObject, GuiObject)

	return self
end

function InventoryItem:SetInputEndedCallback(Callback)
	self.DraggableObject:SetInputEndedCallback(Callback)
end

function InventoryItem:GiveNode(Node)
	if self.CurrentNode then
		self.CurrentNode:SetOccupant(nil)
	end

	self.CurrentNode = Node
	self.CurrentNode:SetOccupant(self.GuiObject)

	self:Reset()
	self.GuiObject.Parent = Node()
end

function InventoryItem:Reset()
	if self.CurrentNode then
		self.GuiObject.Position = UDim2.fromScale(.5, .5)
		self.GuiObject.ZIndex = self.CurrentNode().ZIndex + 1
		self.GuiObject.ItemIcon.ZIndex = self.GuiObject.ZIndex
	end
end

function InventoryItem:ValidateItem(Object)
	if not Object:IsA("Model") then
		return false, nil
	end

	if not Object:WaitForChild("Instance", 2)
		or not Object:WaitForChild("Type", 2)
		or not Object:WaitForChild("ImageId", 2) then
		return false, nil
	end

	return true
end

function InventoryItem:IsFocused()
	return self.DraggableObject.Input
end

function InventoryItem:Destroy()
	if self.CurrentNode then
		self.CurrentNode:SetOccupant(nil)
	end
	self.DraggableObject:DisableDragging()
	self.GuiObject:Destroy()

	setmetatable(self, nil)
end

return InventoryItem