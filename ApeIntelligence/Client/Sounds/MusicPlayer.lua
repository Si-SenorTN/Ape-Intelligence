local Player = game:GetService("Players").LocalPlayer

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("ApeIntelligence"))

local SoundService = require("SoundService")
local table = require("Table")

local MusicPlayer = {}
MusicPlayer.__index = MusicPlayer
MusicPlayer.ClassName = "MusicPlayer"

function MusicPlayer.new(Library)
	return setmetatable({
		Library = Library;
		RollOff = 1;

		SoundLibrary = SoundService.CreateSoundLibrary(Library)
	}, MusicPlayer)
end

function MusicPlayer:PlayRandomMusic(LibName)
	if not self.SoundLibrary[LibName] then return end

	local RandomizedLib = table.shuffle(self.SoundLibrary[LibName].Library)

	local Wrap = coroutine.wrap(function()
		while Player do
			for _, Table in pairs(RandomizedLib) do
				self.SoundLibrary[LibName]:PlayMusicFromLibrary(Table.SoundName, true)
				wait(self.RollOff)
			end
		end	
	end)

	Wrap()
end

return MusicPlayer
