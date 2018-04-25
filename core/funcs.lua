----------------------------
-- Support Functions File --
----------------------------

--[[ Read Files ]]--

function sw.load_admins()
	local f = io.open(path.."config/admins.txt", "r")
	if (f ~= nil) then
		for line in f:lines() do
			if (string.sub(line, 1, 2) ~= "//") then -- Comment string
				if (tonumber(line) ~= nil) then
					table.insert(admins, tonumber(line)) -- U.S.G.N. ID
				else
					table.insert(admins, line) -- Steam ID
				end
			end
		end
		io.close(f)
		print("File \"admins.txt\" is successfully loaded.")
	else
		print("File \"admins.txt\" is missing!")
	end
end

function sw.load_adverts()
	local f = io.open(path.."config/adverts.txt", "r")
	if (f ~= nil) then
		for line in f:lines() do
			if (string.sub(line, 1, 2) ~= "//") then -- Comment string
				table.insert(adverts, line)
			end
		end
		io.close(f)
		print("File \"adverts.txt\" is successfully loaded.")
	else
		print("File \"adverts.txt\" is missing!")
	end
end

function sw.load_maps()
	local f = io.open(path.."config/maplist.txt", "r")
	if (f ~= nil) then
		for line in f:lines() do
			if (string.sub(line, 1, 2) ~= "//") then -- Comment string
				table.insert(maps, line)
			end
		end
		io.close(f)
		print("File \"maplist.txt\" is successfully loaded.")
	else
		print("File \"maplist.txt\" is missing!")
	end
end

function sw.load_boxes()
	local f = io.open(path.."config/boxes.txt", "r")
	if (f ~= nil) then
		for line in f:lines() do
			if (string.sub(line, 1, 2) ~= "//") then -- Comment string
				if (string.sub(line, 1, 4) == "#box") then
					local stat = sw.get_table_boxes(line)
					table.insert(sw.boxes, stat)
				end
			end
		end
		io.close(f)
		print("File \"boxes.txt\" is successfully loaded.")
	else
		print("File \"boxes.txt\" is missing!")
	end
end

