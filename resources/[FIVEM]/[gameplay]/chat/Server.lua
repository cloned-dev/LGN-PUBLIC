-- Made by Tazio

local DISCORD_WEBHOOK = "https://canary.discord.com/api/webhooks/866831500770803712/EFfEgmXDaDsKTRs9UV1a0KopWz1Cts65qSbI73S4_Po0P39-3kel6nBS_iulTyj1GA_d"
local DISCORD_NAME = "LGN | Logs"
local STEAM_KEY = "00CCA845BFFC69B91012F11D77279794"
local DISCORD_IMAGE = "" -- default is FiveM logo

--DON'T EDIT BELOW THIS

PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, content = "Discord Webhook is **ONLINE**", avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })

AddEventHandler('chatMessage', function(source, name, message) 

	if string.match(message, "@everyone") then
		message = message:gsub("@everyone", "`@everyone`")
	end
	if string.match(message, "@here") then
		message = message:gsub("@here", "`@here`")
	end
	--print(tonumber(GetIDFromSource('steam', source), 16)) -- DEBUGGING
	--print('https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. STEAM_KEY .. '&steamids=' .. tonumber(GetIDFromSource('steam', source), 16))
	if STEAM_KEY == '' or STEAM_KEY == nil then
		PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = name .. " [" .. source .. "]", content = message, tts = false}), { ['Content-Type'] = 'application/json' })
	else
		PerformHttpRequest('https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' .. STEAM_KEY .. '&steamids=' .. tonumber(GetIDFromSource('steam', source), 16), function(err, text, headers)
			local image = string.match(text, '"avatarfull":"(.-)","')
			--print(image) -- DEBUGGING
			PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = name .. " [" .. source .. "]", content = message, avatar_url = image, tts = false}), { ['Content-Type'] = 'application/json' })
		end)
	end
end)

--[[AddEventHandler('playerConnecting', function() 
    --PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, content = "```CSS\n".. GetPlayerName(source) .. " connecting\n```", avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
    sendToDiscord("Server Login", "**" .. GetPlayerName(source) .. "** is connecting to the server.", 65280)
end)

AddEventHandler('playerConnecting', function() 
    --PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, content = "```CSS\n".. GetPlayerName(source) .. " connecting\n```", avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
    sendToDiscord("Server Login", "**" .. GetPlayerName(source) .. "** is connecting to the server.", 65280)
end)

AddEventHandler('playerDropped', function(reason) 
	local color = 16711680
	if string.match(reason, "Kicked") or string.match(reason, "Banned") then
		color = 16007897
	end
  sendToDiscord("Server Logout", "**" .. GetPlayerName(source) .. "** has left the server. \n Reason: " .. reason, color)
end)--]]

function GetIDFromSource(Type, ID) --(Thanks To WolfKnight [forum.FiveM.net])
    local IDs = GetPlayerIdentifiers(ID)
    for k, CurrentID in pairs(IDs) do
        local ID = stringsplit(CurrentID, ':')
        if (ID[1]:lower() == string.lower(Type)) then
            return ID[2]:lower()
        end
    end
    return nil
end

function stringsplit(input, seperator)
	if seperator == nil then
		seperator = '%s'
	end
	
	local t={} ; i=1
	
	for str in string.gmatch(input, '([^'..seperator..']+)') do
		t[i] = str
		i = i + 1
	end
	
	return t
end

function sendToDiscord(name, message, color)
  local connect = {
        {
            ["color"] = color,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = "Made by Faded",
            },
        }
    }
  PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({username = DISCORD_NAME, embeds = connect, avatar_url = DISCORD_IMAGE}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent("SendToDiscord")
AddEventHandler("SendToDiscord", sendToDiscord)

--Anon Message
RegisterCommand("anon", function(source, args, raw)
    if #args <= 0 then return end
	local name = GetPlayerName(source)
    local message = table.concat(args, " ")
	TriggerClientEvent('chatMessage', -1, "Anonymous |", { 255, 0, 0 }, message, "alert")
	sendToDiscord("[**Anon**]", "**"..name.. "** has sent: " ..message)
end)

--OOC Message
RegisterCommand("ooc", function(source, args, raw)
    if #args <= 0 then return end
	local name = GetPlayerName(source)
    local message = table.concat(args, " ")
	TriggerClientEvent('chatMessage', -1, "^7^*OOC ^7^r | " .. GetPlayerName(source) .." : " , { 128, 128, 128 }, message, "ooc")
	sendToDiscord("[**OOC**]", "**"..name.. "** has sent: " ..message)
end)

RegisterCommand("/", function(source, args, raw)
    if #args <= 0 then return end
	local name = GetPlayerName(source)
    local message = table.concat(args, " ")
	TriggerClientEvent('chatMessage', -1, "^7^*OOC ^7^r | " .. GetPlayerName(source) .." : " , { 128, 128, 128 }, message, "ooc")
	sendToDiscord("[**OOC**]", "**"..name.. "** has sent: " ..message)
end)

--Chat Proximity
AddEventHandler('chatMessage', function(source, name, message)
    if string.sub(message, 1, string.len("/")) ~= "/" then
        local name = GetPlayerName(source)
	TriggerClientEvent("sendProxMsg", -1, source, name, message)
    end
    CancelEvent()
end)

--Function
function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end