local activeCityHallInteractions = {}
local cityHallBlips = {}

local function createCityHallBlip(coords, blipData, locationId)
	local blipHandle = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blipHandle, blipData.sprite or 1)
	SetBlipColour(blipHandle, blipData.color or 0)
	SetBlipScale(blipHandle, blipData.scale or 0.8)
	SetBlipAsShortRange(blipHandle, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(blipData.label or locationId)
	EndTextCommandSetBlipName(blipHandle)
	return blipHandle
end

function CreateCityHallLocations()
	local interactionDistance = Config.InteractDistance or 5.0

	for locationId, cityHall in pairs(Config.CityHallLocations or {}) do
		if not activeCityHallInteractions[locationId] and type(locationId) == 'string' and type(cityHall) == 'table' and cityHall.location then
			local locationCoords = cityHall.location
			local interactionId = ('mrnewb_cityhall_%s'):format(locationId:gsub('%s+', '_'):lower())
			local availableJobs = cityHall.availableJobs or {}

			if cityHall.blipData then
				cityHallBlips[locationId] = createCityHallBlip(locationCoords, cityHall.blipData, locationId)
			end

			exports[bridge.name]:AddInteraction(interactionId, {
				model = cityHall.model or 's_m_y_hwaycop_01',
				coords = vector3(locationCoords.x, locationCoords.y, locationCoords.z),
				heading = locationCoords.w or 0.0,
				radius = 150.0,
				options = {
					{
						name = interactionId .. '_job',
						label = locale('Target.CityHallLabel'),
						icon = locale('Target.CityHallIcon'),
						distance = interactionDistance,
						onSelect = function()
							OpenJobMenu(locationId, availableJobs)
						end,
					},
					{
						name = interactionId .. '_id',
						label = locale('Target.IdCardLabel'),
						icon = locale('Target.IdCardIcon'),
						distance = interactionDistance,
						onSelect = function()
							OpenIdCardMenu(locationId)
						end,
					},
					{
						name = interactionId .. '_apply',
						label = locale('Target.ApplyLabel'),
						icon = locale('Target.ApplyIcon'),
						distance = interactionDistance,
						onSelect = function()
							OpenApplicationMenu(locationId)
						end,
					},
				},
			})

			activeCityHallInteractions[locationId] = interactionId
		end
	end
end

function RemoveCityHallLocations()
	for locationId, interactionId in pairs(activeCityHallInteractions) do
		exports[bridge.name]:RemoveInteraction(interactionId)
		activeCityHallInteractions[locationId] = nil
	end

	for locationId, blipHandle in pairs(cityHallBlips) do
		if blipHandle and DoesBlipExist(blipHandle) then
			RemoveBlip(blipHandle)
		end
		cityHallBlips[locationId] = nil
	end
end

AddEventHandler('Newb_Bridge:client:playerLoad', CreateCityHallLocations)
AddEventHandler('Newb_Bridge:client:playerUnload', RemoveCityHallLocations)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	RemoveCityHallLocations()
end)

CreateThread(function()
	Wait(500)
	if next(activeCityHallInteractions) then return end
	CreateCityHallLocations()
end)
