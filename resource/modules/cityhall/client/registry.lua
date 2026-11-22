local activeCityHallInteractions = {}
local cityHallBlips = {}

local function createCityHallBlip(coords, blipData, locationId)
	local blipHandle = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blipHandle, blipData.sprite)
	SetBlipColour(blipHandle, blipData.color)
	SetBlipScale(blipHandle, blipData.scale)
	SetBlipAsShortRange(blipHandle, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(blipData.label)
	EndTextCommandSetBlipName(blipHandle)
	return blipHandle
end

function CreateCityHallLocations()
	local interactionDistance = Config.InteractDistance

	for locationId, cityHall in pairs(Config.CityHallLocations) do
		if not activeCityHallInteractions[locationId] and cityHall.location then
			local locationCoords = cityHall.location
			local interactionId = ('mrnewb_cityhall_%s'):format(locationId:gsub('%s+', '_'):lower())
			local availableJobs = cityHall.availableJobs

			if cityHall.blipData then
				cityHallBlips[locationId] = createCityHallBlip(locationCoords, cityHall.blipData, locationId)
			end

			exports[bridge.name]:AddInteraction(interactionId, {
				model = cityHall.model,
				coords = vector3(locationCoords.x, locationCoords.y, locationCoords.z),
				heading = locationCoords.w,
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

AddEventHandler('Newb_Bridge:client:playerLoaded', CreateCityHallLocations)
AddEventHandler('Newb_Bridge:client:playerUnloaded', RemoveCityHallLocations)

AddEventHandler('onResourceStop', function(resourceName)
	if cache.resource ~= resourceName then return end
	RemoveCityHallLocations()
end)

CreateThread(function()
	Wait(500)
	if next(activeCityHallInteractions) then return end
	CreateCityHallLocations()
end)
