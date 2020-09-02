--\* Signal Class *\--
--\* Creates an RBXScriptConnection
--\* Fully equipped with a maid, meaning any external connection
--\* to this signal will auto GC

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))

local Maid = require("Maid")

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

function Signal.new()
	local self = {}

	local BindableEvent = Instance.new("BindableEvent")
	self.Maid = Maid.new()

	self.BindableEvent = BindableEvent
	self.Maid:GiveTask(BindableEvent)

	self.Args = nil
	self.ArgsCount = nil
	
	return setmetatable(self, Signal)
end

function Signal:Connect(func)
	assert(typeof(func) == "function", "Passed argument in Connect must be a function")

	return self.Maid:GiveTask(self.BindableEvent.Event:Connect(function(...)
		func(unpack(self.Args, 1, self.ArgsCount))
	end))
end

function Signal:Wait()
	self.BindableEvent.Event:Wait()
	assert(self.Args, "Missing Arguments")
	return unpack(self.Args, 1, self.ArgsCount)
end

function Signal:Fire(...)
	self.Args = {...}
	self.ArgsCount = select("#", ...)
	self.BindableEvent:Fire()
end

function Signal:Destroy()
	self.Args = nil
	self.ArgsCount = nil

	self.Maid:DoCleaning()
end

return Signal
