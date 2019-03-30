--- Timer module
---------------------------
function Timer()
	local indexOf = function(t, value)
		for i, v in ipairs(t) do
			if v == value then
				return i
			end
		end
		return false
	end
	local timeMas = {}
	local holeIndex = {}
	local usedIndex = {}
	local removeIndex = {}
	local methods = {
		newTimer = function(calback, time, loop, ...)
			local index = #timeMas + 1
			if #holeIndex > 0 then
				index = holeIndex[1]
				table.remove(holeIndex, 1)
			end
			loop = not (not loop)
			timeMas[index] = {fn = calback, ms = time, currentTime = os.time(), loop = loop, oldTime = time, arg = {...}}
			table.insert(usedIndex, index)
			return index
		end,
		removeTimer = function(timerId)
			if not timerId then
				timerId = false
			end
			table.insert(removeIndex, timerId)
		end
	}
	function removeTimer()
		for _, timerId in pairs(removeIndex) do
			if timerId == false then
				timeMas = {}
				usedIndex = {}
				holeIndex = {}
				break
			else
				local findI = indexOf(usedIndex, timerId)
				if findI then
					timeMas[timerId] = nil
					table.remove(usedIndex, findI)
					table.insert(holeIndex, timerId)
				end
			end
		end
		removeIndex = {}
	end
	methods.run = function()
		removeTimer()
		for key, val in pairs(timeMas) do
			timeMas[key].ms = val.ms - os.difftime(os.time(), val.currentTime)
			timeMas[key].currentTime = os.time()

			if val.ms <= 0 then
				val.fn(key, table.unpack(val.arg))
				if val.loop then
					timeMas[key].ms = val.oldTime + val.ms
					timeMas[key].currentTime = os.time()
				else
					methods.removeTimer(key)
				end
			end
		end
		removeTimer()
	end
	return methods
end
local timers = Timer()
function setTimeout(func, time, loop)
	return timers.newTimer(func, time, loop ~= nil and loop or false)
end
---------------------------

local settings = {
	difficulties = {
		[1] = {
			time = 120,
			maps = {
				{
					map = "@6098326",
					gravity = 10,
					wind = 0
				},
				{
					map = "@6127996",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7585590",
					gravity = 10,
					wind = 0
				},
				{
					map = "94",
					gravity = 10,
					wind = 0
				},
				{
					map = "93",
					gravity = 10,
					wind = 0
				},
				{
					map = "@1804382",
					gravity = 10,
					wind = 0
				}
			}
		 -- @1804382
		},
		[2] = {
			time = 120,
			maps = {
				{
					map = "@3981622",
					gravity = 10,
					wind = 0
				},
				{
					map = "@6099672",
					gravity = 10,
					wind = 0
				},
				{
					map = "@6099790",
					gravity = 10,
					wind = 0
				},
				{
					map = "@6131429",
					gravity = 10,
					wind = 0
				},
				{
					map = "@6119237",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7007184",
					gravity = 10,
					wind = 0
				},
				{
					map = "@1755112",
					gravity = 10,
					wind = 0
				},
				{
					map = "@1936415",
					gravity = 10,
					wind = 0
				}
			} -- @7007184 @1755112 @1936415
		},
		[3] = {
			time = 120,
			maps = {
				{
					map = "@6106612",
					gravity = 10,
					wind = 0
				},
				{
					map = "@3041325",
					gravity = 10,
					wind = 0
				},
				{
					map = "@2270547",
					gravity = 10,
					wind = 0
				},
				{
					map = "@3591685",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7585593",
					gravity = 10,
					wind = 0
				}
			} -- @3041325 @2270547 @3591685
		},
		[4] = {
			time = 120,
			maps = {
				{
					map = "@6131429",
					gravity = 10,
					wind = 0
				},
				{
					map = "@4509035",
					gravity = 10,
					wind = 0
				},
				{
					map = "@5723863",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7585946",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7585687",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7586938",
					gravity = 13,
					wind = -10
				},
				{
					map = "@7586799",
					gravity = 10,
					wind = 0
				},
			} -- @4509035 @5723863 @7585946
		},
		[5] = {
			time = 150,
			maps = {
				{
					map = "@6116891",
					gravity = 10,
					wind = 0
				},
				{
					map = "@6117158",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7586022",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7585766",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7585651",
					gravity = 10,
					wind = 0
				},
				{
					map = "@7585606",
					gravity = 10,
					wind = 0
				}
			}
		}
	},
	admins = {"Qweqwenoob#0000", "Zxrussia#0000"}
}

