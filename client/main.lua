local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData				= {}
local HasAlreadyEnteredMarker	= false
local LastZone					= nil
local CurrentAction				= nil
local CurrentActionMsg			= ''
local CurrentActionData			= {}
local Blips						= {}
local JobBlips					= {}

local vehicleNearPlayer, currentJobPlate = nil, nil
local currentlyBusy, barrelTaken = false, false
local jobVehicles = {}
local jobVehicleHash = GetHashKey('"'..Config.JobVehicleName..'"') -- bobcatxl
local barrelEntityObject = GetHashKey('"'..Config.barrelEntityName..'"')

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()

	Citizen.Wait(5000)

	if PlayerData.job.name == 'yellowjack' then
		ESX.TriggerServerCallback('esx_yellowjackjob:RequestJobVehiclesInfos', function(cb)
			jobVehicles = cb
		end)
	end
	CreateJobBlips()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	if PlayerData.job.name == 'yellowjack' then
		ESX.TriggerServerCallback('esx_yellowjackjob:RequestJobVehiclesInfos', function(cb)
			jobVehicles = cb
		end)
	end
	DeleteJobBlips()
	CreateJobBlips()
end)

RegisterNetEvent('esx:setSecondJob')
AddEventHandler('esx:setSecondJob', function(job)
  PlayerData.second_job = job
end)

function IsJobTrue()
	if PlayerData ~= nil then
		if PlayerData.job ~= nil and PlayerData.job.name == 'yellowjack' then
			return true
		else
			return false
		end
	end
end

function IsGradeBoss()
	if PlayerData ~= nil then
		if PlayerData.job.grade_name == 'boss' then
			return true
		else
			return false
		end
	end
end

function CreateJobBlips()
	if IsJobTrue() then
		for k,v in pairs(Config.JobBlips) do
			local blipCoord = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)

			SetBlipSprite (blipCoord, v.Sprite)
			SetBlipDisplay(blipCoord, v.Display)
			SetBlipScale	(blipCoord, v.Scale)
			SetBlipColour (blipCoord, v.Color)
			SetBlipAsShortRange(blipCoord, true)

			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(v.Name)
			EndTextCommandSetBlipName(blipCoord)

			table.insert(JobBlips, blipCoord)
		end
	end
end

function DeleteJobBlips()
	if JobBlips[1] ~= nil then
		for i=1, #JobBlips, 1 do
			RemoveBlip(JobBlips[i])
			JobBlips[i] = nil
		end
	end
end

function OpenVaultMenu()

	if Config.EnableVaultManagement then

		local elements = {
			--{label = _U('get_object'), value = 'get_stock'},
			{label = _U('put_object'), value = 'put_stock'}
		}

		if PlayerData.job.grade >= 2 then
			table.insert(elements, {label = _U('get_object'), value = 'get_stock'})
		end

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'vault',
			{
				title		= _U('vault'),
				align		= 'top-left',
				elements = elements,
			},
			function(data, menu)

				local action = data.current.value
				if action == 'put_stock' then
					OpenPutStocksMenu()
				elseif action == 'get_stock' then
					OpenGetStocksMenu()
				end

			end,

			function(data, menu)

				menu.close()

				CurrentAction		= 'menu_vault'
				CurrentActionMsg	= _U('open_vault')
				CurrentActionData	= {}
			end
		)

	end

end

function OpenFridgeMenu()

	local elements = {
		{label = _U('get_object'), value = 'get_stock'},
		{label = _U('put_object'), value = 'put_stock'}
	}


	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'fridge',
		{
			title		= _U('fridge'),
			align		= 'top-left',
			elements = elements,
		},
		function(data, menu)

			local action = data.current.value
			if action == 'put_stock' then
				OpenPutFridgeStocksMenu()
			elseif action == 'get_stock' then
				OpenGetFridgeStocksMenu()
			end

		end,

		function(data, menu)

			menu.close()

			CurrentAction		= 'menu_fridge'
			CurrentActionMsg	= _U('open_fridge')
			CurrentActionData	= {}
		end
	)

end

