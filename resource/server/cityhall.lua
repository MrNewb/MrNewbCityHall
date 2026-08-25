local applicationCooldownByIdentifier = {}

local function findCityHallNearPlayer(src, locationId)
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) then return end
	if type(locationId) ~= 'string' or locationId == '' or #locationId > 64 then return end

	local cityHall = Config.CityHallLocations and Config.CityHallLocations[locationId]
	if not cityHall or not cityHall.location then return end

	local locationCoords = cityHall.location
	local maxDistance = (Config.InteractDistance or 5.0) + 1.0
	if #(GetEntityCoords(playerPed) - vector3(locationCoords.x, locationCoords.y, locationCoords.z)) > maxDistance then
		return bridge.notifications.notify(src, { description = locale('Notify.TooFar'), type = 'error' })
	end

	return cityHall
end

local function assignCityHallJob(src, locationId, jobName)
	local cityHall = findCityHallNearPlayer(src, locationId)
	if not cityHall then return false end
	if type(jobName) ~= 'string' or jobName == '' or #jobName > 64 then return false end

	local jobGrade = tonumber(cityHall.availableJobs and cityHall.availableJobs[jobName])
	if jobGrade == nil then return false end

	if not bridge.framework.setPlayerJob(src, jobName, jobGrade) then return false, bridge.notifications.notify(src, { description = locale('Notify.JobSetFailed'), type = 'error' }) end

	bridge.notifications.notify(src, { description = locale('Notify.JobSet', jobName, jobGrade), type = 'success' })
	return true
end

local function purchaseIdCard(src, locationId)
	if not findCityHallNearPlayer(src, locationId) then return false end

	local idCardPrice = tonumber(Config.IdCardPrice) or 0
	if idCardPrice < 0 then return false end

	local idCardItem = Config.IdCardItem or 'id_card'
	local bankBalance = tonumber(bridge.framework.getMoney(src, 'bank')) or 0
	if bankBalance < 0 then return false, bridge.notifications.notify(src, { description = locale('Notify.NotEnoughMoney', idCardPrice), type = 'error' }) end
	if bankBalance < idCardPrice then return false, bridge.notifications.notify(src, { description = locale('Notify.NotEnoughMoney', idCardPrice), type = 'error' }) end

	if idCardPrice > 0 and not bridge.framework.removeMoney(src, 'bank', idCardPrice, 'cityhall_id_card') then
		return false, bridge.notifications.notify(src, { description = locale('Notify.NotEnoughMoney', idCardPrice), type = 'error' })
	end

	if GetResourceState('um-idcard') == 'started' then
		exports['um-idcard']:CreateMetaLicense(src, idCardItem)
	elseif GetResourceState('bl_idcard') == 'started' then
		exports.bl_idcard:createLicense(src, idCardItem)
	else
		if not bridge.inventory.canCarryItem(src, idCardItem, 1) then
			if idCardPrice > 0 then bridge.framework.addMoney(src, 'bank', idCardPrice, 'cityhall_id_card_refund') end
			return false, bridge.notifications.notify(src, { description = locale('Notify.CannotCarry'), type = 'error' })
		end

		local identifier = bridge.framework.getIdentifier(src)
		local _, firstName, lastName = bridge.framework.getCharacterName(identifier)
		if not bridge.inventory.addItem(src, idCardItem, 1, {
			description = ('%s %s'):format(firstName or '', lastName or ''),
			dob = bridge.framework.getPlayerDob(src),
		}) then
			if idCardPrice > 0 then bridge.framework.addMoney(src, 'bank', idCardPrice, 'cityhall_id_card_refund') end
			return false, bridge.notifications.notify(src, { description = locale('Notify.CannotCarry'), type = 'error' })
		end
	end

	bridge.notifications.notify(src, { description = locale('Notify.IdCardPurchased', idCardPrice), type = 'success' })
	return true
end

local function submitJobApplication(src, locationId, applicationType, answers)
	if not findCityHallNearPlayer(src, locationId) then return false end

	local application = GetApplication(applicationType)
	if not application or not ValidateApplicationAnswers(application, answers) then return false end

	local identifier = bridge.framework.getIdentifier(src)
	if not identifier then return false end

	local cooldownSeconds = tonumber(Config.ApplicationCooldown) or 60
	local currentTime = os.time()
	if cooldownSeconds > 0 and (applicationCooldownByIdentifier[identifier] or 0) + cooldownSeconds > currentTime then
		return false, bridge.notifications.notify(src, { description = locale('Notify.ApplicationCooldown'), type = 'error' })
	end

	local validatedAnswers = {}
	for questionIndex = 1, math.min(#application.questions, 20) do
		validatedAnswers[questionIndex] = answers[questionIndex]
	end

	local _, firstName, lastName = bridge.framework.getCharacterName(identifier)
	local characterName = ('%s %s'):format(firstName or '', lastName or '')
	if not SubmitDiscordLog(applicationType, validatedAnswers, characterName, identifier) then
		return false, bridge.notifications.notify(src, { description = locale('Notify.ApplicationFailed'), type = 'error' })
	end

	applicationCooldownByIdentifier[identifier] = currentTime
	bridge.notifications.notify(src, { description = locale('Notify.ApplicationSubmitted', application.label or applicationType), type = 'success' })
	return true
end

lib.callback.register('MrNewbCityHall:Callback:SetJob', function(src, locationId, jobName)
	return assignCityHallJob(src, locationId, jobName)
end)

lib.callback.register('MrNewbCityHall:Callback:PurchaseIdCard', function(src, locationId)
	return purchaseIdCard(src, locationId)
end)

lib.callback.register('MrNewbCityHall:Callback:SubmitApplication', function(src, locationId, applicationType, answers)
	return submitJobApplication(src, locationId, applicationType, answers)
end)

AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	exports[bridge.name]:VersionCheck('MrNewb/patchnotes', resourceName)
end)
