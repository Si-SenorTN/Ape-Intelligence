local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local require = require(ReplicatedStorage:WaitForChild("ApeIntelligence"))

local Events = ReplicatedStorage:FindFirstChild("Events")
local SnackbarEvent = Events and Events:FindFirstChild("ClientSnackbarEvent")
local Snackbar = require("Snackbar")

local Sounds = {}
Sounds.__index = Sounds
Sounds.ClassName = "SoundUtility"

local function CreateSnackbar(...)
	if SnackbarEvent then
		SnackbarEvent:Fire(...)
	else
		Snackbar:CreateSnackbar(...)
	end
end

local function CreateSoundInstanceAndParent(Id, Name, Parent)
	local Sound = Instance.new("Sound")
	Sound.Name = Name
	Sound.SoundId = "rbxassetid://"..Id
	Sound.SoundGroup = Parent
	Sound.Parent = Parent
end

function Sounds.new(SoundLibrary, LibraryName)
	assert(typeof(SoundLibrary) == "table", "Passed SoundLibrary must be a dictionary containing AssetIds")
	assert(typeof(LibraryName) == "string" and not SoundService:FindFirstChild(LibraryName))

	local self = {}

	self.SoundTable = SoundLibrary
	self.SoundGroup = Instance.new("SoundGroup")
	self.SoundGroup.Name = LibraryName
	self.SoundGroup.Parent = SoundService
	self.SoundGroup.Volume = 1

	for _, Table in pairs(self.SoundTable) do
		if Table.AssetId and typeof(Table.AssetId) == "number" then
			CreateSoundInstanceAndParent(Table.AssetId, Table.SoundName, self.SoundGroup)
		end
	end

	return setmetatable(self, Sounds)
end

function Sounds:AdjustSoundLibraryVolume(NewVolume, Animated)
	local LookupLibrary = self.SoundGroup
	if Animated then
		local Info = TweenInfo.new(math.min(1, LookupLibrary.Volume/NewVolume))
		TweenService:Create(LookupLibrary, Info, {Volume = NewVolume}):Play()
	else
		LookupLibrary.Volume = NewVolume
	end
end

function Sounds:GetSoundFromLibrary(Name)
	local LookupLibrary = self.SoundGroup
	local Sound = LookupLibrary:FindFirstChild(Name)
	if Sound and Sound:IsA("Sound") then
		return Sound
	end
	warn(Sound, " is not a valid sound instance in ", LookupLibrary)
	return nil
end

function Sounds:PlayMusicFromLibrary(Name, Yield)
	local Sound = self:GetSoundFromLibrary(Name)
	if Sound then
		CreateSnackbar(("[SoundService]: Now Playing - "..Sound.Name), "Dark", 5)
		Sound:Play()
		if Yield then Sound.Ended:Wait() end
	end
end

function Sounds:StopAllSounds()
	for _, Sound in pairs(self.SoundGroup:GetChildren()) do
		if Sound:IsA("Sound") then
			Sound:Stop()
		end
	end
end

return Sounds