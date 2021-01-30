local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Replication = {}

function ReadOnlyTable(table)
	return setmetatable(table, {
		__index = function()
			return "The metatable is locked"
		end;

		__newindex = function()
			return "The metatable is locked"
		end;
	})
end

function Replication.ClassifyModuleScriptType(Module, Ancestor)
	if Ancestor then
		local FirstParent = Module:FindFirstAncestorWhichIsA("ModuleScript")
		if FirstParent and FirstParent:IsDescendantOf(Ancestor) then
			return Replication.ScriptType.SubModule
		end
	end

	local Parent = Module.Parent
	while Parent and Parent ~= Ancestor do
		local ParentName = Parent.Name
		if ParentName == "Server" then
			return Replication.ScriptType.Server
		elseif ParentName == "Client" then
			return Replication.ScriptType.Client
		end
		Parent = Parent.Parent
	end

	return Replication.ScriptType.Shared
end

function Replication.ReparentModulesByScriptType(Map, Type, Parent)
	assert(type(Map) == "table")
	assert(type(Type) == "string")
	assert(typeof(Parent) == "Instance")

	for _, Module in pairs(Map[Type]) do
		Module.Parent = Parent
	end
end

function Replication.GetMapForParent(Parent)
	assert(typeof(Parent) == "Instance")
	local Map = {
		[Replication.ScriptType.Shared] = {};
		[Replication.ScriptType.Client] = {};
		[Replication.ScriptType.Server] = {};
		[Replication.ScriptType.SubModule] = {};
	}

	for _, Descendant in pairs(Parent:GetDescendants()) do
		if Descendant:IsA("ModuleScript") then
			local ScriptType = Replication.ClassifyModuleScriptType(Descendant, Parent)
			table.insert(Map[ScriptType], Descendant)
		end
	end
	
	return Map
end

function Replication.MergeModuleIntoLookupTable(Module, Lookup)
	if Lookup[Module.Name] then
		warn("Duplicate of ", Module.Name, " found, using first one found")
	else
		Lookup[Module.Name] = Module
	end
end

function Replication.MergeMapIntoLookupTable(Lookup, Map, AcceptedModes)
	for _, ScriptType in pairs(AcceptedModes) do
		for _, Module in pairs(Map[ScriptType]) do
			Replication.MergeModuleIntoLookupTable(Module, Lookup)
		end
	end
end

Replication.ScriptType = ReadOnlyTable({
	Shared = "Shared";
	Client = "Client";
	Server = "Server";
	SubModule = "SubModule";
})

function Replication.IsInTable(table, Value)
	assert(type(table) == "table")
	assert(Value, "Must pass in a value to check for")

	for _, Entry in pairs(table) do
		if Entry == Value then
			return true
		end
	end
	return false
end

function Replication.CreateReplicationFolder(Name)
	assert(type(Name) == "string")
	local CheckReplicated = ReplicatedStorage:FindFirstChild(Name)
	if CheckReplicated and CheckReplicated:IsA("Folder") then
		local Children = CheckReplicated:GetChildren()
		if #Children > 1 then
			error(string.format([[A folder with the same name as %s was found, and has Children within it.\n
			Will not procceed with replication process as this will interfere.]], Name))
		else
			return CheckReplicated
		end
	end

	local ReplicationFolder = Instance.new("Folder")
	ReplicationFolder.Name = Name
	ReplicationFolder.Parent = ReplicatedStorage

	return ReplicationFolder
end

return Replication