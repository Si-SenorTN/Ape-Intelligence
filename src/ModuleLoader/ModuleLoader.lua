local ReplicationUtility = require(script.Parent.ReplicationUtility)
local Replication = require(script.Parent.Replication)

local ModuleLoader = {}
ModuleLoader.ClassName = "ModuleLoader"

function ModuleLoader.new(LoadableModes, Map)
	local self = setmetatable({}, ModuleLoader)

	self._LoadableScriptTypes = LoadableModes or {
		Replication.ScriptType.Server;
		Replication.ScriptType.Client;
		Replication.ScriptType.Shared;
	}
	self.ScriptReplicationMap = Map or {}

	self.LookupTable = {}
	self.require = ReplicationUtility.RequireByName(ReplicationUtility.DetectCyclicalPatterns(require), self.LookupTable)

	return self
end

function ModuleLoader:AddModule(Module)
	assert(typeof(Module) == "Instance" and Module:IsA("ModuleScript"))

	local ScriptType = Replication.ClassifyModuleScriptType(Module, nil)
	local ActionTaken = false

	if Replication.IsInTable(self._LoadableScriptTypes, ScriptType) then
		Replication.MergeModuleIntoLookupTable(self.LookupTable, Module)
		ActionTaken = true
	end

	if self.ScriptReplicationMap[ScriptType] then
		Module.Parent = self.ScriptReplicationMap[ScriptType]
		ActionTaken = true
	end

	if not ActionTaken then	
		warn(string.format("Added module %q but was not Replicated or added to Lookup table", Module:GetFullName()))
	end
end

function ModuleLoader:AddModulesFromParent(Parent)
	assert(typeof(Parent) == "Instance", "Modules must be added from parent Instance")

	local Map = Replication.GetMapForParent(Parent)

	Replication.MergeMapIntoLookupTable(self.LookupTable, Map, self._LoadableScriptTypes)

	for ScriptType, _Parent in pairs(self.ScriptReplicationMap) do
		Replication.ReparentModulesByScriptType(Map, ScriptType, _Parent)
	end
end

function ModuleLoader:__call(...)
	return self.require(...)
end

function ModuleLoader:__index(Key)
	if ModuleLoader[Key] then
		return ModuleLoader[Key]
	end

	return self.require(Key)
end

return ModuleLoader