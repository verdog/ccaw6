-- player/shell stuff ----------

-- player ----------------------
function p_new(x, y)
	return {
		x=x,
		y=y,
		size=4,
	}
end

function p_in_board(p, ox, oy)
	pox = p.x + ox -- p. offset x
	poy = p.y + oy -- p. offset y
	if p.size == 4 then
		return pox < 13 and pox >= 0
		and    poy < 10 and poy >= 0
	elseif p.size == 3 then
		return pox < 13 and pox >= 0
		and    poy < 12 and poy >= 0
	elseif p.size == 2 then
		return pox < 14 and pox >= 0
		and    poy < 12 and poy >= 0
	else
		return pox < 14 and pox >= 0
		and    poy < 13 and poy >= 0
	end
end

function p_tiles(p)
	tiles = {}
	if p.size == 4 then
		add(tiles, {x=p.x,   y=p.y  })
		add(tiles, {x=p.x+1, y=p.y  })
		add(tiles, {x=p.x,   y=p.y+1})
		add(tiles, {x=p.x+1, y=p.y+1})
		add(tiles, {x=p.x,   y=p.y+2})
		add(tiles, {x=p.x+1, y=p.y+2})
		add(tiles, {x=p.x,   y=p.y+3})
		add(tiles, {x=p.x+1, y=p.y+3})
	elseif p.size == 3 then
		add(tiles, {x=p.x,   y=p.y  })
		add(tiles, {x=p.x+1, y=p.y  })
		add(tiles, {x=p.x,   y=p.y+1})
		add(tiles, {x=p.x+1, y=p.y+1})
	elseif p.size == 2 then
		add(tiles, {x=p.x,   y=p.y  })
		add(tiles, {x=p.x,   y=p.y+1})
	else
		add(tiles, {x=p.x,   y=p.y  })
	end
	return tiles
end

function p_overlap_wall(p, ox, oy)
	for pxy in all(p_tiles(p)) do
		mx = pxy.x + ox + 1 -- map x
		my = pxy.y + oy + 1 -- map y
		if fget(mget(mx, my), 0) then
			return true
		end
	end
	return false
end

function
p_overlap_sh(p, sh, ox, oy)
	-- ox, oy apply to p	
	for pxy in all(p_tiles(p)) do
		for shxy in all(sh_tiles(sh)) do
			if pxy.x + ox == shxy.x
			and pxy.y + oy == shxy.y then
				return true
			end
		end
	end

	return false
end

function p_in_bounds(p, ox, oy)
	if (p_overlap_wall(p, ox, oy)) return false
	for sh in all(world.shells) do
		if p_overlap_sh(p, sh, ox, oy)
		then
			return false
		end
	end
	return p_in_board(p, ox, oy)
end

function p_can_split(p)
	fpib = p_in_bounds
	if p.size == 4
	or p.size == 3 then
		return fpib(p, 0, -1)
		and    fpib(p, 0, 1)
	elseif p.size == 2 then
		return fpib(p, 0, -1)
	else
		return false
	end
end

function p_split(p)
	shls = world.shells
	add(shls, sh_new(
		p.x, p.y - 1, p.size, true))	
	add(shls, sh_new(
		p.x,
		p.y + (p.size - 1),
		p.size, false))	
	
	if (p.size == 4) p.y += 1
	p.size -= 1
end

function p_can_merge(p)
	u = nil
	l = nil
	for sh in all(world.shells) do
		if p.size == 3
		and sh.size == 4
		and sh.x == p.x then
			if sh.y == p.y - 2 then
				u = sh
			elseif sh.y == p.y + 2 then
				l = sh
			end
		elseif p.size == 2
		and sh.size == 3
	 and (sh.x == p.x
		or sh.x == p.x - 1) then
			if sh.y == p.y - 1 then
				u = sh
			elseif sh.y == p.y + 2 then
				l = sh
			end
		elseif p.size == 1
		and sh.size == 2
		and (sh.x == p.x
		     or sh.x + 1 == p.x) then
			if sh.y == p.y - 1 then
				u = sh
			elseif sh.y == p.y + 1 then
				l = sh
			end
		end
	end
	return u, l
