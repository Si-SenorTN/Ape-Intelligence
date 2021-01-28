--\* Table Extension *\--
--\* adds more methods into regular tables
--\* local table = require("Table") -- redefine table

local RobloxTable = table

local Table = {}
local RNG = Random.new(tick())

--\* returns a random index in a table
Table.random = function(t)
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

--\* similar to metamethod __concat, will combine two tables together, without having to create/invoke any metamethod
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

Table.get = function(t, value)
	assert(value ~= nil)

	for i, v in pairs(t) do
		if value == v or tostring(v) == value then
			return t[i]
		end
	end

	return nil
end

local function getRecursive(t, value)
	for i, v in pairs(t) do
		if value == v or tostring(v) == value then
			return i
		elseif type(v) == "table" then
			local thing = getRecursive(v, value)
			if thing then return thing else
				continue
			end
		end
	end

	return nil
end

Table.getRecursive = function(t, value)
	assert(value ~= nil)

	return getRecursive(t, value)
end

Table.geti = function(t, index)
	assert(index ~= nil)

	for i, v in pairs(t) do
		if index == i then
			return t[i]
		end
	end

	return nil
end

local function getiRecursive(t, index)
	for i, v in pairs(t) do
		if index == i then
			return t[i]
		elseif type(v) == "table" then
			local thing = getiRecursive(v, index)
			if thing then return thing else
				continue
			end
		end
	end

	return nil
end

local function getAndTake(t, value)
	local haystack
	for i, v in pairs(t) do
		if value == v then
			return t
		elseif type(v) == "table" then
			haystack = getAndTake(v, value)
		end
	end
	return haystack
end
Table.getAndTake = getAndTake

Table.takeKeys = function(t, value)
	for i, v in pairs(t) do
		if v == value then
			return i, v
		end
	end
end

-- ONLY WORKS WITH ARRAYS
function Table.getHighest(t)
	local Index, Highest
	for i, v in pairs(t) do
		if not Highest or v > Highest then
			Index, Highest = i, v
		end
	end
	return Index, Highest
end
-- http://lua-users.org/wiki/CopyTable

-- avoids the metamethod __pairs
local function DeepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
		end
		setmetatable(copy, DeepCopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end
Table.deep = DeepCopy

Table.shallow = function(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function deepRecursive(orig, copies)
	copies = copies or {}
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		if copies[orig] then
			copy = copies[orig]
		else
			copy = {}
			copies[orig] = copy
			for orig_key, orig_value in next, orig, nil do
				copy[deepRecursive(orig_key, copies)] = deepRecursive(orig_value, copies)
			end
			setmetatable(copy, deepRecursive(getmetatable(orig), copies))
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end
Table.deepRecursive = deepRecursive

function merge(t1, t2)
	for k, v in pairs(t2) do
		if (type(v) == "table") and (type(t1[k] or false) == "table") then
			merge(t1[k], t2[k])
		else
			t1[k] = v
		end
	end
	return t1
end
Table.merge = merge

function table_eq(table1, table2)
	local avoid_loops = {}
	local function recurse(t1, t2)
		-- compare value types
		if type(t1) ~= type(t2) then return false end
		-- Base case: compare simple values
		if type(t1) ~= "table" then return t1 == t2 end
		-- Now, on to tables.
		-- First, let's avoid looping forever.
		if avoid_loops[t1] then return avoid_loops[t1] == t2 end
		avoid_loops[t1] = t2
		-- Copy keys from t2
		local t2keys = {}
		local t2tablekeys = {}
		for k, _ in pairs(t2) do
			if type(k) == "table" then table.insert(t2tablekeys, k) end
			t2keys[k] = true
		end
		-- Let's iterate keys from t1
		for k1, v1 in pairs(t1) do
			local v2 = t2[k1]
			if type(k1) == "table" then
				-- if key is a table, we need to find an equivalent one.
				local ok = false
				for i, tk in ipairs(t2tablekeys) do
					if table_eq(k1, tk) and recurse(v1, t2[tk]) then
						table.remove(t2tablekeys, i)
						t2keys[tk] = nil
						ok = true
						break
					end
				end
				if not ok then return false end
			else
				-- t1 has a key which t2 doesn't have, fail.
				if v2 == nil then return false end
				t2keys[k1] = nil
				if not recurse(v1, v2) then return false end
			end
		end
		-- if t2 has a key which t1 doesn't have, fail.
		if next(t2keys) then return false end
		return true
	end
	return recurse(table1, table2)
end
Table.deepCompare = table_eq

return setmetatable({}, {
	__index = function(t, key)
		if Table[key] then
			return Table[key]
		else
			return RobloxTable[key]
		end
	end;

	__newindex = function()
		error("Cannot write into table extension", 2)
	end;
})