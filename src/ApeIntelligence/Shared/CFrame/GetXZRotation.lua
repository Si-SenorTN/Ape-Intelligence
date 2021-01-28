local Up = Vector3.new(0, 1, 0)

local function GetBackVector(CFrame)
	local _,_,_,_,_,R6,_,_,R9,_,_,R12 = CFrame:GetComponents()
	return Vector3.new(R6, R9, R12)
end

return function(CF)
	local BackVector = GetBackVector(CF)
	local ModBackVector = Vector3.new(BackVector.X, 0, BackVector.Z).Unit

	local Right = Up:Cross(ModBackVector)

	return CFrame.new(CF.X, CF.Y, CF.Z,
		Right.X, Up.X, ModBackVector.X,
		Right.Y, Up.Y, ModBackVector.Y,
		Right.Z, Up.Z, ModBackVector.Z
	)
end