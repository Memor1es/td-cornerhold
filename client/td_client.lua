ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)  

local satilanNpcler = {}
local rastgeleEsya, rastgeleEsyaAdi, rastgeleEsyaFiyati, miktar, npc, bolgeKordinat, bolgeAdi = nil, nil, nil, nil, nil, nil, nil
local koseTut, npcBulundu, npcAra = false, false, false

RegisterCommand("köşetut", function(source, args)
	ESX.TriggerServerCallback('td-kosetut:polissayisi', function(cops)
		if cops >= Config.PoliceCount then 
			local playerPed = PlayerPedId()
			if not IsPedInAnyVehicle(playerPed) and not koseTut then			
				miktar = 5
				if args[1] and tonumber(args[1]) < 5 then
					miktar = tonumber(args[1])
				end

				koseTut = true
				npcBulundu = false
				npcAra = true
			elseif IsPedInAnyVehicle(playerPed) then
				exports['mythic_notify']:DoHudText('inform', _U('invehicle'))
			else
				exports['mythic_notify']:DoHudText('inform', _U('alreadymaking'))
			end
		else
			exports['mythic_notify']:DoHudText('inform', _U('notcops'))
		end
	end)
end)

Citizen.CreateThread(function()
	while true do
		cd = 100
		if koseTut then
			if not npcBulundu and npcAra then
				cd = 5000
				local playerPed = PlayerPedId()
				local playerCoords = GetEntityCoords(playerPed)

				local bolgeBulundu = false
				for kodadi, bolge in pairs(Config.bolge) do
					local bolgeKordinat = bolge["kordinat"]
					if #(bolgeKordinat - playerCoords) < 45 then
						bolgeAdi = kodadi
						bolgeBulundu = true
						break
					end
				end

				if bolgeBulundu then
					exports['mythic_notify']:DoHudText('inform', _U('devamming'))
					Citizen.Wait(3000)
					npc = pedAra(playerPed)
				else
					koseTut = false
					npcAra = false
					npcBulundu = false
					exports['mythic_notify']:DoHudText('inform', _U('error_place'))
				end
			end

			if npcBulundu and not npcAra and not satilanNpcler[npc] then
				cd = 1
				local playerPed = PlayerPedId()
				local playerCoords = GetEntityCoords(playerPed)
				local npcCoords = GetEntityCoords(npc)
				local npcMesafe = #(npcCoords - playerCoords)

				if #(bolgeKordinat - playerCoords) < 100 then
					if npcMesafe < 50 then
						local npcArabada = IsPedInAnyVehicle(npc)
						if npcArabada then
							npcAraci = GetVehiclePedIsIn(npc, false)
						end

						DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z+1.05, "~g~[E] ~w~" .. miktar ..  " Adet " .. rastgeleEsyaAdi .." Sat / ".. rastgeleEsyaFiyati*miktar .."$ ~g~[H] ~w~Kov", 0.45)
						
						if HasEntityBeenDamagedByAnyPed(npc) then
							exports['mythic_notify']:DoHudText('inform', _U('injured_buyer'))
							tekrarNpcAra(true)
							polisBildirim("Kavga Dövüş")
							
						elseif npcMesafe <= 2.0 or npcArabada and npcMesafe < 15 then
							if npcArabada then
								FreezeEntityPosition(npcAraci, true)
							else
								FreezeEntityPosition(npc, true)
								animasyon(npc, "anim@amb@clubhouse@mini@darts@", "wait_idle")
							end

							if npcMesafe <= 2.0 then
								if IsControlJustPressed(0, 51) then -- E
									satilanNpcler[npc] = true
									ESX.TriggerServerCallback('td-kosetut:satis-gerceklesti', function(durum)
										if durum then
											animasyon(playerPed, "mp_common", "givetake1_a")
											Citizen.Wait(350)
											if not npcArabada then animasyon(npc, "mp_common", "givetake1_a") end
											tekrarNpcAra(false)
										else
											tekrarNpcAra(true)
										end
									end, rastgeleEsya, rastgeleEsyaFiyati, miktar)
									Citizen.Wait(5000)
								elseif IsControlJustPressed(0, 304) then -- H
									exports['mythic_notify']:DoHudText('inform', _U('fuckoffbuyer'))
									TriggerServerEvent('td-kosetut:policenotif')
									tekrarNpcAra(true)																
								end
							end
						else
							if npcArabada then
								FreezeEntityPosition(npcAraci, false)
							else
								FreezeEntityPosition(npc, false)
							end
						end
					else
						exports['mythic_notify']:DoHudText('inform', _U('so_far'))
						tekrarNpcAra(true)	
					end
				else
					exports['mythic_notify']:DoHudText('inform', _U('so_far_seller'))
					npcBulundu = false
					npcAra = false
					koseTut = false
				end
			end
		end
		Citizen.Wait(cd)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1500)
		if npcBulundu and not IsPedInAnyVehicle(npc) then
			local playerPed = PlayerPedId()
	        local playerPos = GetEntityCoords(playerPed)
			TaskGoToCoordAnyMeans(npc, playerPos, 1.0, 0, 0, 786603, 0xbf800000)
		end	
	end
