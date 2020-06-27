--\* Table Extension *\--
--\* adds more methods into regular tables
--\* local table = require("Table") -- redefine table

local RobloxTable = table

local Table = {}
local RNG = Random.new()

--\* returns a random index in a table
Table.random = function(t, key)
	return t[RNG:NextInteger(1, #t)]
end

--\* randomizes a tables order
Table.shuffle = function(t)
	for i = #t, 2, -1 do
		local rand = RNG:NextInteger(1, i)
		t[i], t[rand] = t[rand], t[i]
	end
	return t
end

--\* similar to metamethod __concat, will combine two tables together, without having to create/invoke metamethod
Table.combine = function(t1, t2)
	local array = {}
	for i, v in pairs(t1) do
		array[i] = v
	end
	for i, v in pairs(t2) do
		array[i] = v
	end
	return array
end

Table.readonly = function(t)
	return setmetatable(t, {
		__index = function(self, index)
			error(index, " is not a member", 2)
		end;
		__newindex = function()
			error("Cannot write into a ReadOnly table", 2)
		end;
	})
end

return setmetatable({}, {
	__index = function(t, key)
		if Table[key] then
			return Table[key]
		else
			return RobloxTable[key]
		end
	end;

	__newindex = function()
		error("Cannot write into table extension")
	end;
})