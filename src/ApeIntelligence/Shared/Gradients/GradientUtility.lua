local GradientUtility = {}

local Epsilon = .001

function GradientUtility.GradientTransparencyResize(UIGradient, Alpha, Rotation)
	if Rotation then
		UIGradient.Rotation = Rotation
	end

	if Alpha - Epsilon <= 0 then
		UIGradient.Transparency = NumberSequence.new(1, 1)
	elseif Alpha == 1 then
		UIGradient.Transparency = NumberSequence.new(0, 0)
	else
		UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(Alpha - Epsilon, 0),
			NumberSequenceKeypoint.new(Alpha, 1),
			NumberSequenceKeypoint.new(1, 1)
		})
	end
end

function GradientUtility.GradientColorResize(UIGradient, Alpha, Color0, Color1, Rotation)
	if Rotation then
		UIGradient.Rotation = Rotation
	end

	if Alpha - Epsilon <= 0 then
		UIGradient.Color = ColorSequence.new(Color1)
	elseif Alpha == 1 then
		UIGradient.Color = ColorSequence.new(Color0)
	else
		UIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color0),
			ColorSequenceKeypoint.new(Alpha - Epsilon, Color0),
			ColorSequenceKeypoint.new(Alpha, Color1),
			ColorSequenceKeypoint.new(1, Color1)
		})
	end
end

return GradientUtility