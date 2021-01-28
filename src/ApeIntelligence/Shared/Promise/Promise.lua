--[[
--/* reference
--/* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise

-- A+ standard:
-- Pending = initial state, nothing has returned
-- Fufiled = completed successfully
-- Rejected = operation failed
	When pending, a promise:
		may transition to either the fulfilled or rejected state.
	When fulfilled, a promise:
		must not transition to any other state.
		must have a value, which must not change.
	When rejected, a promise:
		must not transition to any other state.
		must have a reason, which must not change.
--]]

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))
local FastSpawn = require("FastSpawn")

local RunService = game:GetService("RunService")

local function IsPromise(object)
	return type(object) == "table" and object.ClassName == "Promise"
end

-- forward declarations
local FulfilledPromise
local RejectedPromise

local Promise = {}
Promise.__index = Promise
Promise.ClassName = "Promise"

-- function to determine promises
Promise.IsPromise = IsPromise

-- Constructors

function Promise.new(Func) -- Promise.new(function(Resolve, Reject() --
	local self = setmetatable({}, Promise)

	self.PendingList = {}
	self.Source = debug.traceback()
	self.UnconsumedException = true

	if type(Func) == "function" then
		Func(self:_GetResolveReject())
	end

	return self
end

-- executes a Promise in Quenty fast spawn style, no obscured errors
-- bit more expensive take - prefered base method to call

function Promise.Spawn(Func) -- Promise.Spawn(function(Resolve, Reject() --
	local promise = Promise.new()

	FastSpawn(Func, promise:_GetResolveReject()) -- you could just use coroutine.wrap

	return promise
end

--

-- Resolved Rejected base methods

function Promise.Resolved(...)
	local Args = select("#", ...)

	if Args == 0 then
		return FulfilledPromise
	elseif Args ==  1 and IsPromise(...) then
		local promise = (...)

		if not promise.PendingList then
			return promise
		end
	end

	local promise = Promise.new()
	promise:Resolve(...)
	return promise
end

function Promise.Rejected(...)
	local Args = select("#", ...)

	if Args == 0 then
		return RejectedPromise
	end

	local promise = Promise.new()
	promise:_ExecuteReject({...}, Args)
	return promise
end

-- Check states

function Promise:IsPending()
	return self.PendingList ~= nil
end

function Promise:IsRejected()
	return self._Rejected ~= nil
end

function Promise:IsFulfilled()
	return self._Fulfilled ~= nil
end

-- Methods

function Promise:Resolve(...)
	if not self.PendingList then
		return
	end

	local Length = select("#", ...)

	if Length == 0 then
		self:_ExecuteFulfill({}, 0)
	elseif self == (...) then
		self:Reject("Type error, Resolved to self")
	elseif IsPromise(...) then
		if Length > 1 then
			warn("Extra arguments are dropped when resolving a promise, /n", self.Source)
		end
		local promise = (...)
		if promise.PendingList then
			promise.UnconsumedException = false
			promise.PendingList[#promise.PendingList + 1] = {
				function(...)
					self:Resolve(...)
				end, function(...)
					if self.PendingList then
						self:Reject(...)
					end
				end, nil
			}
		elseif promise._Rejected then
			promise.UnconsumedException = false
			self:_ExecuteReject(promise._Rejected, promise._Length)
		elseif promise._Fulfilled then
			self:_ExecuteFulfill(promise._Fulfilled, promise._Length)
		else
			error("Promise:Resolve() - bad state for second Promise", 2)
		end
	elseif type(...) == "function" then
		if Length > 1 then
			warn("Extra arguments are dropped when resolving a function, /n", self.Source)
		end

		local Func = {...}
		Func(self:_GetResolveReject())
	else
		--
		self:_ExecuteFulfill({...}, Length)
	end
end

function Promise:Reject(...)
	return self:_ExecuteReject({...}, select("#", ...))
end

function Promise:Then(OnFulfilled, OnRejected)
	if type(OnRejected) == "function" then
		self.UnconsumedException = false
	end

	if self.PendingList then
		local promise = Promise.new()
		self.PendingList[#self.PendingList + 1] = {
			OnFulfilled;
			OnRejected;
			promise;
		}
		return promise
	else
		return self:_ExecuteThen(OnFulfilled, OnRejected, nil)
	end
end

function Promise:Tap(OnFulfilled, OnRejected)
	local Result = self:Then(OnFulfilled, OnRejected)
	if Result == self then
		return Result
	end

	if self._Fulfilled then
		return self
	elseif self._Rejected then
		return self
	elseif self.PendingList then
		local function ReturnSelf()
			return self
		end

		return self:Then(ReturnSelf, ReturnSelf)
	else
		error("Promise:Tap() - bad state", 2)
	end
end

function Promise:Wait()
	if self._Fulfilled then
		return table.unpack(self._Fulfilled, 1, self._Length)
	elseif self._Rejected then
		error(tostring(self._Rejected[1]), 2)
	else
		local BindableEvent = Instance.new("BindableEvent")

		self:Then(function()
			BindableEvent:Fire()
		end, function()
			BindableEvent:Fire()
		end)

		BindableEvent.Event:Wait()
		BindableEvent:Destroy()

		if self._Rejected then
			error(tostring(self._Rejected[1]), 2)
		else -- default to resolve state
			return table.unpack(self._Fulfilled, 1, self._Length)
		end
	end
end

function Promise:Finally(Func)
	return self:Then(Func, Func)
end

-- catches errors
function Promise:Catch(OnRejected)
	return self:Then(nil, OnRejected)
end

-- defaults to reject on destroy
function Promise:Destroy()
	self:_ExecuteReject({}, 0)
end

-- returns results of a promise
-- boolean, values
-- local IsFufilled, Results = Promise:GetResults()
function Promise:GetResults()
	if self._Rejected then
		return false, table.unpack(self._Rejected, 1, self.Length)
	elseif self._Fulfilled then
		return true, table.unpack(self._Fulfilled, 1, self.Length)
	else
		error("Promise:GetResults() - still pending")
	end
end

--

-- internal functions

function Promise:_ExecuteFulfill(Values, Length)
	if not self.PendingList then
		return
	end

	self._Fulfilled = Values
	self._Length = Length

	local List = self.PendingList
	self.PendingList = nil
	for _, Data in pairs(List) do
		self:_ExecuteThen(table.unpack(Data))
	end
end

function Promise:_ExecuteReject(Values, Length)
	if not self.PendingList then
		return
	end

	self._Rejected = Values
	self._Length = Length

	local List = self.PendingList
	self.PendingList = nil
	for _, Data in pairs(List) do
		self:_ExecuteThen(table.unpack(Data))
	end

	if self.UnconsumedException and self._Length > 0 then
		coroutine.resume(coroutine.create(function()
			RunService.Heartbeat:Wait()

			if self.UnconsumedException then
				warn(string.format("[Promise] - Uncaught exception in promise\n\n%q\n\n%s",
					tostring(self._Rejected[1]), self.Source))
			end
		end))
	end
end

function Promise:_ExecuteThen(Fulfilled, Rejected, promise)
	if self._Fulfilled then
		if type(Fulfilled) == "function" then
			if promise then
				promise:Resolve(Fulfilled(table.unpack(self._Fulfilled, 1, self._Length)))
				return promise
			else
				local Results = table.pack(Fulfilled(table.unpack(self._Fulfilled, 1, self._Length)))
				if Results.n == 0 then
					return FulfilledPromise
				elseif Results.n == 1 and IsPromise(Results[1]) then
					return Results[1]
				else
					local promise2 = Promise.new()
					promise2:Resolve(table.unpack(Results, 1, Results.n))
					return promise2
				end
			end
		else
			if promise then
				promise:_ExecuteFulfill(self._Fulfilled, self._Length)
				return promise
			else
				return self
			end
		end
	elseif self._Rejected then
		if type(Rejected) == "function" then
			if promise then
				promise:Resolve(Rejected(table.unpack(self._Rejected, 1, self._Length)))
				return promise
			else
				local Results = table.pack(Rejected(table.unpack(self._Rejected, 1, self._Length)))
				if Results.n == 0 then
					return FulfilledPromise
				elseif Results.n == 1 and IsPromise(Results[1]) then
					return Results[1]
				else
					local promise2 = Promise.new()
					promise2:Resolve(table.unpack(Results, 1, Results.n))
					return promise2
				end
			end
		else
			if promise then
				promise:_ExecuteReject(self._Rejected, self._Length)
				return promise
			else
				return self
			end
		end
	else
		error("Promise - still pending")
	end
end

function Promise:_GetResolveReject()
	return function(...)
		self:Resolve(...)
	end, function(...)
		self:_ExecuteReject({...}, select("#", ...))
	end
end

--

FulfilledPromise = Promise.new()
FulfilledPromise:_ExecuteFulfill({}, 0)

RejectedPromise = Promise.new()
RejectedPromise:_ExecuteReject({}, 0)

-- Alias methods
Promise.Yield = Promise.Wait

return Promise