local room = {
	currentGame = {
		shaman = nil,
		winningMice = {},
		map = {},
		mapDifficulty = 1
	},
	playerHistory = {}
}

local commands = {
	["help"] = function(args)
		ui.addTextArea(-1, "{{textareas/help.xml}}", args.playerName, 200, 140, 440, 170, 0x1B1B1B, 0x000000, 0.9, true)
	end,
	["lb"] = function(args)
		displayLeadeboard(args.playerName)
	end,
	["skip"] = function(args)
		if args.playerName == room.shaman then
			newGame()
		end
	end,
	["mort"] = function(args)
		tfm.exec.killPlayer(args.playerName)
	end,
	["setdiff"] = function(args)
		local diffs
		local temp = string.find(args[1], "-")
		if temp ~= nil then
			local splitted = string.split(args[1], "-")
			diffs = {
				minDiff = tonumber(splitted[1]),
				maxDiff = tonumber(splitted[2])
			} --cuz gmatch slow
		elseif args[1] ~= nil then
			diffs = {
				minDiff = tonumber(args[1]),
				maxDiff = tonumber(args[1])
			}
		end

		if diffs.minDiff ~= nil and diffs.maxDiff ~= nil then
			if
				table.containsKey(settings.difficulties, diffs.minDiff) and table.containsKey(settings.difficulties, diffs.maxDiff)
			 then
				room.playerHistory[args.playerName].maxDiff = math.max(diffs.minDiff, diffs.maxDiff)
				room.playerHistory[args.playerName].minDiff = math.min(diffs.minDiff, diffs.maxDiff)
			end
		end

		print(
			"Difficult setted: " ..
				room.playerHistory[args.playerName].minDiff .. "-" .. room.playerHistory[args.playerName].maxDiff
		)
	end,
	["closeTextArea"] = function(args)
		ui.removeTextArea(args[1], args.playerName)
	end,
	["closelb"] = function(args)
		closeLeaderboard(args.playerName)
	end,
	["lbpreviouspage"] = function(args)
		if not table.containsKey(showedLeaderboards, playerName) then
			return
		end

		local currentPage = showedLeaderboards[playerName].currentPage
		updateLeaderboardTable(args.playerName, currentPage - 1)
	end,
	["lbnextpage"] = function(args)
		if not table.containsKey(showedLeaderboards, playerName) then
			return
		end

		local currentPage = showedLeaderboards[playerName].currentPage
		updateLeaderboardTable(args.playerName, currentPage + 1)
	end
}

local adminCommands = {
	["map"] = function(args)
		if (args[1] == nil) then
			newGame()
		else
			newGame({map = args[1], gravity = nil, wind = nil, difficulty = 1})
		end
	end,
	["vamp"] = function(args)
		tfm.exec.setVampirePlayer(args[1] and args[1] or args.playerName)
	end,
	["res"] = function(args)
		tfm.exec.respawnPlayer(args[1] and args[1] or args.playerName)
	end,
	["sham"] = function(args)
		tfm.exec.setShaman(args[1] and args[1] or args.playerName)
	end,
	["kill"] = function(args)
		if (args[1] ~= nil) then
			tfm.exec.killPlayer(args[1])
		else
			for k, v in pairs(tfm.get.room.playerList) do
				if not v.isDead then
					tfm.exec.killPlayer(k)
				end
			end
		end
	end,
	["time"] = function(args)
		tfm.exec.setGameTime(args[1] and args[1] or 120, true)
	end
}