function OpenVehicleSpawnerMenu()

	local vehicles = Config.Zones.Vehicles

	ESX.UI.Menu.CloseAll()

	local elements = {}

	for i=1, #Config.AuthorizedVehicles, 1 do
		local vehicle = Config.AuthorizedVehicles[i]
		table.insert(elements, {label = vehicle.label, value = vehicle.name})
	end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'vehicle_spawner',
		{
			title		= _U('vehicle_menu'),
			align		= 'top-left',
			elements = elements,
		},
		function(data, menu)

			menu.close()

			local model = data.current.value

			local vehicle = GetClosestVehicle(vehicles.SpawnPoint.x,	vehicles.SpawnPoint.y,	vehicles.SpawnPoint.z,	3.0,	0,	71)

			if not DoesEntityExist(vehicle) then

				local playerPed = PlayerPedId()

				ESX.Game.SpawnVehicle(model, {
					x = vehicles.SpawnPoint.x,
					y = vehicles.SpawnPoint.y,
					z = vehicles.SpawnPoint.z
				}, vehicles.Heading, function(vehicle)
					--TaskWarpPedIntoVehicle(playerPed,	vehicle,	-1) -- teleport into vehicle
					--SetVehicleMaxMods(vehicle)
					SetVehicleDirtLevel(vehicle, 0)
					if IsVehicleModel(vehicle, jobVehicleHash) then
						local plate = GetVehicleNumberPlateText(vehicle)
						jobVehicles[plate] = {quantity = 0, maximum = 0}
						TriggerServerEvent('esx_yellowjackjob:UpdateServerJobVehiclesTable', plate)
						Citizen.Wait(100)
					end
				end)

			else
				ESX.ShowNotification(_U('vehicle_out'))
			end

		end,
		function(data, menu)

				menu.close()

				CurrentAction		 = 'menu_vehicle_spawner'
				CurrentActionMsg	= _U('vehicle_spawner')
				CurrentActionData = {}

		end
	)

end

function OpenSocietyActionsMenu()

	local elements = {
		{label = _U('billing'),		value = 'billing'}
	}

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'society_actions',
		{
			title		= _U('society_name_billing'),
			align		= 'top-left',
			elements	= elements
		},
		function(data, menu)
			local action = data.current.value
			if action == 'billing' then
				OpenBillingMenu()
			end
		end,
		function(data, menu)
			menu.close()
		end
	)

end

function OpenBillingMenu()

	ESX.UI.Menu.Open(
		'dialog', GetCurrentResourceName(), 'billing',
		{
			title = _U('billing_amount')
		},
		function(data, menu)

			local amount = tonumber(data.value)
			local player, distance = ESX.Game.GetClosestPlayer()

			if player ~= -1 and distance <= 3.0 then

				menu.close()
				if amount == nil or amount < 0 then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_yellowjack', _U('society_name_billing'), amount)
				end

			else
				ESX.ShowNotification(_U('no_players_nearby'))
			end

		end,
		function(data, menu)
			menu.close()
		end
	)
end

