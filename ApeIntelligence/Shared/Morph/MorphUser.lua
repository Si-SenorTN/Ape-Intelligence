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
		if Part:IsA("BasePart") and Ignore[Part.Name] then
			Part.Transparency = 1
		end
	end
end

local function UnanchoredCanCollideFalse(Children, Anchor)
	for _, Part in pairs(Children) do
		if Part:IsA("BasePart") then
			Part.Anchored = Anchor
			Part.CanCollide = false
		end
	end
end

local MorphUser = {}
MorphUser.ClassName = "MorphGiver"
MorphUser.Secondary = {
	["Shirt"] = true;
	["Pants"] = true;
	["ShirtGraphic"] = true;
}

function MorphUser:Morph(Character, Model, Pieces, Anchor, Ignore, ClearFolder)
	assert(typeof(Character) == "Instance" and Character:IsA("Model"))
	assert(typeof(Model) == "Instance" and Model:IsA("Model"))
	assert(typeof(Pieces) == "table")
	if Ignore then
		assert(typeof(Ignore) == "table")
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
		if CharPart and Pieces[Piece.Name] then
			local Middle = Piece.Middle -- every morph should have a middle piece, if he dont LEAVE HIS ASS (roblox moderation please, this is a joke)
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
			UnanchoredCanCollideFalse(SecondChildren, Anchor)
		end
		if self.Secondary[Piece.ClassName] then
			Piece.Parent = Character
		end
	end
	if Ignore then
		MakeTransparentFromIgnoreList(Character, Ignore)
	end
end

function MorphUser:CleanCharacter(Character, Blacklist)
	assert(typeof(Character) == "Instance" and Character:IsA("Model"))
	assert(typeof(Blacklist) == "table")

	for _, Instance in pairs(Character:GetDescendants()) do
		if Blacklist[Instance.ClassName] then
			Instance:Destroy()
		end
	end
end

return MorphUser