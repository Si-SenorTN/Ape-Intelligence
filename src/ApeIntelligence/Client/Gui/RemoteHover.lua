local TweenService = game:GetService("TweenService")
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local Maid = require("Maid")

local RemoteHover = {}
RemoteHover.__index = RemoteHover
RemoteHover.ClassName = "RemoteHover"

local function CheckDesc(Base, Index, Info)
	local TweenInTable = {}
	local TweenOutTable = {}
	for _, GuiBase in pairs(Base:GetDescendants()) do
		if GuiBase:IsA("GuiBase") and Index[GuiBase.ClassName] then
			local NewIndex = Index[GuiBase.ClassName]
			local TweenIn = TweenService:Create(GuiBase, Info, NewIndex.FinishedProperties)
			local TweenOut = TweenService:Create(GuiBase, Info, NewIndex.BaseProperties)
			table.insert(TweenInTable, TweenIn)
			table.insert(TweenOutTable, TweenOut)
		end
	end
	return TweenInTable, TweenOutTable
end

function RemoteHover.new(Base, TweenProperties, BaseToTween)
	assert(typeof(Base) == "Instance" and typeof(BaseToTween) == "Instance")
	assert(Base:IsA("GuiBase") and BaseToTween:IsA("GuiBase"))
	assert(typeof(TweenProperties) == "table")

	local self = setmetatable({}, RemoteHover)
	self.Maid = Maid.new()

	self.Base = Base
	self.BaseToTween = BaseToTween
	self.Activated = false

	self.TweenIn = TweenService:Create(BaseToTween, TweenProperties.Info, TweenProperties.FinishedProperties)
	self.TweenOut = TweenService:Create(BaseToTween, TweenProperties.Info, TweenProperties.BaseProperties)

	local InTable, OutTable = {}, {}
	if TweenProperties["PossibleChildren"] then
		InTable, OutTable = CheckDesc(self.BaseToTween, TweenProperties.PossibleChildren, TweenProperties.Info)
	end

	self.ChildInTable = InTable
	self.ChildOutTable = OutTable

	return self
end

function RemoteHover:Enable()
	if self.Activated then return end
	
	self.Activated = true
	self.Maid:GiveTask(self.Base.MouseEnter:Connect(function()
		self.TweenIn:Play()
		for _, TweenBase in pairs(self.ChildInTable) do
			if TweenBase:IsA("TweenBase") then
				TweenBase:Play()
			end
		end
	end))

	self.Maid:GiveTask(self.Base.MouseLeave:Connect(function()
		self.TweenOut:Play()
		for _, TweenBase in pairs(self.ChildOutTable) do
			if TweenBase:IsA("TweenBase") then
				TweenBase:Play()
			end
		end
	end))
end

function RemoteHover:Disable()
	self.Maid:DoCleaning()
	self.Activated = false
end

return RemoteHover
