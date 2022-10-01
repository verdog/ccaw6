-- player/shell stuff ----------

-- player ----------------------
function p_new(x, y, size)
	return {
		size=size,
		b=p_b_new(x, y, size),
		dxs=x, -- display x start
		dys=y, -- display y start
		dts=0, -- display t start
		dte=0.1, -- display t end
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

	if (p.size == 4) p.b.y += 1
	p.size -= 1
	p.b = p_b_new(p.b.x, p.b.y,
		p.size)
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
	return u, l
end

function p_merge(p, u, l)
	p.b.x = u.b.x
	del(world.shells, u)
	del(world.shells, l)
	p.size += 1
	if (p.size == 4) p.b.y -= 1
	p.b = p_b_new(p.b.x, p.b.y,
		p.size)
end

function p_update(p)
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
	elseif (dx != 0 or dy != 0)
	-- and p_can_push(p, dx, dy) then
	then
		-- try pushing
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

function sh_draw(sh)
	sx = lerp( -- screen x 
		(sh.dxs + 1) * 8, (sh.b.x + 1) * 8,
		(t() - sh.dts) / (sh.dte - sh.dts))
	sy = lerp( -- screen y 
		(sh.dys + 1) * 8, (sh.b.y + 1) * 8,
		(t() - sh.dts) / (sh.dte - sh.dts))
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