function OpenGetStocksMenu()

	ESX.TriggerServerCallback('esx_yellowjackjob:getStockItems', function(items)

		local elements = {}

		for i=1, #items, 1 do
			if items[i].count > 0 then
				table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
			end
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{
				title		= _U('society_stock'),
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil then
							ESX.ShowNotification(_U('invalid_quantity'))
						else
							menu2.close()
							menu.close()
							--OpenGetStocksMenu()

							TriggerServerEvent('esx_yellowjackjob:getStockItem', itemName, count)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end)

end

function OpenPutStocksMenu()

	ESX.TriggerServerCallback('esx_yellowjackjob:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do

			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
			end

		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'stocks_menu',
			{
				title		= _U('inventory'),
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil then
							ESX.ShowNotification(_U('invalid_quantity'))
						else
							menu2.close()
							menu.close()
							--OpenPutStocksMenu()

							TriggerServerEvent('esx_yellowjackjob:putStockItems', itemName, count)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end)

end

function OpenGetFridgeStocksMenu()

	ESX.TriggerServerCallback('esx_yellowjackjob:getFridgeStockItems', function(items)

		local elements = {}

		for i=1, #items, 1 do
			if items[i].count > 0 then
				table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
			end
		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'fridge_menu',
			{
				title		= _U('fridge_stock'),
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'fridge_menu_get_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil then
							ESX.ShowNotification(_U('invalid_quantity'))
						else
							menu2.close()
							menu.close()
							--OpenGetFridgeStocksMenu()

							TriggerServerEvent('esx_yellowjackjob:getFridgeStockItem', itemName, count)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end)

end

function OpenPutFridgeStocksMenu()

	ESX.TriggerServerCallback('esx_yellowjackjob:getPlayerInventory', function(inventory)

		local elements = {}

		for i=1, #inventory.items, 1 do

			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {label = item.label .. ' x' .. item.count, type = 'item_standard', value = item.name})
			end

		end

		ESX.UI.Menu.Open(
			'default', GetCurrentResourceName(), 'fridge_menu',
			{
				title		= _U('inventory'),
				elements = elements
			},
			function(data, menu)

				local itemName = data.current.value

				ESX.UI.Menu.Open(
					'dialog', GetCurrentResourceName(), 'fridge_menu_put_item_count',
					{
						title = _U('quantity')
					},
					function(data2, menu2)

						local count = tonumber(data2.value)

						if count == nil then
							ESX.ShowNotification(_U('invalid_quantity'))
						else
							menu2.close()
							menu.close()
							--OpenPutFridgeStocksMenu()

							TriggerServerEvent('esx_yellowjackjob:putFridgeStockItems', itemName, count)
						end

					end,
					function(data2, menu2)
						menu2.close()
					end
				)

			end,
			function(data, menu)
				menu.close()
			end
		)

	end)

end

function GetAlcoholBarrelMenu()

	local elements = {
		{label = _U('get_barrel_harvest'), value = 'get_barrel'},
		{label = _U('put_barrel_harvest'), value = 'put_barrel'}
	}

	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'menu_barrel_harvest',
		{
			title		= _U('menu_harvest_title'),
			elements = elements
		},
		function(data, menu)
			local action = data.current.value
			menu.close()
			if action == 'get_barrel' then
				if barrelTaken then
					ESX.ShowNotification(_U('already_have_barrel'))
				else
					GetAlcoholBarrel()
				end
			elseif action == 'put_barrel' then
				if not barrelTaken then
					ESX.ShowNotification(_U('dont_have_barrel'))
				else
					RemoveAlcoholBarrel()
				end
			end
		end,
		function(data, menu)
			menu.close()
		end
	)

end

function GetAlcoholBarrel()
	currentlyBusy = true

	local playerPed = PlayerPedId()
	if not HasAnimDictLoaded("anim@heists@box_carry@") then
		RequestAnimDict("anim@heists@box_carry@")
	end
	while not HasAnimDictLoaded("anim@heists@box_carry@") do
		Citizen.Wait(0)
	end
	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
	Citizen.Wait(4000)
	ClearPedTasks(playerPed)
	Citizen.Wait(1000)
	alcoholBarrel = CreateObject(barrelEntityObject, 0, 0, 0, true, true, true) -- creates object
	AttachEntityToEntity(alcoholBarrel, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)

	TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)

	Citizen.Wait(1000)

	barrelTaken = true
	currentlyBusy = false
end

function RemoveAlcoholBarrel()
	currentlyBusy = true

	local playerPed = PlayerPedId()
	ClearPedTasksImmediately(playerPed)
	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
	DeleteEntity(alcoholBarrel)
	Citizen.Wait(3000)
	ClearPedTasks(playerPed)
	Citizen.Wait(3000)

	barrelTaken = false
	currentlyBusy = false
end