end)

RegisterNetEvent('td-kosetut:setblip') -- s
AddEventHandler('td-kosetut:setblip', function()
    local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)

    exports["mythic_notify"]:DoHudText("inform", "Köşe Tutuluyor!", 35000, error )
    blip = AddBlipForCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 75)
    Citizen.Wait(38000)
    TriggerEvent('td-bankrob:killblip')
end)

RegisterNetEvent('td-bankrob:killblip')
AddEventHandler('td-bankrob:killblip', function()
    RemoveBlip(blip)
end)



function animasyon(ped, ad, anim)
	ESX.Streaming.RequestAnimDict(ad, function()
		TaskPlayAnim(ped, ad, anim, 8.0, -8.0, -1, 0, 0, 0, 0, 0)
	end)
end



function pedAra(playerPed)
	local playerCoords = GetEntityCoords(playerPed)
	local handle, ped = FindFirstPed()
	local success
	local rped = nil
	repeat
		local mesafe = #(playerCoords - GetEntityCoords(ped))
		if mesafe < 30.0 and not IsPedAPlayer(ped) and not satilanNpcler[ped] then
			rped = ped
			if not IsPedInAnyVehicle(rped) then
				exports['mythic_notify']:DoHudText('inform', _U('buyerincoming'))
			else
				exports['mythic_notify']:DoHudText('inform', _U('buyerwanttomalzeme'))
			end

			rastgeleEsyaSec = math.random(1, #Config.bolge[bolgeAdi]["esyalar"]) 
			rastgeleEsya = Config.bolge[bolgeAdi]["esyalar"][rastgeleEsyaSec]
			rastgeleEsyaAdi = Config.EsyaAdlari[rastgeleEsya]
			rastgeleEsyaFiyati = math.random(exports["td-holdcorner"]:KoseTut(rastgeleEsya).r1, exports["td-holdcorner"]:KoseTut(rastgeleEsya).r2)
			bolgeKordinat = playerCoords
			satilanNpcler[rped] = false
			npcBulundu = true
			npcAra = false
			break
		end
		success, ped = FindNextPed(handle)
	until not success
	EndFindPed(handle)
	return rped
end

function tekrarNpcAra(listeEkle)
	if listeEkle then
		satilanNpcler[npc] = true
	end
	Citizen.Wait(2000)
	if IsPedInAnyVehicle(npc) then
		local arac = GetVehiclePedIsIn(npc, false)
		TaskWanderStandard(arac, 10.0, 10)
		FreezeEntityPosition(arac, false)
	else
		TaskWanderStandard(npc, 10.0, 10)
		FreezeEntityPosition(npc, false)
		ClearPedTasks(npc)
	end
	ClearPedTasks(playerPed)
	Citizen.Wait(5000)
	npcBulundu = false
	npcAra = true
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 250
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 140)
end