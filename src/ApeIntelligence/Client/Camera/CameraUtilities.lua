--!nonstrict
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local BaseObject = require("BaseObject")

local CameraUtil = setmetatable({}, BaseObject)
CameraUtil.__index = CameraUtil
CameraUtil.ClassName = "CameraUtilities"

--[[export type InterpolateObject = {
	Camera: Instance;
	Part: BasePart;
	Offset: Vector3;
	Time: number;
	Degrees: number;
	RepeatCount: number;
	Reverses: boolean;
	Focus: boolean;
}]]

function CameraUtil.InterpolateAroundPart(Camera, Part, Offset, Time, Degrees, RepeatCount, Reverses, Focus): InterpolateObject
	assert(Camera:IsA("Camera"))

	local self = setmetatable(BaseObject.new(), CameraUtil)

	self.Camera = Camera
	self.Part = Part
	self.Offset = Offset or Vector3.new(0, 0, 5)
	self.Time = Time or 5
	self.Degrees = Degrees or 360
	self.RepeatCount = RepeatCount or -1
	self.Reverses = Reverses or false
	self.Focus = Focus or true

	self.RotValue = Instance.new("NumberValue")
	self.Maid:GiveTask(self.RotValue)

	local Info = TweenInfo.new(self.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, self.RepeatCount, self.Reverses)
	self.Tween = TweenService:Create(self.RotValue, Info, {Value = self.Degrees})

	self.LogicFunction = function()
		self.Camera.Focus = self.Part.CFrame

		local RotCFrame = CFrame.new(self.Part.Position) * CFrame.Angles(0, math.rad(self.RotValue.Value), 0)
		self.Camera.CFrame = RotCFrame:ToWorldSpace(CFrame.new(self.Offset))

		if self.Focus then
			self.Camera.CFrame = CFrame.new(self.Camera.CFrame.Position, self.Part.Position)
		end
	end

	self.LogicLoop = RunService.Heartbeat

	function self.Start()
		self:Stop()

		self.Tween:Play()
		self.Maid.Connection = self.LogicLoop:Connect(self.LogicFunction)
	end

	function self.Stop()
		if not self.Maid.Connection then return end

		self.Tween:Cancel()
		self.Maid.Connection = nil
	end

	return self
end

return CameraUtil