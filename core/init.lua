Bridge = exports.community_bridge:Bridge()
SharedData = {}

function locale(message, ...)
    return Bridge.Language.Locale(message, ...)
end

if IsDuplicityVersion() then return end
RegisterNetEvent("community_bridge:Client:OnPlayerUnload")

RegisterNetEvent("community_bridge:Client:OnPlayerLoaded")