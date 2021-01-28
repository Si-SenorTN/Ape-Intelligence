local UserInputService = game:GetService("UserInputService")

local require = require(game:GetService("ReplicatedStorage").ApeIntelligence)
local BaseObject = require("BaseObject")

local RotateViewport = setmetatable({}, BaseObject)
RotateViewport.__index = RotateViewport

function RotateViewport.new(ViewportFrame: ViewportFrame, OffsetCFrame: CFrame, CameraSubject: Instance)
	local self = setmetatable(BaseObject.new(), RotateViewport)

	self.ViewportFrame = ViewportFrame
	self.OffsetCFrame = OffsetCFrame
	self.CameraSubject = CameraSubject
	self.Camera = self.ViewportFrame.CurrentCamera

	self.Input = false
	self.XAngle = 0
	self.YAngle = 0

	self:Enable() -- by deafult

	return self
end

function RotateViewport:Enable()
	self.Maid:GiveTask(self.ViewportFrame.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1
			or InputObject.UserInputType == Enum.UserInputType.Touch then
			self.Input = true
		end
	end))

	self.Maid:GiveTask(self.ViewportFrame.InputEnded:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1
			or InputObject.UserInputType == Enum.UserInputType.Touch then
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			self.Input = false
		end
	end))

	self.Maid:GiveTask(self.ViewportFrame.InputChanged:Connect(function(InputObject)
		if self.Input and (InputObject.UserInputType == Enum.UserInputType.MouseMovement
			or InputObject.UserInputType == Enum.UserInputType.Touch) then
			self.XAngle -= InputObject.Delta.X * .4
			self.YAngle = math.clamp(self.YAngle - InputObject.Delta.Y * .4, -80, 80)
		end
	end))
end

function RotateViewport:Disable()
	self.Maid:DoCleaning()
end

function RotateViewport:Update(DeltaTime): ()
	if self.Input == true then
		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	end

	local XYValues = (CFrame.Angles(0, math.rad(self.XAngle), 0) * CFrame.Angles(math.rad(-self.YAngle), math.rad(180), 0))
	local CameraCFrame = self.CameraSubject.CFrame * XYValues * self.OffsetCFrame

	self.Camera.CFrame = CameraCFrame
end

return RotateViewport