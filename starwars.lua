-------------------------------------------
-- Star Wars v1.0a by leoska			 --
-- Use Encoding: Windows 1252            --
-------------------------------------------
-- Credits:					--
-- 1. leoska (Author)		--
-- 2. 2SEXY (koef cycle)	--
-- Special for RU2D			--
------------------------------

---------------------------
-- List of Targets	-------
---------------------------

--[[ Namespaces (Tables) ]]--
sw = {}


--[[ Global Values ]]--
minutes = 0
seconds = 0
version = { release = 0, patch = 0, debug = "0.898a" }
admins = {} -- Admins list
adverts = {} -- Adverts list
maps = {} -- Map list
sw.stats_minutes = 0 -- Minutes for refresh (write to file) rank
sw.items = {} -- Items from FIle
sw.ranks = {} -- Rank system
sw.boxes = {} -- Boxes from File
sw.heroes = {} -- All classes
sw.heroesempire = {} -- Empire classes
sw.heroesrepublic = {} -- Republic classes
sw.heroesevents = {} -- Classes functions
sw.heroesvars = {}
sw.heroesinterface = {} -- Classes HUD Interface
sw.objects = {} -- Dynamic projectile objects
sw.p_lasers = {} -- Lasers
sw.items_koef = {} -- Dynamic percentage array
sw.base_koef = 4-- Base koefficient
sw.skills = {}
sw.rarity = {"Common", "Uncommon", "Rare", "Mythical", "Legendary"}


--[[ Dofiles ]]--
path = "sys/lua/Star Wars/"
dofile(path.."config/settings.cfg")
dofile(path.."config/config.cfg")
--dofile(path.."core/filter.lua")
dofile(path.."core/values.lua")
dofile(path.."core/updates.lua")
dofile(path.."core/support.lua")
dofile(path.."core/funcs.lua")
dofile(path.."core/basic.lua")


--[[ Addhooks ]]--
addhook("startround", "sw.startround")
addhook("endround", "sw.endround")
addhook("always", "sw.always")
addhook("second", "sw.second")
addhook("minute", "sw.minute")
addhook("attack", "sw.attack")
addhook("serveraction", "sw.serveraction")
addhook("select", "sw.select")
addhook("menu", "sw.menu")
addhook("spawn", "sw.spawn")
addhook("team", "sw.team")
addhook("join", "sw.join")
addhook("leave", "sw.leave")
addhook("hit", "sw.hitting")
addhook("say", "sw.say")
addhook("use", "sw.use")
addhook("drop", "sw.drop")
addhook("die", "sw.die")
addhook("buy", "sw.buy")

print(_VERSION)
print(os.date("%X", os.time()))
parse("restart")