function CheckCollectedBarrels()
	Citizen.CreateThread(function()
		while playerWantsToDoTheRun do

			Citizen.Wait(1)

			local playerPed = PlayerPedId()

			if not IsPedInAnyVehicle(playerPed, true) then
				local coords = GetEntityCoords(playerPed)

				if not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 4.0) then
					vehicleNearPlayer = nil
					currentJobPlate = nil
					Citizen.Wait(1000)
				else
					vehicleNearPlayer = GetClosestVehicle(coords.x, coords.y, coords.z, 4.0, 0, 71)
					if DoesEntityExist(vehicleNearPlayer) and IsVehicleModel(vehicleNearPlayer, jobVehicleHash) and GetVehicleEngineHealth(vehicleNearPlayer) > 0.0 then
						local plate = GetVehicleNumberPlateText(vehicleNearPlayer)
						if jobVehicles[plate] ~= nil then
							coordsVehicleNearPlayer = GetEntityCoords(vehicleNearPlayer)
							currentJobPlate = plate
							local barrelsQuantity = jobVehicles[currentJobPlate].quantity
							local maximumQuantity = jobVehicles[currentJobPlate].maximum
							if barrelsQuantity == 0 then
								ESX.Game.Utils.DrawText3D(coordsVehicleNearPlayer + vector3(0.0, 0.0, 1.0), _U('barrels_inside_vehicle_0', barrelsQuantity, maximumQuantity), 1.0)
							elseif barrelsQuantity == 5 then
								ESX.Game.Utils.DrawText3D(coordsVehicleNearPlayer + vector3(0.0, 0.0, 1.0), _U('barrels_inside_vehicle_5', barrelsQuantity, maximumQuantity), 1.0)
							else
								ESX.Game.Utils.DrawText3D(coordsVehicleNearPlayer + vector3(0.0, 0.0, 1.0), _U('barrels_inside_vehicle', barrelsQuantity, maximumQuantity), 1.0)
							end
							if not currentlyBusy and barrelTaken and barrelsQuantity < maximumQuantity then
								ESX.Game.Utils.DrawText3D(coordsVehicleNearPlayer + vector3(0.0, 0.0, 0.87), _U('press_E_to_put'), 1.0)
							elseif not currentlyBusy and not barrelTaken and barrelsQuantity > 0 then
								ESX.Game.Utils.DrawText3D(coordsVehicleNearPlayer + vector3(0.0, 0.0, 0.87), _U('press_E_to_get'), 1.0)
							end
						else
							currentJobPlate = nil
							vehicleNearPlayer = nil
							Citizen.Wait(2000)
						end
					else
						vehicleNearPlayer = nil
						currentJobPlate = nil
						Citizen.Wait(2000)
					end

				end
			else
				vehicleNearPlayer = nil
				currentJobPlate = nil
				barrelTaken = false
				Citizen.Wait(1000)
			end

		end
	end)
end

-- Job key controls
function ControlsCollectedBarrels()
	Citizen.CreateThread(function()
		while playerWantsToDoTheRun do

			Citizen.Wait(1)

			local playerPed = PlayerPedId()

			if not IsPedInAnyVehicle(playerPed, true) then
				if currentlyBusy or vehicleNearPlayer == nil or currentJobPlate == nil or GetVehicleEngineHealth(vehicleNearPlayer) <= 0.0 then
					Citizen.Wait(1000)
				else

					if IsControlJustReleased(1,	Keys['E']) and IsInputDisabled(0) then
						local barrelsQuantity = jobVehicles[currentJobPlate].quantity
						local maximumQuantity = jobVehicles[currentJobPlate].maximum
						if barrelTaken and barrelsQuantity < maximumQuantity then
							PutBarrelInVehicle(currentJobPlate)
						elseif not barrelTaken and barrelsQuantity > 0 then
							GetBarrelFromVehicle(currentJobPlate)
						end
					end

				end
			else
				if barrelTaken then
					ClearPedTasksImmediately(playerPed)
					DeleteEntity(alcoholBarrel)
					Citizen.Wait(500)
					ClearPedTasks(playerPed)
					Citizen.Wait(500)
					barrelTaken = false
				end
				Citizen.Wait(1000)
			end

		end
	end)
end

function PutBarrelInVehicle(savedCurrentJobPlate)
	local barrelsQuantity = jobVehicles[currentJobPlate].quantity
	local maximumQuantity = jobVehicles[currentJobPlate].maximum
	if barrelsQuantity < maximumQuantity then
		jobVehicles[currentJobPlate].quantity = barrelsQuantity + 1
		TriggerServerEvent('esx_yellowjackjob:UpdateServerJobVehiclesTable', savedCurrentJobPlate, jobVehicles[currentJobPlate].quantity)
	end
	RemoveAlcoholBarrel()
