local UserInputService = game:GetService("UserInputService")

local require = require(game:GetService("ReplicatedStorage").ApeIntelligence)
local BuildToolTip = require("BuildToolTip")
local BootstrapPalette = require("BootstrapPalette")
local Maid = require("Maid")
local table = require("Table")

local ToolTip = {}
ToolTip.__index = ToolTip

function ToolTip.new(Parent)
	local self = setmetatable({}, ToolTip)
	self.Maid = Maid.new()
	self.ToolTip = BuildToolTip()
	self.ToolTip.Visible = false
	self.ToolTip.Parent = Parent
	self.CurrentHovered = nil
	self.Contents = {}

	return self
end

function ToolTip:ConnectAllGuis()
	self:Disconnect() -- cleanup state

	local ViewportSize = workspace.CurrentCamera.ViewportSize
	local Padding = Vector2.new(30, 20)

	self.Maid:GiveTask(UserInputService.InputChanged:Connect(function(InputObject)
		if self.CurrentHovered and (InputObject.UserInputType == Enum.UserInputType.Touch
			or InputObject.UserInputType == Enum.UserInputType.MouseMovement) then
			-- position context menu offset to mouse/clamp it to certain bounds on screen
			local Position = InputObject.Position
			local AbsSize = self.ToolTip.AbsoluteSize
			local RelativeOffset = AbsSize/2 + Padding
			local ClampedX, ClampedY = math.clamp(Position.X + RelativeOffset.X, 0, ViewportSize.X - AbsSize.X/2), math.clamp(Position.Y + RelativeOffset.Y, 0, ViewportSize.Y - AbsSize.Y/2)

			self.ToolTip.Position = UDim2.new(0, ClampedX, 0, ClampedY)
		end
	end))

	for Index, Data in pairs(self.Contents) do
		local GuiBase, Title, Description = Data.GuiBase, Data.Title, Data.Description

		self.Maid:GiveTask(GuiBase.InputBegan:Connect(function(InputObject)
			if InputObject.UserInputType == Enum.UserInputType.Touch
				or InputObject.UserInputType == Enum.UserInputType.MouseMovement then
				self.CurrentHovered = GuiBase

				local BootstrapStyle = (Data.Style and BootstrapPalette[Data.Style]) or BootstrapPalette.White
				self.ToolTip.Visible = true
				self.ToolTip.Title.Text = string.upper(Title)
				self.ToolTip.Title.TextColor3 = BootstrapStyle.RGB
				self.ToolTip.Body.Text = string.upper(Description)

				local Width = math.clamp(self.ToolTip.Body.TextBounds.X + 24 * 2, 120, 700)
				self.ToolTip.Size = UDim2.new(0, Width, self.ToolTip.Size.Y.Scale, 0)
			end

			local InputEndedTrashId
			InputEndedTrashId = self.Maid:GiveTask(GuiBase.InputEnded:Connect(function(InputEndedObject)
				if InputEndedObject.UserInputType == Enum.UserInputType.Touch
					or InputEndedObject.UserInputType == Enum.UserInputType.MouseMovement then
					self.CurrentHovered = nil
					self.ToolTip.Visible = false

					self.Maid[InputEndedTrashId] = nil
				end
			end))
		end))
	end
end

function ToolTip:Edit(GuiBase, Title, Description, TitleStyle)
	local Index = table.getRecursive(self.Contents, GuiBase)
	self.Contents[Index] = {
		GuiBase = GuiBase;
		Title = Title;
		Description = Description;
		Style = TitleStyle;
	}

	if self.CurrentHovered == GuiBase then
		local BootstrapStyle = BootstrapPalette[TitleStyle] or BootstrapPalette.White
		self.ToolTip.Title.Text = string.upper(Title)
		self.ToolTip.Title.TextColor3 = BootstrapStyle.RGB
		self.ToolTip.Body.Text = string.upper(Description)
	end

	self:ConnectAllGuis()
end

function ToolTip:AddGuiBase(GuiBase, Title, Description, TitleStyle)
	table.insert(self.Contents, #self.Contents + 1, {
		GuiBase = GuiBase;
		Title = Title;
		Description = Description;
		Style = TitleStyle;
	})
	self:ConnectAllGuis()
end

function ToolTip:RemoveGuiBase(GuiBase)
	GuiBase = table.getRecursive(self.Contents, GuiBase)
	table.remove(self.Contents, GuiBase)
end

function ToolTip:Disconnect()
	self.CurrentHovered = nil
	self.Maid:DoCleaning()
end

return ToolTip