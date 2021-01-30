local ViewportFrameHandler = {}
ViewportFrameHandler.__index = ViewportFrameHandler
ViewportFrameHandler.ClassName = "ViewportFrameHandler"
ViewportFrameHandler.AcceptedItems = {
	["Shirt"] = true;
	["Pants"] = true;
	["Humanoid"] = true;
}

local function SafeClone(Object)
	local Arch = Object.Archivable
	Object.Archivable = true
	local Clone = Object:Clone()
	Object.Archivable = Arch
	return Clone
end

local function HandleViewport(ViewportFrame)
	local Camera = Instance.new("Camera")
	ViewportFrame.CurrentCamera = Camera
	return Camera
end

local function CleanItem(Item)
	local Clone = SafeClone(Item)

	local EmptyModel = Instance.new("Model")
	EmptyModel.Name = Item.Name
	local Desc = Clone:GetDescendants()

	if #Desc > 0 then
		for _, Instance in pairs(Desc) do
			if ViewportFrameHandler.AcceptedItems[Instance.ClassName] or Instance:IsA("BasePart") then
				Instance.Parent = EmptyModel
			end
		end
		Clone:Destroy()
	else -- its a single part
		Clone.Parent = EmptyModel
	end

	return EmptyModel
end

function ViewportFrameHandler.new(ViewportFrame, Item)
	assert(typeof(ViewportFrame) == "Instance" and ViewportFrame:IsA("ViewportFrame"), "First parameter must be a ViewportFrame")
	assert(typeof(Item) == "Instance", "Passed Item must be an instance")

	local self = setmetatable({}, ViewportFrameHandler)

	self.ViewportFrame = ViewportFrame

	local ViewportCamera = HandleViewport(self.ViewportFrame)
	self.Camera = ViewportCamera

	local Item = CleanItem(Item)
	self.Item = Item
	self.Item.Parent = self.ViewportFrame

	return self
end

return ViewportFrameHandler