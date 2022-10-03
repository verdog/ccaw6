-- world and levels

function map_offset(l)
	return {x=l % 8, y=flr(l/8)}
end

function load_level(l)
	w = {
		players = {},
		shells = {},
		ticked = false,
		lvl=l,
		goalx = nil,
		goaly = nil,
		copy = nil,
	}

	loff = map_offset(l)
	toplx = loff.x*16
	toply = loff.y*16

	-- copy map into cell 0
	for y=toply,toply+15 do
		for x=toplx,toplx+15 do
			mset(x-toplx, y-toply, mget(x, y))
		end
	end

	-- scan for players
	p4 = nil
	p3 = nil
	p2 = nil
	p1 = nil

	for y=1,13 do
		for x=1,14 do
			if mget(x, y) == 1 
			and mget(x, y+2) == 33
			then
				-- found p4
				p4 = p_new(x-1,y-1,4)
				for i=x,x+1 do
					for j=y,y+3 do
						mset(i, j, 16)
					end
				end
			elseif mget(x, y) == 3 
			and mget(x, y+1) == 19
			then
				-- found p3
				p3 = p_new(x-1,y-1,3)
				for i=x,x+1 do
					for j=y,y+1 do
						mset(i, j, 16)
					end
				end
			elseif mget(x, y) == 5 
			and mget(x, y+1) == 21
			then
				-- found p2
				p2 = p_new(x-1,y-1,2)
				for j=y,y+1 do
					mset(x, j, 16)
				end
			elseif mget(x, y) == 6 
			then
				-- found p1
				p1 = p_new(x-1,y-1,1)
				mset(x, y, 16)
			end
		end
	end

	-- scan for shells
	sh4u = nil
	sh4l = nil
	sh3u = nil
	sh3l = nil
	sh2u = nil
	sh2l = nil

	for y=1,13 do
		for x=1,14 do
			if mget(x, y) == 1 
			then
				sh4u = sh_new(x-1,y-1, 4,
					true)
				for i=x,x+1 do
					for j=y,y+1 do
						mset(i, j, 16)
					end
				end
			elseif mget(x, y) == 33 
			then
				sh4l = sh_new(x-1,y-1, 4,
					false)
				for i=x,x+1 do
					for j=y,y+1 do
						mset(i, j, 16)
					end
				end
			elseif mget(x, y) == 3 
			then
				sh3u = sh_new(x-1,y-1, 3,
					true)
				mset(x, y, 16)
				mset(x+1, y, 16)
			elseif mget(x, y) == 19 
			then
				sh3l = sh_new(x-1,y-1, 3,
					false)
				mset(x, y, 16)
				mset(x+1, y, 16)
			elseif mget(x, y) == 5 
			then
				sh2u = sh_new(x-1,y-1, 2,
					true)
				mset(x, y, 16)
			elseif mget(x, y) == 21 
			then
				sh2l = sh_new(x-1,y-1, 2,
					false)
				mset(x, y, 16)
			end
		end
	end

	-- nest players
	if p4 then
		if not p3 and not sh3u then
			p4.subp = p_new(0, 0, 3)
			if not p2 and not sh2u then
				p4.subp.subp = p_new(0, 0, 2)
				if not p1 then
					p4.subp.subp.subp = p_new(
					 0, 0, 1)
				end
			end
		end
		add(w.players, p4)
	end

	if p3 then
		if not p2 and not sh2u then
			p3.subp = p_new(0, 0, 2)
			if not p1 then
				p3.subp.subp = p_new(
					0, 0, 1)
			end
		end
		add(w.players, p3)
	end

	if p2 then
		if not p1 then
			p2.subp = p_new(
				0, 0, 1)
		end
		add(w.players, p2)
	end

	if p1 then
		add(w.players, p1)
	end

	if (sh2u) add(w.shells, sh2u)
	if (sh2l) add(w.shells, sh2l)
	if (sh3u) add(w.shells, sh3u)
	if (sh3l) add(w.shells, sh3l)
	if (sh4u) add(w.shells, sh4u)
	if (sh4l) add(w.shells, sh4l)

	-- find goal
	done = false
	for y=1,13 do
		for x=1,14 do
			if mget(x, y) == 48 then
				w.goalx = x-1
				w.goaly = y-1
				done = true
				break
			end
		end
		if (done) break
	end

	return w
end
