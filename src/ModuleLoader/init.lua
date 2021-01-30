--[[
	--\* ApeIntelligence Module Loader *\--

	A module loader religiously sampled from Quenty's 'Nevermore' Engine.
		(because i love his require by name/replication methods so much)

	::General Usage::
		Place module and its children in a preferred parent(must be in a service that replicates)

		All modules under the Client folder in the Engine will replicate to client
		All modules under the Server folder in the Engine will stay in the Server
		All modules under the Shared folder in the Engine will be free to use by both Client and Server

		Use the module loader

		local require = require(PATH_TO_THIS_MODULE)

	::Require Modules by name::

	local Maid = requrie("Maid")
	----------------------------
		self.Maid = Maid.new()
		------------------------
		self.Maid:DoCleaning()
	----------------------------
--]]
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ServerScriptServiceModules = "ApeIntelligence"
local ReplicationFolderName = "ReplicationFolder"
local ServerTimeOut = 5
local ClientTimeOut = ServerTimeOut

local Replication = require(script.Replication)
local ModuleLoader = require(script.ModuleLoader)

if RunService:IsServer() and RunService:IsClient() or not RunService:IsRunning() then
	if RunService:IsRunning() then
		warn("Loading modules in PlaySolo, it is reccomended you use accurate PlaySolo")
	end

	local Loader = ModuleLoader.new({
		Replication.ScriptType.Shared;
		Replication.ScriptType.Client;
		Replication.ScriptType.Server;
	})

	if ServerScriptServiceModules then
		local ModuleLibrary = ServerScriptService:WaitForChild(ServerScriptServiceModules, ServerTimeOut)
		if not ModuleLibrary then
			error(string.format("After waiting %d seconds, %s is not a valid member of ServerScriptService", ServerTimeOut, ServerScriptServiceModules))
		end
		Loader:AddModulesFromParent(ModuleLibrary)
	end

	return Loader
elseif RunService:IsServer() then
	local ReplicationFolder = Replication.CreateReplicationFolder(ReplicationFolderName)

	local Loader = ModuleLoader.new(
	{
		Replication.ScriptType.Server;
		Replication.ScriptType.Shared;
	},
	{
		[Replication.ScriptType.Client] = ReplicationFolder;
		[Replication.ScriptType.Shared] = ReplicationFolder;
	})

	if ServerScriptServiceModules then
		local ModuleLibrary = ServerScriptService:WaitForChild(ServerScriptServiceModules, ServerTimeOut)
		if not ModuleLibrary then
			error(string.format("After waiting %d seconds, %s is not a valid member of ServerScriptService", ServerTimeOut, ServerScriptServiceModules))
		end
		Loader:AddModulesFromParent(ModuleLibrary)
	end

	return Loader
elseif RunService:IsClient() then
	local Loader = ModuleLoader.new({
		Replication.ScriptType.Shared;
		Replication.ScriptType.Client;
	})

	local ReplicationFolder = ReplicatedStorage:WaitForChild(ReplicationFolderName, ClientTimeOut)
	if not ReplicationFolder then
		error(string.format("After waiting %d seconds, %s is not a valid member of Replicated Storage", ClientTimeOut, ReplicationFolderName))
	end
	Loader:AddModulesFromParent(ReplicationFolder)

	return Loader
else
	error("Replication process will not continue: Unknown State", 2)
end