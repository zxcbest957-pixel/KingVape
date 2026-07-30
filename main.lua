local license = ... or {}
license.Key = script_key or license.Key or "KING-VAPE-FREE"
local Loaded = game:IsLoaded()
if not Loaded then
	repeat task.wait() until game:IsLoaded()
	task.wait(2)
end
if shared.vape then shared.vape:Uninject() end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('King Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local clear_teleport_queue = clear_teleport_queue or clearteleportqueue or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local cleanPath = select(1, path:gsub('kingvape/', ''))
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/zxcbest957-pixel/KingVape/main/'..cleanPath, true)
		end)
		if suc and res and res ~= '404: Not Found' then
			writefile(path, res)
		elseif isfile(cleanPath) then
			writefile(path, readfile(cleanPath))
		end
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()

	local teleportedServers
	(function()
		if (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if isfile('kingvape/main.lua') then
					loadstring(readfile('kingvape/main.lua'), 'main')(_scriptconfig)
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/zxcbest957-pixel/KingVape/main/init.lua'), 'init.lua')(_scriptconfig)
				end
			]]
			local teleportConfig = httpService:JSONEncode(license)
			teleportConfig = teleportConfig:gsub('":true', "=true"):gsub('{"', '{')
			teleportConfig = teleportConfig:gsub(',"', ','):gsub('":', '=')
			teleportConfig = teleportConfig:gsub('%[', '{'):gsub('%]', '}')
			teleportScript = teleportScript:gsub('_key', tostring(license.Key or 'KING-VAPE'))
			teleportScript = teleportScript:gsub('_scriptconfig', teleportConfig)
			if identifyexecutor() == 'Potassium' then
				teleportScript = 'task.wait(12)\n'.. teleportScript
			end
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			queue_on_teleport(teleportScript)
		end
	end)()

	if not vape.Categories then return end
	if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
		if not shared.vapereload then
			vape:CreateNotification('King Vape', 'Successfully loaded King Vape! '.. (vape.VapeButton and 'Press the button in the top right' or 'Press '..table.concat(vape.Keybind, ' + '):upper())..' to open GUI', 6)
		end
	end
end

downloadFile("kingvape/libraries/pathfind.lua")
if not isfile('kingvape/profiles/gui.txt') then
	writefile('kingvape/profiles/gui.txt', 'new')
end
local gui = 'new'

if not isfolder('kingvape/assets/'..gui) then
	makefolder('kingvape/assets/'..gui)
end
if not isfile('kingvape/profiles/commit.txt') then
	writefile('kingvape/profiles/commit.txt', 'kingvape-v1.0')
end

getgenv().used_init = true
vape = loadstring(downloadFile('kingvape/guis/'..gui..'.lua'), 'gui')(license)
_G.vape = vape
shared.vape = vape
shared.vapesmooth = true

if hookmetamethod then
local old; old = hookmetamethod(game, "__namecall", function(self, Remote, ...)
    if not checkcaller() and getnamecallmethod() == "FireServer" then
        if typeof(Remote) == "Instance" and Remote.Name == "TabFreezeAnticheat_ClientToServerReport" then
            return
        end
    end
    return old(self, Remote, ...)
end)
end

if not shared.VapeIndependent then
	if isfile('kingvape/games/universal.lua') then
		loadstring(readfile('kingvape/games/universal.lua'), 'universal')(license)
	elseif isfile('games/universal.lua') then
		loadstring(readfile('games/universal.lua'), 'universal')(license)
	end

	if isfile('kingvape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('kingvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
	elseif isfile('games/'..game.PlaceId..'.lua') then
		loadstring(readfile('games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(license)
	end

	if vape.ThreadFix then
		setthreadidentity(8)
	end
	
	if isfile('kingvape/libraries/premium.lua') then
		loadstring(readfile('kingvape/libraries/premium.lua'), 'premium')(license)
	elseif isfile('libraries/premium.lua') then
		loadstring(readfile('libraries/premium.lua'), 'premium')(license)
	end
	
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end