end

function GetBarrelFromVehicle(savedCurrentJobPlate)
	local barrelsQuantity = jobVehicles[currentJobPlate].quantity
	if barrelsQuantity > 0 then
		jobVehicles[currentJobPlate].quantity = barrelsQuantity - 1
		TriggerServerEvent('esx_yellowjackjob:UpdateServerJobVehiclesTable', savedCurrentJobPlate, jobVehicles[savedCurrentJobPlate].quantity)
	end
	GetAlcoholBarrel()
end

function CreateAlcoholBottle()
	currentlyBusy = true

	local playerPed = PlayerPedId()
	ClearPedTasksImmediately(playerPed)
	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
	DeleteEntity(alcoholBarrel)
	Citizen.Wait(8000)
	ClearPedTasks(playerPed)

	local randomBadAlcohol = math.random(1, 20)
	TriggerServerEvent('esx_yellowjackjob:CreatingAlcoholBottle', randomBadAlcohol)

	Citizen.Wait(1000)

	barrelTaken = false
	currentlyBusy = false
end

RegisterNetEvent('esx_yellowjackjob:ReturnJobVehiclesFromServerTable')
AddEventHandler('esx_yellowjackjob:ReturnJobVehiclesFromServerTable', function(serverVehicles)
	jobVehicles = serverVehicles
end)

