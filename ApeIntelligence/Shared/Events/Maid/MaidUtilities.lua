--\* Maid Extension *\--
--\* this is meant to be required
--\* and used by Maid class

local MaidUtil = {}

function MaidUtil:IsTaskValid(Task)
	return typeof(Task) == "function"
	or typeof(Task) == "RBXScriptConnection"
	or Task.Destroy
	or false
end

function MaidUtil:DoTask(Task)
	if typeof(Task) == "function" then
		Task()
	elseif typeof(Task) == "RBXScriptConnection" then
		Task:Disconnect()
	elseif Task.Destroy then
		Task:Destroy()
	end
end

return MaidUtil