---------------------
--  Valuables File --
---------------------

function array(m)
	local array = {}
	for i = 1, m do
		array[i] = 0
	end
	return array
end

function arrays(m, n)
	local array = {}
	for i = 1, m do
		array[i] = n
	end
	return array
end

--[[function arrays2d(m, n)
	local array = {}
	for i = 1, m do
		table.insert(array, n)
	end
	return array
end]]

-- Players values
sw.p_credits = array(32)
sw.p_page = array(32)
sw.p_class = array(32)
sw.p_subclass = array(32)
sw.p_health = array(32)
sw.p_barrier = array(32)
sw.p_lightsaber = {} -- 1 splash, 2 - projectile, 3 - saber
sw.p_inventory = {}
sw.p_boxes = {}
sw.p_rank = {}
sw.p_interface = {}
sw.p_set = {}
sw.p_lasthit = array(32)
sw.p_load = array(32)
sw.p_herskin = arrays(32, -1)
sw.p_herhat = arrays(32, -1)
sw.p_team = arrays(32, 0)
sw.p_times = {}
--sw.p_stats = arrays(32, {["levels"] = {}, ["exp"] = {}, ["mapexp"] = {}})

-- Fucking pointer from arrays(m, n)!!!!!!!!!!!!
for i = 1, 32 do
	sw.p_lightsaber[i] = {["splash"] = nil, ["light"] = nil, ["saber"] = nil}
	sw.p_inventory[i] = {}
	sw.p_boxes[i] = {}
	sw.p_rank[i] = {}
	sw.p_interface[i] = {}
	sw.p_set[i] = {["skin"] = 0, ["hat"] = 0}
	sw.p_times[i] = {["hpreg"] = 0, ["brreg"] = 0, ["enreg"] = 0, ["invis"] = 0, ["cd"] = 0, ["edge"] = false, ["oldwpn"] = 0, ["knife"] = false}
end