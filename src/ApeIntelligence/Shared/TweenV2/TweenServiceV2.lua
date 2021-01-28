-- thanks SteadyOn
local module = {}
local tService = game:GetService("TweenService")
local rService = game:GetService("RunService")
local tEvent

if tEvent == nil and rService:IsServer() then
	tEvent = Instance.new("RemoteEvent")
	tEvent.Parent = script
	tEvent.Name = "TweenEvent"
else
	tEvent = script:WaitForChild("TweenEvent")
end

local function TweenInfo_To_Table(tInfo)
	local info = {}
	info[1] = tInfo.Time or 1 
	info[2] = tInfo.EasingStyle or Enum.EasingStyle.Quad
	info[3] = tInfo.EasingDirection or Enum.EasingDirection.Out
	info[4] = tInfo.RepeatCount or 0
	info[5] = tInfo.Reverses or false
	info[6] = tInfo.DelayTime or 0
	return info
end

local function Table_To_TweenInfo(tbl)
	return TweenInfo.new(unpack(tbl))
end

local function serverAssignProperties(instance, properties)
	for property, value in pairs (properties) do
		instance[property] = value
	end
end

local latestFinish = {} -- this table operates on both the client and the server, server side it only stores GLOBAL tweens, local side it stores every local tween.

function module:GetTweenObject(instance, tInfo, propertyTable)
	local tweenMaster = {}
	tweenMaster.DontUpdate = {} -- table of specific players that it stopped for part way.
	tInfo = TweenInfo_To_Table(tInfo)

	local function Play(Yield, SpecificClient, Queue) -- this is on it's own as it needs to be called by both QueuePlay and Play
		local finishTime = os.time()+tInfo[1]
		local waitTime = tInfo[1]
		latestFinish[instance] = latestFinish[instance] or os.time() -- cannot be nil.
		Queue = Queue or false
		tweenMaster.Paused = false

		if SpecificClient == nil and not Queue then
			latestFinish[instance] = finishTime -- adds an entry to array with finish time of this tween (used for queueing)
			tEvent:FireAllClients("RunTween", instance, tInfo, propertyTable)
		elseif Queue and SpecificClient == nil then -- deal with queued tweens
			waitTime = waitTime + (latestFinish[instance] - os.time())
			latestFinish[instance] = finishTime + (latestFinish[instance] - os.time()) -- adds an entry to array with finish time of this tween (used for queueing)
			tEvent:FireAllClients("QueueTween", instance, tInfo, propertyTable)
		elseif Queue then
			tEvent:FireClient("QueueTween", instance, tInfo, propertyTable) -- queue tween for specific player
		else
			tEvent:FireClient("RunTween", instance, tInfo, propertyTable) -- play tween for specific player
		end

		if Yield and SpecificClient == nil then
			local i, existingFinish = 0, latestFinish[instance]
			repeat wait(0.1) i += 1 until i >= waitTime or tweenMaster.Stopped
			if latestFinish[instance] == existingFinish then
				latestFinish[instance] = nil -- clear memory if this instance hasn't already been retweened.
			end
			if tweenMaster.Paused == nil or tweenMaster.Paused == false then
				serverAssignProperties(instance, propertyTable) -- assign the properties server side
			end
			return
		elseif SpecificClient == nil then
			spawn(function()
				local i, existingFinish = 0, latestFinish[instance]
				repeat wait(0.1) i += 1 until i >= waitTime or tweenMaster.Stopped
				if latestFinish[instance] == existingFinish then
					latestFinish[instance] = nil -- clear memory if this instance hasn't already been retweened.
				end
				if tweenMaster.Paused == nil or tweenMaster.Paused == false then
					serverAssignProperties(instance, propertyTable) -- assign the properties server side
				end
			end)
		end
	end

	function tweenMaster:Play(Yield, SpecificClient)
		Play(Yield, SpecificClient)
	end

	function tweenMaster:QueuePlay(Yield, SpecificClient)
		Play(Yield, SpecificClient, true)
	end

	function tweenMaster:Pause(SpecificClient)
		if SpecificClient == nil then
			tweenMaster.Paused = true
			tEvent:FireAllClients("PauseTween", instance)
		else
			table.insert(tweenMaster.DontUpdate, SpecificClient)
			tEvent:FireClient("PauseTween", instance)
		end
	end

	function tweenMaster:Stop(SpecificClient)
		if SpecificClient == nil then
			tweenMaster.Stopped = true
			tEvent:FireAllClients("StopTween", instance)
		else
			tEvent:FireClient("StopTween", instance)
		end
	end

	return tweenMaster
end

if rService:IsClient() then -- OnClientEvent only works clientside
	local runningTweens = {}

	tEvent.OnClientEvent:Connect(function(purpose, instance, tInfo, propertyTable)
		if tInfo ~= nil then
			tInfo = Table_To_TweenInfo(tInfo)
		end

		local function runTween(queued)
			local finishTime = os.time()+tInfo.Time
			latestFinish[instance] = latestFinish[instance] or os.time() -- cannot be nil.

			local existingFinish = latestFinish[instance]
			if queued and latestFinish[instance] >= os.time() then
				local waitTime = (latestFinish[instance] - os.time())
				latestFinish[instance] = finishTime + waitTime
				existingFinish = latestFinish[instance]
				wait(waitTime)
			else
				latestFinish[instance] = finishTime
			end

			if runningTweens[instance] ~= nil then -- im aware this will pick up paused tweens, however it doesn't matter
				runningTweens[instance]:Cancel() -- stop previously running tween to run this one
			end

			local tween = tService:Create(instance, tInfo, propertyTable)
			runningTweens[instance] = tween
			tween:Play()
			wait(tInfo.Time or 1)
			if latestFinish[instance] == existingFinish then
				latestFinish[instance] = nil -- clear memory if this instance hasn't already been retweened.
			end
			if runningTweens[instance] == tween then -- make sure it hasn't changed to a different tween
				runningTweens[instance] = nil -- remove to save memory
			end
		end

		if purpose == "RunTween" then
			runTween()
		elseif purpose == "QueueTween" then
			runTween(true) -- run as a queued tween
		elseif purpose == "StopTween" then
			if runningTweens[instance] ~= nil then -- check that the tween exists
				runningTweens[instance]:Stop() -- stop the tween
				runningTweens[instance] = nil -- delete from table
			else
				warn("Tween being stopped does not exist.")
			end
		elseif purpose == "PauseTween" then
			if runningTweens[instance] ~= nil then -- check that the tween exists
				runningTweens[instance]:Pause() -- pause the tween
			else
				warn("Tween being paused does not exist.")
			end
		end
	end)
end

return module