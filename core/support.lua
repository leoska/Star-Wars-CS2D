--------------------------------
-- Support Functions File 	  --
-- Use Encoding: Windows 1252 --
--------------------------------

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

--[[ Parsing Functions ]]--

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
			else
				-- If there is no data
				table.insert(stata, nil)
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
			else
				-- If there is no data
				table.insert(stata, nil)
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
						-- Error here (default items here)
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
			else
				-- If there is no data
				table.insert(stata, nil)
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