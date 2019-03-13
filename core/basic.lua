--------------------------------
-- General Functions File     --
-- Use Encoding: Windows 1252 --
--------------------------------

sw.load_admins()
sw.load_adverts()
sw.load_maps()
sw.load_heroes()
sw.load_boxes()
sw.load_items()
sw.load_ranks()
sw.load_scripts()


function sw.startround()
	local pls = player(0, "tableliving")
	-- Update HUD
	for i, p in pairs(pls) do
		sw.hud_interface_clear(p)
		sw.hud_interface_update(p)
	end
end

function sw.endround(mode)
end

function sw.always()
	local speedlaser = 5 -- Msecs
	for j, las in pairs(sw.p_lasers) do
		if ((tile(math.floor(las["x"] / 32), math.floor(las["y"] / 32), "wall")) or (las["livetime"] > 50)) then
			sw.destroylaser(j)
		else
			las["x"] = las["x"] + las["ix"] * 32
			las["y"] = las["y"] + las["iy"] * 32
			las["livetime"] = las["livetime"] + 1

			local pls = player(0, "tableliving")
			for i, p in pairs(pls) do
				if ((dist(las["x"], las["y"], player(p, "x"), player(p, "y")) <= 27) and (p ~= las["player"])) then
					if (sw.p_times[p]["edge"]) then
						local var = math.ceil(math.random(1, 3))
						local ang = math.ceil(math.random(-45, 45))
						las["angle"] = las["angle"] + math.rad(180 + ang)
						las["ix"] = math.cos(las["angle"])
						las["iy"] = math.sin(las["angle"])
						las["rot"] = math.deg(las["angle"]) - 90
						las["player"] = p

						local plss = player(0, "table")
						for _t, s in pairs(plss) do
							if (dist(las["x"], las["y"], player(s, "x"), player(s, "y")) <= sw_sound_distance) then
								parse("sv_sound2 "..s.." \"sw/lb_edge"..var..".wav\"")
							end
						end

						sw.p_times[p]["edge"] = false
					else
						sw.hit(p, las["player"], las["wpn"], las["dmg"])
						sw.destroylaser(j)
					end
				end
			end

			tween_move(las["imgid"], speedlaser, las["x"], las["y"], las["rot"])
			tween_move(las["lightid"], speedlaser, las["x"], las["y"])
		end
	end

	local projlist = projectilelist(1, 0)
	for j, proj in pairs(projlist) do
		local x = projectile(proj.id, proj.player, "x")
		local y = projectile(proj.id, proj.player, "y")
		parse('freeprojectile '..proj.id..' '..proj.player)
		parse("explosion "..x.." "..y.." 64 20 "..proj.player)
	end
end

function sw.second()
	--[[seconds = seconds + 1
	if (seconds >= 60) then
		seconds = 0
	end]]
	local pls, class = player(0, "tableliving"), 0
	-- Regen event
	for i, p in pairs(pls) do
		if (sw.p_lasthit[p] < 60) then
			sw.p_lasthit[p] = sw.p_lasthit[p] + 1
		end
		if (sw.p_class[p] > 0) then
			class = sw.heroes[sw.p_class[p]]
			sw.HeroesBarrierRegen(p, 5)

			-- Event (everysecond)
			if (sw.heroesevents[sw.p_class[p]] ~= nil) then
				if (sw.heroesevents[sw.p_class[p]].everysecond ~= nil) then
					sw.heroesevents[sw.p_class[p]].everysecond(p) -- Function Listener
				end
			end
		end
	end

	-- Event (Global Second)
	if (sw.heroesevents[sw.p_class[p]] ~= nil) then
		if (sw.heroesevents[sw.p_class[p]].globalsecond ~= nil) then
			sw.heroesevents[sw.p_class[p]].globalsecond() -- Function Listener
		end
	end
end

