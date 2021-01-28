local RobloxString = string

local String = {}

String.firstUpper = function(Str)
	return Str:gsub("^%a", string.upper)
end

return setmetatable({}, {
	__index = function(t, key)
		if String[key] then
			return String[key]
		else
			return RobloxString[key]
		end
	end;

	__newindex = function()
		error("Cannot write into table extension", 2)
	end;
})