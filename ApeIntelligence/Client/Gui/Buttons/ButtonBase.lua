local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local Maid = require("Maid")

local ButtonBase = {}
ButtonBase.__index = ButtonBase
ButtonBase.ClassName = "ButtonBase"

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

local function PlayInteractiveSound(SoundId, Volume)
	local Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://"..SoundId
	Sound.Volume = Volume
	SoundService:PlayLocalSound(Sound)
	Debris:AddItem(Sound, Sound.TimeLength + .8)
end

function ButtonBase.new(instance, Properties, Info, Callback)
	assert(typeof(instance) == "Instance" and instance:IsA("GuiBase"))
	assert(type(Properties) == "table")
	assert(typeof(Info) == "TweenInfo")

	if Callback then
		assert(type(Callback) == "function")
	end

	local self = setmetatable({}, ButtonBase)

	self.Maid = Maid.new()

	self.Base = instance
	self.Properties = Properties
	self.BaseProperties = Properties.BaseProperties
	self.FinishedProperties = Properties.FinishedProperties
	self.Selected = false

	self.TweenIn = TweenService:Create(instance, Info, self.FinishedProperties)
	self.TweenOut = TweenService:Create(instance, Info, self.BaseProperties)

	local InTable, OutTable = {}, {}
	if Properties["PossibleChildren"] then
		InTable, OutTable = CheckDesc(self.Base, Properties.PossibleChildren, Info)
	end

	self.ChildInTable = InTable
	self.ChildOutTable = OutTable

	self.Callback = Callback or nil
	self.Connections = {}

	return self
end

function ButtonBase:OnMouseEnter(Silent)
	if self.Selected then return end

	if self.Properties["HoverSound"] and not Silent then
		local Sound = self.Properties.HoverSound
		PlayInteractiveSound(Sound.SoundId, Sound.Volume)
	end

	self.TweenIn:Play()
	if #self.ChildInTable > 0 then
		for _, TweenBase in pairs(self.ChildInTable) do
			if TweenBase:IsA("TweenBase") then
				TweenBase:Play()
			end
		end
	end
end

function ButtonBase:OnMouseLeave()
	if self.Selected then return end

	self.TweenOut:Play()
	if #self.ChildOutTable > 0 then
		for _, TweenBase in pairs(self.ChildOutTable) do
			if TweenBase:IsA("TweenBase") then
				TweenBase:Play()
			end
		end
	end
end

function ButtonBase:RunCallback(Silent)
	if self.Selected then return end
	
	if self.Properties["ClickSound"] and not Silent then
		local Sound = self.Properties.ClickSound
		PlayInteractiveSound(Sound.SoundId, Sound.Volume)
	end

	if self.Callback then
		self.Callback(self.Base)
	end
end

function ButtonBase:ConnectHovers()
	self.Maid.Enter = self.Base.MouseEnter:Connect(function()
		self:OnMouseEnter()
	end)

	self.Maid.Leave = self.Base.MouseLeave:Connect(function()
		self:OnMouseLeave()
	end)
end

function ButtonBase:ConnectActivation()
	if not self.Base:IsA("GuiButton") then return end

	self.Maid.Activated = self.Base.Activated:Connect(function()
		self:RunCallback()
	end)
end

function ButtonBase:Setup()
	self:Deactivate()

	self:ConnectHovers()
	self:ConnectActivation()
end

function ButtonBase:Deactivate()
	self.Maid:DoCleaning()
	self.Selected = false
	self:OnMouseLeave()
end

function ButtonBase:Destroy()
	self:Deactivate()
	self.Base:Destroy()
	self = nil
end

return ButtonBase
