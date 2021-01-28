local UserInputService = game:GetService("UserInputService")

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local Maid = require("Maid")

local DraggableBar = {}
DraggableBar.__index = DraggableBar
DraggableBar.ClassName = "DraggableBar"

function DraggableBar.new(Bar, Gui, InputEndedCallback)
	assert(typeof(Bar) == "Instance" and typeof(Gui) == "Instance")
	assert(Bar:IsA("GuiBase") and Gui:IsA("GuiBase"))

	local self = setmetatable({}, DraggableBar)

	self.Maid = Maid.new()

	self.Input = false

	self.Bar = Bar
	self.Gui = Gui

	self.InputEndedCallback = InputEndedCallback
	--self:EnableDragging() -- default behavior

	return self
end

function DraggableBar:EnableDragging()
	self:DisableDragging() -- clean up states

	local StartPos = self.Gui.Position
	local DragStart

	local function UpdatePosition(InputObject)
		local Delta = InputObject.Position - DragStart

		local OffsetX = Delta.X + StartPos.X.Offset
		local OffsetY = Delta.Y + StartPos.Y.Offset

		self.Gui.Position = UDim2.new(self.Gui.Position.X.Scale, OffsetX, self.Gui.Position.Y.Scale, OffsetY)
	end

	self.Maid:GiveTask(self.Bar.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType ~= Enum.UserInputType.MouseButton1
			and InputObject.UserInputType ~= Enum.UserInputType.Touch then return end

		DragStart = InputObject.Position
		StartPos = self.Gui.Position
		self.Input = true

		self.Maid.InputEnded = self.Bar.InputEnded:Connect(function(InputEndedObject)
			if InputEndedObject.UserInputType ~= Enum.UserInputType.MouseButton1
				and InputEndedObject.UserInputType ~= Enum.UserInputType.Touch then return end

			self.Input = false
			self.Maid.InputEnded = nil
			self.Maid.InputChanged = nil
			if self.InputEndedCallback then
				self.InputEndedCallback(StartPos, self.Gui.Position)
			end
		end)

		self.Maid.InputChanged = UserInputService.InputChanged:Connect(function(InputChangedObject)
			if self.Input then
				UpdatePosition(InputChangedObject)
			end
		end)
	end))
end

function DraggableBar:SetInputEndedCallback(Callback)
	self.InputEndedCallback = Callback
end

function DraggableBar:DisableDragging()
	self.Maid:DoCleaning()

	if self.Input and self.InputEndedCallback then
		self.InputEndedCallback(self.Gui.Position, self.Gui.Position)
	end
	self.Input = false
end

return DraggableBar