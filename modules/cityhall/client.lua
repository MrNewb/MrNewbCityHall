---@diagnostic disable: duplicate-set-field
local cityHallObj = {}
CityHallClass = {}
CityHallClass.__index = CityHallClass

function CityHallClass:new(id, location, entityType, model, availableJobs, blipData)
    local obj = {
        id = id,
        location = location,
        entityType = entityType,
        model = model,
        availableJobs = availableJobs,
        blipData = blipData,
    }
    setmetatable(obj, self)
    cityHallObj[id] = obj
    obj:register()

    return obj
end

function BuildCityHallObjects()
    for k, v in pairs(Config.CityHallLocations) do
        CityHallClass:new(k, v.location, v.entityType, v.model, v.availableJobs, v.blipData)
    end
end

function CityHallClass:register()
    self.blip = self.blipData and Bridge.Utility.CreateBlip(vector3(self.location.x, self.location.y, self.location.z), self.blipData.sprite, self.blipData.color, self.blipData.scale, self.id, true, 4) or nil
    Bridge.Entity.Create({
        id = self.id,
        entityType = self.entityType,
        model = self.model,
        coords = self.location,
        heading = self.location.w,
        spawnDistance = 150,
        OnSpawn = function(entityData)
            self:onEnter(entityData)
        end,
        OnRemove = function(entityData)
            self:OnRemove(entityData)
        end
    })
end

function CityHallClass:onEnter(entityData)
    SetEntityInvincible(entityData.spawned, true)
    FreezeEntityPosition(entityData.spawned, true)
    Bridge.Target.AddLocalEntity(entityData.spawned, {
        {
            name     = 'City Hall ' .. entityData.id,
            label    = locale("Target.CityHallLabel"),
            icon     = locale("Target.CityHallIcon"),
            color    = locale("Target.CityHallColor"),
            distance = 5,
            onSelect = function()
                OpenJobMenuOptions(self.id, self.availableJobs)
            end
        },
        {
            name     = 'City Hall Ids' .. entityData.id,
            label    = locale("Target.IdCardLabel"),
            icon     = locale("Target.IdCardIcon"),
            color    = locale("Target.IdCardColor"),
            distance = 5,
            onSelect = function()
                OpenIdCardMenuOptions(self.id)
            end
        },
        {
            name     = 'City Hall Applications' .. entityData.id,
            label    = locale("Target.ApplyLabel"),
            icon     = locale("Target.ApplyIcon"),
            color    = locale("Target.ApplyColor"),
            distance = 5,
            onSelect = function()
                OpenApplicationMenuOptions(self.id)
            end
        },
    })
end

function CityHallClass:OnRemove(entityData)
    if not entityData.spawned then return end
    Bridge.Target.RemoveLocalEntity(entityData.spawned)
end

function CityHallClass:delete()
    Bridge.Entity.Destroy(self.id)
    if self.blip then Bridge.Utility.RemoveBlip(self.blip) end
    cityHallObj[self.id] = nil
end

function DestroyAll()
    for k, v in pairs(cityHallObj) do
        v:delete()
    end
end

-- Wait(1000)
-- BuildCityHallObjects()

AddEventHandler('community_bridge:Client:OnPlayerLoaded', function()
    Wait(1000)
    BuildCityHallObjects()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    DestroyAll()
end)

AddEventHandler("community_bridge:Client:OnPlayerUnload", function()
    DestroyAll()
end)