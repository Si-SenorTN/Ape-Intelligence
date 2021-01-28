local RunService = game:GetService("RunService")
local EventUtil = {}

function EventUtil.InvokeOnFirst(func, ...)
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

function EventUtil.wait(time)
	local EventConnection
	-- TO-DO: fix

	if RunService:IsClient() then
		EventConnection = RunService.RenderStepped
	elseif RunService:IsServer() then
		EventConnection = RunService.Heartbeat
	end
	local Accumulated = 0

	local function yield(TimeAccumulated)
		coroutine.yield(TimeAccumulated)
		return TimeAccumulated
	end

	local yieldCoro = coroutine.create(yield)

	local ScriptSignal
	ScriptSignal = EventConnection:Connect(function(DeltaTime)
		Accumulated += DeltaTime
		if Accumulated >= time then
			coroutine.resume(yieldCoro, Accumulated)
			ScriptSignal:Disconnect()
		end
	end)

	return yield
end

function EventUtil.delay(time, func)
	local EventConnection

	if RunService:IsClient() then
		EventConnection = RunService.RenderStepped
	elseif RunService:IsServer() then
		EventConnection = RunService.Heartbeat
	end
	local Accumulated = 0

	local ScriptSignal
	ScriptSignal = EventConnection:Connect(function(DeltaTime)
		Accumulated += DeltaTime
		if Accumulated >= time then
			ScriptSignal:Disconnect()
			func(Accumulated)
		end
	end)
end

return EventUtil