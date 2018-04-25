---------------------------
-- Update Functions File --
---------------------------

--[[function string.split(t, sub, ms)
	if t == nil or t == "" then return {t} end
	if sub == nil or sub == "" then return {t} end
	if ms == nil then ms = 0 end
	local result = {}
	local from = 1
	local delim_from, delim_to = string.find(t, sub, from  )
	local len_ = 0
	while delim_from do
		table.insert(result, string.sub(t, from , delim_from-1 ) )
		from  = delim_to + 1
		delim_from, delim_to = string.find(t, sub, from  )
		len_ = len_ + 1
		if ms ~= 0 and len_ >= ms then
			table.insert(result, result[ms].." "..string.sub(t, from))
			table.remove(result, ms)
			return result
		end
	end
	table.insert(result, string.sub(t, from ))
	return result
end

function string.count(t, sub)
	if t == nil or t == "" then return -1 end
	if sub == nil or sub == "" then return -1 end
	local last_ = 0
	local count_ = 0
	while 1 do
		if string.find(t, sub, last_) == nil then
			break
		elseif last_ <= string.find(t, sub, last_) then
			last_ = string.find(t, sub, last_)+1
			count_ = count_ + 1
		end
	end
	return count_
end]]

function string.split(t, b)
	local cmd = {}
	local match = "[^%s]+"
	if type(b) == "string" then match = "[^"..b.."]+" end
	for word in string.gmatch(t, match) do table.insert(cmd, word) end
	return cmd
end

function dist(x1, y1, x2, y2)
	return math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
end

function hudtxt2(pl, layer, c, txt, x, y, aling)
	parse('hudtxt2 '..pl..' '..layer..' "'..colors[c]..''..txt..'" '..x..' '..y..' '..aling)
end

function bio_msg2(pl, col, txt)
	msg2(pl ,colors[col]..''..txt)
end