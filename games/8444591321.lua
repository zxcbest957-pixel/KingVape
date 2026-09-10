local vape = shared.vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			local commit = (isfile('catsix/profiles/commit.txt') and readfile('catsix/profiles/commit.txt')) or 'main'
			if not commit or commit == '' then commit = 'main' end
			return game:HttpGet('https://raw.githubusercontent.com/zxcbest957-pixel/KingVape/'..commit..'/'..select(1, path:gsub('catsix/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

vape.Place = 6872274481
if isfile('catsix/games/'..vape.Place..'.lua') then
	local content = readfile('catsix/games/'..vape.Place..'.lua')
	if content and not content:find('Enemy Bases Only') then
		pcall(delfile, 'catsix/games/'..vape.Place..'.lua')
	end
end

if isfile('catsix/games/'..vape.Place..'.lua') then
	loadstring(readfile('catsix/games/'..vape.Place..'.lua'), 'bedwars')()
else
	if not shared.VapeDeveloper then
		local suc, res = pcall(function()
			local commit = (isfile('catsix/profiles/commit.txt') and readfile('catsix/profiles/commit.txt')) or 'main'
			if not commit or commit == '' then commit = 'main' end
			return game:HttpGet('https://raw.githubusercontent.com/zxcbest957-pixel/KingVape/'..commit..'/games/'..vape.Place..'.lua', true)
		end)
		if suc and res ~= '404: Not Found' then
			loadstring(downloadFile('catsix/games/'..vape.Place..'.lua'), 'bedwars')()
		end
	end
end
