--\* Maid Class *\--
--\* Usefull for cleaning of events/instances/execution of functions

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))

local MaidUtil = require("MaidUtilities")

local Maid = {}
Maid.ClassName = "Maid"

function Maid.new()
	return setmetatable({
		_Trash = {}
	}, Maid)
end

--\* Check for Maids *\--
--\* Will return true if passed object is a maid
function Maid:IsMaid(Maid)
	return typeof(Maid) == "table" and Maid.ClassName == "Maid"
end

--\* Index *\--
--\* if key is not a valid memeber of Maid, 
--\* will return new Maid[Key]
function Maid:__index(Key)
	if Maid[Key] then
		return Maid[Key]
	else
		return self._Trash[Key]
	end
end

function Maid:__newindex(Key, NewTask)
	if Maid[Key] ~= nil then
		error(string.format("'%s' is reserved", Key), 2)
	end

	local Garbage = self._Trash
	local OldTask = Garbage[Key]

	if OldTask == NewTask then return end

	Garbage[Key] = NewTask

	if OldTask then
		MaidUtil:DoTask(OldTask)
	end
end

--\* GiveTask *\--
--\* Takes in an item to clean,
--\* will return the TrashId
function Maid:GiveTask(Task)
	if not Task then
		error("Given task cannot be false or nil", 2)
	elseif not MaidUtil:IsTaskValid(Task) then
		error("Given task is bad/invalid", 2)
	end

	local TrashId = #self._Trash + 1
	self[TrashId] = Task

	return TrashId
end

function Maid:GivePromise(Promise)
	if not Promise:IsPending() then
		return Promise
	end

	local NewPromise = Promise.Resolved(Promise)
	local Id = self:GiveTask(NewPromise)

	NewPromise:Finally(function()
		self[Id] = nil
	end)

	return NewPromise
end

--\* Delayed *\--
--\* will do given task after given delay time
function Maid.Delayed(time, Task)
	assert(typeof(time) == "number")
	assert(Task ~= nil)
	
	delay(time, function()
		MaidUtil:DoTask(Task)
	end)
end

--\* DoCleaning *\--
--\* Will clean all tasks given
function Maid:DoCleaning()
	local Garbage = self._Trash

	for Index, Trash in pairs(Garbage) do
		if typeof(Trash) == "RBXScriptConnection" then
			Garbage[Index] = nil
			Trash:Disconnect()
		end
	end
	--\* Cleans all maid tasks
	--\* If more tasks are added to maid during cleaning process,
	--\* they will be added to the que
	local Key, Trash = next(Garbage)
	while Trash ~= nil do
		rawset(Garbage, Key, nil)
		MaidUtil:DoTask(Trash)

		Key, Trash = next(Garbage)
	end
end

--\* Alias Methods*\--
--\* Destroy
Maid.Destroy = Maid.DoCleaning

return Maid
