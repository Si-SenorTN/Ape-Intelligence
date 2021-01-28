--[[
	Map: 
		local Map = {
			"Head";
			"Left Arm";
			"Right Arm";
		} -- something of this nature, specify the parts were looking for/to match to
		  -- if you use "Eyes" or "Chest" just name them the actual r6/r15 part respectively
--]]

local function MakeTransparentFromIgnoreList(Character, Ignore)
	for _, Part in pairs(Character:GetChildren()) do
		if Part:IsA("BasePart") and Ignore[Part.Name] or table.find(Ignore, Part.Name) then
			Part.Transparency = 1
		end
	end
end

local function UnanchoredCanCollideFalse(Children)
	for _, Part in pairs(Children) do
		if Part:IsA("BasePart") then
			Part.Anchored = false
			Part.CanCollide = false
			Part.Massless = true
		end
	end
end

local MorphUser = {}
MorphUser.ClassName = "MorphGiver"
MorphUser.Secondary = {
	["Shirt"] = true;
	["Pants"] = true;
	["ShirtGraphic"] = true;
	["BodyColors"] = true;
}

function MorphUser:Morph(Character, Model, Pieces, Ignore, ClearFolder)
	assert(typeof(Character) == "Instance" and Character:IsA("Model"))
	assert(typeof(Model) == "Instance" and Model:IsA("Model"))
	assert(type(Pieces) == "table")
	if Ignore then
		assert(type(Ignore) == "table")
	end

	local MorphFolder = Character:FindFirstChild("MorphFolder", true)
	if not MorphFolder or not MorphFolder:IsA("Folder") then
		MorphFolder = Instance.new("Folder")
		MorphFolder.Name = "MorphFolder"
		MorphFolder.Parent = Character
	end
	if ClearFolder then
		MorphFolder:ClearAllChildren()
	end
	local ModelClone = Model:Clone()
	ModelClone.Parent = MorphFolder

	for _, Piece in pairs(ModelClone:GetChildren()) do
		local CharPart = Character:FindFirstChild(Piece.Name)
		if CharPart and (Pieces[Piece.Name] or table.find(Pieces, Piece.Name)) then
			local Middle = Piece.Middle
			local SecondChildren = Piece:GetChildren()
			for _, Child in pairs(SecondChildren) do
				if Child.Name ~= "Middle" then
					local Weld = Instance.new("Weld")
					Weld.Part0 = Middle
					Weld.Part1 = Child
					local CJ = CFrame.new(Middle.Position)
					local C0 = Middle.CFrame:Inverse() * CJ
					local C1 = Child.CFrame:Inverse() * CJ
					Weld.C0 = C0
					Weld.C1 = C1
					Weld.Parent = Middle
				end
			end
			local Weld = Instance.new("Weld")
			Weld.Part0 = CharPart
			Weld.Part1 = Middle
			Weld.C0 = CFrame.new(0, 0, 0)
			Weld.Parent = CharPart
			UnanchoredCanCollideFalse(SecondChildren)
		end
		if self.Secondary[Piece.ClassName] then
			Piece.Parent = Character
		end
	end
	if Ignore then
		MakeTransparentFromIgnoreList(Character, Ignore)
	end
end

function MorphUser:CleanCharacterWithBlacklist(Character, Blacklist)
	assert(typeof(Character) == "Instance" and Character:IsA("Model"))
	assert(type(Blacklist) == "table")

	for _, Instance in pairs(Character:GetDescendants()) do
		if Blacklist[Instance.ClassName] or table.find(Blacklist, Instance.ClassName) then
			Instance:Destroy()
		end
	end
end

function MorphUser:CleanCharacterWithWhitelist(Character, Whitelist)
	assert(typeof(Character) == "Instance" and Character:IsA("Model"))
	assert(type(Whitelist) == "table")

	for _, Instance in pairs(Character:GetDescendants()) do
		if not Whitelist[Instance.ClassName] or not table.find(Whitelist, Instance.ClassName) then
			Instance:Destroy()
		end
	end
end

return MorphUser