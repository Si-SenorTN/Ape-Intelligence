local Node = {}

function Node.new(GuiBase, IsImporant)
	local self = setmetatable({}, {
		__call = function() return GuiBase end
	})

	self.IsImportant = IsImporant
	self.IsOccupied = false
	self.Occupant = nil

	function self:SetOccupant(GuiBase)
		self.Occupant = GuiBase
		self.IsOccupied = GuiBase and true or false
	end

	function self:SetHolderType(Type)
		self.Type = Type
	end

	return self
end

return Node