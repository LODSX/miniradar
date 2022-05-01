function lerp (a, b, t)
    return a + (b - a) * t
end

function swithDefaultHud(state)
    for _, component in ipairs(config.hiddenComponents) do
        setPlayerHudComponentVisible(component, state);
    end
end

function splitMask(image, x, y, sx, sy, margin)
	dxDrawImageSection(x - margin, y - margin, sx + margin * 2, margin, x - margin, y - margin, sx + margin * 2, margin, image)
	dxDrawImageSection(x - margin, y + sy, sx + margin * 2, margin, x - margin, y + sy, sx + margin * 2, margin, image)
	dxDrawImageSection(x - margin, y, margin, sy, x - margin, y, margin, sy, image)
	dxDrawImageSection(x + sx, y, margin, sy, x + sx, y, margin, sy, image)
end