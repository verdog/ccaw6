-- body

-- body ------------------------
function b_new(x, y, w, h)
	return {
		sx=x, -- start x
		sy=y, -- start y
		x=x, -- upper left corner
		y=y,
		w=w, -- width
		h=h, -- height
	}
end

function b_tiles(b)
	tiles = {}
	for i=b.x,b.x+b.w-1 do
		for j=b.y,b.y+b.h-1 do
			add(tiles, {x=i, y=j})
		end
	end
	return tiles
end

function b_in_board(b, ox, oy)
	box = b.x + ox
	boy = b.y + oy
	return box >= 0
	and    box + b.w-1 < 14
	and    boy >= 0
	and    boy + b.h-1 < 13
end

function
b_overlap_wall(b, ox, oy)
	moff = map_offset(world.lvl)
	for bxy in all(b_tiles(b)) do
		mx = bxy.x + ox + 1 + moff.x*16
		my = bxy.y + oy + 1 + moff.y*16
		if fget(mget(mx, my), 0) then
			return true
		end
	end
	return false
end

function
b_overlap_b(b, b2, ox, oy)
 -- can't overlap self
	if (b == b2) return false
	-- ox, oy apply to b	
	for bxy in all(b_tiles(b)) do
		for b2xy in all(b_tiles(b2)) do
			if bxy.x + ox == b2xy.x
			and bxy.y + oy == b2xy.y then
				return true
			end
		end
	end
	return false
end

function b_in_bounds(b, ox, oy)
	if b_overlap_wall(b, ox, oy) then
		return false
	end
	for p in all(world.players) do
		if b_overlap_b(b, p.b,
		ox, oy) then
			-- xxx: order matters when
			-- players are adjacent...
			return false
		end
	end
	for sh in all(world.shells) do
		if b_overlap_b(b, sh.b,
			ox, oy)
		then
			return false
		end
	end
	return b_in_board(b, ox, oy)
end
