function _init()
	palt(0, false)
	palt(15, true)

	reset()
end

world = {}

function reset()
	world = {
		player = p_new(0, 0),
		shells = {},
		current_map = 0, 
	}
end

function _update60()
	p_update(world.player)
end

function _draw()
	cls(1)
	map(0,0)
	-- screen borders
	line(8, 7, 119, 7, 7) -- top
	line(7, 8, 7, 111) -- left
	line(120, 8, 120, 111) -- right
	line(8, 112, 119, 112) -- bottom

	p_draw(world.player)
	foreach(world.shells, sh_draw)
end
