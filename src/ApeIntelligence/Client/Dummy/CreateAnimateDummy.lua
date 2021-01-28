local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local BaseObject = require("BaseObject")

local AnimateDummy = {}
AnimateDummy.__index = AnimateDummy

local function StopAllAnimations(Animator)
	for _, AnimationTrack in pairs(Animator:GetPlayingAnimationTracks()) do
		AnimationTrack:Stop()
	end
end

local function SafeClone(Object)
	local Arch = Object.Archivable
	Object.Archivable = true
	local Clone = Object:Clone()
	Object.Archivable = Arch
	return Clone
end

function AnimateDummy.new(Rig)
	assert(typeof(Rig) == "Instance" and Rig:IsA("Model"), "Passed rig must be a Model")

	local Animator = Rig:FindFirstChildOfClass("Humanoid") or Rig:FindFirstChildOfClass("AnimationController")
	assert(Animator, "Passed rig must have a Humanoid or AnimationController")
	assert(Rig.PrimaryPart, "It is advised to use a PrimaryPart in your rig")

	local self = setmetatable(BaseObject.new(), AnimateDummy)

	self.Rig = SafeClone(Rig)
	self.Animator = Animator
	self.AnimationObject = Instance.new("Animation")
	self.AnimationObject.Name = "MainAnimation"
	self.AnimationObject.Parent = self.Rig

	self.Maid:GiveTask(self.Rig)
	self.Maid:GiveTask(self.AnimationObject)

	return self
end

function AnimateDummy:MoveRig(Location)
	if typeof(Location) == "Vector3" then
		self.Rig.PrimaryPart.CFrame = CFrame.new(Location)
	elseif typeof(Location) == "CFrame" then
		self.Rig.PrimaryPart.CFrame = Location
	else
		warn("Cannot use ", typeof(Location), " to position Dummy")
	end
end

function AnimateDummy:PlayAnimation(AnimationId, Priority, StopAll)
	assert(type(AnimationId) == "number")
	self.AnimationObject.AnimationId = "rbxassetid://"..AnimationId
	local Track = self.Animator:LoadAnimation(self.AnimationObject)
	Track.Priority = Priority and Enum.AnimationPriority[Priority] or Enum.AnimationPriority.Action
	if StopAll then StopAllAnimations(self.Animator) end
	Track:Play()
end

return AnimateDummy