function sw.load_items()
	local f = io.open(path.."config/items.txt", "r")
	if (f ~= nil) then
		for line in f:lines() do
			if (string.sub(line, 1, 2) ~= "//") then -- Comment string
				if (string.sub(line, 1, 5) == "#item") then
					local stat = sw.get_table_items(line)
					table.insert(sw.items, stat)
				end
			end
		end
		io.close(f)

		-- koefficient
		sw.items_koef[1] = 1
		for i = 1, (#sw.rarity - 1) do
			sw.items_koef[i + 1] = sw.items_koef[i] / sw.base_koef
			sw.items_koef[i] = sw.items_koef[i] - sw.items_koef[i + 1]
		end

		print("File \"items.txt\" is successfully loaded.")
	else
		print("File \"items.txt\" is missing!")
	end
end

function sw.load_heroes()
	local f = io.open(path.."config/heroes.txt", "r")
	if (f ~= nil) then
		for line in f:lines() do
			if (string.sub(line, 1, 2) ~= "//") then -- Comment string
				if (string.sub(line, 1, 5) == "#hero") then
					local stat = sw.get_table_heroes(line)
					table.insert(sw.heroes, stat)

					-- Environment
					sw.heroesvars[#sw.heroes] = {}
					sw.heroesinterface[#sw.heroes] = {}

					-- Insert into Empire or Republic
					stat["classid"] = #sw.heroes
					if (stat[2] == "Empire") then
						table.insert(sw.heroesempire, stat)
					elseif (stat[2] == "Republic") then
						table.insert(sw.heroesrepublic, stat)
					else
						print("Error: "..stat[1].." has incorrect Affiliation")
					end
				end
			end
		end
		io.close(f)

		if (#sw.heroesempire < 1) then
			print("Error: Empire has no one hero")
		elseif (#sw.heroesrepublic < 1) then
			print("Error: Republic has no one hero")
		else
			print("File \"heroes.txt\" is successfully loaded.")
		end
	else
		print("File \"heroes.txt\" is missing!")
	end
end

function sw.load_ranks()
	local f = io.open(path.."data/ranks.txt", "r")
	if (f ~= nil) then
		local args, usgn, points, kills, deaths
		for line in f:lines() do
			args = string.split(line, ":")
			name = args[1]
			usgn = tonumber(args[2])
			points = tonumber(args[3])
			kills = tonumber(args[4])
			deaths = tonumber(args[5])
			table.insert(sw.ranks, {name, usgn, points, kills, deaths})
		end
		io.close(f)
		print("File \"ranks.txt\" is successfully loaded.")
	else
		print("File \"ranks.txt\" is missing!")
	end
end

function sw.load_scripts()
	-- Load Script File of Class
	for i, c in pairs(sw.heroes) do
		if (file_exists(path.."config/classes/"..c[1]..".lua")) then
			-- Create POINTER HERE
			sw.listenerclass = i
			local script = require(path.."config/classes/"..c[1])
			table.insert(sw.heroesevents, script)
			print("Script File \""..c[1]..".lua\" is successfully loaded.")
		else
			print("Script File \""..c[1]..".lua\" is missing!")
		end
	end
	sw.listenerclass = nil
end

--[[ Get Functions ]]--

function sw.get_table_boxes(line)
	local load_string = string.split(line, ":")
	local i, j, g
	local stata = {}
	local ln
	local str = ""
	for i = 1, 3 do
		if (load_string[i + 1] ~= nil) then
			ln = string.split(load_string[i + 1], " ")
			if (ln[1]) then
				if (#ln > 1) then
					str = ln[1]
					for g, j in pairs(ln) do
						if (g > 1) then
							str = str.." "..j
						end
					end
					table.insert(stata, str)
				elseif ((i < 3)) then -- Name and Group must be string!
					table.insert(stata, ln[1])
				else -- Other may be tonumber.
					table.insert(stata, tonumber(ln[1]))
				end
			end
		end
	end
	return stata
end

function sw.get_table_items(line)
	local load_string = string.split(line, ":")
	local i, j, g
	local stata = {}
	local ln
	local str = ""
	for i = 1, 6 do
		if (load_string[i + 1] ~= nil) then
			ln = string.split(load_string[i + 1], " ")
			if (ln[1]) then
				if (#ln > 1) then
					str = ln[1]
					for g, j in pairs(ln) do
						if (g > 1) then
							str = str.." "..j
						end
					end
					table.insert(stata, str)
				elseif ((i < 4) or (i == 6)) then -- Name, Group and IMG must be a string!
					table.insert(stata, ln[1])
				else -- Other may be tonumber.
					table.insert(stata, tonumber(ln[1]))
				end
			end
		end
	end
	return stata
end

function sw.get_table_heroes(line)
	local load_string = string.split(line, ":")
	local i, j, g
	local stata = {}
	local ln
	local str = ""
	for i = 1, 8 do
		if (load_string[i + 1] ~= nil) then
			ln = string.split(load_string[i + 1], " ")
			if (ln[1]) then
				if (i == 7) then -- Items
					local items = string.split(ln[1], ",")
					if (#items > 0) then
						table.insert(stata, items)
					else
						-- Error here
					end
				--[[elseif (i > 7) then -- Skills
					local skill = {}
					skill = sw.skills_check_list(ln[1])
					if (#skill > 0) then
						table.insert(stata, skill)
					end]]--
				else
					if (#ln > 1) then
						str = ln[1]
						for g, j in pairs(ln) do
							if (g > 1) then
								str = str.." "..j
							end
						end
						table.insert(stata, str)
					elseif ((i < 4) or (i == 8)) then -- Name and IMG must be a string!
						table.insert(stata, ln[1])
					else -- Other may be tonumber.
						table.insert(stata, tonumber(ln[1]))
					end
				end
			end
		end
	end
	return stata
end

function sw.get_rank_table()
	local top, flag = {}, true
	for _, p in pairs(sw.ranks) do
		-- 1: USGN; 2: Points; 3: Name
		table.insert(top, {p[2], p[3], p[1]})
	end
	-- Bubble Sort
	for i = 1, (#top - 1) do
		flag = true
		for j = 1, (#top - 1) do
			if (top[j][2] < top[j + 1][2]) then
				top[j][1], top[j + 1][1] = top[j + 1][1], top[j][1]
				top[j][2], top[j + 1][2] = top[j + 1][2], top[j][2]
				top[j][3], top[j + 1][3] = top[j + 1][3], top[j][3]
				flag = false
			end
		end
		if (flag) then
			break
		end
	end
	return top
end

function sw.get_usgn_points(id)
	local usgn = player(id, "usgn")
	if (usgn > 0) then
		for _, p in pairs(sw.ranks) do
			if (p[2] == usgn) then
				return p[3]
			end
		end
	end
	return nil
end

--[[ Menu Functions ]]--

function sw.open_menu(id, m)
	if (m == 0) then -- Main Menu
		if (player(id, "usgn") > 0) then
			local class, boxes, credits = "Not Chosen", #sw.p_boxes[id], sw.p_credits[id]
			local rank, points  = sw.check_league_rank(player(id, "usgn")), sw.get_usgn_points(id)
			local league = "No rank"
			-- NEEEEEEEEED FIXXX
			if (rank > 0) then
				league = sw.check_usgn_league(rank, points)	
			end

			if (points == nil) then
				points = ""
			end

			if (sw.p_class[id] > 0) then
				class = sw.heroes[sw.p_class[id]][1]
			end

			menu(id, "Star Wars Menu@b,Class Menu|Current Class: "..class..",Collection|Class Items and Inventory,Loot Boxes|Boxes: "..boxes..",(Shop|Credits: "..credits.."),Rank ["..league.."]|Points: "..points..",(Achievements)")
		end
	elseif (m == 1) then -- Class Menu
		local page = sw.p_page[id]
		sw.heroes_menu(id, page)
	elseif (m == 2) then -- Inventory
		menu(id, "Class Items and Inventory@b,Class Items,All Items,,,,,,Back|Main Menu")
		local page = sw.p_page[id]
		sw.items_menu(id, page)
	elseif (m == 3) then -- Loot Boxes
		local page = sw.p_page[id]
		sw.boxes_menu(id, page)
	end
end

function sw.heroes_menu(id, page)
	local i, body_menu, hero = 0, ""
	if (page == 0) then

		for i = 1, 7 do
			if (sw.p_team[id] == 1) then
				if (i <= #sw.heroesempire) then
					body_menu = body_menu..""..sw.heroesempire[i][1].." ["..sw.heroesempire[i][3].."]|Affiliation: "..sw.heroesempire[i][2]..","
				else
					body_menu = body_menu..","
				end
			elseif (sw.p_team[id] == 2) then
				if (i <= #sw.heroesrepublic) then
					body_menu = body_menu..""..sw.heroesrepublic[i][1].." ["..sw.heroesrepublic[i][3].."]|Affiliation: "..sw.heroesrepublic[i][2]..","
				else
					body_menu = body_menu..","
				end
			else
				body_menu = body_menu..","
			end
		end

		body_menu = body_menu.."Back|Main Menu"
		if (sw.p_team[id] == 1) then
			if (#sw.heroesempire > 7) then
				body_menu = body_menu..",Next|Next Page"
			end
		elseif (sw.p_team[id] == 2) then
			if (#sw.heroesrepublic > 7) then
				body_menu = body_menu..",Next|Next Page"
			end
		end
	elseif (page > 0) then

		local starti = 8 + 7 * (page - 1)
		local endi = 14 + 7 * (page - 1)
		for i = starti, endi do
			if (sw.p_team[id] == 1) then
				if (i <= #sw.heroesempire) then
					body_menu = body_menu..""..sw.heroesempire[i][1].." ["..sw.heroesempire[i][3].."]|Affiliation: "..sw.heroesempire[i][2]..","
				else
					body_menu = body_menu..","
				end
			elseif (sw.p_team[id] == 2) then
				if (i <= #sw.heroesrepublic) then
					body_menu = body_menu..""..sw.heroesrepublic[i][1].." ["..sw.heroesrepublic[i][3].."]|Affiliation: "..sw.heroesrepublic[i][2]..","
				else
					body_menu = body_menu..","
				end
			else
				body_menu = body_menu..","
			end
		end

		body_menu = body_menu.."Back|Previous Page"
		if (sw.p_team[id] == 1) then
			if (endi < #sw.heroesempire) then
				body_menu = body_menu..",Next|Next Page"
			end
		elseif (sw.p_team[id] == 2) then
			if (endi < #sw.heroesrepublic) then
				body_menu = body_menu..",Next|Next Page"
			end
		end
	end
	menu(id, "Choose Your Class Page "..(page + 1).."@b,"..body_menu)
end

function sw.items_menu(id, page)
	local i, body_menu, item = 0, ""
	if (page == 0) then
		for i = 1, 7 do
			if (i <= #sw.p_inventory[id]) then
				item = sw.p_inventory[id][i]
				body_menu = body_menu..""..sw.items[item][1].."|Category: "..sw.items[item][2]..","
			else
				body_menu = body_menu..","
			end
		end
		body_menu = body_menu.."Back|Main Menu"
		if (#sw.p_inventory[id] > 7) then
			body_menu = body_menu..",Next|Next Page"
		end
	elseif (page > 0) then
		local starti = 8 + 7 * (page - 1)
		local endi = 14 + 7 * (page - 1)
		for i = starti, endi do
			if (i <= #sw.p_inventory[id]) then
				item = sw.p_inventory[id][i]
				body_menu = body_menu..""..sw.items[item][1].."|Category: "..sw.items[item][2]..","
			else
				body_menu = body_menu..","
			end
		end
		body_menu = body_menu.."Back|Previous Page"
		if (endi < #sw.p_inventory[id]) then
			body_menu = body_menu..",Next|Next Page"
		end
	end
	menu(id, "Inventory Page "..(page + 1)..","..body_menu)
end

function sw.boxes_menu(id, page)
	local i, body_menu, box = 0, ""
	if (page == 0) then
		for i = 1, 7 do
			if (i <= #sw.p_boxes[id]) then
				box = sw.p_boxes[id][i]
				body_menu = body_menu..""..sw.boxes[box][1].."|Category: "..sw.boxes[box][2]..","
			else
				body_menu = body_menu..","
			end
		end
		body_menu = body_menu.."Back|Main Menu"
		if (#sw.p_boxes[id] > 7) then
			body_menu = body_menu..",Next|Next Page"
		end
	elseif (page > 0) then
		local starti = 8 + 7 * (page - 1)
		local endi = 14 + 7 * (page - 1)
		for i = starti, endi do
			if (i <= #sw.p_boxes[id]) then
				box = sw.p_boxes[id][i]
				body_menu = body_menu..""..sw.boxes[box][1].."|Category: "..sw.boxes[box][2]..","
			else
				body_menu = body_menu..","
			end
		end
		body_menu = body_menu.."Back|Previous Page"
		if (endi < #sw.p_boxes[id]) then
			body_menu = body_menu..",Next|Next Page"
		end
	end
	menu(id, "Loot Boxes Page "..(page + 1)..","..body_menu)
end

function sw.heroes_render_menu(id, but)
	local page = sw.p_page[id]
	if (page == 0) then
		if (but > 0 and but < 8) then
			if (sw.p_team[id] == 1) then
				sw.p_subclass[id] = sw.heroesempire[but]["classid"]
			elseif (sw.p_team[id] == 2) then
				sw.p_subclass[id] = sw.heroesrepublic[but]["classid"]
			end
			msg2(id, string.format("©128255255Your Class After The Next Spawn Will Be %s", sw.heroes[sw.p_subclass[id]][1]))
		elseif (but == 8) then
			sw.open_menu(id, 0)
		end
	elseif (page > 0) then
		local p = but + 7 + 7 * (page - 1)
		if (but > 0 and but < 8) then
			if (sw.p_team[id] == 1) then
				sw.p_subclass[id] = sw.heroesempire[p]["classid"]
			elseif (sw.p_team[id] == 2) then
				sw.p_subclass[id] = sw.heroesrepublic[p]["classid"]
			end
			msg2(id, string.format("©128255255Your Class After The Next Spawn Will Be %s", sw.heroes[sw.p_subclass[id]][1]))
		elseif (but == 8) then
			sw.p_page[id] = page - 1
			sw.heroes_menu(id, sw.p_page[id])
		end
	end
	if (but == 9) then
		sw.p_page[id] = page + 1
		sw.heroes_menu(id, sw.p_page[id])
	end
end

function sw.boxes_render_menu(id, but)
	local page = sw.p_page[id]
	if (page == 0) then
		if (but > 0 and but < 8) then
			-- Drop from box system here
			sw.item_box_drop(id, sw.p_boxes[id][but])
			table.remove(sw.p_boxes[id], but)
		elseif (but == 8) then
			sw.open_menu(id, 0)
		end
	elseif (page > 0) then
		local p = but + 7 + 7 * (page - 1)
		if (but > 0 and but < 8) then
			-- Drop from box system here
			sw.item_box_drop(id, sw.p_boxes[id][p])
			table.remove(sw.p_boxes[id], p)
		elseif (but == 8) then
			sw.p_page[id] = page - 1
			sw.boxes_menu(id, sw.p_page[id])
		end
	end
	if (but == 9) then
		sw.p_page[id] = page + 1
		sw.boxes_menu(id, sw.p_page[id])
	end
end

function sw.items_render_menu(id, but)
	local page = sw.p_page[id]
	if (page == 0) then
		if (but > 0 and but < 8) then
			-- Show item
			msg2(id, sw.p_inventory[id][but])
		elseif (but == 8) then
			sw.open_menu(id, 0)
		end
	elseif (page > 0) then
		local p = but + 7 + 7 * (page - 1)
		if (but > 0 and but < 8) then
			-- Show item
			msg2(id, sw.p_inventory[id][p])
		elseif (but == 8) then
			sw.p_page[id] = page - 1
			sw.items_menu(id, sw.p_page[id])
		end
	end
	if (but == 9) then
		sw.p_page[id] = page + 1
		sw.items_menu(id, sw.p_page[id])
	end
end

--[[ Checks Functions ]]--

function sw.item_check_hero(hero)
	for _, j in pairs(sw.heroes) do
		if (j[1] == hero) then
			return true
		end
	end
	return false
end

function sw.check_usgn_rank(id)
	local usgn, flag = player(id, "usgn"), true
	if (usgn > 0) then
		for _, p in pairs(sw.ranks) do
			if (p[2] == usgn) then
				flag = false
				local league
				local rank = sw.check_league_rank(usgn)
				local col1 = "©000255000"
				-- Show Stats
				if (rank > 0) then
					league = sw.check_usgn_league(rank, p[3])
					msg2(id, col1.."===[[ Your stats ]]===")
					msg2(id, col1.."Logged in: #"..usgn)
					msg2(id, col1.."Rank: "..rank.." of "..(#sw.ranks))
					msg2(id, col1.."League: "..league)
					msg2(id, col1.."Points: "..p[3])
					msg2(id, col1.."======================")
				end
				-- Update NickName
				if (p[1] ~= player(id, "name")) then
					p[1] = player(id, "name")
				end
				break
			end
		end
		if (flag) then

		end
	else
		local col1 = "©255000000"
		msg2(id, col1.."Please Check Your U.S.G.N. Account Settings!@C")
	end
end

function sw.check_usgn_league(rank, points)
	if (points < 500) then
		return "Bronze"
	elseif ((points >= 500) and (points < 1000)) then
		return "Silver"
	elseif ((points >= 1000) and (points < 1500)) then
		return "Gold"
	elseif ((points >= 1500) and (points < 2000)) then
		return "Platinum"
	elseif (points >= 2000) then
		if (rank <= sw_ampls_grandmaster) then
			return "GrandMaster"
		else
			return "Diamond"
		end
	end
end

function sw.check_league_rank(usgn)
	local top = sw.get_rank_table()
	for i, p in pairs(top) do
		if (usgn == p[1]) then
			return i
		end
	end
	return 0
end

--[[ Interface ]]--

function sw.hud_interface_update(id)
	local col1, col2, col3, col4 = "©128255000", "©000255000", "©255255255", "©128166255"
	local class = sw.heroes[sw.p_class[id]]
	local wpos, hpos = player(id, "screenw"), player(id, "screenh")
	if (#sw.p_interface[id] < 1) then
		-- Mask for HP bar
		local img = image("gfx/sw/pixel.bmp<n>", 0, 0, 2, id)
		imagecolor(img, 0, 0, 0)
		imagescale(img, 150, 60)
		imagepos(img, wpos / 2, hpos - 90, 0)
		imagealpha(img, 0.5)
		table.insert(sw.p_interface[id], img)

		-- Mask for classes HUD
		local x, y = wpos * 1.5 / 2, hpos - 90
		img = image("gfx/sw/pixel.bmp<n>", 0, 0, 2, id)
		imagecolor(img, 0, 0, 0)
		imagescale(img, 50 * #sw.heroesinterface[sw.p_class[id]], 70)
		imagepos(img, x, y, 0)
		imagealpha(img, 0.5)
		table.insert(sw.p_interface[id], img)
		print(x.." "..y)

		-- Classes HUD
		local mx = #sw.heroesinterface[sw.p_class[id]]
		for imgid, obj in pairs(sw.heroesinterface[sw.p_class[id]]) do
			img = image(obj, 0, 0, 2, id)
			imagepos(img, x + 50 * (imgid - 1) - 25 * (mx - 1), y - 10, 0)
			table.insert(sw.p_interface[id], img)
		end
	end

	parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, 10, col1.."Class: "..class[1], wpos / 2 - 65, hpos - 120, 0))
	if (sw.p_barrier[id] > 0) then
		parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, 11, col1.."Health: "..sw.p_health[id]..""..col3.."("..col4..""..sw.p_barrier[id]..""..col3..")"..col1.."/"..class[4], wpos / 2 - 65, hpos - 105, 0))
	else
		parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, 11, col1.."Health: "..sw.p_health[id].."/"..class[4], wpos / 2 - 65, hpos - 105, 0))
	end
	sw.hud_interface_hpbar(id)
	--parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", p, 11, col1.."Health: ", 20, 455, 0))
end

function sw.hud_interface_hpbar(id)
	local str1, str2 = "", ""
	local col1, col2, col3 = "©255255255", "©128255000", "©000128255"
	local wpos, hpos = player(id, "screenw"), player(id, "screenh")
	for i = 1, (math.ceil(sw.p_health[id] / 5)) do
		str1 = str1.."|"
	end
	for i = 1, (math.ceil(sw.p_barrier[id] / 5)) do
		str2 = str2.."|"
	end
	parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, 12, col1.."["..col2..""..str1..""..col3..""..str2..""..col1.."]", wpos / 2 - 65, hpos - 90, 0))
end

function sw.hud_interface_clear(id)
	for i = 10, 19 do
		parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, i, "", 0, 0, 0))
	end
	for _, p in pairs(sw.p_interface[id]) do
		freeimage(p)
	end
	sw.p_interface[id] = {}
end

function sw.HudAddIndicator(idhud, fname)
	if (file_exists("gfx/sw/"..fname)) then
		local stata = "<spritesheet:gfx/sw/hud/"..fname..":32:32:<n>>"
		table.insert(sw.heroesinterface[sw.listenerclass], idhud, stata)
	end
end

function sw.HudSetIndicator(id, idhud, frame, text)
	if (#sw.p_interface[id] > 1) then
		if (sw.p_interface[id][2 + idhud] ~= nil) then
			local wpos, hpos = player(id, "screenw"), player(id, "screenh")
			local x, y = wpos * 1.5 / 2, hpos - 90
			local mx = #sw.heroesinterface[sw.p_class[id]]

			imageframe(sw.p_interface[id][2 + idhud], frame)
			parse(string.format("hudtxt2 %d %d \"%s\" %d %d %d", id, 14 + idhud, text, x + 50 * (idhud - 1) - 25 * (mx - 1), y + 10, 1))
		end
	end
end

--[[ Functions for Events ]]--

function sw.HeroesHealthRegen(id, hp)
	local class = sw.heroes[sw.p_class[id]]
	if (sw.p_health[id] < class[4]) then
		sw.p_health[id] = sw.p_health[id] + hp
		if (sw.p_health[id] > class[4]) then
			sw.p_health[id] = class[4]
		end
		sw.hud_interface_update(id)
	end
end

function sw.HeroesBarrierRegen(id, bar)
	if (sw.p_lasthit[id] > 1) then
		sw.p_times[id]["brreg"] = sw.p_times[id]["brreg"] + 1
		if (sw.p_times[id]["brreg"] >= 1) then
			sw.p_times[id]["brreg"] = 0
			local class = sw.heroes[sw.p_class[id]]
			if (sw.p_barrier[id] < class[5]) then
				sw.p_barrier[id] = sw.p_barrier[id] + bar
				if (sw.p_barrier[id] > class[5]) then
					sw.p_barrier[id] = class[5]
				end
				sw.hud_interface_update(id)
			end
		end
	end
end

--[[ Functions for Vars ]]--

--[[ Other functions ]]--

function sw.createsaber(id)
	if ((sw.p_lightsaber[id]["saber"] == nil) and (sw.p_lightsaber[id]["light"] == nil)) then
		sw.p_lightsaber[id]["light"] = image("gfx/sw/flare4.bmp", 3, 0, id + 200)
		sw.p_lightsaber[id]["saber"] = image("gfx/sw/lightsaber_d.png<b>", 3, 0, id + 200)
		local img = sw.p_lightsaber[id]["saber"]
		local light = sw.p_lightsaber[id]["light"]
		if (player(id, "team") == 1) then
			--imagecolor(img, 255, 0, 0)
			imagecolor(light, 255, 0, 0)
		elseif (player(id, "team") == 2) then
			imagecolor(img, 0, 0, 255)
			imagecolor(light, 0, 0, 255)
		end
		imageblend(light, 1)
		imagealpha(light, 0.35)

		local plsl = player(0, "table")
		local px = player(id, "x")
		local py = player(id, "y")
		-- Sound of Saber (ON)
		for _, i in pairs(plsl) do
			if (dist(px, py, player(i, "x"), player(i, "y")) <= sw_sound_distance) then
				parse("sv_sound2 "..i.." \"sw/lb_on.wav\"")
			end
		end
	end
end

function sw.destroysaber(id)
	if (sw.p_lightsaber[id]["saber"] ~= nil) then
		freeimage(sw.p_lightsaber[id]["saber"])
		sw.p_lightsaber[id]["saber"] = nil
	end
	if (sw.p_lightsaber[id]["light"] ~= nil) then
		freeimage(sw.p_lightsaber[id]["light"])
		sw.p_lightsaber[id]["light"] = nil
	end

end

function sw.createlaser(id)
	local px = player(id, "x")
	local py = player(id, "y")
	local pr = math.rad(player(id, "rot") - 90)
	local incx = math.cos(pr)
	local incy = math.sin(pr)
	local imgx = px + (incx * 20)
	local imgy = py + (incy * 20)

	local img = image("gfx/sprites/laserbeam1.bmp", 0, 0, 1)
	local light = image("gfx/sprites/flare4.bmp", imgx, imgy, 1)

	if (player(id, "team") == 1) then
		imagecolor(img, 255, 0, 0)
		imagecolor(light, 255, 0, 0)
	elseif (player(id, "team") == 2) then
		imagecolor(img, 0, 0, 255)
		imagecolor(light, 0, 0, 255)
	end

	imagescale(img, 0.1, 0.8)
	imageblend(img, 1)
	imageblend(light, 1)
	imagealpha(light, 0.2)
	imagepos(img, imgx, imgy, player(id, "rot"))

	--msg("IMG: "..img)
	--msg("LIGHT: "..light)

	return {["player"] = id, ["imgid"] = img, ["lightid"] = light, ["x"] = imgx, ["y"] = imgy, ["ix"] = incx, ["iy"] = incy, ["rot"] = player(id, "rot"), ["angle"] = pr, ["livetime"] = 0}
end

function sw.destroylaser(laser)
	freeimage(sw.p_lasers[laser]["imgid"])
	freeimage(sw.p_lasers[laser]["lightid"])
	table.remove(sw.p_lasers, laser)
end

function sw.load_usgn_stats(id)
	local usgn = player(id, "usgn")

end

function sw.item_box_drop(id, box)
	local dice, rar = 1 - math.random(), 0
	for i = 1, #sw.items_koef do
		if (dice <= sw.items_koef[i]) then
			rar = i
		end
	end
	-- Drop Credits or Item?
	if (rar < 1) then
		msg("Credits: "..math.random(50, 500))
	else
		local items = {}
		for j, p in pairs(sw.items) do
			-- Group item = group box AND rarity = dice
			if ((sw.boxes[box][2] == p[2]) and (rar == p[5] + 1)) then
				table.insert(items, j)
			end
		end

		if (#items > 0) then
			local it = math.floor(math.random(1, #items))
			local item = items[it]
			table.insert(sw.p_inventory[id], item)
		else
			msg("Credits: "..math.random(50, 500))
		end
	end
end

function sw.player_reset_times(id)
	sw.p_times[id] = {["hpreg"] = 0, ["brreg"] = 0, ["enreg"] = 0, ["invis"] = 0, ["cd"] = 0, ["edge"] = false, ["oldwpn"] = 0, ["knife"] = false}
end

function sw.player_reset_values(id)
	sw.p_credits[id] = 0
	sw.p_class[id] = 0
	sw.p_subclass[id] = 0
	sw.p_lasthit[id] = 0
	sw.p_load[id] = 0
	sw.p_team[id] = 0
	sw.p_herskin[id] = nil
	sw.p_inventory[id] = {}
	sw.p_boxes[id] = {}
	sw.p_rank[id] = {}
	sw.p_interface[id] = {}
	sw.p_set[id] = {["skin"] = 0, ["hat"] = 0}
end

function sw.save_ranks()
	local f, str = assert(io.open(path.."data/ranks.txt", "w")), ""
	if (f ~= nil) then
		for _, j in pairs(sw.ranks) do
			str = ""
			for i = 1, #j do
				if (str == "") then
					str = j[1]
				else
					str = str..":"..j[i]
				end
			end
			if (str ~= "") then
				f:write(str)
			else
				print("Error: failed save ranks")
			end
		end
		io.close(f)
	end
end

function sw.player_save_boxes(id)
	if (player(id, "usgn") > 0) then
		local f = assert(io.open(path.."data/boxes/"..player(id, "usgn")..".txt", "w"))
		if (f ~= nil) then
			for i, j in pairs(sw.p_boxes[id]) do
				f:write(j)
				f:write("\n")
			end
			io.close(f)
		else
			print("Error: failed save boxes "..player(id, "usgn"))
		end
	end

	if (player(id, "steamid") ~= "0") then
		local f = assert(io.open(path.."data/boxes/"..player(id, "steamid")..".txt", "w"))
		if (f ~= nil) then
			for i, j in pairs(sw.p_boxes[id]) do
				f:write(j)
				f:write("\n")
			end
			io.close(f)
		else
			print("Error: failed save boxes "..player(id, "steamid"))
		end
	end
end

function sw.player_load_boxes(id)
	-- USGN
	if (player(id, "usgn") > 0) then
		local f = assert(io.open(path.."data/boxes/"..player(id, "usgn")..".txt", "r"))
		if (f ~= nil) then
			for line in f:lines() do
				table.insert(sw.p_boxes[id], tonumber(line))
			end
			io.close(f)
		else
			print("File \"items.txt\" is missing!")
		end
	-- SteamID
	elseif (player(id, "steamid") ~= "0") then
		local f = assert(io.open(path.."data/boxes/"..player(id, "steamid")..".txt", "r"))
		if (f ~= nil) then
			for line in f:lines() do
				table.insert(sw.p_boxes[id], tonumber(line))
			end
			io.close(f)
		else
			print("File \"items.txt\" is missing!")
		end
	end
end

function checkadmin(id)
	for i, p in pairs(admins) do
		if ((player(id, "usgn") == tonumber(p)) or (player(id, "steamid") == p)) then
			return true
		end
	end
	return false
end

function file_exists(name)
	local f = io.open(name, "r")
	if (f ~= nil) then 
		io.close(f)
		return true 
	else 
		return false 
	end
end

function freeimg(img)
	freeimage(tonumber(img))
end

function freeedge(id)
	sw.p_times[tonumber(id)]["edge"] = false
end