if GetCurrentResourceName() == "td-holdcorner" then
SX = nil

TriggerEvent('esx:getSharedObject', function(obj) 
    ESX = obj 
end)

ESX.RegisterServerCallback('td-kosetut:item-kontrol', function(source, cb, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local items = xPlayer.getInventoryItem(item)
    if items == nil then
        cb(0)
    else
        cb(items.count)
    end
end)


ESX.RegisterServerCallback('td-kosetut:polissayisi', function(source, cb)
	local xPlayers = ESX.GetPlayers()

	polissayisi = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			polissayisi = polissayisi + 1
		end
	end

	cb(polissayisi)
end)


RegisterServerEvent('td-kosetut:policenotif')
AddEventHandler('td-kosetut:policenotif', function()
	local xPlayers = ESX.GetPlayers()

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			TriggerClientEvent('td-kosetut:setblip',xPlayer.source)
		end
	end
end)

ESX.RegisterServerCallback('td-kosetut:satis-gerceklesti', function(source, cb, RastgeleEsya, fiyat, miktar)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local item = xPlayer.getInventoryItem(RastgeleEsya).count
    if item >= miktar then
        xPlayer.removeInventoryItem(RastgeleEsya, miktar)
        Citizen.Wait(500)
        xPlayer.addMoney(fiyat*miktar)
        xPlayer.showNotification(miktar ..' Miktar '.. RastgeleEsya ..' '.. fiyat*miktar ..'$')
        dclog(xPlayer, ''..miktar.. ' Adet - '..RastgeleEsya.. ' Karşılıgında -  ' ..fiyat*miktar..' $ Aldı')
        cb(true)
    else
        xPlayer.showNotification("Alıcı birşeyler almak istemiyor.")
        cb(false)
    end
end)



function dclog(xPlayer, text)
    local playerName = Sanitize(xPlayer.getName())
    
    local discord_webhook = GetConvar('discord_webhook', Config.webhook)
    if discord_webhook == '' then
      return
    end
    local headers = {
      ['Content-Type'] = 'application/json'
    }
    local data = {
      ["username"] = 'teamDemo - Köşetut-Log',
      ["avatar_url"] = 'https://cdn.discordapp.com/attachments/736920123079917579/740573179654963280/7a1ce7c3a09f95709a7a7ed6142ab39e_1.png',
      ["embeds"] = {{
        ["author"] = {
          ["name"] = playerName .. ' - ' .. xPlayer.identifier
        },
        ["color"] = 15158332,
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
      }}
    }
    data['embeds'][1]['description'] = text
    PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

function Sanitize(str)
    local replacements = {
        ['&' ] = '&amp;',
        ['<' ] = '&lt;',
        ['>' ] = '&gt;',
        ['\n'] = '<br/>'
    }

    return str
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s)
            return ' '..('&nbsp;'):rep(#s-1)
        end)
end
else
        print("--------------------------------")
        print("Scriptin ismi td-cornerhold olmali.")
        print("https://discord.gg/sMHCzsh")
        print("--------------------------------")
        print("")
end