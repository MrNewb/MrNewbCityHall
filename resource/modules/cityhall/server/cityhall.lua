local applicationCooldownByIdentifier = {}
local lastCallbackTimeBySource = {}

local function isRateLimited(src)
	local now = GetGameTimer()
	if (lastCallbackTimeBySource[src] or 0) + 1000 > now then return true end
	lastCallbackTimeBySource[src] = now
	return false
end

AddEventHandler('playerDropped', function()
	lastCallbackTimeBySource[source] = nil
end)

local function fail(src, key, ...)
	bridge.notifications.notify(src, { description = locale(key, ...), type = 'error' })
	return false
end

local function findCityHallNearPlayer(src, locationId)
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) then return end
	if type(locationId) ~= 'string' or locationId == '' or #locationId > 64 then return end

	local cityHall = Config.CityHallLocations[locationId]
	if not cityHall or not cityHall.location then return end

	local coords = cityHall.location
	if #(GetEntityCoords(playerPed) - vector3(coords.x, coords.y, coords.z)) > Config.InteractDistance + 1.0 then
		return fail(src, 'Notify.TooFar')
	end

	return cityHall
end

local function assignCityHallJob(src, locationId, jobName)
	if isRateLimited(src) then return false end
	local cityHall = findCityHallNearPlayer(src, locationId)
	if not cityHall then return false end
	if type(jobName) ~= 'string' or jobName == '' or #jobName > 64 then return false end

	local jobGrade = tonumber(cityHall.availableJobs and cityHall.availableJobs[jobName])
	if jobGrade == nil then return false end

	if not bridge.framework.setPlayerJob(src, jobName, jobGrade) then return fail(src, 'Notify.JobSetFailed') end

	lib.logger(src, 'cityHallJob', ('set job %s grade %s'):format(jobName, jobGrade))
	bridge.notifications.notify(src, { description = locale('Notify.JobSet', jobName, jobGrade), type = 'success' })
	return true
end

local function purchaseIdCard(src, locationId)
	if isRateLimited(src) then return false end
	if not findCityHallNearPlayer(src, locationId) then return false end

	local idCardPrice = Config.IdCardPrice
	local idCardItem = Config.IdCardItem
	if bridge.framework.getMoney(src, 'bank') < idCardPrice then return fail(src, 'Notify.NotEnoughMoney', idCardPrice) end

	if idCardPrice > 0 and not bridge.framework.removeMoney(src, 'bank', idCardPrice, 'cityhall_id_card') then
		return fail(src, 'Notify.NotEnoughMoney', idCardPrice)
	end

	if GetResourceState('um-idcard') == 'started' then
		exports['um-idcard']:CreateMetaLicense(src, idCardItem)
	elseif GetResourceState('bl_idcard') == 'started' then
		exports.bl_idcard:createLicense(src, idCardItem)
	else
		if not bridge.inventory.canCarryItem(src, idCardItem, 1) then
			if idCardPrice > 0 then bridge.framework.addMoney(src, 'bank', idCardPrice, 'cityhall_id_card_refund') end
			return fail(src, 'Notify.CannotCarry')
		end

		local identifier = bridge.framework.getIdentifier(src)
		local _, firstName, lastName = bridge.framework.getCharacterName(identifier)
		if not bridge.inventory.addItem(src, idCardItem, 1, {
			description = ('%s %s'):format(firstName or '', lastName or ''),
			dob = bridge.framework.getPlayerDob(src),
		}) then
			if idCardPrice > 0 then bridge.framework.addMoney(src, 'bank', idCardPrice, 'cityhall_id_card_refund') end
			return fail(src, 'Notify.CannotCarry')
		end
	end

	lib.logger(src, 'cityHallIdCard', ('bought %s for $%s'):format(idCardItem, idCardPrice))
	bridge.notifications.notify(src, { description = locale('Notify.IdCardPurchased', idCardPrice), type = 'success' })
	return true
end

local function submitJobApplication(src, locationId, applicationType, answers)
	if isRateLimited(src) then return false end
	if not findCityHallNearPlayer(src, locationId) then return false end

	local application = GetApplication(applicationType)
	if not application or not ValidateApplicationAnswers(application, answers) then return false end

	local identifier = bridge.framework.getIdentifier(src)
	if not identifier then return false end

	local now = os.time()
	if Config.ApplicationCooldown > 0 and (applicationCooldownByIdentifier[identifier] or 0) + Config.ApplicationCooldown > now then
		return fail(src, 'Notify.ApplicationCooldown')
	end

	local _, firstName, lastName = bridge.framework.getCharacterName(identifier)
	local characterName = ('%s %s'):format(firstName or '', lastName or '')
	if not SubmitDiscordLog(applicationType, answers, characterName, identifier) then
		return fail(src, 'Notify.ApplicationFailed')
	end

	applicationCooldownByIdentifier[identifier] = now
	bridge.notifications.notify(src, { description = locale('Notify.ApplicationSubmitted', application.label), type = 'success' })
	return true
end

lib.callback.register('MrNewbCityHall:server:selectedJob', assignCityHallJob)

lib.callback.register('MrNewbCityHall:server:purchasedIdCard', purchaseIdCard)

lib.callback.register('MrNewbCityHall:server:submittedApplication', submitJobApplication)

AddEventHandler('onResourceStart', function(resourceName)
	if cache.resource ~= resourceName then return end
	exports[bridge.name]:VersionCheck('MrNewb/patchnotes', resourceName)
end)
