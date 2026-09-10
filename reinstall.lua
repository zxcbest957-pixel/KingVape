local delFolder = delfolder or deletefolder
local delFile = delfile or deletefile
local listFiles = listfiles or listdir
local isFolder = isfolder or is_folder
local isFile = isfile or is_file

local function wipe(path)
	if isFolder and isFolder(path) then
		if listFiles then
			local s, items = pcall(listFiles, path)
			if s and typeof(items) == 'table' then
				for _, item in ipairs(items) do
					if isFolder and isFolder(item) then
						wipe(item)
					elseif delFile then
						pcall(delFile, item)
					end
				end
			end
		end
		if delFolder then
			pcall(delFolder, path)
		end
	elseif isFile and isFile(path) then
		if delFile then
			pcall(delFile, path)
		end
	elseif delFolder then
		pcall(delFolder, path)
	end
end

wipe('catsix')

local stillExists = isFolder and isFolder('catsix')
if not stillExists then
	print('[KingVape] Папка catsix успешно удалена из workspace!')
	if (identifyexecutor or getexecutorname) then
		pcall(function()
			game:GetService('StarterGui'):SetCore('SendNotification', {
				Title = 'KingVape Cleaner',
				Text = 'Папка catsix успешно удалена!',
				Duration = 4
			})
		end)
	end
else
	warn('[KingVape] Не удалось удалить папку catsix.')
end