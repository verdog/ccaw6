function _init()
	-- color 15 is transparent
	palt(0, false)
	palt(15, true)

	-- alter button repeat speeds
	poke(0x5f5c, 5)
	poke(0x5f5d, 2)

	reset()
end

world = {}

function reset()
	world = {
		players = {p_new(0, 0, 4),
							      p_new(3, 0, 4)},
		shells = {},
		current_map = 0, 
	}
end

function _update60()
	foreach(world.players, p_update)
end

function _draw()
	cls(1)
	map(0,0)
	-- screen borders
	line(8, 7, 119, 7, 7) -- top
	line(7, 8, 7, 111) -- left
	line(120, 8, 120, 111) -- right
	line(8, 112, 119, 112) -- bottom

	foreach(world.players, p_draw)
	foreach(world.shells, sh_draw)
end
