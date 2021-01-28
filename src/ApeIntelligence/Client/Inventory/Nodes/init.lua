local NodesStatic = {}
NodesStatic.__index = NodesStatic

local NodeClass = require(script.Node)

-- looking for a uniform set of nodes to use as a position and occupant reference point
function NodesStatic.new(...)
	return setmetatable({
		Nodes = {};
		TopParents = {...};
	}, NodesStatic)
end

function NodesStatic:IsTopParentVisible(Node)
	for _, TopParent in pairs(self.TopParents) do
		if Node():IsDescendantOf(TopParent) and TopParent.Visible == true then
			return true
		end
	end
	return false
end

function NodesStatic:AddNode(GuiObject, IsImportant, Type)
	if not GuiObject:IsA("GuiBase") then return end
	local NodeObject = NodeClass.new(GuiObject, IsImportant)

	if Type then
		NodeObject:SetHolderType(Type)
	end

	table.insert(self.Nodes, NodeObject)

	return NodeObject
end

function NodesStatic:GetNode(Number)
	return self.Nodes[Number]
end

function NodesStatic:SetToNearestNode(InvItem, PreviousNode)
	local GuiObject = InvItem.GuiObject
	local Nearest, Distance, TestDist

	for _, Node in pairs(self.Nodes) do
		local CurrentDist = (Node().AbsolutePosition - GuiObject.AbsolutePosition).Magnitude

		if not Distance or Distance > CurrentDist then
			Distance = CurrentDist
			Nearest = Node

			TestDist = Vector2.new(
				math.abs(Node().AbsolutePosition.X - GuiObject.AbsolutePosition.X),
				math.abs(Node().AbsolutePosition.Y - GuiObject.AbsolutePosition.Y)
			)
		end
	end

	if Nearest == PreviousNode or not self:IsTopParentVisible(Nearest) or self:IsNodeOccupied(Nearest) then
		InvItem:Reset()
		return false, 0, Vector2.new()
	else
		InvItem:GiveNode(Nearest)
		return true, Distance, TestDist
	end
end

function NodesStatic:IsNodeOccupied(Node)
	return Node.IsOccupied
end

function NodesStatic:GetAnyOpenSlot(IgnoreVisiblity)
	for _, Node in pairs(self.Nodes) do
		if Node.IsImportant or (not IgnoreVisiblity and not self:IsTopParentVisible(Node)) then
			continue
		end

		if not self:IsNodeOccupied(Node) then
			return Node
		end
	end
	return nil
end

return NodesStatic