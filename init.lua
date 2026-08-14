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

local screenGui = Instance.new('ScreenGui')
screenGui.Name = 'KingVapeLoader'
screenGui.ResetOnSpawn = false
screenGui.Parent = gethui and gethui() or cloneref(game:GetService('CoreGui'))

local mainFrame = Instance.new('Frame')
mainFrame.Size = UDim2.fromOffset(360, 95)
mainFrame.Position = UDim2.new(0.5, -180, 0.05, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new('UICorner')
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new('UIStroke')
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = mainFrame

local title = Instance.new('TextLabel')
title.Size = UDim2.new(1, -30, 0, 26)
title.Position = UDim2.fromOffset(15, 12)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = '👑 KINGVAPE'
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local subtitle = Instance.new('TextLabel')
subtitle.Size = UDim2.new(1, -30, 0, 16)
subtitle.Position = UDim2.fromOffset(15, 36)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = 'Privacy & Security Edition'
subtitle.TextColor3 = Color3.fromRGB(160, 160, 180)
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = mainFrame

local downloader = Instance.new('TextLabel')
downloader.Size = UDim2.new(1, -30, 0, 18)
downloader.Position = UDim2.fromOffset(15, 58)
downloader.BackgroundTransparency = 1
downloader.Font = Enum.Font.GothamMedium
downloader.Text = 'Initializing KingVape...'
downloader.TextColor3 = Color3.fromRGB(220, 220, 235)
downloader.TextSize = 13
downloader.TextXAlignment = Enum.TextXAlignment.Left
downloader.Parent = mainFrame

local function downloadFile(path, func)
	if not isfile(path) then
		if not license.Closet then
			downloader.Text = 'Downloading '.. path
		end
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/zxcbest957-pixel/KingVape/'..readfile('catsix/profiles/commit.txt')..'/'..select(1, path:gsub('catsix/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
		downloader.Text = ''
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	return
end


for _, folder in {'catsix', 'catsix/games', 'catsix/profiles', 'catsix/assets', 'catsix/libraries', 'catsix/guis'} do
	if not isfolder(folder) then
		downloader.Text = 'Downloading '.. folder
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local commit = license.Commit or nil
	if not commit then
		local _, subbed = pcall(function() 
			return game:HttpGet('https://github.com/zxcbest957-pixel/KingVape') 
		end)
		commit = subbed:find('currentOid')
		commit = commit and subbed:sub(commit + 13, commit + 52) or nil
		commit = commit and #commit == 40 and commit or 'main'
	end
	if commit == 'main' or (isfile('catsix/profiles/commit.txt') and readfile('catsix/profiles/commit.txt') or '') ~= commit then
		if commit ~= 'main' and isfile('catsix/profiles/commit.txt') then
			shared.updated = readfile('catsix/profiles/commit.txt')
		end
		wipeFolder('catsix')
		wipeFolder('catsix/games')
		wipeFolder('catsix/guis')
		wipeFolder('catsix/libraries')
	end
	writefile('catsix/profiles/commit.txt', commit)
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
end

downloader.Text = 'Loaded!'
task.delay(1, function()
	pcall(function() screenGui:Destroy() end)
end)
return loadstring(downloadFile('catsix/main.lua'), 'main')(license)