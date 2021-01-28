local Spring = {}
Spring.__index = Spring

function AbsDistance(x)
	return type(x) == "number" and math.abs(x) or x.Magnitude
end

-- constructors
function Spring.new(Position, Velocity, Target, Stiffness, Damping, Precision)
	local self = setmetatable({}, Spring)

	self.Position = Position
	self.Velocity = Velocity
	self.Target = Target
	self.Stiffness = Stiffness
	self.Damping = Damping
	self.Precision = Precision

	return self
end

-- methods
function Spring:Update(DeltaTime)
	local Displacement = self.Position - self.Target
	local SpringForce = -self.Stiffness * Displacement
	local DampForce = -self.Damping * self.Velocity

	local Accel = SpringForce + DampForce
	local NewVelocity = self.Velocity + Accel * DeltaTime
	local NewPos = self.Position + NewVelocity

	if AbsDistance(NewVelocity) < self.Precision and AbsDistance(self.Target - NewPos) < self.Precision then
		self.Position = self.Target
		self.Velocity -= self.Velocity
		return
	end

	self.Position = NewPos
	self.Velocity = NewVelocity
end

return Spring