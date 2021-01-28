--- Forked from Nevermore
-- modified syntax
-- https://github.com/Quenty/NevermoreEngine/blob/version2/Modules/Shared/Promise/PendingPromiseTracker.lua

--- Tracks pending promises
-- @classmod PendingPromiseTracker

local PendingPromiseTracker = {}
PendingPromiseTracker.ClassName = "PendingPromiseTracker"
PendingPromiseTracker.__index = PendingPromiseTracker

function PendingPromiseTracker.new()
	local self = setmetatable({}, PendingPromiseTracker)

	self._PendingPromises = {}

	return self
end

function PendingPromiseTracker:Add(promise)
	if promise:IsPending() then
		self._PendingPromises[promise] = true
		promise:Finally(function()
			self._PendingPromises[promise] = nil
		end)
	end
end

function PendingPromiseTracker:GetAll()
	local promises = {}
	for promise, _ in pairs(self._PendingPromises) do
		table.insert(promises, promise)
	end
	return promises
end

return PendingPromiseTracker