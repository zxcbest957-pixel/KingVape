--!nocheck
local license = ... or {}
license.Key = script_key or license.Key

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
downloader.TextColor3 = Color3.new(1, 1, 1)
downloader.Font = Enum.Font.GothamBold
downloader.Text = ''
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or cloneref(game:GetService('CoreGui')))

local function downloadFile(path, func)
	local content
	if isfile(path) then
		pcall(function() content = readfile(path) end)
	end
	if not content or content == '' or content == '404: Not Found' then
		if not license.Closet then
			downloader.Text = 'Downloading '.. path
		end
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/zxcbest957-pixel/KingVape/main/'..select(1, path:gsub('catsix/', '')), true)
		end)
		if not suc or res == '404: Not Found' or not res or res == '' then
			error(res or 'Failed to download '..tostring(path))
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		pcall(writefile, path, res)
		content = res
		downloader.Text = ''
	end
	return (func or function() return content end)(path)
end

local function wipeFolder(path)
	if isfolder(path) then
		pcall(function()
			for _, file in listfiles(path) do
				if isfile(file) and not file:find('color.txt') and not file:find('font.txt') and not file:find('favorites.txt') and not file:find('gui.txt') then
					pcall(delfile, file)
				end
			end
		end)
	end
end

for _, folder in {'catsix', 'catsix/games', 'catsix/profiles', 'catsix/assets', 'catsix/libraries', 'catsix/guis'} do
	if not isfolder(folder) then
		downloader.Text = 'Downloading '.. folder
		makefolder(folder)
	end
end

wipeFolder('catsix/guis')
wipeFolder('catsix/games')
wipeFolder('catsix/libraries')
writefile('catsix/profiles/commit.txt', 'main')
	if shared.updated or #listfiles('catsix/profiles') < 4 then
		shared.VapePresetInstall = function()
			local suc, req = pcall(request, {
				Url = 'https://api.github.com/repos/zxcbest957-pixel/KingVape/contents/profiles',
				Method = 'GET'
			})
			if not suc or req.StatusCode ~= 200 then return false end
			local body = cloneref(game:GetService('HttpService')):JSONDecode(req.Body)
			if not body or typeof(body) ~= 'table' then return false end
			local installed = false
			for _, v in body do
				if v.type == 'file' and pcall(downloadFile, 'catsix/'.. ({v.path:gsub(' ', '%%20')})[1]) then
					installed = true
				end
			end
			return installed
		end
	end

downloader.Text = ''
return loadstring(downloadFile('catsix/main.lua'), 'main')(license)