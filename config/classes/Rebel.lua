local class = {}

-- Init Values
local p_countdown_firegrenade = {}
local p_countdown_selfheal = {}
for i = 1, 32 do
	p_countdown_firegrenade[i] = 0
	p_countdown_selfheal[i] = 0
end

-- Add HUD Indicators
sw.HudAddIndicator(1, "grena.bmp")
sw.HudAddIndicator(2, "selfheal.bmp")

-- Globalsecond event
class.globalsecond = function()
end

-- Everysecond event
class.everysecond = function(id)
	if (p_countdown_firegrenade[id] > 0) then
		p_countdown_firegrenade[id] = p_countdown_firegrenade[id] - 1
		sw.HudSetIndicator(id, 1, 2, string.format("©255000000%s", p_countdown_firegrenade[id]))
		if (p_countdown_firegrenade[id] == 0) then
			sw.HudSetIndicator(id, 1, 1, "©000255000[E]")
		end
	end

	if (p_countdown_selfheal[id] > 0) then
		p_countdown_selfheal[id] = p_countdown_selfheal[id] - 1
		sw.HudSetIndicator(id, 2, 2, string.format("©255000000%s", p_countdown_selfheal[id]))
		if (p_countdown_selfheal[id] == 0) then
			sw.HudSetIndicator(id, 2, 1, "©000255000[F3]")
		end
	end
end

-- Spawn event
class.onspawn = function(id)
	p_countdown_firegrenade[id] = 0
	p_countdown_selfheal[id] = 0
	sw.HudSetIndicator(id, 1, 1, "©000255000[E]")
	sw.HudSetIndicator(id, 2, 1, "©000255000[F3]")
end

-- Attack event
class.attack = function(id, wpn)
end

-- Serveraction 2
class.f3 = function(id)
	if (p_countdown_selfheal[id] < 1) then
		sw.HeroesHealthRegen(id, 25)
		p_countdown_selfheal[id] = 17
		parse("effect \"flare\" "..player(id, "x").." "..player(id, "y").." 12 16 255 67 164")
		sw.HudSetIndicator(id, 2, 2, "©255000000"..p_countdown_selfheal[id])
	end
end

-- Serveraction 3
class.f4 = function(id)
end

-- Press G
class.drop = function(id)
end

-- Press E
class.use = function(id)
	if (p_countdown_firegrenade[id] < 1) then
		local x = player(id, "x")
		local y = player(id, "y")
		local dist = player(id, "mousedist")
		local dir = player(id, "rot")
		parse("spawnprojectile "..id.." 51 "..x.." "..y.." "..dist.." "..dir)
		p_countdown_firegrenade[id] = 15
		sw.HudSetIndicator(id, 1, 2, "©255000000"..p_countdown_firegrenade[id])
	end
end

return class