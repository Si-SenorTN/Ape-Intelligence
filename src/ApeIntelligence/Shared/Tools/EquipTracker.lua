local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local Signal = require("Signal")
local Maid = require("Maid")

local function InvokeOnFirst(func, ...)
	local Bind = Instance.new("BindableEvent")
	local Events = {...}

	local function Fire(...)
		for i = 1, #Events do
			Events[i]:Disconnect()
		end

		return Bind:Fire(...)
	end

	for i = 1, #Events do
		Events[i] = Events[i]:Connect(Fire)
	end

	return Bind.Event:Connect(function()
		func()
		Bind:Destroy()
	end)
end

local EquipTracker = {}
EquipTracker.__index = EquipTracker
EquipTracker.ClassName = "EquipTracker"

function EquipTracker.new(Player)
	assert(typeof(Player) == "Instance" and Player:IsA("Player"), "Passed in Instance must be a Player")

	local self = setmetatable({}, EquipTracker)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	
	self._Maid = Maid.new()
	self.EquipChange = Signal.new()

	self.CurrentEquipped = nil
	self.LastEquipped = nil

	self._Maid.ChildAdded = Character.ChildAdded:Connect(function(Obj)
		if Obj:IsA("Tool") then
			self.EquipChange:Fire(true, Obj)
			self.CurrentEquipped = Obj
		end
	end)

	self._Maid.ChildRemoved = Character.ChildRemoved:Connect(function(Obj)
		if Obj:IsA("Tool") then
			self.EquipChange:Fire(false, Obj)
			self.CurrentEquipped = nil
			self.LastEquipped = Obj
		end
	end)

	InvokeOnFirst(function()
		self._Maid:DoCleaning()
	end, Player.CharacterRemoving, Humanoid.Died)

	return self
end

return EquipTracker