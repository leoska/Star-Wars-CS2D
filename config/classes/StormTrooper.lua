local class = {}

-- Init Values
local p_countdown_grenade = {}
for i = 1, 32 do
	p_countdown_grenade[i] = 0
end

sw.HudAddIndicator(1, "grena.bmp")

-- Globalsecond event
class.globalsecond = function()
end

-- Everysecond event
class.everysecond = function(id)
	if (p_countdown_grenade[id] > 0) then
		p_countdown_grenade[id] = p_countdown_grenade[id] - 1
		sw.HudSetIndicator(id, 1, 2, "©255000000"..p_countdown_grenade[id])
		if (p_countdown_grenade[id] == 0) then
			sw.HudSetIndicator(id, 1, 1, "©000255000[E]")
		end
	end
end

-- Spawn event
class.onspawn = function(id)
	p_countdown_grenade[id] = 0
	sw.HudSetIndicator(id, 1, 1, "©000255000[E]")
end

-- Attack event
class.attack = function(id, wpn)
end

-- Serveraction 2
class.f3 = function(id)
end

-- Serveraction 3
class.f4 = function(id)
end

-- Press G
class.drop = function(id)
end

-- Press E
class.use = function(id)
	if (p_countdown_grenade[id] < 1) then
		local x = player(id, "x")
		local y = player(id, "y")
		local dist = player(id, "mousedist")
		local dir = player(id, "rot")
		parse("spawnprojectile "..id.." 51 "..x.." "..y.." "..dist.." "..dir)
		p_countdown_grenade[id] = 15
		sw.HudSetIndicator(id, 1, 2, "©255000000"..p_countdown_grenade[id])
	end
end

return class