adminCommands["shaman"] = adminCommands["sham"]
adminCommands["respawn"] = adminCommands["res"]

tfm.exec.disableAllShamanSkills(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoTimeLeft(true)

function init()
	-------------------------------------------------
	for k, v in pairs(tfm.get.room.playerList) do
		eventNewPlayer(k)
	end

	newGame()
end

-- fix for bug when there is any phisycal object on map and it was caled with summoningend
local shamanCantSpawn = true

function onRoundEnd()
	if room.currentGame.shaman ~= nil and room.currentGame.winningMice ~= nil then
		local currentExp = room.playerHistory[room.currentGame.shaman].experience
		local earnedExp = calculateExperience(#room.currentGame.winningMice, room.currentGame.map.difficulty)

		print(room.currentGame.shaman .. " earned " .. earnedExp .. "xp.")

		room.playerHistory[room.currentGame.shaman].experience = currentExp + earnedExp

		if
			room.playerHistory[room.currentGame.shaman].experience >=
				nextLevel(room.playerHistory[room.currentGame.shaman].level + 1)
		 then
			room.playerHistory[room.currentGame.shaman].level = room.playerHistory[room.currentGame.shaman].level + 1
		end

	-- add exp to shaman
	end

	room.currentGame.winningMice = {}
end

function newGame(mapinfo)
	shamanCantSpawn = true
	setTimeout(
		function()
			shamanCantSpawn = false
		end,
		3000
	)

	onRoundEnd()

	for k, v in pairs(tfm.get.room.playerList) do
		if v.inHardMode == 2 then
			tfm.exec.setPlayerScore(k, -1)
		end
	end

	room.currentGame.shaman = getShamFromScore()

	tfm.exec.setPlayerScore(room.currentGame.shaman, 0)

	print("Got shaman with nickname: " .. room.currentGame.shaman)

	room.currentGame.map = mapinfo == nil and getRandomMapForPlayer(room.currentGame.shaman) or mapinfo

	print("Got map for new game: " .. room.currentGame.map.map)

	tfm.exec.newGame(room.currentGame.map.map)

	ui.setMapName("<CH>" .. room.currentGame.map.map .. "<N> - Difficulty " .. room.currentGame.map.difficulty)
	ui.setShamanName(
		"<CH>" .. room.currentGame.shaman .. "<VP> Lvl. " .. room.playerHistory[room.currentGame.shaman].level
	)

	messageBox(getMapDescription(room.currentGame.map), 5000)

	setTimeout(
		function()
			print("Setting " .. room.currentGame.shaman .. " as shaman")
			tfm.exec.setShaman(room.currentGame.shaman)
		end,
		3000
	)

	print("Waiting 3 seconds before setting " .. room.currentGame.shaman .. " as shaman")

	if tfm.get.room.playerList[room.currentGame.shaman].inHardMode == 2 then
		print("Killing " .. room.currentGame.shaman .. " because of divine.")

		tfm.exec.killPlayer(room.currentGame.shaman)
		messageBox("Disable divine mode!", 10, room.currentGame.shaman)
	end
end

function nextLevel(level)
	local exponent = 1.3
	local baseXP = 30
	return math.floor(baseXP * (level ^ exponent))
end

function calculateExperience(miceCount, difficulty)
	local exp = 0
	for i = 1, miceCount do
		exp = exp + (10 * difficulty * (1 / i))
	end
	return exp
end

function getRandomMapForPlayer(playerName)
	local randDiff = math.random(room.playerHistory[playerName].minDiff, room.playerHistory[playerName].maxDiff)
	local randMapIndex = math.random(#settings.difficulties[randDiff].maps)
	local result = settings.difficulties[randDiff].maps[randMapIndex]
	result["difficulty"] = randDiff

	print("Found random map for player " .. playerName .. ": " .. result.map)

	return result
end

function getMapDescription(mapinfo)
	local gravity = mapinfo.gravity ~= nil and mapinfo.gravity or "Unknown"
	local wind = mapinfo.wind ~= nil and mapinfo.wind or "Unknown"
	return "Gravity: " .. gravity .. "\t Wind: " .. wind
end

function getShamFromScore() --string
	local score = -1
	local nickname
	for k, v in pairs(tfm.get.room.playerList) do 
		-- print(k .. " " .. v.score)
		if v.score > score then
			score = v.score
			nickname = k
		end
	end
	return nickname
end

function isAllDead()
	for k, v in pairs(tfm.get.room.playerList) do
		if not v.isDead then
			print("Not all dead because of " .. k .. " is live.")
			return false
		end
	end
	return true
end

local showedLeaderboards = {}

local leaderboardTitle = {
	text = "{{textareas/lbtitle.xml}}",
	x = 100,
	y = 80,
	width = 600,
	height = 30,
	opacity = 0.8
}

local leaderboardCloseButton = {
	text = "{{textareas/lbclosebutton.xml}}",
	x = leaderboardTitle.x + 575,
	y = leaderboardTitle.y + 8,
	width = 15,
	height = 15,
	opacity = 0.3
}

local leaderboardTable = {
	text = "",
	x = leaderboardTitle.x,
	y = leaderboardTitle.y,
	width = leaderboardTitle.width,
	height = 240,
	opacity = 0.8
}

local leaderboardPreviousPageButton = {
	text = "{{textareas/lbpreviuspagebutton.xml}}",
	x = leaderboardTable.x + leaderboardTable.width - 100,
	y = leaderboardTitle.y + leaderboardTable.height + 15,
	width = 20,
	height = 20,
	opacity = 0.8
}

local leaderboardCurrentPage = {
	text = "<p align='center'><b>1</b></p>",
	x = leaderboardPreviousPageButton.x + 40,
	y = leaderboardPreviousPageButton.y,
	width = 20,
	height = 20,
	opacity = 0.8
}

local leaderboardNextPageButton = {
	text = "{{textareas/lbnextpagebutton.xml}}",
	x = leaderboardCurrentPage.x + 40,
	y = leaderboardPreviousPageButton.y,
	width = 20,
	height = 20,
	opacity = 0.8
}

function showLeaderboardCurrentPage(playerName, page)
	local leaderboardCurrentPage = {
		text = "<p align='center'><b>" .. page .. "</b></p>",
		x = leaderboardPreviousPageButton.x + 40,
		y = leaderboardPreviousPageButton.y,
		width = 20,
		height = 20,
		opacity = 0.8
	}
	return showObjectToPlayer(leaderboardCurrentPage, playerName)
end

function ljustify(str, size)
	local len = str:len()

	if len >= size then
		return str
	end

	local result = str

	for i = 1, size - len do
		result = result .. " "
	end

	return result
end

function getKeysSortedByValue(tbl, sortFunction)
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	table.sort(
		keys,
		function(a, b)
			return sortFunction(tbl[a], tbl[b])
		end
	)

	return keys
end

function sortedLeaderboardKeys()
	return getKeysSortedByValue(
		room.playerHistory,
		function(a, b)
			return a.level > b.level
		end
	)
end

function showTableToPlayer(columns, rows, height, x, y, player)
	local currentX = x

	local columnsIndexes = {}

	for i, v in ipairs(columns) do
		local text = ""
		for _, row in ipairs(rows) do
			text = text .. row[i] .. "<br/>"
		end

		local columnobj = {
			text = text,
			x = currentX,
			y = y,
			width = v.width,
			height = heigh,
			opacity = 0
		}
		currentX = currentX + v.width

		local fmt = "Showing object with text %s at {%s,%s}"

		print(fmt:format(text, columnobj.x, columnobj.y))

		columnsIndexes[i] = showObjectToPlayer(columnobj, player)
		print("Showed column with index " .. columnsIndexes[i])
	end

	return columnsIndexes
end

function updateLeaderboardTable(playerName, page)
	if page <= 0 then
		page = 1
	end

	if showedLeaderboards[playerName] == nil then
		return --something went wrong
	end

	if page == showedLeaderboards[playerName].currentPage == page then
		return --something went wrong
	end

	for i, column in ipairs(showedLeaderboards[playerName].content) do
		ui.removeTextArea(column, playerName)
	end

	showLeaderboardTable(playerName, page)
end

function showLeaderboardTable(playerName, page)
	local rows = {
		{
			"<font size='12' color='#D8D8D8'><b> #</b></font>",
			"<font size='12' color='#D8D8D8'><b>Name</b></font>",
			"<font size='12' color='#D8D8D8'><b>Level</b></font>",
			"<font size='12' color='#D8D8D8'><b>Experience</b></font>",
			"<font size='12' color='#D8D8D8'><b>Next level</b></font>",
			"<font size='12' color='#D8D8D8'><b>Difficulties</b></font>"
		}
	}

	local sortedNames = sortedLeaderboardKeys()

	local perPage = 10

	local pages = math.floor(#sortedNames / perPage)

	if page > pages then
		page = pages
	elseif page < 0 then
		page = 1
	end

	local starting = 1 + page * perPage
	local ending = starting + 10

	print("Showing leaderboard to " .. playerName .. " from " .. starting .. " to " .. ending)

	for i, key in ipairs(sortedNames) do
		if i >= starting and i < ending then
			local isMe = room.playerHistory[key].playerName == playerName
			local row = {
				"<font size='12' color='" .. (isMe and "#BABD2F" or "#D8D8D8") .. "'> " .. i .. ".</font>",
				"<font size='12' color='" ..
					(isMe and "#BABD2F" or "#D8D8D8") .. "'>" .. room.playerHistory[key].playerName .. "</font>",
				"<font size='12' color='#D8D8D8'>" .. room.playerHistory[key].level .. "</font>",
				"<font size='12' color='#D8D8D8'>" .. room.playerHistory[key].experience .. "</font>",
				"<font size='12' color='#D8D8D8'>" .. nextLevel(room.playerHistory[key].level + 1) .. "</font>",
				"<font size='12' color='#D8D8D8'>" ..
					room.playerHistory[key].minDiff .. " - " .. room.playerHistory[key].maxDiff .. "</font>"
			}

			rows[#rows + 1] = row
		end
	end

	return showTableToPlayer(
		{
			{width = 40},
			{width = 180},
			{width = 100},
			{width = 100},
			{width = 100},
			{width = 100}
		},
		rows,
		leaderboardTable.height - leaderboardTitle.height - 10,
		leaderboardTable.x,
		leaderboardTable.y + leaderboardTitle.height + 10,
		playerName
	)
end

function showObjectToPlayer(obj, playerName)
	local index = createAreaIndex()
	ui.addTextArea(
		index,
		obj.text,
		playerName,
		obj.x, --x
		obj.y, --y
		obj.width, --width
		obj.height, --height
		0x1B1B1B,
		0x000000,
		obj.opacity,
		true
	)
	return index
end

function closeLeaderboard(playerName)
	if (showedLeaderboards[playerName] == nil) then
		print("There is no opened leaderboard for " .. playerName .. ", returning.")
		return
	end

	for k, v in pairs(showedLeaderboards[playerName].indexes) do
		if (k == "content") then
			for i, column in ipairs(v) do
				ui.removeTextArea(column, playerName)
			end
		else
			ui.removeTextArea(v, playerName)
		end
	end
end

function displayLeadeboard(playerName)
	if (showedLeaderboards[playerName] ~= nil) then
		closeLeaderboard(playerName)
	end

	showedLeaderboards[playerName] = {
		indexes = {
			table = showObjectToPlayer(leaderboardTable, playerName),
			title = showObjectToPlayer(leaderboardTitle, playerName),
			content = showLeaderboardTable(playerName, 1),
			-- contentSplitter = showObjectToPlayer(leaderboardTableSplitter, playerName),
			closeButton = showObjectToPlayer(leaderboardCloseButton, playerName),
			previousPageButton = showObjectToPlayer(leaderboardPreviousPageButton, playerName),
			currentPage = showLeaderboardCurrentPage(playerName, 1),
			nextPageButton = showObjectToPlayer(leaderboardNextPageButton, playerName)
		},
		currentPage = 1
	}
end

function messageBox(message, time, playerName, topcenterPosition, yPosition)
	local height, width = textAreaSizeByText(message)

	local X = (topcenterPosition == nil and 400 or topcenterPosition) - (width / 2)
	local Y = yPosition == nil and 40 or yPosition
	local index = addTextArea(X, Y, height, width, message, playerName)
	timers.newTimer(
		function(timerid, areaIndex, player)
			ui.removeTextArea(areaIndex, playerName)
		end,
		time,
		false,
		index,
		player
	)
end

function addTextArea(X, Y, height, width, message, playerName)
	local index = createAreaIndex()
	message = "<p align='center'>" .. message .. "</p>"
	ui.addTextArea(index, message, playerName, X, Y, width, height, 0x1B1B1B, 0x000000, 0.5, true)
	return index
end

function addAutoSizedTextArea(X, Y, message, playerName)
	return addTextArea(X, Y, textAreaSizeByText(message), message, playerName)
end

function textAreaSizeByText(message)
	local len, vlen = 0, 0
	local splitted = string.split(message, "<br>")
	for i, v in ipairs(splitted) do
		vlen = v:len()
		if vlen > len then
			len = vlen
		end
	end
	local height = 17 * (#splitted - 1)
	local width = 20 + len * 8
	return height, width
end

local textAreas = 0
function createAreaIndex()
	textAreas = textAreas + 1
	if (textAreas > 100000) then
		textAreas = 0
	end
	return textAreas
end

function splitAndProcessCmd(playerName, message)
	local args = string.split(message, "%s")
	local key = string.lower(table.remove(args, 1))
	args.playerName = playerName
	processCmd(key, args)
end

function processCmd(key, args)
	if table.containsKey(commands, key) then
		print("Got player command: " .. key)
		commands[key](args)
	elseif table.containsValue(settings.admins, args.playerName) and table.containsKey(adminCommands, key) then
		print("Got administrator command: " .. key)
		adminCommands[key](args)
	end
end

function bindKeyboardForAll(key, down)
	for k, v in pairs(tfm.get.room.playerList) do
		system.bindKeyboard(k, key, down, true)
	end
end

function unbindKeyboardForAll(key, bord)
	for k, v in pairs(tfm.get.room.playerList) do
		system.bindKeyboard(k, key, down, false)
	end
end

local onKeyDownEvents = {}
function onKeyDown(func, keyCode)
	if not table.containsKey(onKeyDownEvents, keyCode) then
		onKeyDownEvents[keyCode] = {}
	end

	onKeyDownEvents[keyCode][#onKeyDownEvents[keyCode] + 1] = func
	bindKeyboardForAll(keyCode, true)
end
function offKeyDown(func, keyCode)
	if not table.containsKey(onKeyDownEvents, keyCode) then
		return
	end

	table.remove(onKeyDownEvents[keyCode], func)
	unbindKeyboardForAll(key, false)
end

local onKeyUpEvents = {}
function onKeyUp(func, keyCode)
	if not table.containsKey(onKeyUpEvents, keyCode) then
		onKeyUpEvents[keyCode] = {}
	end
	onKeyUpEvents[keyCode][#onKeyUpEvents[keyCode] + 1] = func
end
function offKeyUp(func, keyCode)
	if not table.containsKey(onKeyUpEvents, keyCode) then
		return
	end

	table.remove(onKeyUpEvents[keyCode], func)
end

function handleKey(table, keyCode, playerName, xPlayerPosition, yPlayerPosition)
	if table[keyCode] ~= nil then
		for _, func in ipairs(table[keyCode]) do
			-- 		-- probably you do not need to know key and state of him when
			-- 		-- you are using some specific event like onkeydown, so
			-- 		-- here is just playerName and positions
			func(playerName, xPlayerPosition, yPlayerPosition)
		end
	end
end

function keyboardHandler(playerName, keyCode, down, xPlayerPosition, yPlayerPosition)
	if down then
		handleKey(onKeyDownEvents, keyCode, playerName, xPlayerPosition, yPlayerPosition)
	else
		handleKey(onKeyUpEvents, keyCode, playerName, xPlayerPosition, yPlayerPosition)
	end
end

--
-- Events
--

function eventChatCommand(playerName, message)
	splitAndProcessCmd(playerName, message)
end

function eventNewGame()
end

function eventTextAreaCallback(textAreaID, playerName, callback)
	local args = {playerName = playerName, [1] = textAreaID}
	processCmd(callback, args)
end

function eventNewPlayer(playerName)
	if not table.containsKey(room.playerHistory, playerName) then
		room.playerHistory[playerName] = {
			playerName = playerName,
			minDiff = 1,
			maxDiff = 3,
			experience = 0,
			level = 1
		}
	end
	-- onKeyUpEvents onKeyDownEvents
	for k, v in pairs(onKeyDownEvents) do
		system.bindKeyboard(playerName, k, true, true)
	end

	for k, v in pairs(onKeyUpEvents) do
		system.bindKeyboard(playerName, k, false, true)
	end
end

function eventLoop(currentTime, timeRemaining)
	timers.run()

	if timeRemaining < 0 then
		print("Starting new game because of there is no time.")
		newGame()
	end
end

function eventPlayerWon(playerName, timeElapsed)
	if (playerName ~= room.currentGame.shaman) then
		table.insert(room.currentGame.winningMice, playerName)
	end

	if isAllDead() then
		print("Starting new game because of there is no more live mouse.")
		newGame()
	end
end

function eventPlayerDied(playerName)
	if playerName == room.currentGame.shaman then
		tfm.exec.setGameTime(20, true)
	end

	if isAllDead() then
		print("Starting new game because of all mice died.")
		newGame()
	end
end

function eventSummoningEnd(playerName, objectType, xPosition, yPosition, angle, xSpeed, ySpeed, other)
	if
		not shamanCantSpawn and other.type ~= 26 and other.type ~= 27 and other.type ~= 0 and
			playerName == room.currentGame.shaman
	 then
		print(playerName .. " summoned unallowed object, killing him.")
		tfm.exec.removeObject(other.id)
		tfm.exec.killPlayer(playerName)
		messageBox("Only portals and arrows!", 10, playerName)
	end
end

function eventKeyboard(playerName, keyCode, down, xPlayerPosition, yPlayerPosition)
	keyboardHandler(playerName, keyCode, down, xPlayerPosition, yPlayerPosition)
end

--
-- Extentions
--

function string.split(input, seperator)
	local res = {}
	for part in string.gmatch(input, "[^" .. seperator .. "]+") do
		table.insert(res, part)
	end
	return res
end

function table.containsValue(t, element)
	if element == nil then
		return false
	end
	for key, value in pairs(t) do
		if value == element then
			return true
		end
	end
	return false
end

function table.containsKey(t, element)
	if element == nil then
		return false
	end
	return t[element] ~= nil
end

function table.clone(org)
	return {table.unpack(org)}
end

-- system.disableChatCommandDisplay("help", true)

-- Bindings

onKeyDown(
	function(player, x, y)
		displayLeadeboard(player)
	end,
	81
)

onKeyUp(
	function(player, x, y)
		closeLeaderboard(player)
	end,
	81
)

---

init()