end

function p_merge(p, u, l)
	p.x = u.x
	del(world.shells, u)
	del(world.shells, l)
	p.size += 1
	if (p.size == 4) p.y -= 1
end

function p_update(p)
	fpib = p_in_bounds
	if btnp(⬅️)
	and fpib(p, -1, 0) then
		p.x -= 1
	elseif btnp(➡️) 
	and fpib(p, 1, 0) then
		p.x += 1
	elseif btnp(⬆️)
	and fpib(p, 0, -1) then
	 p.y -= 1
	elseif btnp(⬇️)
	and fpib(p, 0, 1) then
	 p.y += 1
	end

	if btnp(❎) then
		if p_can_split(p) then
			p_split(p)
		else
			u, l = p_can_merge(p)
			if u != nil and l != nil then
				p_merge(p, u, l)
			end
		end
	end
end

function p_draw(p)
	sx = (p.x + 1) * 8 -- screen x 
	sy = (p.y + 1) * 8 -- screen y 
	if p.size == 4 then
  spr(1, sx, sy)
		spr(1, sx + 8, sy, 1, 1, 1)
		spr(2, sx, sy + 8)
		spr(2, sx, sy + 16)
		spr(2, sx + 8, sy + 8, 1, 1, 1)
		spr(2, sx + 8, sy + 16, 1, 1, 1)
  spr(1, sx, sy + 24,
			1, 1, false, 1)
		spr(1, 
		 sx + 8, sy + 24, 1, 1, 1, 1)
	elseif p.size == 3 then
		spr(3, sx, sy)
		spr(3, sx + 8, sy, 1, 1, 1)
		spr(3, sx, sy + 8,
			1, 1, false, 1)
		spr(3, sx + 8, sy + 8,
			1, 1, 1, 1)
	elseif p.size == 2 then
		spr(4, sx, sy)
		spr(4, sx, sy + 8, 1, 1, 1, 1)
	else -- size == 1
		spr(5, sx, sy)
	end
end

-- shell -----------------------
function
sh_new(x, y, size, is_top)
	return {
		x=x,
		y=y,
		size=size,
		is_top=is_top
	}
end

function sh_tiles(sh)
	tiles = {}
	if sh.size == 4 then
		add(tiles, {x=sh.x,   y=sh.y  })
		add(tiles, {x=sh.x+1, y=sh.y  })
		add(tiles, {x=sh.x,   y=sh.y+1})
		add(tiles, {x=sh.x+1, y=sh.y+1})
	elseif sh.size == 3 then
		add(tiles, {x=sh.x,   y=sh.y  })
		add(tiles, {x=sh.x+1, y=sh.y  })
	else
		add(tiles, {x=sh.x,   y=sh.y  })
	end
	return tiles
end

function sh_draw(sh)
	sx = (sh.x + 1) * 8 -- screen x 
	sy = (sh.y + 1) * 8 -- screen y 
	if sh.size == 4 then
		spr(1, sx,
			sy + (sh.is_top and 0 or 8),
			1, 1, false, not sh.is_top)
		spr(1, sx + 8,
			sy + (sh.is_top and 0 or 8),
			1, 1, 1, not sh.is_top)
		spr(2, sx,
			sy + (sh.is_top and 8 or 0))
		spr(2, sx + 8,
			sy + (sh.is_top and 8 or 0),
			1, 1, 1)
		line(sx,
			sy + (sh.is_top and 15 or 0),
			sx + 15,
			sy + (sh.is_top and 15 or 0),
			8)
	elseif sh.size == 3 then
		spr(3, sx, sy,
			1, 1, false, not sh.is_top)
		spr(3, sx + 8, sy,
			1, 1, 1, not sh.is_top)
		line(sx + 1,
			sy + (sh.is_top and 7 or 0),
			sx + 14,
			sy + (sh.is_top and 7 or 0),
			8)
	else
		spr(4, sx, sy,
			1, 1, false, not sh.is_top)
		line(sx + 1,
			sy + (sh.is_top and 7 or 0),
			sx + 6,
			sy + (sh.is_top and 7 or 0),
			8)
	end
end
