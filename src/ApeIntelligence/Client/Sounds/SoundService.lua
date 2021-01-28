local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))

local SoundGroups = require("SoundUtilities")

local SoundService = {}
SoundService.ClassName = "SoundService"

function SoundService.CreateSoundLibrary(Map)
	local SoundLibraries = {}

	for DirName, SoundLibrary in pairs(Map) do
		SoundLibraries[DirName] = SoundGroups.new(SoundLibrary, DirName)
	end

	return SoundLibraries
end

return SoundService