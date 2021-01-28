--!strict
local Math = {}
local RobloxMath = math

local function cSquared(pointA: Vector3 | Vector2, pointB: Vector3 | Vector2): number
	return (pointB.X - pointA.X)^2 + (pointB.Y - pointA.Y)^2
end

--- Interpolates between two numbers based off percentage given
-- <number> num0
-- <number> num1
--
-- <number> interpolated num0 based off percent
Math.lerp = function(num0: number, num1: number, percent: number): number
	return num0 + ((num1 - num0) * percent)
end

--- Determines the distance between two Vector points
-- <Vector3> | <Vector2> pointA
-- <Vector3> | <Vector2> pointB
--
-- <number> distace/magnitude
Math.distance = function(pointA: Vector3 | Vector2, pointB: Vector3 | Vector2)
	return math.sqrt(cSquared(pointA, pointB))
end

--- Determines if pointA is within pointB by given radius 
-- <Vector3> | <Vector2> pointA
-- <Vector3> | <Vector2> pointB
-- <number> radius
--
-- <boolean> pointA is within radius of pointB
Math.within = function(pointA: Vector3 | Vector2, pointB: Vector3 | Vector2, radius: number): boolean
	return cSquared(pointA, pointB) <= radius*radius
end

-- EgoMoose
Math.dangle = function(a, b)
	local A, B = (math.deg(a) + 360)%360, (math.deg(b) + 360)%360;

	local d = math.abs(B - A);
	local r = d > 180 and 360 - d or d;

	local ab = A - B;
	local sign = ((ab >= 0 and ab <= 180) or (ab <= -180 and ab >= -360)) and 1 or -1;

	return math.rad(r*sign);
end

--- Determins if pointB is infront pointA given the target angle
-- <number> targAngle
-- <Vector3> facing
-- <CFrame> pointA
-- <CFrame> pointB
--
-- <boolean> pointB is infront of pointA
Math.isFront = function(targAngle: number, pointA: CFrame, pointB: CFrame)
	local Facing = pointA.LookVector
	local VectorUnit = (pointA.Position - pointB.Position).Unit
	local Angle = math.acos(Facing:Dot(VectorUnit))

	return Angle >= targAngle
end

return setmetatable({}, {
	__index = function(t, key)
		if Math[key] then
			return Math[key]
		else
			return RobloxMath[key]
		end
	end;

	__newindex = function()
		error("Cannot write into math extension", 2)
	end;
})