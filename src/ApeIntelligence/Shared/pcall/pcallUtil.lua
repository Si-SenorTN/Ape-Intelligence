local Pcall = {}

local GlobalWait = 2

function Pcall.Retry(Limit, Method, self, ...)
	local Success, Value = false, nil
	local RetryCount = 0

	repeat
		if RetryCount >= Limit then
			warn("[pcall] - Retry limit exhaused")
			break
		elseif RetryCount > 0 then
			print("[pcall] - retrying count: ", RetryCount)
			wait(GlobalWait)
		end

		Success, Value = pcall(Method, self, ...)
		RetryCount += 1

	until Success

	return Success, Value
end

return Pcall