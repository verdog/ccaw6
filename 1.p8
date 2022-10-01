-- player/shell stuff ----------

-- player ----------------------
function p_new(x, y, size, subp)
	return {
		size=size,
		subp=subp, -- sub player.
		           -- may be nil
		b=p_b_new(x, y, size),
		dxs=x, -- display x start
		dys=y, -- display y start
		dts=0, -- display t start
		dte=0.1, -- display t end
		fsleep=1, -- sleep frames
		tsleep=0, -- sleep ticks
	}
end

function p_b_new(x, y, size)
	if size == 4 then
		return b_new(x, y, 2, 4)
	elseif size == 3 then
		return b_new(x, y, 2, 2)
	elseif size == 2 then
		return b_new(x, y, 1, 2)
	else
		return b_new(x, y, 1, 1)
	end
end

function p_update_display(p)
	p.dxs = p.b.x
	p.dys = p.b.y
	p.dts = t()
	p.dte = t() + 0.04 + p.size/100
end

function p_can_split(p)
	fbib = b_in_bounds
	if p.size == 4
	or p.size == 3 then
		return fbib(p.b, 0, -1)
		and    fbib(p.b, 0, 1)
	elseif p.size == 2 then
		return fbib(p.b, 0, -1)
	else
		return false
	end
end

function p_split(p)
	shls = world.shells

	u = sh_new(p.b.x, p.b.y,
		p.size, true)
	sh_update_display(u)
	u.b.y -= 1
	add(shls, u)	

	lys = p.b.y
	if p.size == 4 then
		lys = p.b.y + 2
	else -- p.size <= 3
		lys = p.b.y + 1
	end
	l = sh_new(p.b.x, lys,
		p.size, false)
	sh_update_display(l)
	l.b.y = p.b.y + p.size - 1
	add(shls, l)	

	del(world.players, p)
	if p.subp then
		add(world.players, p.subp)
		p.subp.fsleep = 1
		p.subp.b.x = p.b.x
		p.subp.b.y = p.b.y
		if p.size == 4 then 
			p.subp.b.y += 1
		end
	end
	world.ticked = true
end

function p_can_merge(p)
	u = nil
	l = nil
	for sh in all(world.shells) do
		if p.size == 3
		and sh.size == 4
		and sh.b.x == p.b.x then
			if sh.b.y == p.b.y - 2 then
				u = sh
			elseif sh.b.y == p.b.y + 2 then
				l = sh
			end
		elseif p.size == 2
		and sh.size == 3
	 and (sh.b.x == p.b.x
		or sh.b.x == p.b.x - 1) then
			if sh.b.y == p.b.y - 1 then
				u = sh
			elseif sh.b.y == p.b.y + 2 then
				l = sh
			end
		elseif p.size == 1
		and sh.size == 2
		and (sh.b.x == p.b.x
		     or sh.b.x + 1 == p.b.x) then
			if sh.b.y == p.b.y - 1 then
				u = sh
			elseif sh.b.y == p.b.y + 1 then
				l = sh
			end
		end
	end

	if u and l and u.b.x == l.b.x then
		return u, l
	end
	return nil, nil
end

function p_merge(p, u, l)
	del(world.shells, u)
	del(world.shells, l)
	del(world.players, p)
	ny = (u.size == 4)
		and p.b.y - 1 or p.b.y
	np = p_new(u.b.x, ny, p.size +1,
		p)
	add(world.players, np)
	world.ticked = true
end

function p_can_push(p, ox, oy)
	if b_overlap_wall(p.b, ox, oy) then
		return nil
	end

	for p2 in all(world.players) do
		if b_overlap_b(p.b, p2.b, ox, oy) then
			return false
		end
	end

	blockers = 0
	psh = nil

	for sh in all(world.shells) do
		if b_overlap_b(p.b, sh.b,
		ox, oy)
		and p.size >= sh.size - 1
		and b_in_bounds(sh.b, ox, oy) then
			psh = sh
			blockers += 1
		end
	end
	if (blockers == 1) return psh
	return nil
