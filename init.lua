--!nocheck
-- King Vape Client Initializer
local license = ... or {}
license.Key = script_key or license.Key or "KING-VAPE-FREE"

local cloneref = cloneref or function(ref) return ref end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local downloader = Instance.new('TextLabel')
downloader.Size = UDim2.new(1, 0, 0, 40)
downloader.BackgroundTransparency = 1
downloader.TextStrokeTransparency = 0
downloader.TextSize = 20
downloader.TextColor3 = Color3.fromRGB(255, 215, 0)
downloader.Font = Enum.Font.GothamBold
downloader.Text = ''
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or cloneref(game:GetService('CoreGui')))

local function downloadFile(path, func)
	if not isfile(path) then
		if not license.Closet then
			downloader.Text = 'King Vape: Loading '.. path
		end
		local cleanPath = select(1, path:gsub('kingvape/', ''))
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/zxcbest957-pixel/KingVape/main/'..cleanPath, true)
		end)
		if suc and res and res ~= '404: Not Found' then
			writefile(path, res)
		elseif isfile(cleanPath) then
			writefile(path, readfile(cleanPath))
		end
		downloader.Text = ''
	end
	return (func or readfile)(path)
end

for _, folder in {'kingvape', 'kingvape/games', 'kingvape/profiles', 'kingvape/assets', 'kingvape/libraries', 'kingvape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not isfile('kingvape/profiles/commit.txt') then
	writefile('kingvape/profiles/commit.txt', 'main')
end

downloader.Text = ''
if isfile('kingvape/main.lua') then
	return loadstring(readfile('kingvape/main.lua'), 'main')(license)
else
	return loadstring(downloadFile('kingvape/main.lua'), 'main')(license)
end