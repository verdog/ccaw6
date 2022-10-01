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
	world = load_level(0)
end

function _update60()
	world.ticked = false
	foreach(world.players, p_update)
	foreach(world.shells, sh_update)
	if world.ticked then
		for p in all(world.players) do
			if (p.tsleep > 0) p.tsleep -= 1
		end
	end
end

function _draw()
	cls(1)
	moff = map_offset(world.lvl)
	map(moff.x*16, moff.y*16)
	-- screen borders
	line(8, 7, 119, 7, 7) -- top
	line(7, 8, 7, 111) -- left
	line(120, 8, 120, 111) -- right
	line(8, 112, 119, 112) -- bottom

	foreach(world.players, p_draw)
	foreach(world.shells, sh_draw)
end