end

function p_push(p, sh, ox, oy)
	sh_update_display(sh)
	sh.b.x += ox
	sh.b.y += oy
	p_update_display(p)
	p.b.x += ox
	p.b.y += oy
	world.ticked = true
end

function p_update(p)
	if p.fsleep > 0 then
		p.fsleep -= 1
		return
	end

	if (p.tsleep > 0) return

	dx = 0
	dy = 0

	-- x input
	if (btnp(⬅️)) dx -= 1
	if (btnp(➡️)) dx += 1 
	-- y input
	if (btnp(⬆️)) dy -= 1
	if (btnp(⬇️)) dy += 1
	-- apply xy input
	if (dx != 0 or dy != 0)
	and b_in_bounds(p.b, dx, dy) then
		p_update_display(p)
		p.b.x += dx
		p.b.y += dy
		world.ticked = true
	elseif (dx != 0 or dy != 0) then
		-- try pushing
		sh = p_can_push(p, dx, dy)
		if sh then
			p_push(p, sh, dx, dy)
		end
	end

	-- split/merge
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
	sx = lerp( -- screen x 
		(p.dxs + 1)*8, (p.b.x + 1)*8,
		(t() - p.dts) / (p.dte - p.dts))
	sy = lerp( -- screen y 
		(p.dys + 1)*8, (p.b.y + 1)*8,
		(t() - p.dts) / (p.dte - p.dts))
	if p.size == 4 then
  spr(1, sx, sy, 2, 4)
	elseif p.size == 3 then
		spr(3, sx, sy, 2, 2)
	elseif p.size == 2 then
		spr(5, sx, sy, 1, 2)
	else -- size == 1
		spr(6, sx, sy)
	end
end

-- shell -----------------------
function
sh_new(x, y, size, is_top)
	if size == 4 then
		b = b_new(x, y, 2, 2)
	elseif size == 3 then
		b = b_new(x, y, 2, 1)
	else -- size == 2 
		b = b_new(x, y, 1, 1)
	end
	return {
		b=b,
		size=size,
		is_top=is_top,
		dxs=x, -- display x start
		dys=y, -- display y start
		dts=0, -- display t start
		dte=0.1, -- display t end
	}
end

function sh_update_display(sh)
	sh.dxs = sh.b.x
	sh.dys = sh.b.y
	sh.dts = t()
	sh.dte = t() + 0.08 + sh.size/100
end

function sh_can_merge(sh)
	if (not sh.is_top) return nil
	for lsh in all(world.shells) do
		if sh.size == lsh.size
		and sh.b.x == lsh.b.x
		and b_overlap_b(sh.b, lsh.b,
		0, 1) then
			return lsh	
		end
	end
	return nil
end

function sh_merge(u, l)
	p = p_new(u.b.x, u.b.y, u.size)
	p.tsleep = 3
	del(world.shells, u)
	del(world.shells, l)
	add(world.players, p)
end

function sh_update(sh)
	l = sh_can_merge(sh)
	if l then
		sh_merge(sh, l)
	end
end

function sh_draw(sh)
	sx = lerp( -- screen x 
		(sh.dxs + 1) * 8, (sh.b.x + 1) * 8,
		(t() - sh.dts) / (sh.dte - sh.dts))
	sy = lerp( -- screen y 
		(sh.dys + 1) * 8, (sh.b.y + 1) * 8,
		(t() - sh.dts) / (sh.dte - sh.dts))
	if sh.size == 4 then
		spr((sh.is_top) and 1 or 33,
			sx, sy, 2, 2)
	elseif sh.size == 3 then
		spr((sh.is_top) and 3 or 19,
			sx, sy, 2, 1)
	else
		spr((sh.is_top) and 5 or 21,
			sx, sy, 1, 1)
	end
end
