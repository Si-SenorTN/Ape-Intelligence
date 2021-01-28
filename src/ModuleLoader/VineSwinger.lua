--\* Class inspired by Qunety's 'Nevermore' engine
--\* allows you to require modules by name

local ApeUtil = require(script.Parent.ApeUtils)
local ApeRep = require(script.Parent.ApeReplicate)

local VineSwing = {}
VineSwing.ClassName = "VineSwinger"

function VineSwing.new(LoadableModes, Map)
	local self = setmetatable({}, VineSwing)

	self._LoadableScriptTypes = LoadableModes or {
		ApeRep.ScriptType.Server;
		ApeRep.ScriptType.Client;
		ApeRep.ScriptType.Shared;
	}
	self.ScriptReplicationMap = Map or {}

	self.LookupTable = {}
	self.require = ApeUtil.RequireByName(ApeUtil.DetectCyclicalPatterns(require), self.LookupTable)

	return self
end

function VineSwing:AddModule(Module)
	assert(typeof(Module) == "Instance" and Module:IsA("ModuleScript"))

	local ScriptType = ApeRep.ClassifyModuleScriptType(Module, nil)
	local ActionTaken = false

	if ApeRep.IsInTable(self._LoadableScriptTypes, ScriptType) then
		ApeRep.MergeModuleIntoLookupTable(self.LookupTable, Module)
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

function VineSwing:AddModulesFromParent(Parent)
	assert(typeof(Parent) == "Instance", "Modules must be added from parent Instance")

	local Map = ApeRep.GetMapForParent(Parent)

	ApeRep.MergeMapIntoLookupTable(self.LookupTable, Map, self._LoadableScriptTypes)

	for ScriptType, _Parent in pairs(self.ScriptReplicationMap) do
		ApeRep.ReparentModulesByScriptType(Map, ScriptType, _Parent)
	end
end

function VineSwing:__call(...)
	return self.require(...)
end

function VineSwing:__index(Key)
	if VineSwing[Key] then
		return VineSwing[Key]
	end

	return self.require(Key)
end

return VineSwing