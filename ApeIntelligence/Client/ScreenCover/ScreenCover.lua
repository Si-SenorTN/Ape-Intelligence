local TweenService = game:GetService("TweenService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))

local ScreenCoverBuilder = require("ScreenCoverBuilder")
local Maid = require("Maid")
local PlayerGui = require("PlayerGui").GetPlayerGui()

local ScreenCover = {}
ScreenCover.__index = ScreenCover
ScreenCover.ClassName = "ScreenCover"

function ScreenCover.new(ScreenGui)
	if ScreenGui then
		assert(ScreenGui:IsA("ScreenGui"))
	else
		ScreenGui = ScreenCoverBuilder:CreateScreenGui()
		ScreenGui.Parent = PlayerGui
	end

	local self = {}

	self.Maid = Maid.new()
	self.Frame = ScreenCoverBuilder:CreateFrame()
	self.Frame.BackgroundTransparency = 1
	self.Frame.Visible = false

	self.Frame.Parent = ScreenGui

	self.Maid:GiveTask(self.Frame)

	return setmetatable(self, ScreenCover)
end

function ScreenCover:HideScreen(Speed, Yield)
	local Info = TweenInfo.new(Speed, Enum.EasingStyle.Linear)
	self.Frame.Visible = true
	local TweenIn = TweenService:Create(self.Frame, Info, {BackgroundTransparency = 0})
	TweenIn:Play()
	if Yield then TweenIn.Completed:Wait() end
end

function ScreenCover:ShowScreen(Speed, Yield)
	local Info = TweenInfo.new(Speed, Enum.EasingStyle.Linear)
	local TweenOut = TweenService:Create(self.Frame, Info, {BackgroundTransparency = 1})
	TweenOut:Play()
	self.Maid.TweenCompleted = TweenOut.Completed:Connect(function()
		self.Frame.Visible = false
		self.Maid.TweenCompleted = nil
	end)
	if Yield then TweenOut.Completed:Wait() end
end

function ScreenCover:Destroy()
	self.Maid:DoCleaning()
end

return ScreenCover