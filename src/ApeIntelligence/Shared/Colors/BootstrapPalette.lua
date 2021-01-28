local Bootstrap = {}

local function ConvertRGBToColor3(r, g, b)
	return Color3.new(r/255, g/255, b/255)
end

--local function ConvertColor3ToRGB(r, g, b)
--	return Color3.fromRGB(r * 255, g * 255, b * 255)
--end

Bootstrap.Primary = {
	Color = ConvertRGBToColor3(2, 117, 216);
	RGB = Color3.fromRGB(2, 117, 216);
}

Bootstrap.Secondary = {
	Color = ConvertRGBToColor3(108, 117, 125);
	RGB = Color3.fromRGB(108, 117, 125);
}

Bootstrap.Success = {
	Color = ConvertRGBToColor3(40, 167, 69);
	RGB = Color3.fromRGB(40, 167, 69);
}

Bootstrap.Warning = {
	Color = ConvertRGBToColor3(255, 193, 7);
	RGB = Color3.fromRGB(255, 193, 7);
}

Bootstrap.Danger = {
	Color = ConvertRGBToColor3(220, 53, 69);
	RGB = Color3.fromRGB(220, 53, 69);
}

Bootstrap.Info = {
	Color = ConvertRGBToColor3(23, 162, 184);
	RGB = Color3.fromRGB(23, 162, 184);
}

Bootstrap.Light = {
	Color = ConvertRGBToColor3(248, 249, 250);
	RGB = Color3.fromRGB(248, 249, 250);
}

Bootstrap.Dark = {
	Color = ConvertRGBToColor3(52, 58, 64);
	RGB = Color3.fromRGB(52, 58, 64);
}

Bootstrap.Muted = {
	Color = ConvertRGBToColor3(108, 117, 125);
	RGB = Color3.fromRGB(108, 117, 125);
}

Bootstrap.White = {
	Color = Color3.new(1, 1, 1);
	RGB = Color3.fromRGB(255, 255, 255);
}

return Bootstrap