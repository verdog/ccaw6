function _init()
	-- color 15 is transparent
	palt(0, false)
	palt(15, true)

	-- alter button repeat speeds
	poke(0x5f5c, 5)
	poke(0x5f5d, 2)

	menuitem(1, "restart", reset)

	reset()
end

game = {
	lvl = 1,
	state = "puzzle",
	prompt1 = "",
	prompt2 = "",
}
world = {}

function reset()
	world = load_level(game.lvl)
	game.state = "puzzle"
	game.sleep = 0
end

function _update60()
	if game.state == "puzzle" then
		game.prompt1 = ""
		update_puzzle()
	elseif game.state == "win" then
		game.prompt1 = "well done"
		update_win()
	elseif game.state == "title" then
		update_title()
	end
end

function update_puzzle()
	world.ticked = false
	foreach(world.players, p_update)
	foreach(world.shells, sh_update)
	if world.ticked then
		for p in all(world.players) do
			if p.tsleep > 0 then
				p.tsleep -= 1
			end
		end
	end
end

function update_win()
	if game.sleep > 0 then
		game.sleep -= 1
		return
	end

	game.lvl += 1
	if game.lvl == 6 then
		game.lvl = 1
		game.prompt2 = "that's all thanks :)"
	end
	reset()
end

function update_title()

end

function _draw()
	cls()
	map(0,0)
	-- screen borders
	line(8, 7, 119, 7, 7) -- top
	line(7, 8, 7, 111) -- left
	line(120, 8, 120, 111) -- right
	line(8, 112, 119, 112) -- bottm

	print("matryoshka", 44, 1)
	print(game.prompt1, 8, 115) 
	print(game.prompt2, 8, 121) 

	foreach(world.players, p_draw)
	foreach(world.shells, sh_draw)
end