function sw.minute()
	minutes = minutes + 1
	-- Adverts
	if (minutes >= sw_adv_time) then 
		minutes = 0
		if (sw_adv_enable > 0) then
			local n = math.random(1, #adverts)
			parse("msg \""..string.format("%s", adverts[n]).."\"")
		end
	end
	-- Rank Stats
	sw.stats_minutes = sw.stats_minutes + 1
	if (sw.stats_minutes >= sw_stats_update) then
		sw.stats_minutes = 0
		sw.save_ranks()
	end
end

function sw.attack(id)
	local knife = sw.p_times[id]["knife"]

	if ((player(id, "weapontype") == 50) and (knife)) then
		sw.p_lightsaber[id]["splash"] = image("gfx/sw/knifeslash.bmp", 1, 0, 1)
		local img = sw.p_lightsaber[id]["splash"]
		imageblend(img, 1)
		local pr = math.rad(player(id, "rot") - 90)
		local incx = math.cos(pr)
		local incy = math.sin(pr)
		local cx = player(id, "x") + (incx * 30)
		local cy = player(id, "y") + (incy * 30)
		imagepos(img, cx, cy, player(id, "rot"))
		tween_alpha(img, 200, 0)
		timer(200, "freeimg", tostring(sw.p_lightsaber[id]["splash"]))

		-- Edge system
		sw.p_times[id]["edge"] = true
		timer(200, "freeedge", tostring(id))

		-- Sound of Light Saber
		local plsl = player(0, "table")
		for _, i in pairs(plsl) do
			if (dist(cx, cy, player(i, "x"), player(i, "y")) <= sw_sound_distance) then
				parse("sv_sound2 "..i.." \"sw/lb_slash.wav\"")
			end
		end
	elseif ((player(id, "weapontype") > 0) and (player(id, "weapontype") < 50)) then
		-- Create Laser
		table.insert(sw.p_lasers, sw.createlaser(id))

		-- Sound of Blaster
		local px = player(id, "x")
		local py = player(id, "y")
		local plsl = player(0, "table")
		for _, i in pairs(plsl) do
			if (dist(px, py, player(i, "x"), player(i, "y")) <= sw_sound_distance) then
				if (player(id, "weapontype") < 10) then
					parse("sv_sound2 "..i.." \"sw/pistol-1.wav\"")
				else
					--local n = math.ceil(math.random(1, 2))
					--parse("sv_sound2 "..i.." \"sw/trprsht"..n..".wav\"")
				end
			end
		end
	end

	-- Event (attack)
	if (sw.heroesevents[sw.p_class[id]] ~= nil) then
		if (sw.heroesevents[sw.p_class[id]].attack ~= nil) then
			sw.heroesevents[sw.p_class[id]].attack(id, player(id, "weapontype")) -- Function Listener
		end
	end
end

function sw.serveraction(id, but)
	if (but == 1) then -- Main Menu
		sw.open_menu(id, 0)
	elseif (but == 2) then
		-- (serverAction 2) F3 Event
		if (sw.heroesevents[sw.p_class[id]] ~= nil) then
			if (sw.heroesevents[sw.p_class[id]].f3 ~= nil) then
				sw.heroesevents[sw.p_class[id]].f3(id) -- Function Listener
			end
		end
	elseif (but == 3) then
		-- (serverAction 3) F4 Event
		if (sw.heroesevents[sw.p_class[id]] ~= nil) then
			if (sw.heroesevents[sw.p_class[id]].f4 ~= nil) then
				sw.heroesevents[sw.p_class[id]].f4(id) -- Function Listener
			end
		end

		table.insert(sw.p_boxes[id], 1)
	end
end

function sw.select(id, wpn)
	local knife, hero = sw.p_times[id]["knife"], sw.p_class[id]

	if ((knife) and (wpn == 50)) then
		if (sw.p_times[id]["oldwpn"] ~= 50) then
			sw.createsaber(id)
		end
	else
		sw.destroysaber(id)
	end

	-- Event (switchweapon)
	if (sw.heroesevents[sw.p_class[id]] ~= nil) then
		if (sw.heroesevents[sw.p_class[id]].switchwpn ~= nil) then
			sw.heroesevents[sw.p_class[id]].switchwpn(id, wpn, sw.p_times[id]["oldwpn"])-- Function Listener
		end
	end

	sw.p_times[id]["oldwpn"] = wpn
end

function sw.menu(id, title, but)
	if (string.sub(title, 1, 14) == "Star Wars Menu") then
		if ((but > 0) and (but < 4)) then
			sw.p_page[id] = 0
			sw.open_menu(id, but)
		end
	elseif (string.sub(title, 1, 17) == "Choose Your Class") then
		sw.heroes_render_menu(id, but)
	elseif (string.sub(title, 1, 10) == "Loot Boxes") then
		sw.boxes_render_menu(id, but)
	elseif (string.sub(title, 1, 9) == "Inventory") then
		sw.items_render_menu(id, but)
	end
end

function sw.spawn(id)
	if (player(id, "bot")) then
		local rnd = 0
		if (player(id, "team") == 1) then
			rnd = math.floor(math.random(1, #sw.heroesempire))
			sw.p_subclass[id] = sw.heroesempire[rnd]["classid"]
		elseif (player(id, "team") == 2) then
			rnd = math.floor(math.random(1, #sw.heroesrepublic))
			sw.p_subclass[id] = sw.heroesrepublic[rnd]["classid"]
		end
	end

	if (sw.p_subclass[id] == 0) then
		local col1 = "©128255255"
		if (player(id, "team") == 1) then
			sw.p_subclass[id] = sw.heroesempire[1]["classid"]
		elseif (player(id, "team") == 2) then
			sw.p_subclass[id] = sw.heroesrepublic[1]["classid"]
		end
		msg2(id, col1.."The class was automatically selected: "..sw.heroes[sw.p_subclass[id]][1])
	end

	local hero, i, str = sw.p_subclass[id], 0, ""
	sw.p_class[id] = hero
	sw.p_health[id] = sw.heroes[hero][4]
	sw.p_barrier[id] = sw.heroes[hero][5]
	parse("speedmod "..id.." "..sw.heroes[hero][6])
	sw.p_lasthit[id] = 60

	sw.player_reset_times(id)

	sw.hud_interface_update(id)

	local knife = false
	for b, i in pairs(sw.heroes[hero][7]) do
		if (b == 1) then
			sw.p_times[id]["oldwpn"] = i
		end
		str = str..""..i..","
		if (tonumber(i) == 50) then
			knife = true
		end
	end

	sw.destroysaber(id)

	if (knife) then
		if (str == "50,") then
			sw.createsaber(id)
			sw.p_times[id]["oldwpn"] = 50
		end
	end

	sw.p_times[id]["knife"] = knife


	-- Skin
	if (sw.p_set[id]["skin"] > 0) then
		local img = sw.items[sw.p_set[id]["skin"]][6]
		if (img ~= nil) then
			if (file_exists("gfx/sw/items/"..img)) then
				sw.p_herskin[id] = image("gfx/sw/items/"..img.."<m>", 3, 0, 200 + id)
			end
		end
	elseif (sw.heroes[hero][8] ~= "") then
		local img = sw.heroes[hero][8]
		if (img ~= nil) then
			if (file_exists("gfx/sw/player/"..img)) then
				sw.p_herskin[id] = image("gfx/sw/player/"..img.."<m>", 3, 0, 200 + id)
			end
		end
	end

	-- Hat
	if (sw.p_set[id]["hat"] > 0) then
		local img = sw.items[sw.p_set[id]["hat"]][6]
		if (img ~= nil) then
			if (file_exists("gfx/sw/items/"..sw.items[sw.p_set[id]["hat"]][6])) then
				sw.p_herhat[id] = image("gfx/sw/items/"..img.."<m>", 3, 0, 200 + id)
			end
		end
	end

	-- Spawn Event
	if (sw.heroesevents[sw.p_class[id]] ~= nil) then
		if (sw.heroesevents[sw.p_class[id]].onspawn ~= nil) then
			sw.heroesevents[sw.p_class[id]].onspawn(id) -- Function Listener
		end
	end
	
	return str
end

function sw.team(id, t)
	sw.p_team[id] = t
	sw.p_subclass[id] = 0
	if (sw.p_load[id] < 1) then
		if (t > 0) then
			sw.open_menu(id, 1)
		end
		sw.check_usgn_rank(id)
		--sw.load_usgn_stats(id)
		sw.p_load[id] = 1
	end
	sw.hud_interface_clear(id)
	local wpos = player(id, "screenw")
	local col1 = "©238130238"
	local col2 = "©127199255"
	parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, 0, col1.."Star Wars v"..version.debug, wpos / 2, 20, 1))
	parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, 1, col2..""..game("sv_name"), wpos / 2, 40, 1))
end

function sw.join(id)
	sw.player_load_boxes(id)
end

function sw.leave(id, reason)
	-- Destroy Images and HUDs
	sw.destroysaber(id)
	if (sw.p_herskin[id] ~= nil) then
		freeimage(sw.p_herskin[id])
		sw.p_herskin[id] = nil
	end
	if (sw.p_herhat[id] ~= nil) then
		freeimage(sw.p_herhat[id])
		sw.p_herhat[id] = nil
	end
	sw.hud_interface_clear(id)

	-- Save
	sw.player_save_boxes(id)

	-- Reset values
	sw.player_reset_values(id)
end

function sw.hit(id, source, weapon, hpdmg)
	sw.p_lasthit[id], sw.p_times[id]["hpreg"], sw.p_times[id]["brreg"] = 0, 0, 0
	if (player(id, "team") ~= player(source, "team")) then
		-- Damage (Hit)
		if (sw.p_barrier[id] > 0) then
			if (sw.p_barrier[id] < hpdmg) then
				local dmg = hpdmg - sw.p_barrier[id]
				sw.p_health[id] = sw.p_health[id] - dmg
				sw.p_barrier[id] = 0
			else
				sw.p_barrier[id] = sw.p_barrier[id] - hpdmg
			end
		else
			sw.p_health[id] = sw.p_health[id] - hpdmg
		end
		sw.hud_interface_update(id)
		-- Kill player
		if (sw.p_health[id] < 1) then
			sw.p_health[id] = 0
			parse('customkill '..source..' "DC-15a" '..id)
			--[[ Need rework!!!!!!!! ]]--
			--[[if (weapon == 32) then
				parse('customkill '..source..' "DC-15a" '..id)
			elseif (weapon == 50) then
				parse('customkill '..source..' "Lightsaber" '..id)
			elseif (weapon == 4) then
				parse('customkill '..source..' "ST-1" '..id)
			elseif (weapon == 24) then
				parse('customkill '..source..' "DC-15s" '..id)
			elseif (weapon == 35) then
				parse('customkill '..source..' "DC-15x" '..id)
			elseif (weapon == 21) then
				parse('customkill '..source..' "DC-15x" '..id)
			end]]

			sw.destroysaber(id)
			sw.hud_interface_clear(id)

			if (sw.p_herskin[id] ~= nil) then
				freeimage(sw.p_herskin[id])
				sw.p_herskin[id] = nil
			end
			if (sw.p_herhat[id] ~= nil) then
				freeimage(sw.p_herhat[id])
				sw.p_herhat[id] = nil
			end
		end	
	end
	--return 1 (New func for hook "Hit" -----> {sw.hitting})
end

function sw.hitting()
	return 1
end

function sw.say(id, txt)
	-- Check rank
	if (txt == "!rank") then
		sw.check_usgn_rank(id)
		return 1
	-- Show Top (GrandMaster League)
	elseif (txt == "!top") then
		local top = sw.get_rank_table()
		local col1 = "©255128128"
		msg2(id, col1.."=== Top "..sw_ampls_grandmaster.." ===")
		for i = 1, sw_ampls_grandmaster do
			if (top[i] ~= nil) then
				msg2(id, col1..""..i..". "..top[i][3].." ("..top[i][2].." points)")
			end
		end
		return 1
	elseif (checkadmin(id)) then
		local col1 = "©204255000"
		local col2 = "©125249255"
		msg(col1..""..player(id, "name").." (Admin): "..col2..""..txt)
		return 1
	end
end

function sw.use(id)
	-- Use Event
	if (sw.heroesevents[sw.p_class[id]] ~= nil) then
		if (sw.heroesevents[sw.p_class[id]].use ~= nil) then
			sw.heroesevents[sw.p_class[id]].use(id) -- Function Listener
		end
	end
end

function sw.drop(id)
	if (sw_droping_item == 0) then
		return 1
	end
end

function sw.die(id)
	if (sw.p_herskin[id] ~= nil) then
		freeimage(sw.p_herskin[id])
		sw.p_herskin[id] = nil
	end
	if (sw.p_herhat[id] ~= nil) then
		freeimage(sw.p_herhat[id])
		sw.p_herhat[id] = nil
	end
	sw.destroysaber(id)
	sw.hud_interface_clear(id)
	if (sw_droping_item == 0) then
		return 1
	end
end

function sw.buy(id)
	if (sw_buying_item == 0) then
		return 1
	end
end