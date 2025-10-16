---@diagnostic disable: duplicate-set-field
local cityHallObj = {}
CityHallClass = {}
CityHallClass.__index = CityHallClass

function CityHallClass:new(id, location, availableJobs)
    local obj = {
        id = id,
        location = location,
        availableJobs = availableJobs,
    }
    setmetatable(obj, self)
    cityHallObj[id] = obj
    return obj
end

function BuildCityHallObjects()
    for k, v in pairs(Config.CityHallLocations) do
        CityHallClass:new(k, v.location, v.availableJobs)
    end
end

function CityHallClass:setjob(src, jobName)
    if not self.availableJobs[jobName] then return false end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local distance = #(pedCoords - vector3(self.location.x, self.location.y, self.location.z))
    if distance > 5.0 then return false, Bridge.Notify.SendNotify(src, locale("Notify.TooFar"), "error", 5000) end
    Bridge.Framework.SetPlayerJob(src, jobName, self.availableJobs[jobName])
    Bridge.Notify.SendNotify(src, locale("Notify.JobSet", jobName, self.availableJobs[jobName]), "success", 5000)
end

local function grantIdCard(src)
    local umLoaded = GetResourceState("um-idcard") ~= "missing"
    local blLoaded = GetResourceState("bl_idcard") ~= "missing"
    if umLoaded then
        return exports['um-idcard']:CreateMetaLicense(src, 'id_card')
    elseif blLoaded then
        return exports.bl_idcard:createLicense(src, 'id_card')
    end
    local first, last = Bridge.Framework.GetPlayerName(src)
    local dob = Bridge.Framework.GetPlayerDob(src)
    Bridge.Inventory.AddItem(src, "id_card", 1, nil, {description = first .. " " .. last, dob = dob})
end

function CityHallClass:purchaseIdCard(src)
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local distance = #(pedCoords - vector3(self.location.x, self.location.y, self.location.z))
    if distance > 5.0 then return false, Bridge.Notify.SendNotify(src, locale("Notify.TooFar"), "error", 5000) end
    local price = Config.IdCardPrice
    local playerFunds = Bridge.Framework.GetAccountBalance(src, "bank")
    if playerFunds < 0 then return false, Bridge.Notify.SendNotify(src, locale("Notify.NoBankAccount"), "error", 5000) end
    if playerFunds < price then return false, Bridge.Notify.SendNotify(src, locale("Notify.NotEnoughMoney", price), "error", 5000) end
    Bridge.Framework.RemoveAccountBalance(src, "bank", price)
    grantIdCard(src)
    Bridge.Notify.SendNotify(src, locale("Notify.IdCardPurchased", price), "success", 5000)
end

function CityHallClass:delete()
    cityHallObj[self.id] = nil
end

function DestroyAll()
    for k, v in pairs(cityHallObj) do
        v:delete()
    end
end

RegisterNetEvent("MrNewbCityHall:SubmitApplication", function(id, appType, inputData)
    local src = source
    local cityHall = cityHallObj[id]
    if not cityHall then return end
    local availableApps = Config.Applications[appType]
    if not availableApps then return end
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local distance = #(pedCoords - vector3(cityHall.location.x, cityHall.location.y, cityHall.location.z))
    if distance > 5.0 then return Bridge.Notify.SendNotify(src, locale("Notify.TooFar"), "error", 5000) end
    local senderfirst, senderLast = Bridge.Framework.GetPlayerName(src)
    local sender = string.format("%s %s", senderfirst, senderLast)
    local identifier = Bridge.Framework.GetPlayerIdentifier(src)
    SubmitDiscordLog(appType, inputData, sender, identifier)
end)

RegisterNetEvent('MrNewbCityHall:Server:PurchaseIdCard', function(id)
    local src = source
    local cityHall = cityHallObj[id]
    if not cityHall then return end
    cityHall:purchaseIdCard(src)
end)

RegisterNetEvent('MrNewbCityHall:Server:SetJob', function(id, jobName)
    local src = source
    local cityHall = cityHallObj[id]
    if not cityHall then return end
    cityHall:setjob(src, jobName)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    BuildCityHallObjects()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    DestroyAll()
end)