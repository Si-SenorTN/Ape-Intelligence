local ApeUtils = {}

function ApeUtils.RequireByName(Require, Lookup)
	assert(type(Require) == "function")
	assert(type(Lookup) == "table")

	return function(Module)
		if typeof(Module) == "Instance" and Module:IsA("ModuleScript") then
			return Require(Module)
		elseif type(Module) == "string" then
			if Lookup[Module] then
				return Require(Lookup[Module])
			else
				error("Module: "..Module.." doesnt exist within ApeIntelligence", 2)
			end
		else
			error(string.format("Module must be a string or ModuleScript, Got %s for %s", typeof(Module), tostring("Module")))
		end
	end
end

function ApeUtils.DetectCyclicalPatterns(Require)
	assert(type(Require) == "function")

	local Stack = {}
	local Loading = {}

	return function(Module, ...)
		assert(typeof(Module) == "Instance")

		if Loading[Module] then
			local Cycle = ApeUtils.GetCyclicalFromStack(Stack, Loading[Module])
			warn(string.format("CyclicalPattern detected at %q.\nCycle: %s", Module:GetFullName(), Cycle))
			return Require(Module)
		end

		Loading[Module] = #Stack + 1
		table.insert(Stack, Module)

		local Result = Require(Module, ...)
		Loading[Module] = nil

		assert(table.remove(Stack) == Module)

		return Result
	end
end

function ApeUtils.GetCyclicalFromStack(Stack, Depth)
	local string = ""

	for i = Depth, #Stack do
		string = string..Stack[i].Name.." -> "
	end
	return string..Stack[Depth].Name
end

return ApeUtils