local PhysicsService = game:GetService("PhysicsService")
local CollisionsUtil = {}

function CollisionsUtil:OnCharacterAdded(Character, CollisionGroupName)
	if not Character then return end

	CollisionsUtil.SetCollisions(Character, CollisionGroupName)

	Character.DescendantAdded:Connect(function(Object)
		if not Object:IsA("BasePart") then return end
		PhysicsService:SetPartCollisionGroup(Object, CollisionGroupName)
	end)
end

function CollisionsUtil.SetCollisions(Object, CollisionGroupName)
	if Object:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(Object, CollisionGroupName)
	end
	for _, Part in pairs(Object:GetDescendants()) do
		if not Part:IsA("BasePart") then continue end
		PhysicsService:SetPartCollisionGroup(Part, CollisionGroupName)
	end
end

return CollisionsUtil