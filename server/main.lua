ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local Vehicles = {}

ESX.RegisterServerCallback('esx_yellowjackjob:RequestJobVehiclesInfos', function(source, cb)
	cb(Vehicles)
end)

TriggerEvent('esx_addons_gcphone:registerNumber', 'yellowjack', 'Yellow Jack', true, true)
TriggerEvent('esx_society:registerSociety', 'yellowjack', 'Yellow Jack', 'society_yellowjack', 'society_yellowjack', 'society_yellowjack', {type = 'private'})


RegisterServerEvent('esx_yellowjackjob:getStockItem')
AddEventHandler('esx_yellowjackjob:getStockItem', function(itemName, count)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_yellowjack', function(inventory)

		local item = inventory.getItem(itemName)
		local itemQuantity 	= xPlayer.getInventoryItem(itemName).count
		local itemLimit		= xPlayer.getInventoryItem(itemName).limit

		if count > 0 and item.count >= count then
			if itemLimit ~= -1 and (itemQuantity + count) > itemLimit then
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_do_not_room'))
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)
			end
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end

	end)

end)

ESX.RegisterServerCallback('esx_yellowjackjob:getStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_yellowjack', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('esx_yellowjackjob:putStockItems')
AddEventHandler('esx_yellowjackjob:putStockItems', function(itemName, count)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_yellowjack', function(inventory)

		local item = inventory.getItem(itemName)
		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		if count > 0 and item.count >= 0 and count <= playerItemCount then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end

	end)

end)

RegisterServerEvent('esx_yellowjackjob:getFridgeStockItem')
AddEventHandler('esx_yellowjackjob:getFridgeStockItem', function(itemName, count)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_yellowjack_fridge', function(inventory)

		local item = inventory.getItem(itemName)
		local itemQuantity = xPlayer.getInventoryItem(itemName).count
		local itemLimit		= xPlayer.getInventoryItem(itemName).limit

		if count > 0 and item.count >= count then
			if itemLimit ~= -1 and (itemQuantity + count) > itemLimit then
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_do_not_room'))
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_removed') .. count .. ' ' .. item.label)
			end
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end

	end)

end)

ESX.RegisterServerCallback('esx_yellowjackjob:getFridgeStockItems', function(source, cb)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_yellowjack_fridge', function(inventory)
		cb(inventory.items)
	end)

end)

RegisterServerEvent('esx_yellowjackjob:putFridgeStockItems')
AddEventHandler('esx_yellowjackjob:putFridgeStockItems', function(itemName, count)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_yellowjack_fridge', function(inventory)

		local item = inventory.getItem(itemName)
		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		if count > 0 and item.count >= 0 and count <= playerItemCount then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_added') .. count .. ' ' .. item.label)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end

	end)

end)

ESX.RegisterServerCallback('esx_yellowjackjob:getPlayerInventory', function(source, cb)

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local items		= xPlayer.inventory

	cb({
		items = items
	})

end)

RegisterServerEvent('esx_yellowjackjob:UpdateServerJobVehiclesTable')
AddEventHandler('esx_yellowjackjob:UpdateServerJobVehiclesTable', function(plate, quantity)
	local found = false
	if quantity == nil then
		quantity = 0
	end

	for k,v in pairs(Vehicles) do
		if Vehicles[k] == plate then
			found = true
			if quantity ~= v.quantity then
				table.remove(Vehicles, k)
				Vehicles[k] = { quantity = quantity, maximum = Config.QuantityMaximumInVehicle }
				TriggerClientEvent('esx_yellowjackjob:ReturnJobVehiclesFromServerTable', -1, Vehicles)
			end
			break
		end
	end

	if not found then
		Vehicles[plate] = { quantity = quantity, maximum = Config.QuantityMaximumInVehicle }
		TriggerClientEvent('esx_yellowjackjob:ReturnJobVehiclesFromServerTable', -1, Vehicles)
	end
end)

RegisterServerEvent('esx_yellowjackjob:CreatingAlcoholBottle')
AddEventHandler('esx_yellowjackjob:CreatingAlcoholBottle', function(randomBadAlcohol)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	if randomBadAlcohol > 16 or randomBadAlcohol < 5 then
		local number = 3
		TriggerClientEvent('esx:showNotification', _source, _U('assembling_alcohol', number))
		xPlayer.addInventoryItem('whisky', number)
		TriggerClientEvent('esx:showNotification', _source, _U('assembling_badluck'))
	else
		local number = 5
		TriggerClientEvent('esx:showNotification', _source, _U('assembling_alcohol', number))
		xPlayer.addInventoryItem('whisky', number)
	end
end)

RegisterServerEvent('esx_yellowjackjob:startSelling')
AddEventHandler('esx_yellowjackjob:startSelling', function()
	local _source			= source

	local xPlayer			= ESX.GetPlayerFromId(_source)
	local alcoholQuantity 	= xPlayer.getInventoryItem('whisky').count

	if alcoholQuantity == 0 then
		TriggerClientEvent('esx:showNotification', _source, _U('not_enough_alcohol_sell'))
	else
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_yellowjack', function(account)
			societyAccount = account
		end)
		local finalPrice = Config.AlcoholMoneySelling * alcoholQuantity
		if societyAccount ~= nil then
			xPlayer.removeInventoryItem('whisky', alcoholQuantity)
			xPlayer.addMoney(tonumber(finalPrice))
			societyAccount.addMoney(tonumber(finalPrice))
			TriggerClientEvent('esx:showNotification', _source, _U('comp_earned', finalPrice))
		else
			xPlayer.removeInventoryItem('whisky', alcoholQuantity)
			xPlayer.addMoney(tonumber(finalPrice))
		end
		TriggerClientEvent('esx:showNotification', _source, _U('selling_alcohol', finalPrice))
	end

end)
