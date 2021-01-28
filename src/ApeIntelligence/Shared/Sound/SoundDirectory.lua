local SoundService = game:GetService("SoundService")

local SoundObject = {}
SoundObject.__index = SoundObject

function SoundObject.new(Directory)
	return setmetatable({
		Directory = Directory
	}, SoundObject)
end

function SoundObject:GetSubSlot(SlotName)
	local Slot = self.Directory:FindFirstChild(SlotName)
	if Slot then
		return SoundObject.new(Slot)
	end
end

function SoundObject:GetSound(SoundName)
	return self.Directory:FindFirstChild(SoundName)
end

function SoundObject:GetCopy(SoundName)
	return self:GetSound(SoundName):Clone()
end

function SoundObject:Play(SoundName)
	local Sound = self:GetSound(SoundName)
	if not Sound then return end

	SoundService:PlayLocalSound(Sound)
end

function SoundObject:GetSlots()
	return self.Directory:GetChildren()
end

function SoundObject:PlayInParent(SoundName, Parent)
	local Sound = self:GetSound(SoundName)
	if not Sound then return end

	local SoundClone = Sound:Clone()
	SoundClone.Parent = Parent
	SoundClone:Play()

	return SoundClone
end

local SoundUtility = {}
SoundUtility.__index = SoundUtility

function SoundUtility.new(MainDirectory)
	return setmetatable({
		Directory = MainDirectory
	}, SoundUtility)
end

function SoundUtility:GetDirectory(DirectoryName)
	local Directory = self.Directory:FindFirstChild(DirectoryName)
	if not Directory then return end

	return SoundObject.new(Directory)
end

function SoundUtility:GetAll()
	local tab = {}
	for _, SoundGroup in pairs(self.Directory:GetChildren()) do
		if not SoundGroup:IsA("SoundGroup") and not SoundGroup:IsA("Folder") then continue end
		tab[SoundGroup.Name] = SoundObject.new(SoundGroup)
	end
	return tab
end

SoundObject.GetAll = SoundUtility.GetAll

return SoundUtility