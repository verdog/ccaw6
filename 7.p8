-- math/utilities --------------

function lerp(a, b, t)
	return a + (b - a) *
		max(0, min(t, 1))
end