AddEventHandler('esx_yellowjackjob:hasEnteredMarker', function(zone)

	if zone == 'BossActions' then
		CurrentAction		= 'menu_boss_actions'
		CurrentActionMsg	= _U('open_bossmenu')
		CurrentActionData	= {}

	elseif zone == 'Vaults' and Config.EnableVaultManagement then
		CurrentAction		= 'menu_vault'
		CurrentActionMsg	= _U('open_vault')
		CurrentActionData	= {}

	elseif zone == 'Fridge' then
		CurrentAction		= 'menu_fridge'
		CurrentActionMsg	= _U('open_fridge')
		CurrentActionData	= {}

	elseif zone == 'Vehicles' then
		CurrentAction		= 'menu_vehicle_spawner'
		CurrentActionMsg	= _U('vehicle_spawner')
		CurrentActionData	= {}

	elseif zone == 'VehicleDeleters' then
		local playerPed = PlayerPedId()
		if IsPedInAnyVehicle(playerPed,	false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			CurrentAction		= 'delete_vehicle'
			CurrentActionMsg	= _U('store_vehicle')
			CurrentActionData	= {vehicle = vehicle}
		end

	elseif zone == 'Recolte' then
		CurrentAction		= 'menu_harvest'
		CurrentActionMsg	= _U('menu_harvest')
		CurrentActionData	= {}

	elseif zone == 'Transformation' then
		CurrentAction		= 'menu_transfo'
		CurrentActionMsg	= _U('menu_transfo')
		CurrentActionData	= {}

	elseif zone == 'Vente' then
		CurrentAction		 = 'menu_selling'
		CurrentActionMsg	= _U('menu_sell')
		CurrentActionData = {}
	end

end)

AddEventHandler('esx_yellowjackjob:hasExitedMarker', function(zone)

	CurrentAction = nil
	ESX.UI.Menu.CloseAll()

end)

-- Create public blips
Citizen.CreateThread(function()
	local blipMarker = Config.Blips.Blip
	local blipCoord = AddBlipForCoord(blipMarker.Pos.x, blipMarker.Pos.y, blipMarker.Pos.z)

	SetBlipSprite (blipCoord, blipMarker.Sprite)
	SetBlipDisplay(blipCoord, blipMarker.Display)
	SetBlipScale	(blipCoord, blipMarker.Scale)
	SetBlipColour (blipCoord, blipMarker.Color)
	SetBlipAsShortRange(blipCoord, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('map_blip'))
	EndTextCommandSetBlipName(blipCoord)
end)

-- Display markers
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)
		if IsJobTrue() then

			local coords 	= GetEntityCoords(PlayerPedId())
			local isFound = false

			for k,v in pairs(Config.Zones) do
				if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, false, false, false, false)
					isFound = true
				end
			end

			if not isFound then
				Citizen.Wait(1000)
			end

		else
			Citizen.Wait(5000)
		end

	end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)
		if IsJobTrue() then

			local coords		= GetEntityCoords(PlayerPedId())
			local isInMarker	= false
			local currentZone, currentStation

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker	= true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone								= currentZone
				TriggerEvent('esx_yellowjackjob:hasEnteredMarker', currentZone, currentStation)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_yellowjackjob:hasExitedMarker', LastZone)
			end

			if not isInMarker then
				Citizen.Wait(500)
			end

		else
			Citizen.Wait(5000)
		end

	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)

		if CurrentAction == nil then
			Citizen.Wait(250)
		else

			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(1,	Keys['E']) and IsInputDisabled(0) then

				if CurrentAction == 'menu_vault' then
					OpenVaultMenu()

				elseif CurrentAction == 'menu_fridge' then
					OpenFridgeMenu()

				elseif CurrentAction == 'menu_vehicle_spawner' then
					OpenVehicleSpawnerMenu()

				elseif CurrentAction == 'delete_vehicle' then

					local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
					TriggerServerEvent('esx_society:putVehicleInGarage', 'yellowjack', vehicleProps)

					ESX.Game.DeleteVehicle(CurrentActionData.vehicle)

				elseif CurrentAction == 'menu_boss_actions' then

					if not IsGradeBoss() then
						ESX.ShowNotification(_U('boss_required'))
					else
						local options = {
							wash			= Config.EnableMoneyWash,
						}

						ESX.UI.Menu.CloseAll()

						TriggerEvent('esx_society:openBossMenu', 'yellowjack', function(data, menu)

							menu.close()
							CurrentAction			= 'menu_boss_actions'
							CurrentActionMsg	= _U('open_bossmenu')
							CurrentActionData = {}

						end,options)
					end

				elseif CurrentAction == 'menu_harvest' then
					if not IsPedOnFoot(PlayerPedId()) then
						ESX.ShowNotification(_U('no_farming_in_vehicle'))
					else
						GetAlcoholBarrelMenu()
					end

				elseif CurrentAction == 'menu_transfo' then
					local playerPed = PlayerPedId()
					if not IsPedOnFoot(playerPed) then
						ESX.ShowNotification(_U('no_farming_in_vehicle'))
					else
						if not barrelTaken then
							ESX.ShowNotification(_U('dont_have_barrel'))
						else
							local coords = GetEntityCoords(playerPed)
							local canTransfo = true
							if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.5) then
								local warningVehicleClose = GetClosestVehicle(coords.x, coords.y, coords.z, 5.5, 0, 71)
								if DoesEntityExist(warningVehicleClose) and IsVehicleModel(warningVehicleClose, jobVehicleHash) and GetVehicleEngineHealth(warningVehicleClose) > 0.0 then
									local warningPlate = GetVehicleNumberPlateText(warningVehicleClose)
									if jobVehicles[warningPlate] ~= nil then
										canTransfo = not canTransfo
									end
								end
							end
							if canTransfo then
								CreateAlcoholBottle()
							else
								ESX.ShowNotification(_U('vehicle_too_close'))
							end
						end
					end

				elseif CurrentAction == 'menu_selling' then
					TriggerServerEvent('esx_yellowjackjob:startSelling')
				end

				CurrentAction = nil

			end

		end

	end
end)















-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(1)

		if IsControlJustReleased(1,	Keys['F6']) and IsJobTrue() and IsInputDisabled(0) then
			menu_example()
		end

	end
end)


-- FAIRE LANCEMENT RUN DANS MENU JOB PLAYER
function menu_example()
	if not playerWantsToDoTheRun then
		playerWantsToDoTheRun = true
		CheckCollectedBarrels()
		ControlsCollectedBarrels()
	else
		playerWantsToDoTheRun = false
	end
end
