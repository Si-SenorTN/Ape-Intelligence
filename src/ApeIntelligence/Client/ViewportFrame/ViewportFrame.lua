--!nonstrict
local RunService = game:GetService("RunService")

local ViewportFrameHandler = {}
ViewportFrameHandler.__index = ViewportFrameHandler
ViewportFrameHandler.ClassName = "ViewportFrameHandler"
ViewportFrameHandler.AcceptedItems = {
	["Shirt"] = true;
	["Pants"] = true;
	["Humanoid"] = true;
	["ShirtGraphic"] = true;
	["BasePart"] = true;
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
	Camera.Parent = ViewportFrame
	return Camera
end

local function CleanItem(Item)
	local Clone = SafeClone(Item)

	local EmptyModel = Instance.new("Model")
	EmptyModel.Name = Item.Name
	local Desc = Clone:GetDescendants()

	if #Desc > 0 then
		for _, Instance in pairs(Desc) do
			if ViewportFrameHandler.AcceptedItems[Instance.ClassName] then
				Instance.Parent = EmptyModel
			end
		end
		Clone:Destroy()
	else -- its a single part
		Clone.Parent = EmptyModel
	end

	return EmptyModel
end

function ViewportFrameHandler.new(ViewportFrame: ViewportFrame, Item: Instance?)
	local self = setmetatable({}, ViewportFrameHandler)

	self.ViewportFrame = ViewportFrame
	self.Camera = self:CreateCamera(self.ViewportFrame)
	
	if Item then
		local Item = CleanItem(Item)
		self.Item = Item
		self.Item.Parent = self.ViewportFrame
	end

	self.IsRendering = false
	self.RenderConnection = nil
	self.LastUpdate = 0

	self.RenderFunction = function(Delta)
		
	end

	return self
end

function ViewportFrameHandler:CreateCamera(ViewportFrame)
	return HandleViewport(ViewportFrame)
end

function ViewportFrameHandler:RenderContents()
	if self.IsRendering or not self.Item then return end

	self.Rendering = true
	self.RenderConnection = RunService.Heartbeat:Connect(self.RenderFunction)
end

function ViewportFrameHandler:PauseRender()
	if not self.IsRendering then return end

	self.IsRendering = false
	self.RenderConnection:Disconnect()
end

function ViewportFrameHandler:Destroy()
	self:PauseRender()
	self.Camera:Destroy()
end

return ViewportFrameHandler