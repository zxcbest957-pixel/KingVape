local WEBHOOK_URL = "https://discord.com/api/webhooks/1546186427228753982/L0LQ_joP0y1lCmqYvKsmxA0gGoQKvBTIj57vd3i7krg4Tyio-NVovGOJGuxOkWZipcqi"

-- ======================================================
-- Сервисы Roblox
-- ======================================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")

local LocalPlayer = Players.LocalPlayer

-- ======================================================
-- Универсальная функция запросов
-- ======================================================
local httpRequest = (syn and syn.request) 
    or (http and http.request) 
    or http_request 
    or request 
    or (fluxus and fluxus.request)

local function sendHttpRequest(reqData)
    if httpRequest then
        return httpRequest(reqData)
    else
        local res = nil
        pcall(function()
            res = HttpService:PostAsync(reqData.Url, reqData.Body, Enum.HttpContentType.ApplicationJson)
        end)
        return { Body = res }
    end
end

-- ======================================================
-- Получение ПРЯМОЙ ссылки на аватарку через CDN Roblox
-- ======================================================
local function getAvatarUrl(userId)
    local apiUrl = string.format(
        "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%d&size=150x150&format=Png&isCircular=false",
        userId
    )
    
    local success, response = pcall(function()
        if game.HttpGet then
            return game:HttpGet(apiUrl)
        elseif httpRequest then
            local res = httpRequest({ Url = apiUrl, Method = "GET" })
            return res and res.Body
        end
        return nil
    end)

    if success and response then
        local decodeSuccess, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)

        -- Извлекаем прямую ссылку на tr.rbxcdn.com
        if decodeSuccess and data and data.data and data.data[1] and data.data[1].imageUrl then
            return data.data[1].imageUrl
        end
    end

    -- Запасной вариант (если API не ответил)
    return string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", userId)
end

-- ======================================================
-- Вспомогательные функции
-- ======================================================

local function getPlayerCountry()
    local success, code = pcall(function()
        return LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
    end)
    if success and code then
        return string.upper(code)
    end
    return "N/A"
end

local function getExecutorName()
    if identifyexecutor then
        local name, version = identifyexecutor()
        return string.format("%s (%s)", tostring(name), tostring(version or "N/A"))
    elseif getexecutorname then
        return tostring(getexecutorname())
    end
    return "Unknown / Roblox Client"
end

local function getPlaceName()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    if success and info and info.Name then
        return info.Name
    end
    return "Неизвестный Плейс"
end

-- ======================================================
-- Сбор данных и отправка лога
-- ======================================================
local function logExecution()
    if WEBHOOK_URL == "" or WEBHOOK_URL == "ВСТАВЬТЕ_СЮДА_ВАШ_DISCORD_WEBHOOK_URL" then
        warn("[Logger] Webhook URL не указан!")
        return
    end

    local userName = LocalPlayer and LocalPlayer.Name or "Unknown"
    local displayName = LocalPlayer and LocalPlayer.DisplayName or userName
    local userId = LocalPlayer and LocalPlayer.UserId or 0
    local accountAge = LocalPlayer and LocalPlayer.AccountAge or 0
    local isPremium = (LocalPlayer and LocalPlayer.MembershipType == Enum.MembershipType.Premium) and "Да ⭐" or "Нет"
    
    -- Получаем прямую CDN-ссылку на аватарку
    local avatarDirectUrl = getAvatarUrl(userId)
    local profileUrl = string.format("https://www.roblox.com/users/%d/profile", userId)

    local countryCode = getPlayerCountry()
    local executor = getExecutorName()
    local placeName = getPlaceName()
    local placeId = game.PlaceId
    local jobId = game.JobId

    local localDate = os.date("%d.%m.%Y")
    local localTime = os.date("%H:%M:%S")
    local dayOfWeek = os.date("%A")
    local utcTime = os.date("!%H:%M:%S UTC")

    local daysRu = {
        ["Sunday"] = "Воскресенье",
        ["Monday"] = "Понедельник",
        ["Tuesday"] = "Вторник",
        ["Wednesday"] = "Среда",
        ["Thursday"] = "Четверг",
        ["Friday"] = "Пятница",
        ["Saturday"] = "Суббота"
    }
    local dayOfWeekRu = daysRu[dayOfWeek] or dayOfWeek

    local payload = {
        embeds = {
            {
                author = {
                    name = string.format("%s (@%s)", displayName, userName),
                    url = profileUrl,
                    icon_url = avatarDirectUrl
                },
                title = "🚀 Запуск скрипта",
                color = 0x5865F2, -- Фирменный цвет Discord Blurple
                thumbnail = {
                    url = avatarDirectUrl
                },
                fields = {
                    {
                        name = "👤 Аккаунт",
                        value = string.format("**ID:** `%d`\n**Возраст:** `%d дней`\n**Premium:** %s", 
                            userId, accountAge, isPremium),
                        inline = true
                    },
                    {
                        name = "🌍 Регион & Среда",
                        value = string.format("**Страна:** `%s`\n**Executor:** `%s`", countryCode, executor),
                        inline = true
                    },
                    {
                        name = "📅 Дата и Время",
                        value = string.format("**День:** %s\n**Дата:** `%s`\n**Время (Local):** `%s` (`%s`)", 
                            dayOfWeekRu, localDate, localTime, utcTime),
                        inline = false
                    },
                    {
                        name = "🎮 Игра",
                        value = string.format("**Плейс:** [%s](https://www.roblox.com/games/%d)\n**Place ID:** `%d`\n**Job ID:** ```%s```", 
                            placeName, placeId, placeId, jobId ~= "" and jobId or "Studio / N/A"),
                        inline = false
                    }
                },
                footer = {
                    text = "Roblox Execution Analytics",
                    icon_url = avatarDirectUrl
                },
                timestamp = DateTime.now():ToIsoDate()
            }
        }
    }

    local jsonData = HttpService:JSONEncode(payload)

    sendHttpRequest({
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = jsonData
    })
end

task.spawn(logExecution)

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

if shared.ForceUpdate or shared.vapereload then
	wipeFolder('catsix/guis')
	wipeFolder('catsix/games')
	wipeFolder('catsix/libraries')
end
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
